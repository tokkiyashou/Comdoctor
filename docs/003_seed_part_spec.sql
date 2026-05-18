-- ============================================================
-- 시드 데이터 #2: PART_SPEC
-- 자기 정체 + 수용 범위 정보
-- ============================================================

-- ============================================================
-- CPU 스펙
-- 자기 정체: socket, generation, cores, threads, TDP
-- 수용 범위: 없음
-- ============================================================
INSERT INTO part_spec (uid, socket, tdp_watts, attributes) VALUES
('CPU-INTL-000001', 'LGA1700', 58, '{"generation":"12th","cores":4,"threads":8,"base_ghz":3.3,"boost_ghz":4.3,"igpu":false}'),
('CPU-INTL-000002', 'LGA1700', 65, '{"generation":"12th","cores":6,"threads":12,"base_ghz":2.5,"boost_ghz":4.4,"igpu":false}'),
('CPU-INTL-000003', 'LGA1700', 125, '{"generation":"12th","cores":10,"threads":16,"base_ghz":3.7,"boost_ghz":4.9,"igpu":true}'),
('CPU-INTL-000004', 'LGA1700', 125, '{"generation":"12th","cores":12,"threads":20,"base_ghz":3.6,"boost_ghz":5.0,"igpu":true}'),
('CPU-INTL-000005', 'LGA1700', 65, '{"generation":"13th","cores":10,"threads":16,"base_ghz":2.5,"boost_ghz":4.6,"igpu":false}'),
('CPU-INTL-000006', 'LGA1700', 125, '{"generation":"13th","cores":14,"threads":20,"base_ghz":3.5,"boost_ghz":5.1,"igpu":true}'),
('CPU-INTL-000007', 'LGA1700', 125, '{"generation":"13th","cores":16,"threads":24,"base_ghz":3.4,"boost_ghz":5.4,"igpu":true}'),
('CPU-INTL-000008', 'LGA1700', 125, '{"generation":"13th","cores":24,"threads":32,"base_ghz":3.0,"boost_ghz":5.8,"igpu":true}'),
('CPU-INTL-000009', 'LGA1700', 65, '{"generation":"14th","cores":10,"threads":16,"base_ghz":2.5,"boost_ghz":4.7,"igpu":false}'),
('CPU-INTL-000010', 'LGA1700', 125, '{"generation":"14th","cores":14,"threads":20,"base_ghz":3.5,"boost_ghz":5.3,"igpu":true}'),
('CPU-INTL-000011', 'LGA1700', 125, '{"generation":"14th","cores":20,"threads":28,"base_ghz":3.4,"boost_ghz":5.6,"igpu":true}'),
('CPU-INTL-000012', 'LGA1700', 125, '{"generation":"14th","cores":24,"threads":32,"base_ghz":3.2,"boost_ghz":6.0,"igpu":true}'),
('CPU-AMD-000001',     'AM4', 65,  '{"generation":"Zen3","cores":6,"threads":12,"base_ghz":3.5,"boost_ghz":4.4,"igpu":false}'),
('CPU-AMD-000002',    'AM4', 65,  '{"generation":"Zen3","cores":8,"threads":16,"base_ghz":3.4,"boost_ghz":4.6,"igpu":false}'),
('CPU-AMD-000003',  'AM4', 105, '{"generation":"Zen3","cores":8,"threads":16,"base_ghz":3.4,"boost_ghz":4.5,"igpu":false,"v_cache":true}'),
('CPU-AMD-000004',     'AM5', 65,  '{"generation":"Zen4","cores":6,"threads":12,"base_ghz":3.8,"boost_ghz":5.1,"igpu":true}'),
('CPU-AMD-000005',    'AM5', 105, '{"generation":"Zen4","cores":6,"threads":12,"base_ghz":4.7,"boost_ghz":5.3,"igpu":true}'),
('CPU-AMD-000006',    'AM5', 105, '{"generation":"Zen4","cores":8,"threads":16,"base_ghz":4.5,"boost_ghz":5.4,"igpu":true}'),
('CPU-AMD-000007',  'AM5', 120, '{"generation":"Zen4","cores":8,"threads":16,"base_ghz":4.2,"boost_ghz":5.0,"igpu":true,"v_cache":true}'),
('CPU-AMD-000008',    'AM5', 170, '{"generation":"Zen4","cores":16,"threads":32,"base_ghz":4.5,"boost_ghz":5.7,"igpu":true}');


