# 컴닥터 DB 검증 & 수정 내역서

**버전**: 1.0.1 → 1.0.2
**작성일**: 2026-05-23
**범위**: `001_schema.sql`, `004_seed_perf_price_usecase_exception.sql`, `005_example_queries.sql`
**무변경**: `002_seed_part_id.sql`, `003_seed_part_spec.sql`

---

## 요약

총 **7개 항목** 수정:

| 심각도 | 수 | 항목 |
|---|---|---|
| 🔴 버그 | 2 | 005 G2, 005 E1 |
| 🟡 설계 이슈 | 5 | 001 FK ×2, 001 뷰, 005 다중 벤더, 005 D2, 004 compat_exception |

제외 (사용자 선택): 🟢 minor 항목 2건 (`calc_ctr`의 BIGINT, `storage_type` CHECK).

---

## 변경 항목 상세

### [BUG-1] 005 G2 — `aliases` NULL 안전 처리

**파일**: `005_example_queries.sql`
**위치**: G2 쿼리

**문제**
```sql
WHERE uid = 'GPU-NV-000011' AND NOT ('4070슈퍼' = ANY(aliases));
```
`aliases`가 NULL인 부품은 첫 별칭을 영원히 추가 못 함:
- `'x' = ANY(NULL)` → `NULL`
- `NOT NULL` → `NULL`
- WHERE 절은 NULL을 FALSE로 취급 → UPDATE 안 됨

**수정**
```sql
UPDATE part_id
SET aliases = array_append(COALESCE(aliases, ARRAY[]::TEXT[]), '4070슈퍼')
WHERE uid = 'GPU-NV-000011'
  AND (aliases IS NULL OR NOT ('4070슈퍼' = ANY(aliases)));
```
- WHERE에 `IS NULL` 케이스 추가
- `array_append`도 NULL이면 NULL 반환하므로 `COALESCE`로 빈 배열 보장

---

### [BUG-2] 005 E1 — 벤치마크 누락 시 결과 0 row

**파일**: `005_example_queries.sql`
**위치**: E1 적합도 매트릭스 쿼리

**문제**
```sql
cpu_score AS (
    SELECT pp.score AS s FROM part_performance pp ...
    WHERE benchmark_name = 'passmark_cpu_multi'
),
...
FROM user_setup u CROSS JOIN target CROSS JOIN cpu_score CROSS JOIN gpu_score;
```
- 해당 부품의 벤치마크 행이 없으면 CTE가 0 row
- `CROSS JOIN`이 0 row와 곱해지면 결과 전체가 0 row
- 적합도가 "낮음"이 아니라 "결과 없음"으로 깨짐

**수정**
- CTE → 스칼라 서브쿼리 + `COALESCE(..., 0)`로 0점 처리
- `NULLIF(..., 0)`으로 0 나누기도 방어

```sql
scores AS (
    SELECT
        COALESCE((SELECT pp.score FROM part_performance pp, user_setup u
                  WHERE pp.uid = u.current_cpu
                  AND pp.benchmark_name = 'passmark_cpu_multi'), 0) AS cpu_s,
        ...
)
```

**의미적 결정**
- "벤치마크 미측정 = 보수적으로 0점"이 기본 동작
- 추후 UI에서 "측정 안 됨" 플래그를 별도로 노출하는 게 이상적이지만, 우선 결과는 항상 반환

---

### [DESIGN-1] 001 — FK ON DELETE 명시

**파일**: `001_schema.sql`
**대상**:
- `recommendation.recommended_uid` → `part_id(uid)`
- `diagnosis_session.use_case_id` → `use_case_profile(use_case_id)`

**문제**
- ON DELETE 절 없음 → PostgreSQL 기본 NO ACTION
- 의도(이력 보존? 정합성 강제?)가 코드만 봐서 불분명
- 같은 스키마의 다른 FK들은 `CASCADE`를 명시하고 있어 일관성 깨짐

**수정**
```sql
recommended_uid VARCHAR(30) NOT NULL
                REFERENCES part_id(uid) ON DELETE RESTRICT,
use_case_id     VARCHAR(50)
                REFERENCES use_case_profile(use_case_id) ON DELETE RESTRICT,
```

**의미적 결정**
- 추천 이력/진단 세션은 **분석용 데이터**이므로 마스터 데이터(part_id, use_case_profile) 삭제는 명시적으로 차단
- 부품을 정말 지워야 하면 먼저 관련 추천 row를 처리하는 게 안전

