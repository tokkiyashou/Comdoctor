# 컴닥터 (Computer Doctor) Database

PC 진단 + 부품 업그레이드 추천 엔진을 위한 PostgreSQL 데이터베이스 스키마.

## 디렉토리 구조

```
.guide/db/
├── 001_schema.sql                              # 테이블/인덱스/뷰/함수 생성
├── 002_seed_part_id.sql                        # Layer 1 시드 (144개 부품)
├── 003_seed_part_spec.sql                      # Layer 2 시드 (스펙)
├── 004_seed_perf_price_usecase_exception.sql   # Layer 3-5 + 예외 시드
├── 005_example_queries.sql                     # 추천 엔진용 예제 쿼리
└── DB_README.md                                # 이 파일
```

## 빠른 시작

PostgreSQL 14+ 가 설치된 환경에서:

```bash
# 1. 데이터베이스 생성
psql -U postgres -c "CREATE DATABASE ComdoctorDB WITH ENCODING 'UTF8';"

# 2. 스키마 적용
psql -U postgres -d ComdoctorDB -f .guide/db/001_schema.sql

# 3. 시드 데이터 적용
psql -U postgres -d ComdoctorDB -f .guide/db/002_seed_part_id.sql
psql -U postgres -d ComdoctorDB -f .guide/db/003_seed_part_spec.sql
psql -U postgres -d ComdoctorDB -f .guide/db/004_seed_perf_price_usecase_exception.sql

# 4. 검증
psql -U postgres -d computer_doctor -c "
  SELECT category, COUNT(*) FROM part_id GROUP BY category ORDER BY category;
"
```

## 5-Layer 구조 한눈에

| 레이어 | 테이블 | 역할 | 변경 빈도 |
|---|---|---|---|
| 1 | `part_id` | UID 기준 + 별칭 | 불변 (신규만 추가) |
| 2 | `part_spec` | 자기 정체 + 수용 범위 | 불변 |
| 3 | `part_performance` | 벤치마크 점수 (EAV) | 새 벤치마크 추가 시 |
| 4 | `part_price` | 시계열 가격 (append-only) | 매일 |
| 5 | `use_case_profile` | 목적 → 요구사양 매핑 | 사용자 데이터로 튜닝 |
| 보조 | `compat_exception` | 호환성 예외 (수십 행) | 거의 없음 |
| 운영 | `diagnosis_session`, `recommendation` | 사용자 행동 추적 | 실시간 |

## 핵심 설계 결정

### 1. UID는 순수 식별자

UID 형식: `{카테고리}-{제조사}-{6자리 시퀀스}`

```
GPU-NV-000001   ✓ 좋은 UID
GPU-NV-000017   ✓ 시퀀스만 다름

GPU-NV-000011   ✗ 모델명이 들어가면 안 됨
```

**원칙**: ID는 식별자일 뿐이다. 모델명/세대 같은 정보는 `model_name`, `attributes` 같은 다른 컬럼에 둔다.

이렇게 하는 이유:
- 모델명이 리브랜딩되면 UID도 바꿔야 하는 비극을 피함
- 변종 모델(OC 버전, FE 버전)에도 깔끔하게 새 UID 부여
- UID 생성 로직이 단순해짐 (그냥 시퀀스 +1)

### 2. "호환성 DB"는 별도 테이블이 아니다

호환성 페어 테이블(`compat(uid_a, uid_b)`)을 만들지 않음. 대신 부품의 **자기 정체** + **수용 범위**를 PART_SPEC에 담아서 SQL `WHERE`로 직접 매칭.

```
CPU의 자기 정체:        socket=LGA1700, generation=14th
메인보드의 수용 범위:   supported_cpu_gens=['12th','13th','14th']
                       → 호환!
```

데이터가 N×M 페어로 폭증하지 않고, 신규 부품 추가 시 페어 재계산 불필요.

### 3. PART_SPEC은 JSONB + 컬럼 하이브리드

자주 검색되는 호환성 키(`socket`, `ram_type`, `form_factor`, `tdp_watts`)는 컬럼으로 승격해서 인덱스. 부품별 가변 속성은 `attributes` JSONB로.

### 4. PART_PERFORMANCE만 EAV

`(uid, benchmark_name, score)` 행 기반 구조. 새 벤치마크 추가 시 스키마 변경 없이 행만 추가.

`UNIQUE(uid, benchmark_name)` 제약이 자동으로 인덱스를 생성하므로, 가장 빈번한 쿼리("특정 부품의 특정 벤치마크 점수")는 이걸로 처리됨. 별도 인덱스 추가 불필요.

### 5. PART_PRICE는 append-only

수정 없이 신규 행만 쌓아서 시계열 분석 가능. 현재가 조회는 `current_price` 뷰 사용.

## PART_SPEC 카테고리별 키 명세

각 카테고리의 JSONB `attributes`에 반드시 포함해야 할 키:

