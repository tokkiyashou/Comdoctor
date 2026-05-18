# 컴닥터 데이터베이스 설계

> 실제 스키마: `docs/001_schema.sql` 기준 (PostgreSQL 14+)

---

## 인프라 구성

| DB | 역할 |
|----|------|
| **PostgreSQL** | 부품 데이터, 분석 이력 등 영구 저장 |
| **Redis** | Gemini 응답 캐싱, Rate limiting |

---

## 5-Layer 구조

```
part_id                ← UID 중심 기준 테이블 (aliases 포함)
  ├── part_spec        ← 스펙 (JSONB 하이브리드)
  ├── part_performance ← 벤치마크 점수 (EAV)
  ├── part_price       ← 가격 이력 (append-only)
  └── use_case_profile ← 목적별 요구 사양

compat_exception       ← 호환성 예외 케이스
diagnosis_session      ← 사용자 진단 세션
recommendation         ← 추천 결과 + CTR 추적
```

---

## Layer 1 — `part_id`

> 모든 부품의 기준. UID 형식: `{카테고리}-{제조사}-{6자리 시퀀스}`

```sql
CREATE TABLE part_id (
    uid           VARCHAR(30) PRIMARY KEY,     -- ex) GPU-NV-000001
    model_name    VARCHAR(200) NOT NULL,        -- "NVIDIA GeForce RTX 4070"
    category      VARCHAR(20) NOT NULL          -- CPU | GPU | RAM | MB | SSD | PSU | CASE
                  CHECK (category IN ('CPU', 'GPU', 'RAM', 'MB', 'SSD', 'PSU', 'CASE')),
    manufacturer  VARCHAR(50) NOT NULL,
    released_at   DATE,
    aliases       TEXT[],                       -- {"RTX 4070", "지포스 4070", "4070"}
    created_at    TIMESTAMP DEFAULT NOW()
);
```

**별칭 검색 (네이버 API 매칭):**
```sql
-- "4070 슈퍼", "RTX 4070S" 등 다양한 표기 매칭
SELECT uid, model_name FROM part_id
WHERE aliases && ARRAY['4070S', '지포스 4070 슈퍼'];
```

---

## Layer 2 — `part_spec`

> 자주 검색하는 호환성 키는 컬럼 + 인덱스, 나머지는 JSONB.

```sql
CREATE TABLE part_spec (
    uid          VARCHAR(30) PRIMARY KEY REFERENCES part_id(uid),
    socket       VARCHAR(20),    -- CPU/MB 소켓 (LGA1700, AM5)
    ram_type     VARCHAR(10),    -- RAM/MB 타입 (DDR4, DDR5)
    form_factor  VARCHAR(10),    -- MB/CASE 폼팩터 (ATX, mATX, ITX)
    tdp_watts    INTEGER,        -- CPU/GPU 발열 (PSU 계산용)
    pcie_version VARCHAR(10),    -- GPU PCIe 버전
    attributes   JSONB           -- 카테고리별 가변 속성
);
```

**카테고리별 JSONB 필수 키:**

| 카테고리 | 컬럼 (인덱스) | JSONB 주요 키 |
|----------|-------------|-------------|
| CPU | socket, tdp_watts | generation, cores, threads |
| MB | socket, ram_type, form_factor | supported_cpu_gens[], max_ram_mhz, m2_slots |
| RAM | ram_type | speed_mhz, capacity_gb, kit_count |
| GPU | tdp_watts, pcie_version | vram_gb, length_mm |
| PSU | — | wattage, certification |
| CASE | — | supported_form_factors[], max_gpu_length_mm |
| SSD | — | interface, pcie_gen, capacity_gb, seq_read_mbs |

