-- ============================================================
-- 시드 데이터 #1: PART_ID
-- 카테고리별 20~25개 부품 (총 약 160개)
-- ============================================================

-- ============================================================
-- CPU (20개) — Intel 12~14세대, AMD Ryzen 5000~7000
-- ============================================================
INSERT INTO part_id (uid, model_name, category, manufacturer, released_at, aliases) VALUES
('CPU-INTL-000001',  'Intel Core i3-12100F',    'CPU', 'Intel', '2022-01-04', ARRAY['i3-12100F', '12100F', '인텔 i3 12100F']),
('CPU-INTL-000002',  'Intel Core i5-12400F',    'CPU', 'Intel', '2022-01-04', ARRAY['i5-12400F', '12400F', '인텔 i5 12400F']),
('CPU-INTL-000003',  'Intel Core i5-12600K',    'CPU', 'Intel', '2021-11-04', ARRAY['i5-12600K', '12600K']),
('CPU-INTL-000004',  'Intel Core i7-12700K',    'CPU', 'Intel', '2021-11-04', ARRAY['i7-12700K', '12700K']),
('CPU-INTL-000005',  'Intel Core i5-13400F',    'CPU', 'Intel', '2023-01-03', ARRAY['i5-13400F', '13400F']),
('CPU-INTL-000006',  'Intel Core i5-13600K',    'CPU', 'Intel', '2022-10-20', ARRAY['i5-13600K', '13600K']),
('CPU-INTL-000007',  'Intel Core i7-13700K',    'CPU', 'Intel', '2022-10-20', ARRAY['i7-13700K', '13700K']),
('CPU-INTL-000008',  'Intel Core i9-13900K',    'CPU', 'Intel', '2022-10-20', ARRAY['i9-13900K', '13900K']),
('CPU-INTL-000009',  'Intel Core i5-14400F',    'CPU', 'Intel', '2024-01-08', ARRAY['i5-14400F', '14400F']),
('CPU-INTL-000010',  'Intel Core i5-14600K',    'CPU', 'Intel', '2023-10-17', ARRAY['i5-14600K', '14600K']),
('CPU-INTL-000011',  'Intel Core i7-14700K',    'CPU', 'Intel', '2023-10-17', ARRAY['i7-14700K', '14700K']),
('CPU-INTL-000012',  'Intel Core i9-14900K',    'CPU', 'Intel', '2023-10-17', ARRAY['i9-14900K', '14900K']),
('CPU-AMD-000001',     'AMD Ryzen 5 5600',        'CPU', 'AMD',   '2022-04-04', ARRAY['Ryzen 5600', '라이젠 5600']),
('CPU-AMD-000002',    'AMD Ryzen 7 5700X',       'CPU', 'AMD',   '2022-04-04', ARRAY['Ryzen 5700X', '라이젠 5700X']),
('CPU-AMD-000003',  'AMD Ryzen 7 5800X3D',     'CPU', 'AMD',   '2022-04-20', ARRAY['Ryzen 5800X3D', '5800X3D']),
('CPU-AMD-000004',     'AMD Ryzen 5 7600',        'CPU', 'AMD',   '2023-01-10', ARRAY['Ryzen 7600', '라이젠 7600']),
('CPU-AMD-000005',    'AMD Ryzen 5 7600X',       'CPU', 'AMD',   '2022-09-27', ARRAY['Ryzen 7600X', '7600X']),
('CPU-AMD-000006',    'AMD Ryzen 7 7700X',       'CPU', 'AMD',   '2022-09-27', ARRAY['Ryzen 7700X', '7700X']),
('CPU-AMD-000007',  'AMD Ryzen 7 7800X3D',     'CPU', 'AMD',   '2023-04-06', ARRAY['Ryzen 7800X3D', '7800X3D']),
('CPU-AMD-000008',    'AMD Ryzen 9 7950X',       'CPU', 'AMD',   '2022-09-27', ARRAY['Ryzen 7950X', '7950X']);