-- ============================================================
-- GPU 스펙
-- 자기 정체: TDP, VRAM, 길이, PCIe
-- 수용 범위: 없음
-- ============================================================
INSERT INTO part_spec (uid, tdp_watts, pcie_version, attributes) VALUES
('GPU-NV-000001',    130, '4.0', '{"vram_gb":8,"vram_type":"GDDR6","length_mm":250,"power_connector":"8pin"}'),
('GPU-NV-000002',    170, '4.0', '{"vram_gb":12,"vram_type":"GDDR6","length_mm":242,"power_connector":"8pin"}'),
('GPU-NV-000003',  200, '4.0', '{"vram_gb":8,"vram_type":"GDDR6","length_mm":242,"power_connector":"8pin"}'),
('GPU-NV-000004',    220, '4.0', '{"vram_gb":8,"vram_type":"GDDR6","length_mm":242,"power_connector":"12pin"}'),
('GPU-NV-000005',  290, '4.0', '{"vram_gb":8,"vram_type":"GDDR6X","length_mm":267,"power_connector":"12pin"}'),
('GPU-NV-000006',    320, '4.0', '{"vram_gb":10,"vram_type":"GDDR6X","length_mm":285,"power_connector":"12pin"}'),
('GPU-NV-000007',    350, '4.0', '{"vram_gb":24,"vram_type":"GDDR6X","length_mm":313,"power_connector":"12pin"}'),
('GPU-NV-000008',    115, '4.0', '{"vram_gb":8,"vram_type":"GDDR6","length_mm":244,"power_connector":"8pin"}'),
('GPU-NV-000009',  160, '4.0', '{"vram_gb":8,"vram_type":"GDDR6","length_mm":244,"power_connector":"8pin"}'),
('GPU-NV-000010',    200, '4.0', '{"vram_gb":12,"vram_type":"GDDR6X","length_mm":244,"power_connector":"12pin"}'),
('GPU-NV-000011',   220, '4.0', '{"vram_gb":12,"vram_type":"GDDR6X","length_mm":304,"power_connector":"12pin"}'),
('GPU-NV-000012',  285, '4.0', '{"vram_gb":12,"vram_type":"GDDR6X","length_mm":300,"power_connector":"12pin"}'),
('GPU-NV-000013', 285, '4.0', '{"vram_gb":16,"vram_type":"GDDR6X","length_mm":304,"power_connector":"12pin"}'),
('GPU-NV-000014',    320, '4.0', '{"vram_gb":16,"vram_type":"GDDR6X","length_mm":310,"power_connector":"12pin"}'),
('GPU-NV-000015',   320, '4.0', '{"vram_gb":16,"vram_type":"GDDR6X","length_mm":310,"power_connector":"12pin"}'),
('GPU-NV-000016',    450, '4.0', '{"vram_gb":24,"vram_type":"GDDR6X","length_mm":336,"power_connector":"12pin"}'),
('GPU-AMD-000001',   132, '4.0', '{"vram_gb":8,"vram_type":"GDDR6","length_mm":190,"power_connector":"8pin"}'),
('GPU-AMD-000002', 230, '4.0', '{"vram_gb":12,"vram_type":"GDDR6","length_mm":267,"power_connector":"8pin+6pin"}'),
('GPU-AMD-000003', 300, '4.0', '{"vram_gb":16,"vram_type":"GDDR6","length_mm":267,"power_connector":"8pin+8pin"}'),
('GPU-AMD-000004', 245, '4.0', '{"vram_gb":12,"vram_type":"GDDR6","length_mm":267,"power_connector":"8pin+8pin"}'),
('GPU-AMD-000005', 263, '4.0', '{"vram_gb":16,"vram_type":"GDDR6","length_mm":267,"power_connector":"8pin+8pin"}'),
('GPU-AMD-000006',355, '4.0', '{"vram_gb":24,"vram_type":"GDDR6","length_mm":287,"power_connector":"8pin+8pin"}');


