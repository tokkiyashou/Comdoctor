> 이 파일은 기술 스택, 프로젝트 구조, 아키텍처, 개발 환경 세팅, 빌드·배포, 로그 시스템, 서버 확장 방법을 다루는 개발자용 기술 문서입니다.

# 컴닥터 — 개발자 문서

## 목차

1. [기술 스택](#1-기술-스택)
2. [프로젝트 구조](#2-프로젝트-구조)
3. [아키텍처](#3-아키텍처)
4. [개발 환경 세팅](#4-개발-환경-세팅)
5. [API 키 설정](#5-api-키-설정)
6. [개발 실행](#6-개발-실행)
7. [빌드 및 배포](#7-빌드-및-배포)
8. [주요 파일 역할](#8-주요-파일-역할)
9. [환경변수](#9-환경변수)
10. [로그 시스템](#10-로그-시스템)
11. [서버 확장 가이드](#11-서버-확장-가이드)

---

## 1. 기술 스택

| 영역 | 기술 | 언어 | 역할 |
|------|------|------|------|
| 데스크톱 앱 | **Electron v32** | JavaScript | 네이티브 창 생성, 시스템 API 접근 |
| 앱 런타임 | **Node.js** | JavaScript | Electron 메인 프로세스, PowerShell 실행, HTTP 요청 |
| 앱 UI | **HTML5 / CSS3 / Vanilla JS** | HTML, CSS, JS | 렌더러 화면, 애니메이션, 상태 관리 (프레임워크 없음) |
| 백엔드 서버 | **Express.js** | JavaScript | REST API 서버, Gemini 호출 중계 |
| PC 사양 수집 | **PowerShell** | PowerShell | Win32_* WMI 쿼리로 하드웨어 정보 수집 |
| AI 분석 | **Google Gemini API** | — | 업그레이드 플랜 생성 (외부 서비스, REST) |
| 패키징 | **electron-builder** | — | Windows exe/NSIS 인스톨러 빌드 |
| 환경변수 | **dotenv** | — | `.env` 파일 로드 |

---

## 2. 프로젝트 구조

```
comdoctor/
│
├── server/                         # 백엔드 서버 (Express.js)
│   ├── index.js                    # 서버 진입점 — 미들웨어, 라우터, 로그 스케줄러
│   ├── logger.js                   # 로깅 유틸 — access / api / error / stats
│   ├── db.js                       # DB 연동 (stub, 향후 확장)
│   ├── package.json
│   ├── .env                        # 환경변수 (git 제외)
│   ├── .env.example                # 환경변수 템플릿
│   ├── routes/
│   │   └── analyze.js              # POST /api/analyze — Gemini 호출 및 결과 반환
│   └── logs/                       # 자동 생성됨, git 제외
│       ├── access/YYYY-MM.log
│       ├── api/YYYY-MM.log
│       ├── error/YYYY-MM.log
│       └── stats/YYYY-MM.log
│
├── electron-app/                   # Electron 데스크톱 앱
│   ├── main.js                     # 메인 프로세스 — 창 생성, IPC 핸들러, PowerShell 실행
│   ├── preload.js                  # contextBridge — 렌더러↔메인 IPC 브릿지 (보안)
│   ├── package.json
│   ├── .env                        # SERVER_URL 설정 (git 제외)
│   ├── .env.example                # 환경변수 템플릿
│   ├── assets/                     # 정적 에셋
│   └── renderer/                   # UI (Chromium 렌더러에서 실행)
│       ├── index.html
│       ├── styles.css
│       └── app.js
│
├── landing/                        # 랜딩 페이지 (정적 HTML)
│   ├── index.html
│   ├── detail.html
│   └── styles.css
│
├── .guide/
│   ├── DEVELOPER.md                # 이 파일 — 개발자 기술 문서
│   └── API_SPEC.md                 # API 데이터 명세서
│
└── .gitignore
```

---

## 3. 아키텍처

```
┌─────────────────────────────────────────────┐
│            사용자 PC (Windows)               │
│                                             │
│  ┌─────────────────────────────────┐        │
│  │   Electron 렌더러 (Chromium)     │        │
│  │   HTML / CSS / Vanilla JS       │        │
│  └───────────┬─────────────────────┘        │
│              │ contextBridge IPC             │
│  ┌───────────▼─────────────────────┐        │
│  │   Electron 메인 프로세스         │        │
│  │   → PowerShell 실행 (사양 수집)  │        │
│  │   → fetch → 서버                 │        │
│  └───────────┬─────────────────────┘        │
│              │ HTTP (localhost:3001)         │
│  ┌───────────▼─────────────────────┐        │
│  │   Express 서버 (Node.js)         │        │
│  │   POST /api/analyze             │        │
│  │   → 프롬프트 생성 → Gemini 호출  │        │
│  └───────────┬─────────────────────┘        │
└─────────────────────────────────────────────┘
              │ HTTPS (외부)
┌─────────────▼─────────────┐
│   Google Gemini API        │
└───────────────────────────┘
```

**보안 설계 원칙:**
- 렌더러는 Node.js 직접 접근 불가 (`contextIsolation: true`)
- `preload.js`가 `electronAPI.collectSpecs()` / `electronAPI.analyze()` 만 노출
- Gemini API 키는 서버에만 보관 → 클라이언트에 키 미노출

---

## 4. 개발 환경 세팅

### 사전 설치

- [Node.js 22 LTS](https://nodejs.org) 설치

### 프로젝트 클론 및 의존성 설치

```bash
git clone https://github.com/tokkiyashou/Comdoctor.git
cd Comdoctor

cd server && npm install
cd ../electron-app && npm install
```

### 환경변수 초기화

```bash
copy server\.env.example server\.env
copy electron-app\.env.example electron-app\.env
```

`electron-app/.env`의 `SERVER_URL`은 기본값(`http://127.0.0.1:3001`)으로 두면 됩니다.  
`server/.env`에 API 키를 입력하세요 (5장 참고).

---

## 5. API 키 설정

### 5-1. Gemini API 키 발급

1. [Google AI Studio](https://aistudio.google.com/app/apikey) 접속
2. Google 계정으로 로그인
3. **Create API key** 클릭
4. 생성된 키 복사 (`AIza...` 로 시작)

무료 한도: 15 req/분, 1,500 req/일

### 5-2. 네이버 쇼핑 API 키 발급

1. [네이버 개발자 센터](https://developers.naver.com) 접속
2. 애플리케이션 등록 → **검색** API 선택
3. Client ID / Client Secret 복사

무료 한도: 25,000건/일

### 5-3. server/.env 등록

```
GEMINI_API_KEY=AIzaSy...여기에_붙여넣기
GEMINI_MODEL=gemini-2.5-flash
PORT=3001
NAVER_CLIENT_ID=네이버_클라이언트_ID
NAVER_CLIENT_SECRET=네이버_클라이언트_시크릿
```

### 5-4. 동작 확인

서버 실행 후 아래 주소 접속:

```
http://127.0.0.1:3001/health
```

`{"status":"ok"}` 가 보이면 정상.

### 5-5. 주의사항

- `.env` 파일은 절대 git에 올리지 마세요 (`.gitignore`에 포함)
- API 키가 유출되면 즉시 삭제 후 재발급

---

## 6. 개발 실행

컴닥터는 **백엔드 서버**와 **Electron 앱** 두 프로세스를 동시에 실행해야 합니다.

```bash
# 터미널 1 — 백엔드 서버
cd server
node index.js

# 터미널 2 — Electron 앱
cd electron-app
npm start
```

두 터미널 모두 켜진 상태에서 앱 창이 뜨면 정상입니다.

---

## 7. 빌드 및 배포

### exe 패키징

```bash
cd electron-app
npm run build
# → electron-app/dist/컴닥터 Setup x.x.x.exe
```

### 빌드 전 체크리스트

1. `electron-app/.env`의 `SERVER_URL` 확인
   - 로컬: `http://127.0.0.1:3001`
   - 배포용: `https://your-server.com`
2. 서버는 켜지 않아도 됨 (빌드는 Electron 앱만 패키징)

### 소요 시간

- 최초 빌드: 3~5분 (Electron 바이너리 다운로드 포함)
- 이후 빌드: 1~2분

---

## 8. 주요 파일 역할

### `server/routes/analyze.js`

| 함수/라우트 | 역할 |
|------------|------|
| `buildUserPrompt()` | PC 사양을 압축된 키:값 텍스트로 변환 (토큰 절약) |
| `callGemini()` | Gemini REST API 직접 호출 (SDK 미사용, v1beta 엔드포인트) |
| `lookupGpuTier()` | GPU 티어/점수 추정값 계산 후 프롬프트 주입 |
| `fetchNaverPrice()` | 네이버 쇼핑 API로 실시간 가격 조회 |
| `POST /api/analyze` | 요청 수신 → 프롬프트 빌드 → Gemini 호출 → 가격 보정 → JSON 반환 |

### `electron-app/main.js`

| 항목 | 설명 |
|------|------|
| `PS_SCRIPT` | PowerShell로 CPU/MB/RAM/GPU/Storage/OS 수집 |
| `ipcMain.handle('collect-specs')` | 사양 수집 → JSON 반환 |
| `ipcMain.handle('analyze')` | 서버에 fetch 후 결과 반환 (120초 타임아웃) |

### `electron-app/renderer/app.js`

| 항목 | 설명 |
|------|------|
| `state` 객체 | 현재 화면, 스펙, 목적, 예산 등 전역 상태 |
| `App.showScreen(name)` | CSS opacity+transform 트랜지션으로 화면 전환 |
| `renderResults(data, usage)` | 결과 카드, 레이더 차트, 토큰 정보 렌더링 |
| `drawRadar(scores, scoresAfter)` | 순수 SVG 오각 레이더 차트 생성 |

**화면 흐름:**
```
main → step1 → [collecting] → step2 → step3 → step4 → [analyzing] → results
                    ↓
                  manual (직접 입력)
```

---

## 9. 환경변수

### `server/.env`

| 변수 | 설명 | 기본값 |
|------|------|--------|
| `GEMINI_API_KEY` | Google AI Studio API 키 | 없음 (필수) |
| `GEMINI_MODEL` | 사용할 모델명 | `gemini-2.5-flash` |
| `PORT` | 서버 포트 | `3001` |
| `NAVER_CLIENT_ID` | 네이버 쇼핑 API 클라이언트 ID | 없음 (실시간 가격 조회 시 필수) |
| `NAVER_CLIENT_SECRET` | 네이버 쇼핑 API 클라이언트 시크릿 | 없음 (실시간 가격 조회 시 필수) |

### `electron-app/.env`

| 변수 | 설명 | 기본값 |
|------|------|--------|
| `SERVER_URL` | 백엔드 서버 주소 | `http://127.0.0.1:3001` |

---

## 10. 로그 시스템

로그 파일 위치: `server/logs/{type}/YYYY-MM.log` (월별 자동 분리)

| 종류 | 경로 | 보관 기준 |
|------|------|----------|
| 접속 로그 | `logs/access/` | 3개월+ |
| API 호출 로그 | `logs/api/` | 3개월+ |
| 에러 로그 | `logs/error/` | 6개월+ |
| 통계 로그 | `logs/stats/` | 1년+ |

### 로그 포맷

**접속 로그:**
```
[2026-05-10T14:23:01.234Z] POST /api/analyze 200 3421ms 127.0.0.1
```

**API 로그:**
```json
{"ts":"...","success":true,"model":"gemini-2.5-flash","purpose":"게임","budget":500000,"promptTokens":523,"outputTokens":412,"totalTokens":935,"durationMs":3421}
```

**통계 로그 (자정 자동 집계):**
```json
{"date":"2026-05-10","total":47,"succeeded":45,"failed":2,"totalTokens":43820,"avgDurationMs":2841}
```

---

## 11. 서버 확장 가이드

현재는 서버와 앱이 같은 PC에서 실행됩니다.

### 확장 단계별 로드맵

```
단계 1 (현재) — 로컬 단일 PC
  └── 서버 + 앱 동일 PC, 개인 사용

단계 2 — 서버컴 분리
  └── LAN: 서버컴(PM2) + 사용자 PC(Electron 앱)

단계 3 — 외부 공개
  └── 인터넷: 서버컴(nginx + HTTPS + PM2)
      → Rate Limiting, 인증 필요

단계 4 — 클라우드
  └── AWS / GCP / Render 등 배포
      → Docker 컨테이너화 권장
```

### PM2로 서버 상시 실행

```bash
npm install -g pm2
cd server
pm2 start index.js --name comdoctor-server
pm2 save
pm2 startup
```

| 명령어 | 설명 |
|--------|------|
| `pm2 status` | 실행 중인 프로세스 목록 |
| `pm2 logs comdoctor-server` | 실시간 로그 확인 |
| `pm2 restart comdoctor-server` | 서버 재시작 |
| `pm2 stop comdoctor-server` | 서버 중지 |

### LAN 환경 설정

```powershell
# 서버컴 IP 확인
ipconfig

# 방화벽 포트 허용 (관리자 권한)
New-NetFirewallRule -DisplayName "ComDoctor Server" -Direction Inbound -Protocol TCP -LocalPort 3001 -Action Allow
```

`electron-app/.env` 수정:
```
SERVER_URL=http://192.168.1.xxx:3001
```

### 멀티 사용자 고려사항

| 항목 | 현재 | 확장 방향 |
|------|------|----------|
| 요청 처리 | 단일 프로세스 | PM2 cluster 모드 |
| Rate Limiting | 없음 | express-rate-limit 추가 |
| 데이터베이스 | stub | MongoDB / PostgreSQL 연동 |
| 인증 | 없음 | JWT 인증 추가 |