-- ============================================================
-- GPU (22개) — NVIDIA RTX 30/40 시리즈, AMD RX 6000/7000
-- ============================================================
INSERT INTO part_id (uid, model_name, category, manufacturer, released_at, aliases) VALUES
('GPU-NV-000001',      'NVIDIA GeForce RTX 3050 8GB',   'GPU', 'NVIDIA', '2022-01-27', ARRAY['RTX 3050', '지포스 3050']),
('GPU-NV-000002',      'NVIDIA GeForce RTX 3060 12GB',  'GPU', 'NVIDIA', '2021-02-25', ARRAY['RTX 3060', '지포스 3060', '3060 12GB']),
('GPU-NV-000003',    'NVIDIA GeForce RTX 3060 Ti',    'GPU', 'NVIDIA', '2020-12-02', ARRAY['RTX 3060 Ti', '3060Ti']),
('GPU-NV-000004',      'NVIDIA GeForce RTX 3070',       'GPU', 'NVIDIA', '2020-10-29', ARRAY['RTX 3070', '지포스 3070']),
('GPU-NV-000005',    'NVIDIA GeForce RTX 3070 Ti',    'GPU', 'NVIDIA', '2021-06-10', ARRAY['RTX 3070 Ti', '3070Ti']),
('GPU-NV-000006',      'NVIDIA GeForce RTX 3080 10GB',  'GPU', 'NVIDIA', '2020-09-17', ARRAY['RTX 3080', '지포스 3080']),
('GPU-NV-000007',      'NVIDIA GeForce RTX 3090',       'GPU', 'NVIDIA', '2020-09-24', ARRAY['RTX 3090', '지포스 3090']),
('GPU-NV-000008',      'NVIDIA GeForce RTX 4060 8GB',   'GPU', 'NVIDIA', '2023-06-29', ARRAY['RTX 4060', '지포스 4060']),
('GPU-NV-000009',    'NVIDIA GeForce RTX 4060 Ti 8GB','GPU', 'NVIDIA', '2023-05-24', ARRAY['RTX 4060 Ti', '4060Ti']),
('GPU-NV-000010',      'NVIDIA GeForce RTX 4070',       'GPU', 'NVIDIA', '2023-04-13', ARRAY['RTX 4070', '지포스 4070']),
('GPU-NV-000011',     'NVIDIA GeForce RTX 4070 SUPER', 'GPU', 'NVIDIA', '2024-01-17', ARRAY['RTX 4070 Super', '4070S', '지포스 4070 슈퍼']),
('GPU-NV-000012',    'NVIDIA GeForce RTX 4070 Ti',    'GPU', 'NVIDIA', '2023-01-05', ARRAY['RTX 4070 Ti', '4070Ti']),
('GPU-NV-000013',   'NVIDIA GeForce RTX 4070 Ti SUPER','GPU','NVIDIA','2024-01-24', ARRAY['RTX 4070 Ti Super', '4070TiS']),
('GPU-NV-000014',      'NVIDIA GeForce RTX 4080',       'GPU', 'NVIDIA', '2022-11-16', ARRAY['RTX 4080', '지포스 4080']),
('GPU-NV-000015',     'NVIDIA GeForce RTX 4080 SUPER', 'GPU', 'NVIDIA', '2024-01-31', ARRAY['RTX 4080 Super', '4080S']),
('GPU-NV-000016',      'NVIDIA GeForce RTX 4090',       'GPU', 'NVIDIA', '2022-10-12', ARRAY['RTX 4090', '지포스 4090']),
('GPU-AMD-000001',     'AMD Radeon RX 6600',            'GPU', 'AMD',    '2021-10-13', ARRAY['RX 6600', '라데온 6600']),
('GPU-AMD-000002',   'AMD Radeon RX 6700 XT',         'GPU', 'AMD',    '2021-03-18', ARRAY['RX 6700 XT', '6700XT']),
('GPU-AMD-000003',   'AMD Radeon RX 6800 XT',         'GPU', 'AMD',    '2020-11-18', ARRAY['RX 6800 XT', '6800XT']),
('GPU-AMD-000004',   'AMD Radeon RX 7700 XT',         'GPU', 'AMD',    '2023-09-06', ARRAY['RX 7700 XT', '7700XT']),
('GPU-AMD-000005',   'AMD Radeon RX 7800 XT',         'GPU', 'AMD',    '2023-09-06', ARRAY['RX 7800 XT', '7800XT']),
('GPU-AMD-000006',  'AMD Radeon RX 7900 XTX',        'GPU', 'AMD',    '2022-12-13', ARRAY['RX 7900 XTX', '7900XTX']);


