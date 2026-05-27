-- ============================================================
-- 컴닥터 (Computer Doctor) Database Schema
-- Version: 1.0.2
-- Engine: PostgreSQL 14+
-- ============================================================
-- 5-Layer 구조:
--   1. part_id           - UID 기준 (불변)
--   2. part_spec         - 자기 정체 + 수용 범위 (불변)
--   3. part_performance  - 벤치마크 점수 (EAV)
--   4. part_price        - 시계열 가격 (append-only)
--   5. use_case_profile  - 목적 → 요구사양 매핑
--
-- + 보조: compat_exception (호환성 예외)
-- + 운영: diagnosis_session, recommendation
--
-- v1.0.2 변경점 (CHANGELOG.md 참조):
--   - recommendation.recommended_uid FK: ON DELETE RESTRICT 명시
--   - diagnosis_session.use_case_id FK: ON DELETE RESTRICT 명시
--   - cheapest_current_price 뷰 추가 (부품당 1행, 다중 벤더 증식 방지)
-- ============================================================

-- 데이터베이스 생성 (필요시)
-- CREATE DATABASE computer_doctor WITH ENCODING 'UTF8';
-- \c computer_doctor

-- ============================================================
-- Layer 1. PART_ID
-- ============================================================
-- 모든 부품의 영원한 ID. 한 번 부여하면 절대 안 바뀜.
-- UID 규칙: {카테고리}-{제조사}-{6자리 시퀀스}
--   예: GPU-NV-000001, CPU-INTL-000010, RAM-GSKL-000003
-- 원칙: ID는 식별자일 뿐, 정보는 다른 컬럼(model_name 등)에 둔다.
-- ============================================================

