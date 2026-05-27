-- ============================================================
-- 추천 엔진용 예제 쿼리 (Query Cookbook)
-- Version: 1.0.2
-- 각 쿼리를 실행해서 결과 확인 가능
-- ============================================================
-- v1.0.2 변경점 (CHANGELOG.md 참조):
--   - G2: aliases NULL 안전 처리 (🔴 버그)
--   - E1: 벤치마크 누락 시 결과 보존 (🔴 버그)
--   - A1, A2, A3, B2: cheapest_current_price 뷰로 다중 벤더 증식 해결
--   - D2: 동점 결정적 처리 (ROW_NUMBER) + 뷰 통일
-- ============================================================


-- ============================================================
-- A. 호환 부품 검색 (업그레이드 시나리오)
-- ============================================================

-- A1. 메인보드 기준 호환 CPU 찾기
-- 입력: 메인보드 UID (예: MB-ASUS-000004)
-- 출력: 호환 CPU 목록 (성능순, 부품당 1행)
WITH target_mb AS (
    SELECT socket,
           attributes->'supported_cpu_gens' AS cpu_gens
    FROM part_spec
    WHERE uid = 'MB-ASUS-000004'
)
SELECT
    pid.uid,
    pid.model_name,
    ps.attributes->>'generation' AS gen,
    (ps.attributes->>'cores')::int AS cores,
    perf.score AS passmark_multi,
    cp.price_krw,
    cp.vendor
FROM part_id pid
JOIN part_spec ps USING (uid)
JOIN cheapest_current_price cp ON cp.uid = pid.uid
LEFT JOIN part_performance perf ON perf.uid = pid.uid AND perf.benchmark_name = 'passmark_cpu_multi'
CROSS JOIN target_mb t
WHERE pid.category = 'CPU'
  AND ps.socket = t.socket
  AND t.cpu_gens @> jsonb_build_array(ps.attributes->>'generation')
ORDER BY perf.score DESC NULLS LAST
LIMIT 10;


-- A2. 메인보드 기준 호환 RAM 찾기
WITH target_mb AS (
    SELECT ram_type,
           (attributes->>'max_ram_mhz')::int AS max_mhz,
           (attributes->>'max_ram_capacity_gb')::int AS max_gb
    FROM part_spec
    WHERE uid = 'MB-ASUS-000004'
)
SELECT
    pid.uid, pid.model_name,
    (ps.attributes->>'capacity_gb')::int AS gb,
    (ps.attributes->>'speed_mhz')::int AS mhz,
    cp.price_krw, cp.vendor
FROM part_id pid
JOIN part_spec ps USING (uid)
JOIN cheapest_current_price cp ON cp.uid = pid.uid
CROSS JOIN target_mb t
WHERE pid.category = 'RAM'
  AND ps.ram_type = t.ram_type
  AND (ps.attributes->>'speed_mhz')::int <= t.max_mhz
  AND (ps.attributes->>'capacity_gb')::int <= t.max_gb
ORDER BY cp.price_krw ASC
LIMIT 10;


-- A3. 케이스 + PSU 여유 기준 호환 GPU 찾기
-- 시스템 TDP 250W, 케이스 max GPU 길이 350mm
SELECT
    pid.uid, pid.model_name,
    (ps.attributes->>'vram_gb')::int AS vram,
    (ps.attributes->>'length_mm')::int AS length_mm,
    ps.tdp_watts,
    perf.score AS g3d_score,
    cp.price_krw, cp.vendor
FROM part_id pid
JOIN part_spec ps USING (uid)
JOIN cheapest_current_price cp ON cp.uid = pid.uid
LEFT JOIN part_performance perf ON perf.uid = pid.uid AND perf.benchmark_name = 'passmark_g3d'
WHERE pid.category = 'GPU'
  AND (ps.attributes->>'length_mm')::int <= 350   -- 케이스 max GPU 길이
  AND ps.tdp_watts <= 400                          -- (PSU와트 / 1.5) - 다른부품TDP
ORDER BY perf.score DESC NULLS LAST
LIMIT 10;


-- ============================================================
-- B. 목적 기반 추천 (성능 GAP 분석)
-- ============================================================