-- ============================================================
-- RAM (20개) — DDR4 + DDR5, 다양한 용량/속도
-- ============================================================
INSERT INTO part_id (uid, model_name, category, manufacturer, released_at, aliases) VALUES
('RAM-SAMS-000001',  'Samsung DDR4 16GB 3200MHz',           'RAM', 'Samsung',     '2020-01-01', ARRAY['삼성 DDR4 16GB 3200']),
('RAM-SAMS-000002',  'Samsung DDR4 32GB 3200MHz Kit',       'RAM', 'Samsung',     '2020-01-01', ARRAY['삼성 DDR4 32GB 3200']),
('RAM-CRUC-000001',  'Crucial DDR4 16GB 3200MHz',           'RAM', 'Crucial',     '2020-06-01', ARRAY['크루셜 DDR4 16GB']),
('RAM-GSKL-000001',  'G.Skill Ripjaws V DDR4 16GB 3600',    'RAM', 'G.Skill',     '2020-03-01', ARRAY['지스킬 립죠스 16GB']),
('RAM-GSKL-000002',  'G.Skill Ripjaws V DDR4 32GB 3600 Kit','RAM', 'G.Skill',     '2020-03-01', ARRAY['지스킬 립죠스 32GB']),
('RAM-CORS-000001',  'Corsair Vengeance LPX DDR4 16GB 3200','RAM', 'Corsair',     '2019-05-01', ARRAY['커세어 벤전스 16GB']),
('RAM-CORS-000002',  'Corsair Vengeance LPX DDR4 32GB 3600','RAM', 'Corsair',     '2019-05-01', ARRAY['커세어 벤전스 32GB']),
('RAM-TFOR-000001',  'TeamGroup T-Force DDR4 16GB 3200',    'RAM', 'TeamGroup',   '2020-01-01', ARRAY['팀그룹 16GB']),
('RAM-SAMS-000003',  'Samsung DDR5 16GB 4800MHz',           'RAM', 'Samsung',     '2022-01-01', ARRAY['삼성 DDR5 16GB 4800']),
('RAM-SAMS-000004',  'Samsung DDR5 32GB 4800MHz Kit',       'RAM', 'Samsung',     '2022-01-01', ARRAY['삼성 DDR5 32GB 4800']),
('RAM-GSKL-000003',  'G.Skill Trident Z5 DDR5 16GB 5600',   'RAM', 'G.Skill',     '2022-04-01', ARRAY['지스킬 Z5 16GB 5600']),
('RAM-GSKL-000004',  'G.Skill Trident Z5 DDR5 32GB 6000 Kit','RAM','G.Skill',     '2022-08-01', ARRAY['지스킬 Z5 32GB 6000']),
('RAM-GSKL-000005',  'G.Skill Trident Z5 DDR5 32GB 6400 Kit','RAM','G.Skill',     '2023-01-01', ARRAY['지스킬 Z5 32GB 6400']),
('RAM-GSKL-000006',  'G.Skill Trident Z5 DDR5 64GB 6000 Kit','RAM','G.Skill',     '2023-03-01', ARRAY['지스킬 Z5 64GB 6000']),
('RAM-CORS-000003',  'Corsair Vengeance DDR5 32GB 5600 Kit','RAM','Corsair',      '2022-09-01', ARRAY['커세어 벤전스 DDR5 32GB']),
('RAM-CORS-000004',  'Corsair Vengeance DDR5 32GB 6000 Kit','RAM','Corsair',      '2023-01-01', ARRAY['커세어 벤전스 DDR5 32GB 6000']),
('RAM-CORS-000005',  'Corsair Dominator DDR5 64GB 6400 Kit','RAM','Corsair',      '2023-05-01', ARRAY['커세어 도미네이터 64GB']),
('RAM-KING-000001',  'Kingston Fury Beast DDR5 32GB 5600',  'RAM','Kingston',     '2022-10-01', ARRAY['킹스턴 퓨리 32GB']),
('RAM-CRUC-000002',  'Crucial DDR5 32GB 5200 Kit',          'RAM','Crucial',      '2022-09-01', ARRAY['크루셜 DDR5 32GB 5200']),
('RAM-TFOR-000002',  'TeamGroup T-Force Delta DDR5 32GB 6000','RAM','TeamGroup',  '2023-02-01', ARRAY['팀그룹 델타 32GB']);