-- ============================================================
-- RAM 스펙
-- 자기 정체: type, speed, capacity, kit_count
-- 수용 범위: 없음
-- ============================================================
INSERT INTO part_spec (uid, ram_type, attributes) VALUES
('RAM-SAMS-000001', 'DDR4', '{"speed_mhz":3200,"capacity_gb":16,"kit_count":1,"cl":22}'),
('RAM-SAMS-000002', 'DDR4', '{"speed_mhz":3200,"capacity_gb":32,"kit_count":2,"cl":22}'),
('RAM-CRUC-000001', 'DDR4', '{"speed_mhz":3200,"capacity_gb":16,"kit_count":1,"cl":22}'),
('RAM-GSKL-000001', 'DDR4', '{"speed_mhz":3600,"capacity_gb":16,"kit_count":2,"cl":18}'),
('RAM-GSKL-000002', 'DDR4', '{"speed_mhz":3600,"capacity_gb":32,"kit_count":2,"cl":18}'),
('RAM-CORS-000001', 'DDR4', '{"speed_mhz":3200,"capacity_gb":16,"kit_count":2,"cl":16}'),
('RAM-CORS-000002', 'DDR4', '{"speed_mhz":3600,"capacity_gb":32,"kit_count":2,"cl":18}'),
('RAM-TFOR-000001', 'DDR4', '{"speed_mhz":3200,"capacity_gb":16,"kit_count":2,"cl":16}'),
('RAM-SAMS-000003', 'DDR5', '{"speed_mhz":4800,"capacity_gb":16,"kit_count":1,"cl":40}'),
('RAM-SAMS-000004', 'DDR5', '{"speed_mhz":4800,"capacity_gb":32,"kit_count":2,"cl":40}'),
('RAM-GSKL-000003', 'DDR5', '{"speed_mhz":5600,"capacity_gb":16,"kit_count":1,"cl":36}'),
('RAM-GSKL-000004', 'DDR5', '{"speed_mhz":6000,"capacity_gb":32,"kit_count":2,"cl":30}'),
('RAM-GSKL-000005', 'DDR5', '{"speed_mhz":6400,"capacity_gb":32,"kit_count":2,"cl":32}'),
('RAM-GSKL-000006', 'DDR5', '{"speed_mhz":6000,"capacity_gb":64,"kit_count":2,"cl":30}'),
('RAM-CORS-000003', 'DDR5', '{"speed_mhz":5600,"capacity_gb":32,"kit_count":2,"cl":36}'),
('RAM-CORS-000004', 'DDR5', '{"speed_mhz":6000,"capacity_gb":32,"kit_count":2,"cl":30}'),
('RAM-CORS-000005', 'DDR5', '{"speed_mhz":6400,"capacity_gb":64,"kit_count":2,"cl":32}'),
('RAM-KING-000001', 'DDR5', '{"speed_mhz":5600,"capacity_gb":32,"kit_count":2,"cl":40}'),
('RAM-CRUC-000002', 'DDR5', '{"speed_mhz":5200,"capacity_gb":32,"kit_count":2,"cl":42}'),
('RAM-TFOR-000002', 'DDR5', '{"speed_mhz":6000,"capacity_gb":32,"kit_count":2,"cl":30}');