-- B1. 사용자 목적과 부품 성능 GAP 계산
-- 입력: use_case_id + 현재 부품 UID
-- 출력: 각 부품의 성능 GAP (음수면 부족)
WITH user_setup AS (
    SELECT
        'valorant_1440p_144fps' AS use_case_id,
        'CPU-INTL-000002'   AS current_cpu,
        'GPU-NV-000002'       AS current_gpu
),
target AS (
    SELECT cpu_req_score, gpu_req_score
    FROM use_case_profile ucp
    JOIN user_setup u ON ucp.use_case_id = u.use_case_id
),
current_perf AS (
    SELECT
        (SELECT score FROM part_performance pp
         JOIN user_setup u ON pp.uid = u.current_cpu
         WHERE benchmark_name = 'passmark_cpu_multi') AS cpu_score,
        (SELECT score FROM part_performance pp
         JOIN user_setup u ON pp.uid = u.current_gpu
         WHERE benchmark_name = 'passmark_g3d') AS gpu_score
)
SELECT
    'CPU' AS component,
    cp.cpu_score AS current,
    t.cpu_req_score AS required,
    cp.cpu_score - t.cpu_req_score AS gap,
    CASE
        WHEN cp.cpu_score >= t.cpu_req_score THEN 'OK'
        ELSE 'BOTTLENECK'
    END AS status
FROM current_perf cp CROSS JOIN target t
UNION ALL
SELECT
    'GPU',
    cp.gpu_score,
    t.gpu_req_score,
    cp.gpu_score - t.gpu_req_score,
    CASE WHEN cp.gpu_score >= t.gpu_req_score THEN 'OK' ELSE 'BOTTLENECK' END
FROM current_perf cp CROSS JOIN target t;


-- B2. 병목 부품에 대한 업그레이드 후보 추천
-- B1에서 GPU가 병목으로 나오면, 호환 GPU 중 성능 만족하는 것 추천
WITH target AS (
    SELECT gpu_req_score, vram_gb_req
    FROM use_case_profile WHERE use_case_id = 'valorant_1440p_144fps'
)
SELECT
    pid.uid, pid.model_name,
    (ps.attributes->>'vram_gb')::int AS vram,
    perf.score AS g3d,
    cp.price_krw, cp.vendor,
    -- 가성비 점수: 성능 / 가격
    ROUND(perf.score::numeric / cp.price_krw * 1000, 2) AS perf_per_1000krw
FROM part_id pid
JOIN part_spec ps USING (uid)
JOIN cheapest_current_price cp ON cp.uid = pid.uid
JOIN part_performance perf ON perf.uid = pid.uid AND perf.benchmark_name = 'passmark_g3d'
CROSS JOIN target t
WHERE pid.category = 'GPU'
  AND perf.score >= t.gpu_req_score
  AND (ps.attributes->>'vram_gb')::int >= t.vram_gb_req
ORDER BY perf_per_1000krw DESC
LIMIT 10;


-- ============================================================
-- C. 별칭 검색 (네이버 API 매칭)
-- ============================================================

-- C1. 다양한 표기로 부품 찾기
-- 예시: 사용자가 '4070 슈퍼', 'RTX 4070S', '지포스 4070 슈퍼' 등으로 입력해도 매칭
SELECT uid, model_name
FROM part_id
WHERE aliases && ARRAY['4070S', '지포스 4070 슈퍼', 'RTX 4070 Super'];

-- C2. 모델명 부분 매칭 (LIKE)
SELECT uid, model_name
FROM part_id
WHERE model_name ILIKE '%14600K%';


-- ============================================================
-- D. 가격 추이 분석
-- ============================================================

-- D1. 특정 부품의 가격 변동 이력
SELECT
    captured_at::date AS date,
    vendor,
    price_krw,
    in_stock
FROM part_price
WHERE uid = 'GPU-NV-000011'
ORDER BY captured_at DESC
LIMIT 20;