-- ============================================================
-- MB (메인보드, 22개) — LGA1700 + AM5 + AM4
-- ============================================================
INSERT INTO part_id (uid, model_name, category, manufacturer, released_at, aliases) VALUES
('MB-ASUS-000001',     'ASUS PRIME B660M-A',           'MB', 'ASUS',     '2022-01-04', ARRAY['B660M-A', 'ASUS B660']),
('MB-ASUS-000002',    'ASUS PRIME Z690-A',            'MB', 'ASUS',     '2021-11-04', ARRAY['Z690-A', 'ASUS Z690']),
('MB-ASUS-000003',     'ASUS PRIME B760M-A',           'MB', 'ASUS',     '2023-01-03', ARRAY['B760M-A']),
('MB-ASUS-000004',    'ASUS PRIME Z790-A',            'MB', 'ASUS',     '2022-10-20', ARRAY['Z790-A', 'ASUS Z790']),
('MB-ASUS-000005',     'ASUS ROG Strix X670E-A',       'MB', 'ASUS',     '2022-09-27', ARRAY['X670E', 'ROG X670E']),
('MB-ASUS-000006',      'ASUS TUF GAMING B650-PLUS',    'MB', 'ASUS',     '2022-10-04', ARRAY['B650-PLUS', 'TUF B650']),
('MB-MSI-000001',       'MSI PRO B660M-A',              'MB', 'MSI',      '2022-01-04', ARRAY['MSI B660M-A']),
('MB-MSI-000002',       'MSI MAG Z690 TOMAHAWK',        'MB', 'MSI',      '2021-11-04', ARRAY['MSI Z690 토마호크']),
('MB-MSI-000003',       'MSI MAG B760 TOMAHAWK',        'MB', 'MSI',      '2023-01-03', ARRAY['MSI B760 토마호크']),
('MB-MSI-000004',       'MSI MAG Z790 TOMAHAWK',        'MB', 'MSI',      '2022-10-20', ARRAY['MSI Z790 토마호크']),
('MB-MSI-000005',      'MSI MEG X670E ACE',            'MB', 'MSI',      '2022-09-27', ARRAY['MSI X670E ACE']),
('MB-MSI-000006',       'MSI MAG B650 TOMAHAWK',        'MB', 'MSI',      '2022-10-10', ARRAY['MSI B650 토마호크']),
('MB-GBYT-000001',      'GIGABYTE B760M AORUS Elite',   'MB', 'GIGABYTE', '2023-01-03', ARRAY['기가바이트 B760M']),
('MB-GBYT-000002',      'GIGABYTE Z790 AORUS Elite AX', 'MB', 'GIGABYTE', '2022-10-20', ARRAY['기가바이트 Z790']),
('MB-GBYT-000003',     'GIGABYTE X670E AORUS Master',  'MB', 'GIGABYTE', '2022-09-27', ARRAY['기가바이트 X670E']),
('MB-GBYT-000004',      'GIGABYTE B650 AORUS Elite AX', 'MB', 'GIGABYTE', '2022-10-10', ARRAY['기가바이트 B650']),
('MB-ASRK-000001',      'ASRock B760M Pro RS',          'MB', 'ASRock',   '2023-01-03', ARRAY['ASRock B760M']),
('MB-ASRK-000002',      'ASRock Z790 Steel Legend',     'MB', 'ASRock',   '2022-10-20', ARRAY['ASRock Z790']),
('MB-ASUS-000007',      'ASUS TUF GAMING B550-PLUS',    'MB', 'ASUS',     '2020-06-16', ARRAY['B550-PLUS', 'AM4 B550']),
('MB-ASUS-000008',      'ASUS PRIME X570-P',            'MB', 'ASUS',     '2019-07-07', ARRAY['X570-P', 'AM4 X570']),
('MB-MSI-000007',       'MSI MAG B550 TOMAHAWK',        'MB', 'MSI',      '2020-06-16', ARRAY['MSI B550 토마호크']),
('MB-GBYT-000005',      'GIGABYTE X570 AORUS Elite',    'MB', 'GIGABYTE', '2019-07-07', ARRAY['기가바이트 X570']);