-- ============================================================
-- MB(메인보드) 스펙
-- 자기 정체: socket, ram_type, form_factor
-- 수용 범위: supported_cpu_gens[], max_ram_mhz, max_ram_capacity_gb,
--          m2_slots, sata_slots, pcie_slots
-- ============================================================
INSERT INTO part_spec (uid, socket, ram_type, form_factor, attributes) VALUES
('MB-ASUS-000001',  'LGA1700', 'DDR4', 'mATX', '{"supported_cpu_gens":["12th","13th"],"max_ram_mhz":5333,"max_ram_capacity_gb":128,"m2_slots":2,"sata_slots":4,"pcie_slots":2,"chipset":"B660"}'),
('MB-ASUS-000002', 'LGA1700', 'DDR5', 'ATX',  '{"supported_cpu_gens":["12th","13th"],"max_ram_mhz":6400,"max_ram_capacity_gb":128,"m2_slots":4,"sata_slots":6,"pcie_slots":3,"chipset":"Z690"}'),
('MB-ASUS-000003',  'LGA1700', 'DDR4', 'mATX', '{"supported_cpu_gens":["12th","13th","14th"],"max_ram_mhz":5333,"max_ram_capacity_gb":128,"m2_slots":2,"sata_slots":4,"pcie_slots":2,"chipset":"B760"}'),
('MB-ASUS-000004', 'LGA1700', 'DDR5', 'ATX',  '{"supported_cpu_gens":["12th","13th","14th"],"max_ram_mhz":7200,"max_ram_capacity_gb":192,"m2_slots":4,"sata_slots":4,"pcie_slots":3,"chipset":"Z790"}'),
('MB-ASUS-000005',  'AM5',     'DDR5', 'ATX',  '{"supported_cpu_gens":["Zen4","Zen5"],"max_ram_mhz":6400,"max_ram_capacity_gb":128,"m2_slots":4,"sata_slots":6,"pcie_slots":3,"chipset":"X670E"}'),
('MB-ASUS-000006',   'AM5',     'DDR5', 'ATX',  '{"supported_cpu_gens":["Zen4","Zen5"],"max_ram_mhz":6400,"max_ram_capacity_gb":128,"m2_slots":2,"sata_slots":4,"pcie_slots":2,"chipset":"B650"}'),
('MB-MSI-000001',    'LGA1700', 'DDR4', 'mATX', '{"supported_cpu_gens":["12th","13th"],"max_ram_mhz":4800,"max_ram_capacity_gb":128,"m2_slots":2,"sata_slots":4,"pcie_slots":2,"chipset":"B660"}'),
('MB-MSI-000002',    'LGA1700', 'DDR5', 'ATX',  '{"supported_cpu_gens":["12th","13th"],"max_ram_mhz":6400,"max_ram_capacity_gb":128,"m2_slots":4,"sata_slots":6,"pcie_slots":3,"chipset":"Z690"}'),
('MB-MSI-000003',    'LGA1700', 'DDR5', 'ATX',  '{"supported_cpu_gens":["12th","13th","14th"],"max_ram_mhz":7200,"max_ram_capacity_gb":192,"m2_slots":3,"sata_slots":6,"pcie_slots":3,"chipset":"B760"}'),
('MB-MSI-000004',    'LGA1700', 'DDR5', 'ATX',  '{"supported_cpu_gens":["12th","13th","14th"],"max_ram_mhz":7800,"max_ram_capacity_gb":192,"m2_slots":4,"sata_slots":6,"pcie_slots":3,"chipset":"Z790"}'),
('MB-MSI-000005',   'AM5',     'DDR5', 'EATX', '{"supported_cpu_gens":["Zen4","Zen5"],"max_ram_mhz":6600,"max_ram_capacity_gb":128,"m2_slots":5,"sata_slots":6,"pcie_slots":3,"chipset":"X670E"}'),
('MB-MSI-000006',    'AM5',     'DDR5', 'ATX',  '{"supported_cpu_gens":["Zen4","Zen5"],"max_ram_mhz":6600,"max_ram_capacity_gb":128,"m2_slots":3,"sata_slots":6,"pcie_slots":2,"chipset":"B650"}'),
('MB-GBYT-000001',   'LGA1700', 'DDR4', 'mATX', '{"supported_cpu_gens":["12th","13th","14th"],"max_ram_mhz":5333,"max_ram_capacity_gb":128,"m2_slots":2,"sata_slots":4,"pcie_slots":2,"chipset":"B760"}'),
('MB-GBYT-000002',   'LGA1700', 'DDR5', 'ATX',  '{"supported_cpu_gens":["12th","13th","14th"],"max_ram_mhz":7600,"max_ram_capacity_gb":192,"m2_slots":4,"sata_slots":4,"pcie_slots":3,"chipset":"Z790"}'),
('MB-GBYT-000003',  'AM5',     'DDR5', 'EATX', '{"supported_cpu_gens":["Zen4","Zen5"],"max_ram_mhz":6666,"max_ram_capacity_gb":128,"m2_slots":4,"sata_slots":6,"pcie_slots":3,"chipset":"X670E"}'),
('MB-GBYT-000004',   'AM5',     'DDR5', 'ATX',  '{"supported_cpu_gens":["Zen4","Zen5"],"max_ram_mhz":6400,"max_ram_capacity_gb":128,"m2_slots":2,"sata_slots":4,"pcie_slots":2,"chipset":"B650"}'),
('MB-ASRK-000001',   'LGA1700', 'DDR4', 'mATX', '{"supported_cpu_gens":["12th","13th","14th"],"max_ram_mhz":5333,"max_ram_capacity_gb":128,"m2_slots":2,"sata_slots":4,"pcie_slots":2,"chipset":"B760"}'),
('MB-ASRK-000002',   'LGA1700', 'DDR5', 'ATX',  '{"supported_cpu_gens":["12th","13th","14th"],"max_ram_mhz":7200,"max_ram_capacity_gb":192,"m2_slots":4,"sata_slots":8,"pcie_slots":3,"chipset":"Z790"}'),
('MB-ASUS-000007',   'AM4',     'DDR4', 'ATX',  '{"supported_cpu_gens":["Zen3"],"max_ram_mhz":5100,"max_ram_capacity_gb":128,"m2_slots":2,"sata_slots":6,"pcie_slots":3,"chipset":"B550"}'),
('MB-ASUS-000008',   'AM4',     'DDR4', 'ATX',  '{"supported_cpu_gens":["Zen3"],"max_ram_mhz":5100,"max_ram_capacity_gb":128,"m2_slots":2,"sata_slots":6,"pcie_slots":3,"chipset":"X570"}'),
('MB-MSI-000007',    'AM4',     'DDR4', 'ATX',  '{"supported_cpu_gens":["Zen3"],"max_ram_mhz":5100,"max_ram_capacity_gb":128,"m2_slots":2,"sata_slots":6,"pcie_slots":3,"chipset":"B550"}'),
('MB-GBYT-000005',   'AM4',     'DDR4', 'ATX',  '{"supported_cpu_gens":["Zen3"],"max_ram_mhz":5400,"max_ram_capacity_gb":128,"m2_slots":2,"sata_slots":6,"pcie_slots":3,"chipset":"X570"}');


