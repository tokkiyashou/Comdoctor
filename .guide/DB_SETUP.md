# DB 설정 가이드 (Windows)

## 1. PostgreSQL 설치

[postgresql.org/download/windows](https://www.postgresql.org/download/windows/) 에서 설치 파일 다운로드 후 실행.

설치 중 비밀번호 설정 화면에서 입력한 비밀번호를 반드시 기억해둔다. (기본 유저: `postgres`)

---

## 2. PATH 등록

설치 후 터미널에서 `psql` 명령어가 인식되지 않으면 PATH를 수동 등록해야 한다.

1. 윈도우 검색 → "시스템 환경 변수 편집"
2. 하단 "환경 변수" 클릭
3. 시스템 변수 → `Path` 선택 → "편집"
4. "새로 만들기" → `C:\Program Files\PostgreSQL\18\bin` 입력
5. 확인 → **터미널 재시작**

> PATH 등록 없이 바로 쓰려면 전체 경로로 실행:
> `"C:\Program Files\PostgreSQL\18\bin\psql.exe"`

---

## 3. DB 생성

터미널을 **프로젝트 루트** (`comdoctor/`) 에서 열고 순서대로 실행.

### 3-1. psql 접속

```
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres
```

비밀번호 입력 → `postgres=#` 프롬프트 확인.

### 3-2. DB 생성

```sql
CREATE DATABASE ComdoctorDB WITH ENCODING 'UTF8';
```

### 3-3. 접속 종료

```
\q
```

---

## 4. 스키마 및 시드 데이터 적용

> **주의**: Windows에서 인코딩 오류가 발생하면 `set PGCLIENTENCODING=UTF8` 을 먼저 실행한다.

같은 터미널 창에서 아래 순서대로 실행 (각 줄마다 비밀번호 입력):

```
set PGCLIENTENCODING=UTF8
```

```
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -d ComdoctorDB -f .guide/db/001_schema.sql
```

```
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -d ComdoctorDB -f .guide/db/002_seed_part_id.sql
```

```
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -d ComdoctorDB -f .guide/db/003_seed_part_spec.sql
```

```
"C:\Program Files\PostgreSQL\18\bin\psql.exe" -U postgres -d ComdoctorDB -f .guide/db/004_seed_perf_price_usecase_exception.sql
```

> **주의**: 명령어를 복붙할 때 한 줄씩 통째로 복붙한다. 줄이 끊기면 `-f` 뒤에 파일명이 사라져서 오류가 난다.

---

## 5. 환경변수 설정

`server/.env` 파일에 DB 연결 정보 추가:

```
DATABASE_URL=postgresql://postgres:비밀번호@localhost:5432/ComdoctorDB
```

---

## 6. 연결 확인

`server/` 폴더에서:

```
node -e "const db = require('./db.js'); db.ping().then(ok => console.log(ok ? '연결 성공' : '연결 실패'))"
```

`연결 성공` 출력되면 완료.

---

## 시드 데이터 내용

| 파일 | 내용 |
|------|------|
| `001_schema.sql` | 테이블, 인덱스, 뷰 생성 |
| `002_seed_part_id.sql` | 부품 144개 (CPU/GPU/RAM/MB/SSD/PSU/CASE) + 별칭 |
| `003_seed_part_spec.sql` | 부품 스펙 전체 |
| `004_seed_perf_price_usecase_exception.sql` | PassMark 점수, 현재가, 목적 프로파일 23개, 호환 예외 7개 |