-- ============================================================
-- SSD (20개) — NVMe + SATA
-- ============================================================
INSERT INTO part_id (uid, model_name, category, manufacturer, released_at, aliases) VALUES
('SSD-SAMS-000001',    'Samsung 980 NVMe 500GB',       'SSD', 'Samsung',  '2021-03-26', ARRAY['삼성 980 500GB']),
('SSD-SAMS-000002',     'Samsung 980 NVMe 1TB',         'SSD', 'Samsung',  '2021-03-26', ARRAY['삼성 980 1TB']),
('SSD-SAMS-000003',    'Samsung 980 PRO NVMe 1TB',     'SSD', 'Samsung',  '2020-09-22', ARRAY['삼성 980 PRO 1TB']),
('SSD-SAMS-000004',    'Samsung 980 PRO NVMe 2TB',     'SSD', 'Samsung',  '2021-06-01', ARRAY['삼성 980 PRO 2TB']),
('SSD-SAMS-000005',    'Samsung 990 PRO NVMe 1TB',     'SSD', 'Samsung',  '2022-10-01', ARRAY['삼성 990 PRO 1TB']),
('SSD-SAMS-000006',    'Samsung 990 PRO NVMe 2TB',     'SSD', 'Samsung',  '2022-10-01', ARRAY['삼성 990 PRO 2TB']),
('SSD-SAMS-000007',    'Samsung 990 PRO NVMe 4TB',     'SSD', 'Samsung',  '2023-10-01', ARRAY['삼성 990 PRO 4TB']),
('SSD-SAMS-000008',    'Samsung 870 EVO SATA 1TB',     'SSD', 'Samsung',  '2021-01-19', ARRAY['삼성 870 EVO 1TB']),
('SSD-WD-000001',     'WD Black SN770 NVMe 1TB',      'SSD', 'WD',       '2022-02-01', ARRAY['WD SN770 1TB']),
('SSD-WD-000002',    'WD Black SN850X NVMe 1TB',     'SSD', 'WD',       '2022-07-26', ARRAY['WD SN850X 1TB']),
('SSD-WD-000003',    'WD Black SN850X NVMe 2TB',     'SSD', 'WD',       '2022-07-26', ARRAY['WD SN850X 2TB']),
('SSD-SK-000001',       'SK Hynix Platinum P41 NVMe 1TB','SSD','SK Hynix', '2022-04-01', ARRAY['SK 하이닉스 P41 1TB']),
('SSD-SK-000002',       'SK Hynix Platinum P41 NVMe 2TB','SSD','SK Hynix', '2022-04-01', ARRAY['SK 하이닉스 P41 2TB']),
('SSD-CRUC-000001',     'Crucial P5 Plus NVMe 1TB',     'SSD', 'Crucial',  '2021-08-01', ARRAY['크루셜 P5 Plus 1TB']),
('SSD-CRUC-000002',    'Crucial T700 NVMe Gen5 1TB',   'SSD', 'Crucial',  '2023-05-01', ARRAY['크루셜 T700 1TB']),
('SSD-KING-000001',    'Kingston KC3000 NVMe 1TB',     'SSD', 'Kingston', '2022-01-01', ARRAY['킹스턴 KC3000 1TB']),
('SSD-KING-000002',     'Kingston NV2 NVMe 1TB',        'SSD', 'Kingston', '2022-08-01', ARRAY['킹스턴 NV2 1TB']),
('SSD-SOLI-000001',     'Solidigm P44 Pro NVMe 1TB',    'SSD', 'Solidigm', '2022-11-01', ARRAY['솔리다임 P44 Pro 1TB']),
('SSD-TFOR-000001',    'TeamGroup T-Force MP44 1TB',   'SSD', 'TeamGroup','2023-04-01', ARRAY['팀그룹 MP44 1TB']),
('SSD-SAMS-000009',    'Samsung 870 EVO SATA 2TB',     'SSD', 'Samsung',  '2021-01-19', ARRAY['삼성 870 EVO 2TB']);