-- ============================================================
-- SSD 스펙
-- 자기 정체: interface, capacity, form_factor
-- 수용 범위: 없음
-- ============================================================
INSERT INTO part_spec (uid, attributes) VALUES
('SSD-SAMS-000001',  '{"interface":"nvme","pcie_gen":3,"capacity_gb":500,"form_factor":"M.2-2280","seq_read_mbs":3500,"seq_write_mbs":2300}'),
('SSD-SAMS-000002',   '{"interface":"nvme","pcie_gen":3,"capacity_gb":1000,"form_factor":"M.2-2280","seq_read_mbs":3500,"seq_write_mbs":3000}'),
('SSD-SAMS-000003',  '{"interface":"nvme","pcie_gen":4,"capacity_gb":1000,"form_factor":"M.2-2280","seq_read_mbs":7000,"seq_write_mbs":5000}'),
('SSD-SAMS-000004',  '{"interface":"nvme","pcie_gen":4,"capacity_gb":2000,"form_factor":"M.2-2280","seq_read_mbs":7000,"seq_write_mbs":5100}'),
('SSD-SAMS-000005',  '{"interface":"nvme","pcie_gen":4,"capacity_gb":1000,"form_factor":"M.2-2280","seq_read_mbs":7450,"seq_write_mbs":6900}'),
('SSD-SAMS-000006',  '{"interface":"nvme","pcie_gen":4,"capacity_gb":2000,"form_factor":"M.2-2280","seq_read_mbs":7450,"seq_write_mbs":6900}'),
('SSD-SAMS-000007',  '{"interface":"nvme","pcie_gen":4,"capacity_gb":4000,"form_factor":"M.2-2280","seq_read_mbs":7450,"seq_write_mbs":6900}'),
('SSD-SAMS-000008',  '{"interface":"sata","capacity_gb":1000,"form_factor":"2.5","seq_read_mbs":560,"seq_write_mbs":530}'),
('SSD-WD-000001',   '{"interface":"nvme","pcie_gen":4,"capacity_gb":1000,"form_factor":"M.2-2280","seq_read_mbs":5150,"seq_write_mbs":4900}'),
('SSD-WD-000002',  '{"interface":"nvme","pcie_gen":4,"capacity_gb":1000,"form_factor":"M.2-2280","seq_read_mbs":7300,"seq_write_mbs":6300}'),
('SSD-WD-000003',  '{"interface":"nvme","pcie_gen":4,"capacity_gb":2000,"form_factor":"M.2-2280","seq_read_mbs":7300,"seq_write_mbs":6600}'),
('SSD-SK-000001',     '{"interface":"nvme","pcie_gen":4,"capacity_gb":1000,"form_factor":"M.2-2280","seq_read_mbs":7000,"seq_write_mbs":6500}'),
('SSD-SK-000002',     '{"interface":"nvme","pcie_gen":4,"capacity_gb":2000,"form_factor":"M.2-2280","seq_read_mbs":7000,"seq_write_mbs":6500}'),
('SSD-CRUC-000001',   '{"interface":"nvme","pcie_gen":4,"capacity_gb":1000,"form_factor":"M.2-2280","seq_read_mbs":6600,"seq_write_mbs":5000}'),
('SSD-CRUC-000002',  '{"interface":"nvme","pcie_gen":5,"capacity_gb":1000,"form_factor":"M.2-2280","seq_read_mbs":11700,"seq_write_mbs":9500}'),
('SSD-KING-000001',  '{"interface":"nvme","pcie_gen":4,"capacity_gb":1000,"form_factor":"M.2-2280","seq_read_mbs":7000,"seq_write_mbs":6000}'),
('SSD-KING-000002',   '{"interface":"nvme","pcie_gen":4,"capacity_gb":1000,"form_factor":"M.2-2280","seq_read_mbs":3500,"seq_write_mbs":2800}'),
('SSD-SOLI-000001',   '{"interface":"nvme","pcie_gen":4,"capacity_gb":1000,"form_factor":"M.2-2280","seq_read_mbs":7000,"seq_write_mbs":6500}'),
('SSD-TFOR-000001',  '{"interface":"nvme","pcie_gen":4,"capacity_gb":1000,"form_factor":"M.2-2280","seq_read_mbs":7400,"seq_write_mbs":6500}'),
('SSD-SAMS-000009',  '{"interface":"sata","capacity_gb":2000,"form_factor":"2.5","seq_read_mbs":560,"seq_write_mbs":530}');