---

### [DESIGN-2] 001 — `cheapest_current_price` 뷰 추가

**파일**: `001_schema.sql`
**위치**: Layer 4 PART_PRICE 섹션

**문제 (근본 원인)**
기존 `current_price` 뷰는 `DISTINCT ON (uid, vendor)` 즉 **(부품, 벤더)당 1행**.
추천/검색 쿼리에서 `JOIN current_price cp ON cp.uid = pid.uid`만 거는 경우 한 부품이 N개 벤더에 있으면 결과가 N배로 곱해짐. `LIMIT 10`이 "10개 부품"이 아니라 "10개 row"가 됨 (같은 GPU가 쿠팡/다나와/컴퓨존으로 3번 등장).

**수정**
새 뷰 신설 — 부품당 1행, 최저가, 재고 있는 것만:
```sql
CREATE OR REPLACE VIEW cheapest_current_price AS
SELECT DISTINCT ON (uid)
    uid, vendor, price_krw, url, in_stock, captured_at
FROM current_price
WHERE in_stock = TRUE
ORDER BY uid, price_krw ASC, vendor;
```

**의미적 결정**
- `current_price`(벤더별)는 가격 추이/벤더 비교용으로 그대로 유지 (D1에서 사용)
- `cheapest_current_price`(부품당 1행)는 추천/검색용 (A1, A2, A3, B2, D2에서 사용)
- 두 뷰가 의도 분리를 명확히 함

---

### [DESIGN-3] 005 — A1, A2, A3, B2 다중 벤더 증식 해결

**파일**: `005_example_queries.sql`
**대상**: A1 (호환 CPU), A2 (호환 RAM), A3 (호환 GPU), B2 (병목 업그레이드 후보)

**문제**
DESIGN-2의 직접적 증상. `JOIN current_price`로 인해 LIMIT N이 부품 수를 보장하지 못함.

**수정**
- `current_price` → `cheapest_current_price` 교체
- 새 뷰가 `WHERE in_stock = TRUE`를 이미 포함하므로 쿼리에서 해당 조건 제거 (중복)
- 결과 SELECT에 `cp.vendor` 추가 (어느 벤더의 최저가인지 표시)

---

### [DESIGN-4] 005 D2 — 동점 결정적 처리

**파일**: `005_example_queries.sql`
**위치**: D2 카테고리별 최저가 쿼리

**문제**
```sql
JOIN current_price cp ON cp.uid = pid.uid AND cp.price_krw = m.min_price
```
- 같은 카테고리에 같은 최저가가 둘이면 둘 다 나옴
- 다중 벤더 증식까지 합쳐져서 row 수 예측 불가

**수정**
서브쿼리 + GROUP BY MIN 패턴 → ROW_NUMBER 윈도우 함수로 교체:
```sql
WITH ranked AS (
    SELECT
        pid.category, pid.uid, pid.model_name, cp.price_krw, cp.vendor,
        ROW_NUMBER() OVER (
            PARTITION BY pid.category
            ORDER BY cp.price_krw ASC, pid.uid
        ) AS rn
    FROM part_id pid
    JOIN cheapest_current_price cp ON cp.uid = pid.uid
)
SELECT category, model_name, price_krw, vendor
FROM ranked
WHERE rn = 1
ORDER BY category;
```
- 카테고리당 정확히 1행
- 동점 시 `uid` 사전순으로 결정적 tie-break

---

### [DESIGN-5] 004 — `compat_exception` 시드 정리

**파일**: `004_seed_perf_price_usecase_exception.sql`
**삭제 row**: 2건

```sql
-- 삭제됨
('MB-ASUS-000001', 'RAM-SAMS-000003', 'incompatible', 3, 'B660M-A는 DDR4 전용 보드라 ...'),
('MB-ASUS-000001', 'RAM-SAMS-000004', 'incompatible', 3, 'B660M-A는 DDR4 전용 보드라 ...'),
```

**문제**
- schema 코멘트 원칙: *"규칙으로 잡히지 않는 진짜 예외 케이스만"*
- 이 2건은 A2 쿼리의 `ps.ram_type = t.ram_type` 매칭으로 **이미 자동 차단됨**
- 같은 종류의 ram_type 충돌은 시드에 23건 가능한데 이 2건만 들어있어 비일관적

