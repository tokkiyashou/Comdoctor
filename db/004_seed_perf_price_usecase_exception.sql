-- ============================================================
-- 시드 데이터 #3: PART_PERFORMANCE, PART_PRICE,
--                 USE_CASE_PROFILE, COMPAT_EXCEPTION
-- ============================================================

-- ============================================================
-- PART_PERFORMANCE (벤치마크 점수)
-- benchmark_name:
--   passmark_cpu_single, passmark_cpu_multi, passmark_g3d
-- 점수 출처: PassMark (https://www.cpubenchmark.net, https://www.videocardbenchmark.net)
-- ============================================================

-- CPU 성능 (PassMark Single / Multi)
INSERT INTO part_performance (uid, benchmark_name, score, source) VALUES
('CPU-INTL-000001', 'passmark_cpu_single', 3673,  'PassMark'),
('CPU-INTL-000001', 'passmark_cpu_multi',  13779, 'PassMark'),
('CPU-INTL-000002', 'passmark_cpu_single', 3744,  'PassMark'),
('CPU-INTL-000002', 'passmark_cpu_multi',  19601, 'PassMark'),
('CPU-INTL-000003', 'passmark_cpu_single', 4145,  'PassMark'),
('CPU-INTL-000003', 'passmark_cpu_multi',  27499, 'PassMark'),
('CPU-INTL-000004', 'passmark_cpu_single', 4163,  'PassMark'),
('CPU-INTL-000004', 'passmark_cpu_multi',  34611, 'PassMark'),
('CPU-INTL-000005', 'passmark_cpu_single', 3997,  'PassMark'),
('CPU-INTL-000005', 'passmark_cpu_multi',  25381, 'PassMark'),
('CPU-INTL-000006', 'passmark_cpu_single', 4380,  'PassMark'),
('CPU-INTL-000006', 'passmark_cpu_multi',  38389, 'PassMark'),
('CPU-INTL-000007', 'passmark_cpu_single', 4476,  'PassMark'),
('CPU-INTL-000007', 'passmark_cpu_multi',  46974, 'PassMark'),
('CPU-INTL-000008', 'passmark_cpu_single', 4669,  'PassMark'),
('CPU-INTL-000008', 'passmark_cpu_multi',  59685, 'PassMark'),
('CPU-INTL-000009', 'passmark_cpu_single', 4055,  'PassMark'),
('CPU-INTL-000009', 'passmark_cpu_multi',  26890, 'PassMark'),
('CPU-INTL-000010', 'passmark_cpu_single', 4521,  'PassMark'),
('CPU-INTL-000010', 'passmark_cpu_multi',  39915, 'PassMark'),
('CPU-INTL-000011', 'passmark_cpu_single', 4583,  'PassMark'),
('CPU-INTL-000011', 'passmark_cpu_multi',  53498, 'PassMark'),
('CPU-INTL-000012', 'passmark_cpu_single', 4844,  'PassMark'),
('CPU-INTL-000012', 'passmark_cpu_multi',  60975, 'PassMark'),
('CPU-AMD-000001',    'passmark_cpu_single', 3463,  'PassMark'),
('CPU-AMD-000001',    'passmark_cpu_multi',  21987, 'PassMark'),
('CPU-AMD-000002',   'passmark_cpu_single', 3471,  'PassMark'),
('CPU-AMD-000002',   'passmark_cpu_multi',  26973, 'PassMark'),
('CPU-AMD-000003', 'passmark_cpu_single', 3503,  'PassMark'),
('CPU-AMD-000003', 'passmark_cpu_multi',  28097, 'PassMark'),
('CPU-AMD-000004',    'passmark_cpu_single', 4015,  'PassMark'),
('CPU-AMD-000004',    'passmark_cpu_multi',  28837, 'PassMark'),
('CPU-AMD-000005',   'passmark_cpu_single', 4202,  'PassMark'),
('CPU-AMD-000005',   'passmark_cpu_multi',  29927, 'PassMark'),
('CPU-AMD-000006',   'passmark_cpu_single', 4279,  'PassMark'),
('CPU-AMD-000006',   'passmark_cpu_multi',  37104, 'PassMark'),
('CPU-AMD-000007', 'passmark_cpu_single', 4239,  'PassMark'),
('CPU-AMD-000007', 'passmark_cpu_multi',  35990, 'PassMark'),
('CPU-AMD-000008',   'passmark_cpu_single', 4322,  'PassMark'),
('CPU-AMD-000008',   'passmark_cpu_multi',  62841, 'PassMark');

-- GPU 성능 (PassMark G3D Mark)
INSERT INTO part_performance (uid, benchmark_name, score, source) VALUES
('GPU-NV-000001',     'passmark_g3d', 12598, 'PassMark'),
('GPU-NV-000002',     'passmark_g3d', 17175, 'PassMark'),
('GPU-NV-000003',   'passmark_g3d', 20366, 'PassMark'),
('GPU-NV-000004',     'passmark_g3d', 22260, 'PassMark'),
('GPU-NV-000005',   'passmark_g3d', 23663, 'PassMark'),
('GPU-NV-000006',     'passmark_g3d', 25115, 'PassMark'),
('GPU-NV-000007',     'passmark_g3d', 26800, 'PassMark'),
('GPU-NV-000008',     'passmark_g3d', 19432, 'PassMark'),
('GPU-NV-000009',   'passmark_g3d', 22516, 'PassMark'),
('GPU-NV-000010',     'passmark_g3d', 26937, 'PassMark'),
('GPU-NV-000011',    'passmark_g3d', 28860, 'PassMark'),
('GPU-NV-000012',   'passmark_g3d', 30592, 'PassMark'),
('GPU-NV-000013',  'passmark_g3d', 32100, 'PassMark'),
('GPU-NV-000014',     'passmark_g3d', 34882, 'PassMark'),
('GPU-NV-000015',    'passmark_g3d', 35420, 'PassMark'),
('GPU-NV-000016',     'passmark_g3d', 39196, 'PassMark'),
('GPU-AMD-000001',    'passmark_g3d', 15257, 'PassMark'),
('GPU-AMD-000002',  'passmark_g3d', 19762, 'PassMark'),
('GPU-AMD-000003',  'passmark_g3d', 25190, 'PassMark'),
('GPU-AMD-000004',  'passmark_g3d', 23598, 'PassMark'),
('GPU-AMD-000005',  'passmark_g3d', 26852, 'PassMark'),
('GPU-AMD-000006', 'passmark_g3d', 34036, 'PassMark');


-- ============================================================
-- PART_PRICE (현재가 스냅샷 - 2026년 5월 기준 가상 데이터)
-- 실제로는 네이버 API 등으로 매일 갱신됨
-- ============================================================

INSERT INTO part_price (uid, price_krw, vendor, url, in_stock) VALUES
-- CPU
('CPU-INTL-000001', 145000,  '쿠팡', 'https://link.coupang.com/a/example1',  TRUE),
('CPU-INTL-000002', 215000,  '쿠팡', 'https://link.coupang.com/a/example2',  TRUE),
('CPU-INTL-000003', 325000,  '쿠팡', 'https://link.coupang.com/a/example3',  TRUE),
('CPU-INTL-000004', 480000,  '쿠팡', 'https://link.coupang.com/a/example4',  TRUE),
('CPU-INTL-000005', 269000,  '쿠팡', 'https://link.coupang.com/a/example5',  TRUE),
('CPU-INTL-000006', 425000,  '쿠팡', 'https://link.coupang.com/a/example6',  TRUE),
('CPU-INTL-000007', 565000,  '쿠팡', 'https://link.coupang.com/a/example7',  TRUE),
('CPU-INTL-000008', 825000,  '쿠팡', 'https://link.coupang.com/a/example8',  TRUE),
('CPU-INTL-000009', 289000,  '쿠팡', 'https://link.coupang.com/a/example9',  TRUE),
('CPU-INTL-000010', 449000,  '쿠팡', 'https://link.coupang.com/a/example10', TRUE),
('CPU-INTL-000011', 619000,  '쿠팡', 'https://link.coupang.com/a/example11', TRUE),
('CPU-INTL-000012', 895000,  '쿠팡', 'https://link.coupang.com/a/example12', TRUE),
('CPU-AMD-000001',    175000,  '쿠팡', 'https://link.coupang.com/a/example13', TRUE),
('CPU-AMD-000002',   249000,  '쿠팡', 'https://link.coupang.com/a/example14', TRUE),
('CPU-AMD-000003', 425000,  '쿠팡', 'https://link.coupang.com/a/example15', TRUE),
('CPU-AMD-000004',    298000,  '쿠팡', 'https://link.coupang.com/a/example16', TRUE),
('CPU-AMD-000005',   335000,  '쿠팡', 'https://link.coupang.com/a/example17', TRUE),
('CPU-AMD-000006',   459000,  '쿠팡', 'https://link.coupang.com/a/example18', TRUE),
('CPU-AMD-000007', 569000,  '쿠팡', 'https://link.coupang.com/a/example19', TRUE),
('CPU-AMD-000008',   789000,  '쿠팡', 'https://link.coupang.com/a/example20', TRUE),
-- GPU
('GPU-NV-000001',     289000,  '쿠팡', 'https://link.coupang.com/a/example21', TRUE),
('GPU-NV-000002',     365000,  '쿠팡', 'https://link.coupang.com/a/example22', TRUE),
('GPU-NV-000003',   459000,  '쿠팡', 'https://link.coupang.com/a/example23', TRUE),
('GPU-NV-000004',     589000,  '쿠팡', 'https://link.coupang.com/a/example24', TRUE),
('GPU-NV-000005',   679000,  '쿠팡', 'https://link.coupang.com/a/example25', TRUE),
('GPU-NV-000006',     899000,  '쿠팡', 'https://link.coupang.com/a/example26', FALSE),
('GPU-NV-000007',     1450000, '쿠팡', 'https://link.coupang.com/a/example27', FALSE),
('GPU-NV-000008',     385000,  '쿠팡', 'https://link.coupang.com/a/example28', TRUE),
('GPU-NV-000009',   529000,  '쿠팡', 'https://link.coupang.com/a/example29', TRUE),
('GPU-NV-000010',     749000,  '쿠팡', 'https://link.coupang.com/a/example30', TRUE),
('GPU-NV-000011',    849000,  '쿠팡', 'https://link.coupang.com/a/example31', TRUE),
('GPU-NV-000012',   1099000, '쿠팡', 'https://link.coupang.com/a/example32', TRUE),
('GPU-NV-000013',  1249000, '쿠팡', 'https://link.coupang.com/a/example33', TRUE),
('GPU-NV-000014',     1690000, '쿠팡', 'https://link.coupang.com/a/example34', TRUE),
('GPU-NV-000015',    1599000, '쿠팡', 'https://link.coupang.com/a/example35', TRUE),
('GPU-NV-000016',     2890000, '쿠팡', 'https://link.coupang.com/a/example36', TRUE),
('GPU-AMD-000001',    309000,  '쿠팡', 'https://link.coupang.com/a/example37', TRUE),
('GPU-AMD-000002',  519000,  '쿠팡', 'https://link.coupang.com/a/example38', TRUE),
('GPU-AMD-000003',  789000,  '쿠팡', 'https://link.coupang.com/a/example39', FALSE),
('GPU-AMD-000004',  649000,  '쿠팡', 'https://link.coupang.com/a/example40', TRUE),
('GPU-AMD-000005',  789000,  '쿠팡', 'https://link.coupang.com/a/example41', TRUE),
('GPU-AMD-000006', 1399000, '쿠팡', 'https://link.coupang.com/a/example42', TRUE),
-- RAM
('RAM-SAMS-000001', 49000,  '쿠팡', 'https://link.coupang.com/a/example43', TRUE),
('RAM-SAMS-000002', 95000,  '쿠팡', 'https://link.coupang.com/a/example44', TRUE),
('RAM-CRUC-000001', 55000,  '쿠팡', 'https://link.coupang.com/a/example45', TRUE),
('RAM-GSKL-000001', 79000,  '쿠팡', 'https://link.coupang.com/a/example46', TRUE),
('RAM-GSKL-000002', 135000, '쿠팡', 'https://link.coupang.com/a/example47', TRUE),
('RAM-CORS-000001', 75000,  '쿠팡', 'https://link.coupang.com/a/example48', TRUE),
('RAM-CORS-000002', 145000, '쿠팡', 'https://link.coupang.com/a/example49', TRUE),
('RAM-TFOR-000001', 65000,  '쿠팡', 'https://link.coupang.com/a/example50', TRUE),
('RAM-SAMS-000003', 89000,  '쿠팡', 'https://link.coupang.com/a/example51', TRUE),
('RAM-SAMS-000004', 169000, '쿠팡', 'https://link.coupang.com/a/example52', TRUE),
('RAM-GSKL-000003', 109000, '쿠팡', 'https://link.coupang.com/a/example53', TRUE),
('RAM-GSKL-000004', 195000, '쿠팡', 'https://link.coupang.com/a/example54', TRUE),
('RAM-GSKL-000005', 225000, '쿠팡', 'https://link.coupang.com/a/example55', TRUE),
('RAM-GSKL-000006', 389000, '쿠팡', 'https://link.coupang.com/a/example56', TRUE),
('RAM-CORS-000003', 185000, '쿠팡', 'https://link.coupang.com/a/example57', TRUE),
('RAM-CORS-000004', 215000, '쿠팡', 'https://link.coupang.com/a/example58', TRUE),
('RAM-CORS-000005', 449000, '쿠팡', 'https://link.coupang.com/a/example59', TRUE),
('RAM-KING-000001', 165000, '쿠팡', 'https://link.coupang.com/a/example60', TRUE),
('RAM-CRUC-000002', 155000, '쿠팡', 'https://link.coupang.com/a/example61', TRUE),
('RAM-TFOR-000002', 175000, '쿠팡', 'https://link.coupang.com/a/example62', TRUE),
-- MB
('MB-ASUS-000001',  159000, '쿠팡', 'https://link.coupang.com/a/example63', TRUE),
('MB-ASUS-000002', 369000, '쿠팡', 'https://link.coupang.com/a/example64', TRUE),
('MB-ASUS-000003',  189000, '쿠팡', 'https://link.coupang.com/a/example65', TRUE),
('MB-ASUS-000004', 425000, '쿠팡', 'https://link.coupang.com/a/example66', TRUE),
('MB-ASUS-000005',  595000, '쿠팡', 'https://link.coupang.com/a/example67', TRUE),
('MB-ASUS-000006',   295000, '쿠팡', 'https://link.coupang.com/a/example68', TRUE),
('MB-MSI-000001',    149000, '쿠팡', 'https://link.coupang.com/a/example69', TRUE),
('MB-MSI-000002',    355000, '쿠팡', 'https://link.coupang.com/a/example70', TRUE),
('MB-MSI-000003',    265000, '쿠팡', 'https://link.coupang.com/a/example71', TRUE),
('MB-MSI-000004',    389000, '쿠팡', 'https://link.coupang.com/a/example72', TRUE),
('MB-MSI-000005',   695000, '쿠팡', 'https://link.coupang.com/a/example73', TRUE),
('MB-MSI-000006',    315000, '쿠팡', 'https://link.coupang.com/a/example74', TRUE),
('MB-GBYT-000001',   175000, '쿠팡', 'https://link.coupang.com/a/example75', TRUE),
('MB-GBYT-000002',   349000, '쿠팡', 'https://link.coupang.com/a/example76', TRUE),
('MB-GBYT-000003',  695000, '쿠팡', 'https://link.coupang.com/a/example77', TRUE),
('MB-GBYT-000004',   289000, '쿠팡', 'https://link.coupang.com/a/example78', TRUE),
('MB-ASRK-000001',   165000, '쿠팡', 'https://link.coupang.com/a/example79', TRUE),
('MB-ASRK-000002',   325000, '쿠팡', 'https://link.coupang.com/a/example80', TRUE),
('MB-ASUS-000007',   175000, '쿠팡', 'https://link.coupang.com/a/example81', TRUE),
('MB-ASUS-000008',   245000, '쿠팡', 'https://link.coupang.com/a/example82', TRUE),
('MB-MSI-000007',    185000, '쿠팡', 'https://link.coupang.com/a/example83', TRUE),
('MB-GBYT-000005',   229000, '쿠팡', 'https://link.coupang.com/a/example84', TRUE),
-- SSD
('SSD-SAMS-000001',  59000,  '쿠팡', 'https://link.coupang.com/a/example85',  TRUE),
('SSD-SAMS-000002',   95000,  '쿠팡', 'https://link.coupang.com/a/example86',  TRUE),
('SSD-SAMS-000003',  145000, '쿠팡', 'https://link.coupang.com/a/example87',  TRUE),
('SSD-SAMS-000004',  255000, '쿠팡', 'https://link.coupang.com/a/example88',  TRUE),
('SSD-SAMS-000005',  165000, '쿠팡', 'https://link.coupang.com/a/example89',  TRUE),
('SSD-SAMS-000006',  289000, '쿠팡', 'https://link.coupang.com/a/example90',  TRUE),
('SSD-SAMS-000007',  579000, '쿠팡', 'https://link.coupang.com/a/example91',  TRUE),
('SSD-SAMS-000008',  119000, '쿠팡', 'https://link.coupang.com/a/example92',  TRUE),
('SSD-WD-000001',   89000,  '쿠팡', 'https://link.coupang.com/a/example93',  TRUE),
('SSD-WD-000002',  139000, '쿠팡', 'https://link.coupang.com/a/example94',  TRUE),
('SSD-WD-000003',  249000, '쿠팡', 'https://link.coupang.com/a/example95',  TRUE),
('SSD-SK-000001',     129000, '쿠팡', 'https://link.coupang.com/a/example96',  TRUE),
('SSD-SK-000002',     239000, '쿠팡', 'https://link.coupang.com/a/example97',  TRUE),
('SSD-CRUC-000001',   99000,  '쿠팡', 'https://link.coupang.com/a/example98',  TRUE),
('SSD-CRUC-000002',  225000, '쿠팡', 'https://link.coupang.com/a/example99',  TRUE),
('SSD-KING-000001',  119000, '쿠팡', 'https://link.coupang.com/a/example100', TRUE),
('SSD-KING-000002',   75000,  '쿠팡', 'https://link.coupang.com/a/example101', TRUE),
('SSD-SOLI-000001',   115000, '쿠팡', 'https://link.coupang.com/a/example102', TRUE),
('SSD-TFOR-000001',  109000, '쿠팡', 'https://link.coupang.com/a/example103', TRUE),
('SSD-SAMS-000009',  219000, '쿠팡', 'https://link.coupang.com/a/example104', TRUE),
-- PSU
('PSU-CORS-000001',     99000,  '쿠팡', 'https://link.coupang.com/a/example105', TRUE),
('PSU-CORS-000002',     115000, '쿠팡', 'https://link.coupang.com/a/example106', TRUE),
('PSU-CORS-000003',     145000, '쿠팡', 'https://link.coupang.com/a/example107', TRUE),
('PSU-CORS-000004',     179000, '쿠팡', 'https://link.coupang.com/a/example108', TRUE),
('PSU-CORS-000005',    229000, '쿠팡', 'https://link.coupang.com/a/example109', TRUE),
('PSU-CORS-000006',     289000, '쿠팡', 'https://link.coupang.com/a/example110', TRUE),
('PSU-SEAS-000001',  119000, '쿠팡', 'https://link.coupang.com/a/example111', TRUE),
('PSU-SEAS-000002',  149000, '쿠팡', 'https://link.coupang.com/a/example112', TRUE),
('PSU-SEAS-000003',  185000, '쿠팡', 'https://link.coupang.com/a/example113', TRUE),
('PSU-SEAS-000004', 359000, '쿠팡', 'https://link.coupang.com/a/example114', TRUE),
('PSU-MSI-000001',     69000,  '쿠팡', 'https://link.coupang.com/a/example115', TRUE),
('PSU-MSI-000002',     129000, '쿠팡', 'https://link.coupang.com/a/example116', TRUE),
('PSU-MSI-000003',    279000, '쿠팡', 'https://link.coupang.com/a/example117', TRUE),
('PSU-EVGA-000001',     139000, '쿠팡', 'https://link.coupang.com/a/example118', TRUE),
('PSU-EVGA-000002',     175000, '쿠팡', 'https://link.coupang.com/a/example119', TRUE),
('PSU-FSP-000001',   95000,  '쿠팡', 'https://link.coupang.com/a/example120', TRUE),
('PSU-FSP-000002',   145000, '쿠팡', 'https://link.coupang.com/a/example121', TRUE),
('PSU-BEQ-000001',    129000, '쿠팡', 'https://link.coupang.com/a/example122', TRUE),
('PSU-BEQ-000002',299000,'쿠팡', 'https://link.coupang.com/a/example123', TRUE),
('PSU-COOL-000001',    89000,  '쿠팡', 'https://link.coupang.com/a/example124', TRUE),
-- CASE
('CASE-LANL-000001',     115000, '쿠팡', 'https://link.coupang.com/a/example125', TRUE),
('CASE-LANL-000002',    229000, '쿠팡', 'https://link.coupang.com/a/example126', TRUE),
('CASE-LANL-000003',    175000, '쿠팡', 'https://link.coupang.com/a/example127', TRUE),
('CASE-COOL-000001',  149000, '쿠팡', 'https://link.coupang.com/a/example128', TRUE),
('CASE-COOL-000002',   119000, '쿠팡', 'https://link.coupang.com/a/example129', TRUE),
('CASE-COOL-000003',  489000, '쿠팡', 'https://link.coupang.com/a/example130', TRUE),
('CASE-FRAC-000001',  175000, '쿠팡', 'https://link.coupang.com/a/example131', TRUE),
('CASE-FRAC-000002',   229000, '쿠팡', 'https://link.coupang.com/a/example132', TRUE),
('CASE-FRAC-000003', 269000, '쿠팡', 'https://link.coupang.com/a/example133', TRUE),
('CASE-NZXT-000001',    99000,  '쿠팡', 'https://link.coupang.com/a/example134', TRUE),
('CASE-NZXT-000002',      189000, '쿠팡', 'https://link.coupang.com/a/example135', TRUE),
('CASE-NZXT-000003',      295000, '쿠팡', 'https://link.coupang.com/a/example136', TRUE),
('CASE-CORS-000001',   119000, '쿠팡', 'https://link.coupang.com/a/example137', TRUE),
('CASE-CORS-000002',   189000, '쿠팡', 'https://link.coupang.com/a/example138', TRUE),
('CASE-CORS-000003',   359000, '쿠팡', 'https://link.coupang.com/a/example139', TRUE),
('CASE-PHAN-000001',   95000,  '쿠팡', 'https://link.coupang.com/a/example140', TRUE),
('CASE-PHAN-000002',   175000, '쿠팡', 'https://link.coupang.com/a/example141', TRUE),
('CASE-DEEP-000001',   89000,  '쿠팡', 'https://link.coupang.com/a/example142', TRUE),
('CASE-DEEP-000002',   119000, '쿠팡', 'https://link.coupang.com/a/example143', TRUE),
('CASE-BEQ-000001',    115000, '쿠팡', 'https://link.coupang.com/a/example144', TRUE);


-- ============================================================
-- USE_CASE_PROFILE (목적 → 요구사양 매핑)
-- 사업계획서 MVP: Top 10 게임 + 기본 사무 + 영상편집
-- ============================================================

INSERT INTO use_case_profile
  (use_case_id, display_name, category, cpu_req_score, gpu_req_score, ram_gb_req, vram_gb_req, storage_type, extra_req, confidence) VALUES
-- Gaming
('valorant_1440p_144fps',    '발로란트 1440p 144fps',           'gaming',       22000, 18000, 16, 8,  'nvme', '{"genre":"FPS","target_fps":144,"target_resolution":"1440p"}'::jsonb, 1),
('valorant_1080p_240fps',    '발로란트 1080p 240fps',           'gaming',       28000, 22000, 16, 8,  'nvme', '{"genre":"FPS","target_fps":240,"target_resolution":"1080p"}'::jsonb, 1),
('lol_1080p_144fps',         '리그오브레전드 1080p 144fps',     'gaming',       15000, 10000, 16, 4,  'sata_ssd', '{"genre":"MOBA","target_fps":144}'::jsonb, 1),
('lol_1440p_144fps',         '리그오브레전드 1440p 144fps',     'gaming',       18000, 14000, 16, 6,  'nvme', '{"genre":"MOBA","target_fps":144}'::jsonb, 1),
('overwatch_1440p_144fps',   '오버워치 1440p 144fps',           'gaming',       20000, 17000, 16, 8,  'nvme', '{"genre":"FPS","target_fps":144}'::jsonb, 1),
('cyberpunk_1440p_60fps',    '사이버펑크 2077 1440p 60fps',     'gaming',       25000, 28000, 32, 12, 'nvme', '{"target_fps":60,"target_resolution":"1440p","raytracing":true}'::jsonb, 1),
('cyberpunk_4k_60fps',       '사이버펑크 2077 4K 60fps',        'gaming',       28000, 38000, 32, 16, 'nvme', '{"target_fps":60,"target_resolution":"4k","raytracing":true}'::jsonb, 1),
('starfield_1440p_60fps',    '스타필드 1440p 60fps',            'gaming',       28000, 26000, 32, 12, 'nvme', '{"target_fps":60,"target_resolution":"1440p"}'::jsonb, 1),
('eldenring_1440p_60fps',    '엘든링 1440p 60fps',              'gaming',       22000, 22000, 16, 8,  'nvme', '{"target_fps":60,"target_resolution":"1440p"}'::jsonb, 1),
('minecraft_modded_1440p',   '마인크래프트 (모드팩) 1440p',     'gaming',       30000, 18000, 32, 8,  'nvme', '{"target_fps":144,"shaders":true}'::jsonb, 1),
-- Productivity
('office_general',           '일반 사무 / 웹서핑',              'productivity', 8000,  3000,  16, 0,  'sata_ssd', '{}'::jsonb, 1),
('coding_general',           '코딩 / 개발 (IDE, 컴파일)',       'productivity', 18000, 5000,  16, 0,  'nvme', '{"compile":true}'::jsonb, 1),
('coding_heavy',             '코딩 / 도커 + 가상머신',          'productivity', 25000, 5000,  32, 0,  'nvme', '{"containers":true,"vm":true}'::jsonb, 1),
('data_analysis',            '데이터 분석 (Pandas, R)',         'productivity', 25000, 8000,  32, 0,  'nvme', '{"large_dataset":true}'::jsonb, 1),
-- Creative
('photoshop_pro',            '포토샵 전문 작업',                'creative',     22000, 15000, 32, 8,  'nvme', '{}'::jsonb, 1),
('premiere_1080p_edit',      '프리미어 1080p 영상편집',         'creative',     25000, 18000, 32, 8,  'nvme', '{"resolution":"1080p"}'::jsonb, 1),
('premiere_4k_edit',         '프리미어 4K 영상편집',            'creative',     35000, 28000, 32, 12, 'nvme', '{"resolution":"4k"}'::jsonb, 1),
('davinci_4k_color',         '다빈치 리졸브 4K 컬러 그레이딩',  'creative',     30000, 30000, 64, 16, 'nvme', '{"resolution":"4k","color_grading":true}'::jsonb, 1),
('blender_render',           '블렌더 3D 렌더링',                'creative',     35000, 30000, 32, 12, 'nvme', '{"3d_rendering":true}'::jsonb, 1),
-- AI/ML
('llm_inference_small',      '로컬 LLM 추론 (7B 모델)',         'ai_ml',        20000, 25000, 32, 12, 'nvme', '{"model_size_b":7}'::jsonb, 1),
('llm_inference_medium',     '로컬 LLM 추론 (13B~30B)',         'ai_ml',        25000, 35000, 32, 24, 'nvme', '{"model_size_b":30}'::jsonb, 1),
('stable_diffusion',         'Stable Diffusion 이미지 생성',    'ai_ml',        20000, 25000, 32, 12, 'nvme', '{}'::jsonb, 1),
-- General
('streaming_obs',            '게임 스트리밍 (OBS + 게임)',      'general',      30000, 22000, 32, 8,  'nvme', '{"encoding":"NVENC"}'::jsonb, 1);


-- ============================================================
-- COMPAT_EXCEPTION (호환성 예외 - 규칙으로 못 잡는 진짜 예외만)
-- 알파벳 순으로 uid_a < uid_b 유지 (CHECK 제약)
-- ============================================================

INSERT INTO compat_exception (uid_a, uid_b, verdict, severity, reason, source) VALUES
-- AM4 Ryzen 5800X3D는 일부 B450 보드에서 BIOS 업데이트 필요
('CPU-AMD-000003', 'MB-ASUS-000007', 'requires_action', 2,
 'B550 보드에서 5800X3D 사용 시 BIOS 1601 이상 권장. 출시 초기 보드는 BIOS 업데이트 필수.', '제조사 호환성 가이드'),
-- (구 항목 삭제됨 v1.0.2)
--   MB-ASUS-000001 ↔ RAM-SAMS-000003/000004 (DDR4 보드 + DDR5 RAM)
--   이유: ram_type 매칭으로 호환 쿼리에서 자동 차단되므로
--   "규칙으로 잡히지 않는 진짜 예외만"이라는 compat_exception 설계 원칙 위반.
-- RTX 4090 + 850W PSU는 권장 안 함 (4090은 1000W 권장)
('GPU-NV-000016', 'PSU-CORS-000004', 'warning', 2,
 'RTX 4090 사용 시 1000W 이상 PSU 권장. 850W는 트랜시언트 스파이크 시 셧다운 위험.', 'NVIDIA 권장 사양'),
('GPU-NV-000016', 'PSU-EVGA-000002', 'warning', 2,
 'RTX 4090 사용 시 1000W 이상 PSU 권장. 850W는 트랜시언트 스파이크 시 셧다운 위험.', 'NVIDIA 권장 사양'),
('GPU-NV-000016', 'PSU-FSP-000002', 'warning', 2,
 'RTX 4090 사용 시 1000W 이상 PSU 권장. 850W는 트랜시언트 스파이크 시 셧다운 위험.', 'NVIDIA 권장 사양'),
('GPU-NV-000016', 'PSU-SEAS-000003', 'warning', 2,
 'RTX 4090 사용 시 1000W 이상 PSU 권장. 850W는 트랜시언트 스파이크 시 셧다운 위험.', 'NVIDIA 권장 사양');