-- ============================================================
-- PSU 스펙
-- 자기 정체: 없음
-- 수용 범위: wattage (시스템 총 TDP 수용)
-- ============================================================
INSERT INTO part_spec (uid, attributes) VALUES
('PSU-CORS-000001',     '{"wattage":550,"certification":"80+ Gold","modular":"full","pcie_8pin_count":2,"atx_version":"3.0"}'),
('PSU-CORS-000002',     '{"wattage":650,"certification":"80+ Gold","modular":"full","pcie_8pin_count":2,"atx_version":"3.0"}'),
('PSU-CORS-000003',     '{"wattage":750,"certification":"80+ Gold","modular":"full","pcie_8pin_count":4,"atx_version":"3.0"}'),
('PSU-CORS-000004',     '{"wattage":850,"certification":"80+ Gold","modular":"full","pcie_8pin_count":4,"atx_version":"3.0"}'),
('PSU-CORS-000005',    '{"wattage":1000,"certification":"80+ Gold","modular":"full","pcie_8pin_count":6,"atx_version":"3.0"}'),
('PSU-CORS-000006',     '{"wattage":1000,"certification":"80+ Platinum","modular":"full","pcie_8pin_count":6,"atx_version":"3.0"}'),
('PSU-SEAS-000001',  '{"wattage":650,"certification":"80+ Gold","modular":"full","pcie_8pin_count":2}'),
('PSU-SEAS-000002',  '{"wattage":750,"certification":"80+ Gold","modular":"full","pcie_8pin_count":4}'),
('PSU-SEAS-000003',  '{"wattage":850,"certification":"80+ Gold","modular":"full","pcie_8pin_count":4}'),
('PSU-SEAS-000004', '{"wattage":1000,"certification":"80+ Titanium","modular":"full","pcie_8pin_count":6}'),
('PSU-MSI-000001',     '{"wattage":650,"certification":"80+ Bronze","modular":"semi","pcie_8pin_count":2}'),
('PSU-MSI-000002',     '{"wattage":750,"certification":"80+ Gold","modular":"full","pcie_8pin_count":4}'),
('PSU-MSI-000003',    '{"wattage":1000,"certification":"80+ Platinum","modular":"full","pcie_8pin_count":6,"atx_version":"3.0"}'),
('PSU-EVGA-000001',     '{"wattage":750,"certification":"80+ Gold","modular":"full","pcie_8pin_count":4}'),
('PSU-EVGA-000002',     '{"wattage":850,"certification":"80+ Gold","modular":"full","pcie_8pin_count":4}'),
('PSU-FSP-000001',   '{"wattage":650,"certification":"80+ Gold","modular":"full","pcie_8pin_count":2}'),
('PSU-FSP-000002',   '{"wattage":850,"certification":"80+ Gold","modular":"full","pcie_8pin_count":4}'),
('PSU-BEQ-000001',    '{"wattage":700,"certification":"80+ Gold","modular":"full","pcie_8pin_count":2,"atx_version":"3.0"}'),
('PSU-BEQ-000002','{"wattage":1000,"certification":"80+ Platinum","modular":"full","pcie_8pin_count":6,"atx_version":"3.0"}'),
('PSU-COOL-000001',    '{"wattage":650,"certification":"80+ Gold","modular":"full","pcie_8pin_count":2}');