**호환 부품 검색 쿼리 (앱 흐름 [4]):**
```sql
-- 메인보드 기준 호환 RAM + 예산 필터
WITH target_mb AS (
    SELECT ram_type, (attributes->>'max_ram_mhz')::int AS max_mhz
    FROM part_spec WHERE uid = $mb_uid
)
SELECT pid.uid, pid.model_name,
       (ps.attributes->>'speed_mhz')::int AS mhz,
       cp.price_krw
FROM part_id pid
JOIN part_spec ps USING (uid)
JOIN current_price cp ON cp.uid = pid.uid
CROSS JOIN target_mb t
WHERE pid.category = 'RAM'
  AND ps.ram_type = t.ram_type
  AND (ps.attributes->>'speed_mhz')::int <= t.max_mhz
  AND cp.price_krw <= $budget
  AND cp.in_stock = TRUE
ORDER BY cp.price_krw ASC LIMIT 50;
```

---

## Layer 3 — `part_performance`

> EAV 구조. 새 벤치마크 추가 시 스키마 변경 없이 행만 추가.

```sql
CREATE TABLE part_performance (
    id             BIGSERIAL PRIMARY KEY,
    uid            VARCHAR(30) NOT NULL REFERENCES part_id(uid),
    benchmark_name VARCHAR(50) NOT NULL,   -- passmark_cpu_multi | passmark_g3d
    score          NUMERIC(12, 2) NOT NULL,
    source         VARCHAR(100),           -- PassMark
    measured_at    TIMESTAMP DEFAULT NOW(),
    UNIQUE(uid, benchmark_name)
);
```

**현재 시드 데이터 (004_seed_perf_price_usecase_exception.sql):**
- CPU: `passmark_cpu_single`, `passmark_cpu_multi` (PassMark 실측값)
- GPU: `passmark_g3d` (PassMark 실측값)

---

## Layer 4 — `part_price`

> append-only. 수정 없이 신규 행만 추가.

```sql
CREATE TABLE part_price (
    id          BIGSERIAL PRIMARY KEY,
    uid         VARCHAR(30) NOT NULL REFERENCES part_id(uid),
    price_krw   INTEGER NOT NULL CHECK (price_krw > 0),
    vendor      VARCHAR(50) NOT NULL,   -- 쿠팡, 다나와, 컴퓨존
    url         TEXT,                   -- 구매 링크
    in_stock    BOOLEAN DEFAULT TRUE,
    captured_at TIMESTAMP DEFAULT NOW()
);

-- 최신가 조회 뷰
CREATE VIEW current_price AS
SELECT DISTINCT ON (uid, vendor) uid, vendor, price_krw, url, in_stock, captured_at
FROM part_price ORDER BY uid, vendor, captured_at DESC;
```

**일일 갱신 흐름:**
```
part_id.aliases → 네이버 쇼핑 API 검색 → 가격 추출 → INSERT (UPDATE 없음)
```

---

## Layer 5 — `use_case_profile`

> 목적별 최소 요구 사양. 병목 탐지의 기준.

```sql
CREATE TABLE use_case_profile (
    use_case_id   VARCHAR(50) PRIMARY KEY,    -- valorant_1440p_144fps
    display_name  VARCHAR(100) NOT NULL,
    category      VARCHAR(30) NOT NULL,        -- gaming | productivity | creative | ai_ml
    cpu_req_score INTEGER,                     -- PassMark CPU Multi 기준
    gpu_req_score INTEGER,                     -- PassMark G3D 기준
    ram_gb_req    INTEGER,
    vram_gb_req   INTEGER,
    storage_type  VARCHAR(20),                 -- nvme | sata_ssd | hdd
    confidence    SMALLINT DEFAULT 1           -- 1=추정 | 2=일부검증 | 3=사용자데이터검증
);
```

**시드 데이터 (004 파일):** 23개 목적 프로파일 (게이밍 10, 생산성 4, 크리에이티브 5, AI 3, 기타 1)

---

## 보조 테이블 — `compat_exception`

> SQL 규칙으로 잡히지 않는 예외만 저장.

