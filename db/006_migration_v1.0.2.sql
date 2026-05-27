-- ============================================================
-- 마이그레이션 스크립트: v1.0.1 → v1.0.2
-- 대상: 이미 v1.0.1이 적용된 기존 DB 환경
-- 신규 환경은 001_schema.sql부터 순서대로 실행할 것
-- ============================================================

-- Step 1. recommendation.recommended_uid FK: ON DELETE RESTRICT
ALTER TABLE recommendation
    DROP CONSTRAINT IF EXISTS recommendation_recommended_uid_fkey,
    ADD CONSTRAINT recommendation_recommended_uid_fkey
        FOREIGN KEY (recommended_uid) REFERENCES part_id(uid) ON DELETE RESTRICT;

-- Step 2. diagnosis_session.use_case_id FK: ON DELETE RESTRICT
ALTER TABLE diagnosis_session
    DROP CONSTRAINT IF EXISTS diagnosis_session_use_case_id_fkey,
    ADD CONSTRAINT diagnosis_session_use_case_id_fkey
        FOREIGN KEY (use_case_id) REFERENCES use_case_profile(use_case_id) ON DELETE RESTRICT;

-- Step 3. cheapest_current_price 뷰 추가
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

-- Step 4. compat_exception 중복 시드 2건 삭제
-- (ram_type 매칭으로 이미 자동 차단되는 케이스 — 설계 원칙 위반)
DELETE FROM compat_exception
WHERE (uid_a, uid_b) IN (
    ('MB-ASUS-000001', 'RAM-SAMS-000003'),
    ('MB-ASUS-000001', 'RAM-SAMS-000004')
);

-- Step 5. 버전 기록
INSERT INTO schema_version (version, description)
VALUES (
    '1.0.2',
    'FK ON DELETE 명시 (recommendation, diagnosis_session). cheapest_current_price 뷰 추가 (부품당 1행, 다중 벤더 증식 방지). compat_exception 시드에서 규칙 중복 2건 제거.'
)
ON CONFLICT (version) DO NOTHING;