-- ============================================================
-- CASE 스펙
-- 자기 정체: 없음
-- 수용 범위: supported_form_factors[], max_gpu_length_mm, max_cpu_cooler_height_mm
-- ============================================================
INSERT INTO part_spec (uid, attributes) VALUES
('CASE-LANL-000001',     '{"supported_form_factors":["ATX","mATX","ITX"],"max_gpu_length_mm":392,"max_cpu_cooler_height_mm":180,"radiator_top_mm":360,"radiator_front_mm":360}'),
('CASE-LANL-000002',    '{"supported_form_factors":["EATX","ATX","mATX","ITX"],"max_gpu_length_mm":426,"max_cpu_cooler_height_mm":167,"radiator_top_mm":360,"radiator_side_mm":360}'),
('CASE-LANL-000003',    '{"supported_form_factors":["ATX","mATX","ITX"],"max_gpu_length_mm":395,"max_cpu_cooler_height_mm":170,"radiator_top_mm":280,"radiator_side_mm":280}'),
('CASE-COOL-000001',  '{"supported_form_factors":["ITX","mATX"],"max_gpu_length_mm":330,"max_cpu_cooler_height_mm":155}'),
('CASE-COOL-000002',   '{"supported_form_factors":["EATX","ATX","mATX","ITX"],"max_gpu_length_mm":410,"max_cpu_cooler_height_mm":165,"radiator_top_mm":360,"radiator_front_mm":360}'),
('CASE-COOL-000003',  '{"supported_form_factors":["EATX","ATX","mATX","ITX"],"max_gpu_length_mm":491,"max_cpu_cooler_height_mm":166,"radiator_top_mm":420,"radiator_front_mm":420}'),
('CASE-FRAC-000001',  '{"supported_form_factors":["ATX","mATX","ITX"],"max_gpu_length_mm":341,"max_cpu_cooler_height_mm":169,"radiator_top_mm":240,"radiator_front_mm":360}'),
('CASE-FRAC-000002',   '{"supported_form_factors":["ATX","mATX","ITX"],"max_gpu_length_mm":355,"max_cpu_cooler_height_mm":170,"radiator_top_mm":240,"radiator_front_mm":360}'),
('CASE-FRAC-000003', '{"supported_form_factors":["EATX","ATX","mATX","ITX"],"max_gpu_length_mm":423,"max_cpu_cooler_height_mm":188,"radiator_top_mm":360,"radiator_front_mm":360}'),
('CASE-NZXT-000001',    '{"supported_form_factors":["ATX","mATX","ITX"],"max_gpu_length_mm":381,"max_cpu_cooler_height_mm":165,"radiator_top_mm":240,"radiator_front_mm":280}'),
('CASE-NZXT-000002',      '{"supported_form_factors":["EATX","ATX","mATX","ITX"],"max_gpu_length_mm":400,"max_cpu_cooler_height_mm":185,"radiator_top_mm":360,"radiator_front_mm":360}'),
('CASE-NZXT-000003',      '{"supported_form_factors":["EATX","ATX","mATX","ITX"],"max_gpu_length_mm":435,"max_cpu_cooler_height_mm":165,"radiator_top_mm":360,"radiator_side_mm":360}'),
('CASE-CORS-000001',   '{"supported_form_factors":["EATX","ATX","mATX","ITX"],"max_gpu_length_mm":360,"max_cpu_cooler_height_mm":170,"radiator_top_mm":280,"radiator_front_mm":360}'),
('CASE-CORS-000002',   '{"supported_form_factors":["EATX","ATX","mATX","ITX"],"max_gpu_length_mm":420,"max_cpu_cooler_height_mm":170,"radiator_top_mm":360,"radiator_front_mm":360}'),
('CASE-CORS-000003',   '{"supported_form_factors":["EATX","ATX","mATX","ITX"],"max_gpu_length_mm":450,"max_cpu_cooler_height_mm":190,"radiator_top_mm":420,"radiator_front_mm":420}'),
('CASE-PHAN-000001',   '{"supported_form_factors":["EATX","ATX","mATX","ITX"],"max_gpu_length_mm":420,"max_cpu_cooler_height_mm":160,"radiator_top_mm":240,"radiator_front_mm":360}'),
('CASE-PHAN-000002',   '{"supported_form_factors":["EATX","ATX","mATX","ITX"],"max_gpu_length_mm":435,"max_cpu_cooler_height_mm":190,"radiator_top_mm":360,"radiator_front_mm":360}'),
('CASE-DEEP-000001',   '{"supported_form_factors":["EATX","ATX","mATX","ITX"],"max_gpu_length_mm":380,"max_cpu_cooler_height_mm":175,"radiator_top_mm":360,"radiator_front_mm":360}'),
('CASE-DEEP-000002',   '{"supported_form_factors":["EATX","ATX","mATX","ITX"],"max_gpu_length_mm":380,"max_cpu_cooler_height_mm":175,"radiator_top_mm":360,"radiator_front_mm":360}'),
('CASE-BEQ-000001',    '{"supported_form_factors":["ATX","mATX","ITX"],"max_gpu_length_mm":369,"max_cpu_cooler_height_mm":190,"radiator_top_mm":240,"radiator_front_mm":360}');