```sql
CREATE TABLE compat_exception (
    uid_a    VARCHAR(30) REFERENCES part_id(uid),
    uid_b    VARCHAR(30) REFERENCES part_id(uid),
    verdict  VARCHAR(20) CHECK (verdict IN ('incompatible', 'warning', 'requires_action')),
    reason   TEXT NOT NULL,
    CHECK (uid_a < uid_b)
);
```

예시: 특정 MB + CPU 조합에서 BIOS 업데이트 전까지 부팅 불가 등.

---

## 운영 테이블 — 진단 세션 / 추천

```sql
-- 사용자 진단 세션
CREATE TABLE diagnosis_session (
    session_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id        UUID,
    detected_specs JSONB NOT NULL,           -- 에이전트가 수집한 현재 PC
    use_case_id    VARCHAR(50) REFERENCES use_case_profile(use_case_id),
    budget_krw     INTEGER,
    fit_index      SMALLINT,                 -- 0~100 적합도
    bottleneck     VARCHAR(20)               -- CPU | GPU | RAM | STORAGE | NONE
                   CHECK (bottleneck IN ('CPU', 'GPU', 'RAM', 'STORAGE', 'NONE')),
    created_at     TIMESTAMP DEFAULT NOW()
);

-- 추천 결과 + CTR 추적
CREATE TABLE recommendation (
    id              BIGSERIAL PRIMARY KEY,
    session_id      UUID REFERENCES diagnosis_session(session_id),
    recommended_uid VARCHAR(30) REFERENCES part_id(uid),
    rank            SMALLINT NOT NULL,        -- 1, 2, 3
    fit_score       NUMERIC(5, 2),
    reasoning       TEXT,
    clicked         BOOLEAN DEFAULT FALSE,
    purchased       BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMP DEFAULT NOW()
);
```

---

## Redis 사용 방식

### Gemini 응답 캐싱

```
캐시 키: SHA256(specs_json + purpose + budget)
TTL: 24시간

HIT  → 즉시 반환 (Gemini 호출 없음)
MISS → Gemini 호출 → 결과 Redis 저장 → 반환
```

### Rate Limiting

```
키: "rl:{IP}"  TTL: 60초  한도: 분당 5회
초과 시 → 429 반환
```

---

## 시드 데이터 요약

| 파일 | 내용 |
|------|------|
| `002_seed_part_id.sql` | 부품 144개 + 별칭 |
| `003_seed_part_spec.sql` | 스펙 전체 |
| `004_seed_perf_price_usecase_exception.sql` | PassMark 점수 62개, 현재가 144개, 목적 프로파일 23개, 호환 예외 7개 |

---

## DB 적용 순서

```bash
psql -U postgres -c "CREATE DATABASE ComdoctorDB WITH ENCODING 'UTF8';"
psql -U postgres -d ComdoctorDB -f docs/001_schema.sql
psql -U postgres -d ComdoctorDB -f docs/002_seed_part_id.sql
psql -U postgres -d ComdoctorDB -f docs/003_seed_part_spec.sql
psql -U postgres -d ComdoctorDB -f docs/004_seed_perf_price_usecase_exception.sql
```

---

## 현재 코드 연결 포인트

| 현재 코드 | DB 대체 |
|-----------|---------|
| `GPU_TIER_DATA` 배열 | `part_spec.attributes->>'tier'` |
| `db.saveAnalysis()` stub | `diagnosis_session` 테이블 INSERT |
| system prompt 점수 기준표 | `part_performance` PassMark 점수 |
| Gemini 호환성 판단 | `part_spec` SQL WHERE 조건 |

---

## 구현 우선순위

| 순서 | 작업 |
|------|------|
| 1 | `server/db.js` PostgreSQL 구현 (`diagnosis_session` 저장) |
| 2 | 네이버 가격 수집 → `part_price` 저장 파이프라인 |
| 3 | Redis 캐싱 + Rate limiting |
| 4 | 호환 검색 쿼리로 Gemini 대체 |