**삭제하지 않은 5건 (의도대로 유지)**
- `CPU-AMD-000003 ↔ MB-ASUS-000007` (5800X3D BIOS 권장)
- `GPU-NV-000016 ↔ PSU-CORS-000004/EVGA-000002/FSP-000002/SEAS-000003` (4090 + 850W 경고)

→ 모두 "규칙으론 못 잡는 진짜 예외"이므로 의도에 부합

---

## 검증 못 한 항목 (참고)

검증 시점에 시드 파일 002~004가 일시적으로 디스크에 없어 재업로드 후 본 결과, **데이터 자체는 깨끗**했습니다:
- 모든 UID가 명명 규칙 준수
- 005 쿼리가 참조하는 모든 UID (`MB-ASUS-000004`, `CPU-INTL-000002/000006`, `GPU-NV-000002/000009/000011`) 실존 확인
- JSONB 키 일관성 OK (`generation`, `cores`, `vram_gb`, `length_mm`, `max_ram_mhz`, `max_ram_capacity_gb`, `capacity_gb`, `speed_mhz`, `supported_cpu_gens`)
- `benchmark_name` 표기 일관성 OK (`passmark_cpu_single`, `passmark_cpu_multi`, `passmark_g3d`)
- `use_case_id` 참조 일치 OK (`valorant_1440p_144fps`, `cyberpunk_1440p_60fps` 모두 정의됨)
- `compat_exception`의 `uid_a < uid_b` 정규화 모두 준수

데이터 레벨 문제는 위 DESIGN-5 1건뿐.

---

## 미반영 항목 (🟢 minor — 사용자 선택)

다음은 검증에서 발견했으나 사용자가 "🟡 설계 이슈까지"만 수정하도록 선택해 보류한 항목입니다.

### M1. `calc_ctr` 함수 — INTEGER → BIGINT
- `COUNT(*)`는 BIGINT 반환인데 INTEGER 변수에 할당
- 추천 row가 21억 넘으면 overflow (실용적으론 거의 안 일어남)

### M2. `use_case_profile.storage_type` CHECK 누락
- 주석으로만 값 명시 (`'nvme', 'sata_ssd', 'hdd'`)
- 다른 enum성 컬럼은 다 CHECK 있는데 이것만 빠짐
- 오타 값이 들어가도 막을 수 없음

다음 마이그레이션(1.0.3)에서 적용 권장.

---

## 적용 순서 (신규 환경 기준)

```bash
psql -d computer_doctor -f 001_schema.sql
psql -d computer_doctor -f 002_seed_part_id.sql
psql -d computer_doctor -f 003_seed_part_spec.sql
psql -d computer_doctor -f 004_seed_perf_price_usecase_exception.sql
# 005는 예제 쿼리이므로 자동 실행 X (필요 시 개별 실행)
```

## 기존 환경 마이그레이션 (1.0.1 → 1.0.2)

001을 새로 실행하면 테이블이 이미 존재해 에러가 나므로, 기존 DB에는 변경분만 별도 마이그레이션 스크립트로 적용해야 합니다. 필요하면 별도로 작성해드릴 수 있습니다.

대략:
```sql
-- FK 재생성
ALTER TABLE recommendation
    DROP CONSTRAINT recommendation_recommended_uid_fkey,
    ADD CONSTRAINT recommendation_recommended_uid_fkey
    FOREIGN KEY (recommended_uid) REFERENCES part_id(uid) ON DELETE RESTRICT;

ALTER TABLE diagnosis_session
    DROP CONSTRAINT diagnosis_session_use_case_id_fkey,
    ADD CONSTRAINT diagnosis_session_use_case_id_fkey
    FOREIGN KEY (use_case_id) REFERENCES use_case_profile(use_case_id) ON DELETE RESTRICT;

-- 뷰 추가
CREATE OR REPLACE VIEW cheapest_current_price AS ...;

-- 시드 정리
DELETE FROM compat_exception
WHERE (uid_a, uid_b) IN (
    ('MB-ASUS-000001', 'RAM-SAMS-000003'),
    ('MB-ASUS-000001', 'RAM-SAMS-000004')
);

-- 버전 기록
INSERT INTO schema_version (version, description)
VALUES ('1.0.2', 'FK ON DELETE 명시, cheapest_current_price 뷰 추가, compat_exception 시드 정리');
```