| 카테고리 | 컬럼 (인덱스됨) | JSONB 필수 키 |
|---|---|---|
| **CPU** | socket, tdp_watts | generation, cores, threads, base_ghz, boost_ghz, igpu |
| **MB** | socket, ram_type, form_factor | supported_cpu_gens[], max_ram_mhz, max_ram_capacity_gb, m2_slots, sata_slots, chipset |
| **RAM** | ram_type | speed_mhz, capacity_gb, kit_count, cl |
| **GPU** | tdp_watts, pcie_version | vram_gb, vram_type, length_mm, power_connector |
| **PSU** | — | wattage, certification, modular, pcie_8pin_count, atx_version |
| **CASE** | — | supported_form_factors[], max_gpu_length_mm, max_cpu_cooler_height_mm |
| **SSD** | — | interface, pcie_gen, capacity_gb, form_factor, seq_read_mbs |

## 추천 엔진 흐름

```
[1] 사용자 입력         "발로란트 1440p 144fps 잘 뽑고 싶음"
         ↓
[2] 목적 분류 (NLP)     use_case_id = "valorant_1440p_144fps"
         ↓
[3] 요구 점수 조회       USE_CASE_PROFILE: gpu_req=18000, cpu_req=22000
         ↓
[4] 현재 PC 진단        에이전트가 부품 UID 수집
         ↓
[5] 적합도 계산          PART_PERFORMANCE vs USE_CASE_PROFILE → GAP
         ↓
[6] 병목 부품 결정       예: "GPU가 부족"
         ↓
[7] 호환 후보 검색       PART_SPEC SQL WHERE로 호환 GPU 압축 (수천 → 수십)
         ↓
[8] 예외 적용           COMPAT_EXCEPTION의 NOT IN으로 알려진 문제 제외
         ↓
[9] 점수 정렬           성능/가격/재고 종합 점수
         ↓
[10] Top 3 추천 + 쿠팡파트너스 링크
```

각 단계의 구체적 SQL은 `005_example_queries.sql` 참조.

## 시드 데이터 요약

- **부품**: 144개 (CPU 20, GPU 22, RAM 20, MB 22, SSD 20, PSU 20, CASE 20)
- **PassMark 점수**: CPU 40개 + GPU 22개 = 62개 벤치마크
- **현재가**: 144개 부품 전체
- **목적 프로파일**: 23개 (게이밍 10, 생산성 4, 크리에이티브 5, AI 3, 기타 1)
- **호환성 예외**: 7개 (실제 예외 케이스)

## 운영 시 데이터 갱신 가이드

### PART_ID 추가 (신규 부품 출시)

```sql
INSERT INTO part_id (uid, model_name, category, manufacturer, released_at, aliases)
VALUES ('GPU-NV-000017', 'NVIDIA GeForce RTX 5070', 'GPU', 'NVIDIA', '2026-01-15',
        ARRAY['RTX 5070', '지포스 5070']);
```

### PART_PRICE 갱신 (매일 배치)

```python
# 네이버 API로 검색 → 가격 추출 → INSERT (UPDATE X)
for part in db.query("SELECT uid, aliases FROM part_id"):
    prices = naver_shopping_api.search(part.aliases)
    for vendor, price, url in prices:
        db.execute("""
            INSERT INTO part_price (uid, price_krw, vendor, url, in_stock)
            VALUES (%s, %s, %s, %s, %s)
        """, part.uid, price, vendor, url, True)
```

### PART_PERFORMANCE 추가 (새 벤치마크)

```sql
INSERT INTO part_performance (uid, benchmark_name, score, source)
VALUES ('GPU-NV-000017', 'passmark_g3d', 42500, 'PassMark');
```

### USE_CASE_PROFILE 튜닝 (사용자 데이터 누적 후)

```sql
-- 사용자 후기 데이터로 요구 점수 검증된 경우 confidence 상향
UPDATE use_case_profile
SET gpu_req_score = 19500,    -- 실측 데이터로 미세 조정
    confidence = 3
WHERE use_case_id = 'valorant_1440p_144fps';
```

## 검증된 환경

- PostgreSQL 16.13 (Ubuntu)
- 모든 SQL 파일 실행 성공 확인
- 예제 쿼리 5개 결과 검증 완료
- 인덱스 활용 확인 (EXPLAIN ANALYZE: 0.2ms 이내)

## 다음 개발 단계 제안

1. **추천 엔진 (Python)**: 005의 SQL을 FastAPI 백엔드로 래핑
2. **데이터 수집 파이프라인**: 네이버 쇼핑 API + 다나와 크롤링 → PART_PRICE 일일 갱신
3. **PC 진단 에이전트**: Windows WMI/PowerShell로 현재 PC 부품 UID 자동 매핑
4. **A/B 테스트**: USE_CASE_PROFILE의 요구 점수를 사용자 후기로 검증
5. **마이그레이션 버전 관리**: Flyway 또는 Alembic 도입

## Schema Version

| Version | Date | Description |
|---|---|---|
| 1.0.0 | 2026-05-18 | 초기 스키마: 5-Layer + 보조 + 운영 |
| 1.0.1 | 2026-05-18 | UID를 순수 식별자로 단순화. part_performance 중복 인덱스 정리. |