CREATE TABLE part_id (
    uid           VARCHAR(30) PRIMARY KEY,
    model_name    VARCHAR(200) NOT NULL,
    category      VARCHAR(20) NOT NULL
                  CHECK (category IN ('CPU', 'GPU', 'RAM', 'MB', 'SSD', 'PSU', 'CASE')),
    manufacturer  VARCHAR(50) NOT NULL,
    released_at   DATE,
    aliases       TEXT[],          -- 검색용 별칭 (네이버 API 매칭용)
    created_at    TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_part_category ON part_id(category);
CREATE INDEX idx_part_aliases ON part_id USING GIN(aliases);
CREATE INDEX idx_part_model ON part_id(model_name);

COMMENT ON TABLE part_id IS 'Layer 1: 모든 부품의 영원한 UID 기준 테이블';
COMMENT ON COLUMN part_id.aliases IS '"RTX 4070 슈퍼", "지포스 4070S 12GB" 등 표기 변형';


-- ============================================================
-- Layer 2. PART_SPEC
-- ============================================================
-- 부품의 "자기 정체" + "수용 범위" 정보.
-- 호환성 검색에 자주 쓰이는 키는 컬럼으로 승격해서 인덱스.
-- 나머지 가변 속성은 JSONB.
-- ============================================================

CREATE TABLE part_spec (
    uid             VARCHAR(30) PRIMARY KEY REFERENCES part_id(uid) ON DELETE CASCADE,

    -- 호환성 핵심 키 (컬럼 + 인덱스)
    socket          VARCHAR(20),         -- CPU/MB 매칭 (LGA1700, AM5)
    ram_type        VARCHAR(10),         -- RAM/MB 매칭 (DDR4, DDR5)
    form_factor     VARCHAR(10),         -- MB/CASE 매칭 (ATX, mATX, ITX)
    tdp_watts       INTEGER,             -- PSU 와트 계산용
    pcie_version    VARCHAR(10),         -- GPU↔MB

    -- 가변 속성 (자기 정체 + 수용 범위)
    attributes      JSONB NOT NULL DEFAULT '{}'::jsonb,

    updated_at      TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_spec_socket ON part_spec(socket) WHERE socket IS NOT NULL;
CREATE INDEX idx_spec_ram_type ON part_spec(ram_type) WHERE ram_type IS NOT NULL;
CREATE INDEX idx_spec_form_factor ON part_spec(form_factor) WHERE form_factor IS NOT NULL;
CREATE INDEX idx_spec_tdp ON part_spec(tdp_watts) WHERE tdp_watts IS NOT NULL;
CREATE INDEX idx_spec_attrs_gin ON part_spec USING GIN(attributes);

COMMENT ON TABLE part_spec IS 'Layer 2: 자기 정체 + 수용 범위. 호환성 검색의 핵심';
COMMENT ON COLUMN part_spec.attributes IS 'JSONB. 카테고리별 키 명세서 참조';


-- ============================================================
-- Layer 3. PART_PERFORMANCE
-- ============================================================
-- 벤치마크 측정 점수. EAV(Entity-Attribute-Value) 구조.
-- 새 벤치마크 추가 시 스키마 변경 없이 행만 추가.
-- ============================================================

CREATE TABLE part_performance (
    id             BIGSERIAL PRIMARY KEY,
    uid            VARCHAR(30) NOT NULL REFERENCES part_id(uid) ON DELETE CASCADE,
    benchmark_name VARCHAR(50) NOT NULL,
    score          NUMERIC(12, 2) NOT NULL,
    source         VARCHAR(100),
    measured_at    TIMESTAMP DEFAULT NOW(),
    UNIQUE(uid, benchmark_name)
);

-- 인덱스 전략:
-- UNIQUE(uid, benchmark_name) 제약이 자동으로 (uid, benchmark_name) 인덱스를 생성하므로
-- "특정 부품의 특정 벤치마크 점수" 조회는 이걸로 충분 (가장 빈번한 쿼리 패턴).
-- 또한 PostgreSQL은 leftmost prefix를 활용하므로 uid 단독 조회도 같은 인덱스로 처리됨.
-- benchmark_name 단독으로 검색하는 경우(예: "이 벤치마크의 모든 점수")만 별도 인덱스 필요.
CREATE INDEX idx_perf_benchmark ON part_performance(benchmark_name);

COMMENT ON TABLE part_performance IS 'Layer 3: 벤치마크 실측 점수 (EAV)';
COMMENT ON COLUMN part_performance.benchmark_name IS 'passmark_cpu_single, passmark_cpu_multi, passmark_g3d, 3dmark_timespy 등';


-- ============================================================
-- Layer 4. PART_PRICE
-- ============================================================
-- 시계열 가격. append-only (수정 없이 신규 행만 추가).
-- ============================================================

CREATE TABLE part_price (
    id           BIGSERIAL PRIMARY KEY,
    uid          VARCHAR(30) NOT NULL REFERENCES part_id(uid) ON DELETE CASCADE,
    price_krw    INTEGER NOT NULL CHECK (price_krw > 0),
    vendor       VARCHAR(50) NOT NULL,     -- '쿠팡', '다나와', '컴퓨존'
    url          TEXT,                     -- affiliate 링크
    in_stock     BOOLEAN DEFAULT TRUE,
    captured_at  TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_price_uid_time ON part_price(uid, captured_at DESC);
CREATE INDEX idx_price_recent ON part_price(captured_at DESC);
CREATE INDEX idx_price_vendor ON part_price(vendor);

COMMENT ON TABLE part_price IS 'Layer 4: 시계열 가격 (append-only)';

-- ------------------------------------------------------------
-- 뷰: current_price (각 부품×벤더의 가장 최근 가격)
-- ------------------------------------------------------------
-- 가격 추이/벤더 비교 등 "벤더별로 쪼개진" 데이터가 필요한 곳에 사용.
-- 주의: 부품당 1행이 아니므로 추천/검색 쿼리에서 단순 JOIN 시 row 증식.
--       그런 경우엔 아래 cheapest_current_price 사용.

CREATE OR REPLACE VIEW current_price AS
SELECT DISTINCT ON (uid, vendor)
    uid,
    vendor,
    price_krw,
    url,
    in_stock,
    captured_at
FROM part_price
ORDER BY uid, vendor, captured_at DESC;

COMMENT ON VIEW current_price IS '각 부품×벤더의 가장 최근 가격';

-- ------------------------------------------------------------
-- 뷰: cheapest_current_price (각 부품의 최저가 1행)
-- ------------------------------------------------------------
-- 추천/검색 쿼리는 "부품당 1행 + 최저가 + 재고 있음"이 필요함.
-- current_price를 단순 JOIN하면 벤더 수만큼 row가 곱해져
-- LIMIT N이 "N개 부품"을 보장하지 못함 → 이 뷰가 그 문제 해결.

CREATE OR REPLACE VIEW cheapest_current_price AS
SELECT DISTINCT ON (uid)
    uid,
    vendor,
    price_krw,
    url,
    in_stock,
    captured_at
FROM current_price
WHERE in_stock = TRUE
ORDER BY uid, price_krw ASC, vendor;

COMMENT ON VIEW cheapest_current_price IS
    '각 부품의 최저가 1행 (재고 있는 것만). 추천/검색 쿼리용. 다중 벤더 증식 방지';


-- ============================================================
-- Layer 5. USE_CASE_PROFILE
-- ============================================================
-- 목적 → 요구 성능 매핑. 추천 엔진의 두뇌.
-- ============================================================

CREATE TABLE use_case_profile (
    use_case_id      VARCHAR(50) PRIMARY KEY,
    display_name     VARCHAR(100) NOT NULL,
    category         VARCHAR(30) NOT NULL
                     CHECK (category IN ('gaming', 'productivity', 'creative', 'ai_ml', 'general')),
    cpu_req_score    INTEGER,              -- PassMark CPU Multi 기준
    gpu_req_score    INTEGER,              -- PassMark G3D 기준
    ram_gb_req       INTEGER,
    vram_gb_req      INTEGER,
    storage_type     VARCHAR(20),          -- 'nvme', 'sata_ssd', 'hdd'
    extra_req        JSONB DEFAULT '{}'::jsonb,
    confidence       SMALLINT DEFAULT 1
                     CHECK (confidence BETWEEN 1 AND 3),
    updated_at       TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_use_case_category ON use_case_profile(category);

COMMENT ON TABLE use_case_profile IS 'Layer 5: 목적 → 요구사양 매핑';
COMMENT ON COLUMN use_case_profile.confidence IS '1=하드코딩 추정, 2=일부 검증, 3=사용자 데이터로 검증됨';


-- ============================================================
-- 보조 테이블: COMPAT_EXCEPTION
-- ============================================================
-- 규칙으로 잡히지 않는 진짜 예외 케이스만.
-- 양방향 검색 가능 (uid_a < uid_b로 정규화).
-- ============================================================

CREATE TABLE compat_exception (
    id          BIGSERIAL PRIMARY KEY,
    uid_a       VARCHAR(30) NOT NULL REFERENCES part_id(uid) ON DELETE CASCADE,
    uid_b       VARCHAR(30) NOT NULL REFERENCES part_id(uid) ON DELETE CASCADE,
    verdict     VARCHAR(20) NOT NULL
                CHECK (verdict IN ('incompatible', 'warning', 'requires_action')),
    severity    SMALLINT DEFAULT 2 CHECK (severity BETWEEN 1 AND 3),
    reason      TEXT NOT NULL,
    source      VARCHAR(100),
    created_at  TIMESTAMP DEFAULT NOW(),

    CHECK (uid_a < uid_b),
    UNIQUE (uid_a, uid_b, verdict)
);

CREATE INDEX idx_compat_exc_a ON compat_exception(uid_a);
CREATE INDEX idx_compat_exc_b ON compat_exception(uid_b);

COMMENT ON TABLE compat_exception IS '규칙으로 잡히지 않는 호환성 예외만 저장';


-- ============================================================
-- 운영 테이블: DIAGNOSIS_SESSION
-- ============================================================
-- 사용자 진단 세션 기록. KPI 측정 + 추천 학습용.
-- ============================================================
-- 변경 (v1.0.2): use_case_id FK에 ON DELETE RESTRICT 명시
--   이전: 묵시적 NO ACTION. 의도 불명확
--   현재: 마스터 데이터(use_case_profile) 삭제 시 명시적으로 차단

CREATE TABLE diagnosis_session (
    session_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id        UUID,                       -- 비회원도 가능
    detected_specs JSONB NOT NULL,             -- 에이전트가 수집한 현재 PC
    use_case_id    VARCHAR(50)
                   REFERENCES use_case_profile(use_case_id) ON DELETE RESTRICT,
    budget_krw     INTEGER,
    fit_index      SMALLINT CHECK (fit_index BETWEEN 0 AND 100),
    bottleneck     VARCHAR(20)
                   CHECK (bottleneck IN ('CPU', 'GPU', 'RAM', 'STORAGE', 'NONE')),
    created_at     TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_session_use_case ON diagnosis_session(use_case_id);
CREATE INDEX idx_session_created ON diagnosis_session(created_at DESC);
CREATE INDEX idx_session_user ON diagnosis_session(user_id) WHERE user_id IS NOT NULL;

COMMENT ON TABLE diagnosis_session IS '사용자 진단 세션 기록';


-- ============================================================
-- 운영 테이블: RECOMMENDATION
-- ============================================================
-- 추천 결과 + 사용자 행동 추적 (CTR, 구매 전환).
-- ============================================================
-- 변경 (v1.0.2): recommended_uid FK에 ON DELETE RESTRICT 명시
--   이전: 묵시적 NO ACTION. 다른 FK들은 CASCADE 명시되어 일관성 부족
--   현재: 추천 이력은 분석 데이터이므로 마스터(part_id) 삭제 차단을 명시

CREATE TABLE recommendation (
    id              BIGSERIAL PRIMARY KEY,
    session_id      UUID NOT NULL
                    REFERENCES diagnosis_session(session_id) ON DELETE CASCADE,
    recommended_uid VARCHAR(30) NOT NULL
                    REFERENCES part_id(uid) ON DELETE RESTRICT,
    rank            SMALLINT NOT NULL,
    fit_score       NUMERIC(5, 2),         -- 적합도 점수 0-100
    reasoning       TEXT,                  -- 추천 이유 (사용자 표시용)
    clicked         BOOLEAN DEFAULT FALSE,
    purchased       BOOLEAN DEFAULT FALSE,
    clicked_at      TIMESTAMP,
    purchased_at    TIMESTAMP,
    created_at      TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_recom_session ON recommendation(session_id);
CREATE INDEX idx_recom_uid ON recommendation(recommended_uid);
CREATE INDEX idx_recom_clicked ON recommendation(session_id, clicked) WHERE clicked = TRUE;

COMMENT ON TABLE recommendation IS '추천 결과 + CTR/구매 전환 추적';


-- ============================================================
-- 운영 함수: KPI 측정용
-- ============================================================

-- CTR 계산 함수
CREATE OR REPLACE FUNCTION calc_ctr(start_date TIMESTAMP, end_date TIMESTAMP)
RETURNS NUMERIC AS $$
DECLARE
    total_count INTEGER;
    clicked_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO total_count
    FROM recommendation
    WHERE created_at BETWEEN start_date AND end_date;

    SELECT COUNT(*) INTO clicked_count
    FROM recommendation
    WHERE created_at BETWEEN start_date AND end_date AND clicked = TRUE;

    IF total_count = 0 THEN RETURN 0; END IF;
    RETURN ROUND(clicked_count::NUMERIC / total_count * 100, 2);
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION calc_ctr IS '특정 기간의 추천 클릭률(%) 계산';


-- ============================================================
-- 스키마 버전 관리
-- ============================================================

CREATE TABLE schema_version (
    version     VARCHAR(20) PRIMARY KEY,
    applied_at  TIMESTAMP DEFAULT NOW(),
    description TEXT
);

INSERT INTO schema_version (version, description)
VALUES
  ('1.0.0', '초기 스키마: 5-Layer + 보조 + 운영'),
  ('1.0.1', 'UID를 순수 식별자로 단순화 (예: GPU-NV-000001). part_performance 중복 인덱스 정리.'),
  ('1.0.2', 'FK ON DELETE 명시 (recommendation, diagnosis_session). cheapest_current_price 뷰 추가 (부품당 1행, 다중 벤더 증식 방지). compat_exception 시드에서 규칙 중복 2건 제거.');
