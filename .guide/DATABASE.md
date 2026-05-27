# 컴닥터 데이터베이스

> 실제 스키마: `db/001_schema.sql` 기준 (PostgreSQL 18+)

---

## 파일 구조

```
db/
├── 001_schema.sql                              # 테이블/인덱스/뷰/함수 생성
├── 002_seed_part_id.sql                        # Layer 1 시드 (144개 부품)
├── 003_seed_part_spec.sql                      # Layer 2 시드 (스펙)
├── 004_seed_perf_price_usecase_exception.sql   # Layer 3-5 + 예외 시드
├── 005_example_queries.sql                     # 추천 엔진용 예제 쿼리
├── 006_migration_v1.0.2.sql                    # 기존 환경 마이그레이션 (v1.0.1 → v1.0.2)
└── CHANGELOG.md                                # 스키마 변경 이력
```

---

## 설치 및 빠른 시작 (Windows)

### 1. PostgreSQL 설치

[postgresql.org/download/windows](https://www.postgresql.org/download/windows/) 에서 설치 파일 다운로드 후 실행.
설치 중 설정한 비밀번호를 반드시 기억해둔다. (기본 유저: `postgres`)

### 2. PATH 등록

설치 후 터미널에서 `psql`이 인식되지 않으면:

1. 윈도우 검색 → "시스템 환경 변수 편집"
2. 하단 "환경 변수" → 시스템 변수 → `Path` → "편집"
3. "새로 만들기" → `C:\Program Files\PostgreSQL\18\bin` 입력
4. 확인 → **터미널 재시작**

> PATH 없이 바로 쓰려면 전체 경로 사용: `"C:\Program Files\PostgreSQL\18\bin\psql.exe"`

### 3. DB 생성 및 스키마 적용

프로젝트 루트(`comdoctor/`)에서 터미널 열고 순서대로 실행:

```
set PGCLIENTENCODING=UTF8
```

```
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -c "CREATE DATABASE ComdoctorDB WITH ENCODING 'UTF8';"
```

```
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -d ComdoctorDB -f db/001_schema.sql
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -d ComdoctorDB -f db/002_seed_part_id.sql
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -d ComdoctorDB -f db/003_seed_part_spec.sql
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -d ComdoctorDB -f db/004_seed_perf_price_usecase_exception.sql
```

> 명령어를 복붙할 때 한 줄씩 통째로 복붙한다. 줄이 끊기면 `-f` 뒤 파일명이 사라져 오류가 난다.

### 4. 환경변수 설정

`server/.env`에 추가:

```
DATABASE_URL=postgresql://postgres:비밀번호@localhost:5432/ComdoctorDB
```

### 5. 연결 확인

```
node -e "const db = require('./db.js'); db.ping().then(ok => console.log(ok ? '연결 성공' : '연결 실패'))"
```

### 기존 환경 마이그레이션 (v1.0.1 → v1.0.2)

```
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -d ComdoctorDB -f db/006_migration_v1.0.2.sql
```

---

## 인프라 구성

| DB | 역할 |
|----|------|
| **PostgreSQL** | 부품 데이터, 분석 이력 등 영구 저장 |
| **Redis** | Gemini 응답 캐싱, Rate limiting |

---

## 5-Layer 구조

| 레이어 | 테이블 | 역할 | 변경 빈도 |
|---|---|---|---|
| 1 | `part_id` | UID 기준 + 별칭 | 불변 (신규만 추가) |
| 2 | `part_spec` | 자기 정체 + 수용 범위 | 불변 |
| 3 | `part_performance` | 벤치마크 점수 (EAV) | 새 벤치마크 추가 시 |
| 4 | `part_price` | 시계열 가격 (append-only) | 매일 |
| 5 | `use_case_profile` | 목적 → 요구사양 매핑 | 사용자 데이터로 튜닝 |
| 보조 | `compat_exception` | 호환성 예외 (수십 행) | 거의 없음 |
| 운영 | `diagnosis_session`, `recommendation` | 사용자 행동 추적 | 실시간 |

```
part_id
  ├── part_spec        ← 스펙 (JSONB 하이브리드)
  ├── part_performance ← 벤치마크 점수 (EAV)
  ├── part_price       ← 가격 이력 (append-only)
  └── use_case_profile ← 목적별 요구 사양

compat_exception       ← 호환성 예외 케이스
diagnosis_session      ← 사용자 진단 세션
recommendation         ← 추천 결과 + CTR 추적
```

---

## 핵심 설계 결정

### 1. UID는 순수 식별자

형식: `{카테고리}-{제조사}-{6자리 시퀀스}` (예: `GPU-NV-000001`)

ID에 모델명·세대 정보를 넣지 않는다. 모델명이 바뀌어도 UID는 불변.

### 2. 호환성은 DB 규칙으로, 예외만 별도 테이블

호환성 페어 테이블 대신 `part_spec`의 자기 정체 + 수용 범위를 SQL WHERE로 직접 매칭.

```
CPU의 자기 정체:        socket=LGA1700, generation=14th
메인보드의 수용 범위:   supported_cpu_gens=['12th','13th','14th'] → 호환
```

규칙으로 못 잡는 진짜 예외(특정 BIOS 버그 등)만 `compat_exception`에 수동 등록.

### 3. `part_spec`은 JSONB + 컬럼 하이브리드

자주 검색하는 호환성 키(`socket`, `ram_type`, `form_factor`, `tdp_watts`)는 컬럼 + 인덱스.  
부품별 가변 속성은 `attributes JSONB`.

### 4. `part_performance`만 EAV

`(uid, benchmark_name, score)` 행 구조. 새 벤치마크 추가 시 스키마 변경 없이 행만 추가.

### 5. `part_price`는 append-only

수정 없이 신규 행만 쌓아서 시계열 분석 가능. 현재가는 `current_price` 뷰, 최저가는 `cheapest_current_price` 뷰 사용.

---

## PART_SPEC 카테고리별 키 명세

| 카테고리 | 컬럼 (인덱스됨) | JSONB 필수 키 |
|---|---|---|
| **CPU** | socket, tdp_watts | generation, cores, threads, base_ghz, boost_ghz, igpu |
| **MB** | socket, ram_type, form_factor | supported_cpu_gens[], max_ram_mhz, max_ram_capacity_gb, m2_slots, sata_slots, chipset |
| **RAM** | ram_type | speed_mhz, capacity_gb, kit_count, cl |
| **GPU** | tdp_watts, pcie_version | vram_gb, vram_type, length_mm, power_connector |
| **PSU** | — | wattage, certification, modular, pcie_8pin_count, atx_version |
| **CASE** | — | supported_form_factors[], max_gpu_length_mm, max_cpu_cooler_height_mm |
| **SSD** | — | interface, pcie_gen, capacity_gb, form_factor, seq_read_mbs |

---

## 추천 엔진 흐름

```
[1] 사용자 입력         "발로란트 1440p 144fps 잘 뽑고 싶음"
         ↓
[2] 목적 분류           use_case_id = "valorant_1440p_144fps"
         ↓
[3] 요구 점수 조회      USE_CASE_PROFILE: gpu_req=18000, cpu_req=22000
         ↓
[4] 현재 PC 진단        에이전트가 부품 UID 수집
         ↓
[5] 적합도 계산         PART_PERFORMANCE vs USE_CASE_PROFILE → GAP
         ↓
[6] 병목 부품 결정      예: "GPU가 부족"
         ↓
[7] 호환 후보 검색      PART_SPEC SQL WHERE로 호환 GPU 압축
         ↓
[8] 예외 적용           COMPAT_EXCEPTION으로 알려진 문제 제외
         ↓
[9] 점수 정렬           성능/가격/재고 종합
         ↓
[10] Top 3 추천
```

각 단계의 구체적 SQL은 `db/005_example_queries.sql` 참조.

---

## 시드 데이터 요약

| 파일 | 내용 |
|------|------|
| `002_seed_part_id.sql` | 부품 144개 (CPU 20, GPU 22, RAM 20, MB 22, SSD 20, PSU 20, CASE 20) + 별칭 |
| `003_seed_part_spec.sql` | 부품 스펙 전체 |
| `004_seed_perf_price_usecase_exception.sql` | PassMark 점수 62개, 현재가 144개, 목적 프로파일 23개, 호환 예외 5건 |

---

## 운영 시 데이터 갱신

### 신규 부품 추가

```sql
INSERT INTO part_id (uid, model_name, category, manufacturer, released_at, aliases)
VALUES ('GPU-NV-000017', 'NVIDIA GeForce RTX 5070', 'GPU', 'NVIDIA', '2026-01-15',
        ARRAY['RTX 5070', '지포스 5070']);
```

### 가격 갱신 (매일 배치)

```python
for part in db.query("SELECT uid, aliases FROM part_id"):
    prices = naver_shopping_api.search(part.aliases)
    for vendor, price, url in prices:
        db.execute(
            "INSERT INTO part_price (uid, price_krw, vendor, url, in_stock) VALUES (%s, %s, %s, %s, %s)",
            part.uid, price, vendor, url, True
        )
```

### 새 벤치마크 추가

```sql
INSERT INTO part_performance (uid, benchmark_name, score, source)
VALUES ('GPU-NV-000017', 'passmark_g3d', 42500, 'PassMark');
```

---

## Schema Version

| Version | Description |
|---|---|
| 1.0.0 | 초기 스키마: 5-Layer + 보조 + 운영 |
| 1.0.1 | UID 순수 식별자 단순화. part_performance 중복 인덱스 정리 |
| 1.0.2 | FK ON DELETE 명시. cheapest_current_price 뷰 추가. compat_exception 중복 시드 2건 제거 |