-- ============================================================
-- PSU (20개) — 다양한 와트, 80+ 인증
-- ============================================================
INSERT INTO part_id (uid, model_name, category, manufacturer, released_at, aliases) VALUES
('PSU-CORS-000001',   'Corsair RM550x 550W 80+ Gold',           'PSU', 'Corsair',     '2021-04-01', ARRAY['커세어 RM550x']),
('PSU-CORS-000002',   'Corsair RM650x 650W 80+ Gold',           'PSU', 'Corsair',     '2021-04-01', ARRAY['커세어 RM650x']),
('PSU-CORS-000003',   'Corsair RM750x 750W 80+ Gold',           'PSU', 'Corsair',     '2021-04-01', ARRAY['커세어 RM750x']),
('PSU-CORS-000004',   'Corsair RM850x 850W 80+ Gold',           'PSU', 'Corsair',     '2021-04-01', ARRAY['커세어 RM850x']),
('PSU-CORS-000005',  'Corsair RM1000x 1000W 80+ Gold',         'PSU', 'Corsair',     '2021-04-01', ARRAY['커세어 RM1000x']),
('PSU-CORS-000006',   'Corsair HX1000 1000W 80+ Platinum',      'PSU', 'Corsair',     '2022-01-01', ARRAY['커세어 HX1000']),
('PSU-SEAS-000001','Seasonic FOCUS GX-650 650W 80+ Gold',    'PSU', 'Seasonic',    '2020-01-01', ARRAY['시소닉 포커스 650']),
('PSU-SEAS-000002','Seasonic FOCUS GX-750 750W 80+ Gold',    'PSU', 'Seasonic',    '2020-01-01', ARRAY['시소닉 포커스 750']),
('PSU-SEAS-000003','Seasonic FOCUS GX-850 850W 80+ Gold',    'PSU', 'Seasonic',    '2020-01-01', ARRAY['시소닉 포커스 850']),
('PSU-SEAS-000004','Seasonic PRIME TX-1000 1000W 80+ Titanium','PSU','Seasonic',  '2020-06-01', ARRAY['시소닉 프라임 1000']),
('PSU-MSI-000001',   'MSI MAG A650BN 650W 80+ Bronze',         'PSU', 'MSI',         '2022-01-01', ARRAY['MSI MAG 650']),
('PSU-MSI-000002',   'MSI MAG A750GL 750W 80+ Gold',           'PSU', 'MSI',         '2022-01-01', ARRAY['MSI MAG 750']),
('PSU-MSI-000003',  'MSI MEG Ai1000P 1000W 80+ Platinum ATX 3.0','PSU','MSI',       '2023-01-01', ARRAY['MSI MEG 1000']),
('PSU-EVGA-000001',   'EVGA SuperNOVA 750 G6 80+ Gold',         'PSU', 'EVGA',        '2021-06-01', ARRAY['EVGA G6 750']),
('PSU-EVGA-000002',   'EVGA SuperNOVA 850 G6 80+ Gold',         'PSU', 'EVGA',        '2021-06-01', ARRAY['EVGA G6 850']),
('PSU-FSP-000001', 'FSP Hydro G PRO 650W 80+ Gold',          'PSU', 'FSP',         '2021-01-01', ARRAY['FSP 하이드로 650']),
('PSU-FSP-000002', 'FSP Hydro G PRO 850W 80+ Gold',          'PSU', 'FSP',         '2021-01-01', ARRAY['FSP 하이드로 850']),
('PSU-BEQ-000001',  'be quiet! Pure Power 12 M 700W 80+ Gold','PSU', 'be quiet!',   '2023-01-01', ARRAY['비콰이어 700']),
('PSU-BEQ-000002','be quiet! Straight Power 12 1000W 80+ Platinum','PSU','be quiet!','2023-05-01', ARRAY['비콰이어 1000']),
('PSU-COOL-000001',  'Cooler Master MWE Gold 650 V2',          'PSU', 'Cooler Master','2021-01-01', ARRAY['쿨러마스터 MWE 650']);


