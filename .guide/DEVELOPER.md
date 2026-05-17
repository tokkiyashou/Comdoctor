> 이 파일은 기술 스택, 프로젝트 구조, 아키텍처, 주요 파일 역할, 로그 시스템, 서버 확장 방법을 다루는 개발자용 기술 문서입니다.

# 컴닥터 — 개발자 문서

## 목차

1. [기술 스택](#1-기술-스택)
2. [프로젝트 구조](#2-프로젝트-구조)
3. [아키텍처](#3-아키텍처)
4. [주요 파일 역할](#4-주요-파일-역할)
5. [환경변수](#5-환경변수)
6. [로그 시스템](#6-로그-시스템)
7. [빌드 및 실행](#7-빌드-및-실행)
8. [서버 확장 가이드](#8-서버-확장-가이드)

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

### 언어별 역할 요약

```
JavaScript (Node.js)
  ├── electron-app/main.js        ← 앱 진입점, 시스템 연동
  ├── electron-app/preload.js     ← 보안 브릿지
  ├── electron-app/renderer/app.js← UI 로직
  ├── server/index.js             ← 서버 진입점
  ├── server/routes/analyze.js    ← AI 호출 라우터
  └── server/logger.js            ← 로그 유틸

HTML / CSS
  └── electron-app/renderer/      ← 앱 UI 전체

PowerShell
  └── main.js 내 PS_SCRIPT 상수   ← PC 사양 수집 (인라인 스크립트)
```

---

## 2. 프로젝트 구조

```
comdoctor/
│
├── server/                         # 백엔드 서버 (Express.js)
│   ├── index.js                    # 서버 진입점 — 미들웨어, 라우터, 로그 스케줄러
│   ├── logger.js                   # 로깅 유틸 — access / api / error / stats
│   ├── db.js                       # DB 연동 (현재 stub, 향후 확장)
│   ├── package.json                # express, dotenv 등 의존성
│   ├── .env                        # 환경변수 (git 제외)
│   ├── .env.example                # 환경변수 템플릿
│   ├── routes/
│   │   └── analyze.js              # POST /api/analyze — Gemini 호출 및 결과 반환
│   └── logs/                       # 자동 생성됨, git 제외
│       ├── access/YYYY-MM.log      # HTTP 접속 로그
│       ├── api/YYYY-MM.log         # Gemini API 호출 로그
│       ├── error/YYYY-MM.log       # 에러 로그
│       └── stats/YYYY-MM.log       # 일별 요약 통계
│
├── electron-app/                   # Electron 데스크톱 앱
│   ├── main.js                     # 메인 프로세스 — 창 생성, IPC 핸들러, PowerShell 실행
│   ├── preload.js                  # contextBridge — 렌더러↔메인 IPC 브릿지 (보안)
│   ├── package.json                # Electron, electron-builder 설정 + 빌드 구성
│   ├── .env                        # SERVER_URL 설정 (git 제외)
│   ├── .env.example                # 환경변수 템플릿
│   ├── assets/                     # 정적 에셋
│   │   └── Logo.png                # 앱 로고 이미지 (창 아이콘, 화면 표시)
│   └── renderer/                   # UI (Chromium 렌더러에서 실행)
│       ├── index.html              # 전체 화면 구조 (Single-Page, 화면 9개)
│       ├── styles.css              # 다크테마 스타일 — 애니메이션, 레이아웃
│       └── app.js                  # UI 상태 머신 및 로직 (App 객체)
│
├── landing/                        # 랜딩 페이지 (정적 HTML, 서버 불필요)
│   ├── index.html                  # 메인 소개 페이지
│   ├── detail.html                 # 상세 소개 페이지
│   └── styles.css                  # 랜딩 전용 스타일
│
├── .guide/
│   ├── DEVELOPER.md                # 이 파일 — 기술 문서
│   ├── DEV_GUIDE.md                # 개발 환경 전체 가이드 (새 PC 세팅, API 키, 실행, 빌드)
│   └── API_SPEC.md                 # API 데이터 명세서
├── .gitignore                      # node_modules, .env, dist, *.log 제외
└── 컴닥터 로고.png                  # 원본 로고 파일
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
│  │   → App.* 메서드로 화면 전환     │        │
│  └───────────┬─────────────────────┘        │
│              │ contextBridge IPC             │
│  ┌───────────▼─────────────────────┐        │
│  │   Electron 메인 프로세스         │        │
│  │   (Node.js)                      │        │
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
│   (gemini-2.5-flash 등)    │
└───────────────────────────┘
```

**보안 설계 원칙:**
- 렌더러는 Node.js 직접 접근 불가 (`contextIsolation: true`)
- `preload.js`가 `electronAPI.collectSpecs()` / `electronAPI.analyze()` 만 노출
- Gemini API 키는 서버에만 보관 → 클라이언트에 키 미노출

---

## 4. 주요 파일 역할

### `server/routes/analyze.js`

| 함수/라우트 | 역할 |
|------------|------|
| `buildUserPrompt()` | PC 사양을 압축된 키:값 텍스트로 변환 (토큰 절약) |
| `callGemini()` | Gemini REST API 직접 호출 (SDK 미사용, v1beta 엔드포인트) |
| `POST /api/analyze` | 요청 수신 → 프롬프트 빌드 → Gemini 호출 → JSON 반환 |

### `electron-app/main.js`

| 항목 | 설명 |
|------|------|
| `PS_SCRIPT` | PowerShell로 CPU/MB/RAM/GPU/Storage/OS 수집 (Base64 인코딩 전달) |
| `ipcMain.handle('collect-specs')` | 사양 수집 → JSON 반환 (비중요 에러 키 필터링) |
| `ipcMain.handle('analyze')` | 서버에 fetch 후 결과 반환 |
| `Menu.setApplicationMenu(null)` | 메뉴바 숨김 |

### `electron-app/renderer/app.js`

| 항목 | 설명 |
|------|------|
| `state` 객체 | 현재 화면, 스펙, 목적, 예산 등 전역 상태 |
| `App.showScreen(name)` | CSS opacity+transform 트랜지션으로 화면 전환 |
| `renderResults(data, usage)` | 결과 카드, 레이더 차트, 토큰 정보 렌더링 |
| `drawRadar(scores, scoresAfter)` | 순수 SVG 오각 레이더 차트 생성 |
| `buildCard(u, idx)` | 업그레이드 카드 HTML 생성 (자세히 토글, 복사 버튼) |

**화면 흐름:**
```
main → step1 → [collecting] → step2 → step3 → step4 → [analyzing] → results
                    ↓
                  manual (직접 입력)
```

---

## 5. 환경변수

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

## 6. 로그 시스템

로그 파일 위치: `server/logs/{type}/YYYY-MM.log` (월별 자동 분리)

| 종류 | 경로 | 보관 기준 |
|------|------|----------|
| 접속 로그 | `logs/access/` | 3개월+ (정보통신망법) |
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

### logger.js API

```javascript
logger.access(req, res, durationMs)
logger.api({ purpose, budget, model, usage, durationMs, success, error })
logger.error('context', err)
logger.writeDailySummary()  // 자정 자동 호출
```

---

## 7. 빌드 및 실행

자세한 내용은 `DEV_GUIDE.md` 참고.

```bash
# 개발 모드 (터미널 2개)
cd server && node index.js
cd electron-app && npm start

# exe 패키징
cd electron-app && npm run build
# → electron-app/dist/컴닥터 Setup x.x.x.exe
```

---

## 8. 서버 확장 가이드

현재는 서버와 앱이 같은 PC에서 실행됩니다. 사용자가 많아지거나 별도 서버컴을 두는 경우의 확장 방법입니다.

---

### 8-1. 현재 구조 vs 확장 구조

```
【현재 — 로컬 단일 PC】
  사용자 PC: [Electron 앱] ──localhost──▶ [Express 서버]

【확장 — 서버컴 분리】
  사용자 PC:  [Electron 앱] ──LAN/인터넷──▶ [서버컴: Express 서버]
  서버컴:     Express + PM2 상시 실행
```

---

### 8-2. 서버컴에서 서버 실행하기

#### Step 1 — 서버컴에 Node.js 설치

```bash
# Windows: winget 또는 https://nodejs.org 에서 LTS 설치
winget install OpenJS.NodeJS.LTS

# 설치 확인
node --version   # v20 이상 권장
```

#### Step 2 — 프로젝트 복사 및 의존성 설치

```bash
# 서버컴에서
cd server
npm install
```

`.env` 파일 생성:
```
GEMINI_API_KEY=your_key_here
GEMINI_MODEL=gemini-2.5-flash
PORT=3001
```

#### Step 3 — PM2로 프로세스 상시 실행

PM2는 서버 프로세스를 백그라운드에서 유지하고, 충돌 시 자동 재시작합니다.

```bash
# PM2 설치 (전역)
npm install -g pm2

# 서버 시작
cd server
pm2 start index.js --name comdoctor-server

# 부팅 시 자동 시작 등록
pm2 save
pm2 startup   # 출력된 명령어를 관리자 권한으로 실행
```

**PM2 주요 명령어:**

| 명령어 | 설명 |
|--------|------|
| `pm2 status` | 실행 중인 프로세스 목록 |
| `pm2 logs comdoctor-server` | 실시간 로그 확인 |
| `pm2 restart comdoctor-server` | 서버 재시작 |
| `pm2 stop comdoctor-server` | 서버 중지 |
| `pm2 delete comdoctor-server` | PM2에서 제거 |

---

### 8-3. 네트워크 설정

#### 같은 LAN (공유기 내부)

서버컴의 로컬 IP를 확인합니다:
```powershell
# 서버컴에서
ipconfig
# → IPv4 주소: 192.168.1.xxx
```

Windows 방화벽에서 포트 허용:
```powershell
# 관리자 권한 PowerShell
New-NetFirewallRule -DisplayName "ComDoctor Server" -Direction Inbound -Protocol TCP -LocalPort 3001 -Action Allow
```

클라이언트(Electron 앱) `electron-app/.env` 수정:
```
SERVER_URL=http://192.168.1.xxx:3001
```

앱을 다시 빌드하거나 재시작하면 서버컴으로 연결됩니다.

#### 외부 인터넷에서 접근 (포트포워딩)

공유기 설정에서 포트포워딩 추가:
- 외부 포트: `3001`
- 내부 IP: 서버컴 로컬 IP (예: `192.168.1.100`)
- 내부 포트: `3001`

서버컴의 공인 IP 확인: [https://api.ipify.org](https://api.ipify.org) 방문

클라이언트 `.env`:
```
SERVER_URL=http://공인IP:3001
```

> ⚠ 공인 IP는 재접속 시 바뀔 수 있음 (유동 IP). 고정 IP 또는 DDNS 서비스 사용 권장.

---

### 8-4. HTTPS 적용 (보안 강화)

HTTP로 운영하면 API 요청 내용이 평문으로 전달됩니다. 외부 공개 시 HTTPS를 적용하세요.

#### 방법 A — nginx 리버스 프록시 + Let's Encrypt (도메인 필요)

```
[사용자] ──HTTPS:443──▶ [nginx] ──HTTP:3001──▶ [Express]
```

1. 도메인 구매 후 서버 IP에 연결
2. nginx 설치 및 설정
3. `certbot`으로 SSL 인증서 자동 발급·갱신

#### 방법 B — Express에 직접 HTTPS 적용 (인증서 있을 때)

```javascript
// server/index.js 수정 예시
const https = require('https')
const fs = require('fs')

const options = {
  key: fs.readFileSync('cert/privkey.pem'),
  cert: fs.readFileSync('cert/fullchain.pem')
}
https.createServer(options, app).listen(443)
```

클라이언트 `.env`:
```
SERVER_URL=https://your-domain.com
```

---

### 8-5. 멀티 사용자 확장 시 고려사항

여러 사람이 동시에 사용하는 경우:

| 항목 | 현재 상태 | 확장 방향 |
|------|-----------|----------|
| **요청 처리** | 단일 프로세스, 순차 처리 | PM2 cluster 모드 (CPU 코어 수만큼 병렬) |
| **API 한도** | Gemini 무료: 1,500 req/일 | 사용량 증가 시 유료 플랜 전환 |
| **Rate Limiting** | 없음 | express-rate-limit 추가 |
| **데이터베이스** | db.js stub (미사용) | MongoDB / PostgreSQL 연동 |
| **인증** | 없음 (로컬 전용) | API 키 또는 JWT 인증 추가 |
| **모니터링** | 로그 파일만 | PM2 모니터링 + 외부 서비스 (UptimeRobot 등) |

#### PM2 Cluster 모드 (간단한 멀티코어 활용)

```bash
# CPU 코어 수만큼 프로세스 실행
pm2 start index.js --name comdoctor-server -i max
```

#### Rate Limiting 추가 예시

```javascript
// server/index.js에 추가
const rateLimit = require('express-rate-limit')

const limiter = rateLimit({
  windowMs: 60 * 1000,  // 1분
  max: 10,              // IP당 최대 10회
  message: { success: false, error: 'TOO_MANY_REQUESTS', message: '잠시 후 다시 시도해주세요' }
})
app.use('/api/', limiter)
```

```bash
npm install express-rate-limit
```

---

### 8-6. 클라이언트 배포 전략

서버 주소가 바뀌면 Electron 앱을 다시 빌드해야 합니다. 이를 피하는 방법:

**방법 A — 앱 설치 후 설정 파일로 관리 (권장)**

`electron-app/main.js`에서 SERVER_URL을 앱 데이터 폴더의 설정 파일에서 읽도록 확장:
```javascript
// 향후 구현 방향
const configPath = path.join(app.getPath('userData'), 'config.json')
// 사용자가 앱 내 설정 화면에서 서버 주소를 바꿀 수 있게
```

**방법 B — 환경별 빌드**

```bash
# 로컬용
SERVER_URL=http://localhost:3001 npm run build

# 서버컴용
SERVER_URL=http://192.168.1.100:3001 npm run build
```

---

### 8-7. 확장 단계별 로드맵

```
단계 1 (현재)
  └── 로컬 PC: 서버 + 앱 동일 PC
      → 개인 사용, 개발 테스트

단계 2 (서버컴 분리)
  └── LAN: 서버컴(PM2) + 사용자 PC(Electron 앱)
      → 가정/사무실 내 소규모 공유

단계 3 (외부 공개)
  └── 인터넷: 서버컴(nginx + HTTPS + PM2) + 다수 사용자
      → 포트포워딩 or 클라우드 VPS
      → Rate Limiting, 인증 필요

단계 4 (클라우드)
  └── AWS / GCP / Vercel 등에 서버 배포
      → Docker 컨테이너화 권장
      → CI/CD 파이프라인 구성
```