-- D2. 카테고리별 최저가 (현재가)
-- ROW_NUMBER로 카테고리당 1개씩 결정적으로 선택.
-- 동점 시 uid 사전순으로 tie-break.
WITH ranked AS (
    SELECT
        pid.category,
        pid.uid,
        pid.model_name,
        cp.price_krw,
        cp.vendor,
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


-- ============================================================
-- E. 적합도 매트릭스 (Fit Index)
-- ============================================================

-- E1. 사용자 PC 전체 적합도 점수 (0-100)
-- 사업계획서 Step 3 (적합도 매트릭스 계산) 구현
--
-- 주의: 벤치마크 미측정 부품(part_performance에 해당 행 없음)은
--   COALESCE(..., 0)으로 0점 처리 → 결과는 항상 1행 반환.
--   원본은 CTE + CROSS JOIN 구조라 벤치마크가 없으면 0 row가 나옴 (🔴 버그).
WITH user_setup AS (
    SELECT
        'cyberpunk_1440p_60fps'::varchar AS use_case_id,
        'CPU-INTL-000006'::varchar       AS current_cpu,
        'GPU-NV-000009'::varchar         AS current_gpu,
        32                               AS current_ram_gb
),
target AS (
    SELECT ucp.cpu_req_score, ucp.gpu_req_score, ucp.ram_gb_req
    FROM use_case_profile ucp
    JOIN user_setup u USING (use_case_id)
),
scores AS (
    SELECT
        COALESCE((
            SELECT pp.score FROM part_performance pp, user_setup u
            WHERE pp.uid = u.current_cpu AND pp.benchmark_name = 'passmark_cpu_multi'
        ), 0) AS cpu_s,
        COALESCE((
            SELECT pp.score FROM part_performance pp, user_setup u
            WHERE pp.uid = u.current_gpu AND pp.benchmark_name = 'passmark_g3d'
        ), 0) AS gpu_s
)
SELECT
    LEAST(100, ROUND(s.cpu_s / NULLIF(t.cpu_req_score, 0) * 100))                AS cpu_fit_pct,
    LEAST(100, ROUND(s.gpu_s / NULLIF(t.gpu_req_score, 0) * 100))                AS gpu_fit_pct,
    LEAST(100, ROUND(u.current_ram_gb::numeric / NULLIF(t.ram_gb_req, 0) * 100)) AS ram_fit_pct,
    ROUND((
        LEAST(100, s.cpu_s / NULLIF(t.cpu_req_score, 0) * 100)
        + LEAST(100, s.gpu_s / NULLIF(t.gpu_req_score, 0) * 100)
        + LEAST(100, u.current_ram_gb::numeric / NULLIF(t.ram_gb_req, 0) * 100)
    ) / 3) AS overall_fit_index
FROM user_setup u CROSS JOIN target t CROSS JOIN scores s;


-- ============================================================
-- F. KPI 측정용 운영 쿼리
-- ============================================================

-- F1. 최근 30일 CTR
SELECT calc_ctr(NOW() - INTERVAL '30 days', NOW()) AS ctr_30d_pct;

-- F2. 가장 많이 추천된 부품 Top 10
SELECT
    pid.model_name,
    COUNT(*) AS recommendation_count,
    SUM(CASE WHEN r.clicked THEN 1 ELSE 0 END) AS click_count,
    ROUND(SUM(CASE WHEN r.clicked THEN 1.0 ELSE 0 END) / COUNT(*) * 100, 2) AS ctr_pct
FROM recommendation r
JOIN part_id pid ON pid.uid = r.recommended_uid
GROUP BY pid.model_name
ORDER BY recommendation_count DESC
LIMIT 10;


-- ============================================================
-- G. 데이터 유지보수 쿼리
-- ============================================================

-- G1. 가격 DB 오래된 데이터 압축 (1년 이상은 주간 1건만 유지)
-- 실제 운영 시 cron으로 일주일에 1번 실행
DELETE FROM part_price
WHERE captured_at < NOW() - INTERVAL '1 year'
  AND id NOT IN (
    SELECT DISTINCT ON (uid, vendor, date_trunc('week', captured_at)) id
    FROM part_price
    WHERE captured_at < NOW() - INTERVAL '1 year'
    ORDER BY uid, vendor, date_trunc('week', captured_at), captured_at DESC
  );

-- G2. 별칭 추가 (운영 중 새 별칭 발견 시)
-- 주의: aliases는 NULL 가능 컬럼. NULL 처리를 빼먹으면 별칭이 한 번도
--   없었던 부품에 첫 별칭을 영원히 추가하지 못함 (🔴 버그).
UPDATE part_id
SET aliases = array_append(COALESCE(aliases, ARRAY[]::TEXT[]), '4070슈퍼')
WHERE uid = 'GPU-NV-000011'
  AND (aliases IS NULL OR NOT ('4070슈퍼' = ANY(aliases)));