-- ============================================================
-- CASE (20개) — 다양한 폼팩터, GPU 길이 허용
-- ============================================================
INSERT INTO part_id (uid, model_name, category, manufacturer, released_at, aliases) VALUES
('CASE-LANL-000001',     'Lian Li LANCOOL 216',          'CASE', 'Lian Li',       '2022-08-01', ARRAY['리안리 란쿨 216', 'LANCOOL 216']),
('CASE-LANL-000002',    'Lian Li O11 Dynamic EVO',      'CASE', 'Lian Li',       '2021-10-01', ARRAY['리안리 O11 다이나믹']),
('CASE-LANL-000003',    'Lian Li O11 Dynamic Mini',     'CASE', 'Lian Li',       '2021-05-01', ARRAY['리안리 O11 미니']),
('CASE-COOL-000001',  'Cooler Master NR200P',         'CASE', 'Cooler Master', '2020-09-01', ARRAY['쿨러마스터 NR200P']),
('CASE-COOL-000002',   'Cooler Master MasterBox TD500 Mesh','CASE','Cooler Master','2020-04-01',ARRAY['쿨러마스터 TD500']),
('CASE-COOL-000003',  'Cooler Master HAF 700',        'CASE', 'Cooler Master', '2022-04-01', ARRAY['쿨러마스터 HAF 700']),
('CASE-FRAC-000001',  'Fractal Design Meshify 2 Compact','CASE','Fractal Design','2021-04-01',ARRAY['프랙탈 메쉬파이 2 컴팩트']),
('CASE-FRAC-000002',   'Fractal Design North',         'CASE', 'Fractal Design','2023-02-01', ARRAY['프랙탈 노스']),
('CASE-FRAC-000003', 'Fractal Design Torrent',       'CASE', 'Fractal Design','2021-09-01', ARRAY['프랙탈 토렌트']),
('CASE-NZXT-000001',    'NZXT H510 Flow',               'CASE', 'NZXT',          '2021-08-01', ARRAY['NZXT H510']),
('CASE-NZXT-000002',      'NZXT H7 Flow',                 'CASE', 'NZXT',          '2022-03-01', ARRAY['NZXT H7']),
('CASE-NZXT-000003',      'NZXT H9 Flow',                 'CASE', 'NZXT',          '2022-10-01', ARRAY['NZXT H9']),
('CASE-CORS-000001',   'Corsair 4000D Airflow',        'CASE', 'Corsair',       '2020-09-01', ARRAY['커세어 4000D']),
('CASE-CORS-000002',   'Corsair 5000D Airflow',        'CASE', 'Corsair',       '2021-02-01', ARRAY['커세어 5000D']),
('CASE-CORS-000003',   'Corsair 7000D Airflow',        'CASE', 'Corsair',       '2021-04-01', ARRAY['커세어 7000D']),
('CASE-PHAN-000001',   'Phanteks Eclipse P400A',       'CASE', 'Phanteks',      '2020-01-01', ARRAY['팬텍스 P400A']),
('CASE-PHAN-000002',   'Phanteks Eclipse G500A',       'CASE', 'Phanteks',      '2022-01-01', ARRAY['팬텍스 G500A']),
('CASE-DEEP-000001',   'DeepCool CK500',               'CASE', 'DeepCool',      '2022-06-01', ARRAY['딥쿨 CK500']),
('CASE-DEEP-000002',   'DeepCool CH560',               'CASE', 'DeepCool',      '2023-01-01', ARRAY['딥쿨 CH560']),
('CASE-BEQ-000001',    'be quiet! Pure Base 500DX',    'CASE', 'be quiet!',     '2020-07-01', ARRAY['비콰이어 퓨어 베이스 500DX']);
