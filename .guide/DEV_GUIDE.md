> 이 파일은 새 PC 세팅부터 API 키 등록, 개발 실행, exe 빌드·배포까지 개발 환경 전체를 다루는 가이드입니다.

# 컴닥터 개발 환경 가이드

## 1. 새 PC 세팅

### 사전 설치

- [Node.js 22 LTS](https://nodejs.org) 설치

### 프로젝트 세팅

```bash
git clone <저장소 주소>
cd comdoctor

cd server
npm install

cd ../electron-app
npm install
```

### 환경변수 초기화

```bash
# server/.env 생성
copy server\.env.example server\.env

# electron-app/.env 생성
copy electron-app\.env.example electron-app\.env
```

`server/.env`에 Gemini API 키와 네이버 API 키를 입력하세요 (2장 참고). `electron-app/.env`의 `SERVER_URL`은 기본값(`http://127.0.0.1:3001`)으로 두면 됩니다.

---

## 2. API 키 설정

### 2-1. 발급

1. [Google AI Studio](https://aistudio.google.com/app/apikey) 접속
2. Google 계정으로 로그인
3. **Create API key** 클릭
4. 생성된 키 복사 (`AIza...` 로 시작하는 문자열)

무료 한도: 15 req/분, 1,500 req/일

### 2-2. 등록

`server/.env`를 열고 아래와 같이 입력:

```
GEMINI_API_KEY=AIzaSy...여기에_붙여넣기
GEMINI_MODEL=gemini-2.5-flash
PORT=3001
NAVER_CLIENT_ID=네이버_클라이언트_ID
NAVER_CLIENT_SECRET=네이버_클라이언트_시크릿
```

`.env` 파일이 없으면 템플릿을 복사해서 만드세요:

```bash
copy server\.env.example server\.env
```

### 2-3. 키 변경

1. `server/.env` 파일 열기
2. `GEMINI_API_KEY=` 뒤의 값을 새 키로 교체
3. 서버 재시작:

```bash
cd server
node index.js
```

### 2-4. 동작 확인

서버 실행 후 브라우저에서 아래 주소 접속:

```
http://127.0.0.1:3001/health
```

`{"status":"ok"}` 가 보이면 서버 정상. 앱에서 실제 분석을 돌려보면 키 유효 여부 확인 가능.

### 2-5. 모델명 변경

Gemini 모델명이 바뀌면 `server/.env`의 `GEMINI_MODEL` 값만 수정 후 서버 재시작:

```
GEMINI_MODEL=gemini-2.5-flash   ← 새 모델명으로 교체
```

### 2-6. 주의사항

- `.env` 파일은 절대 git에 올리지 마세요 (`.gitignore`에 포함되어 있음)
- API 키가 유출되면 Google AI Studio에서 즉시 삭제 후 재발급
- 무료 한도 초과 시 앱에서 "잠시 후 다시 시도해주세요" 메시지 표시

---

## 3. 개발 실행

### 왜 터미널이 두 개인가?

컴닥터는 **백엔드 서버**와 **Electron 앱** 두 개로 분리된 구조입니다.

```
[개발 중 — 내 PC에서 전부 실행]

터미널 1: server/        ← 나중에 클라우드(Render 등)가 대신할 것
터미널 2: electron-app/  ← 나중에 사용자가 .exe 더블클릭으로 대신할 것
```

백엔드 서버가 하는 일:
- Gemini API 키 보관 및 호출 (키가 사용자 PC에 노출되지 않도록)
- (나중에) 진단 이력 DB 저장

Electron 앱이 하는 일:
- 사용자 UI 표시
- PowerShell로 PC 사양 수집
- 백엔드 서버에 분석 요청 전송

배포 후에는 백엔드 서버만 클라우드로 이전하면 끝. Electron 앱 코드는 변경 없음.

### 터미널 1 — 백엔드 서버

```bash
cd server
npm install     # 최초 1회만
node index.js
```

정상 실행 시:
```
컴닥터 서버 실행 중: http://127.0.0.1:3001
```

### 터미널 2 — Electron 앱

```bash
cd electron-app
npm install     # 최초 1회만
npm start
```

두 터미널 모두 켜진 상태에서 앱 창이 뜨면 정상입니다.

---

## 4. 빌드 및 배포

### exe 패키징

```bash
cd electron-app
npm run build
```

완료되면 `electron-app/dist/` 폴더에 설치 파일이 생깁니다:

```
electron-app/dist/
├── 컴닥터 Setup 1.0.0.exe   ← 배포용 설치 파일
└── win-unpacked/            ← 설치 없이 바로 실행 가능한 폴더
```

### 빌드 전 체크리스트

1. `electron-app/.env`의 `SERVER_URL`이 올바른지 확인
   - 로컬 테스트용: `SERVER_URL=http://127.0.0.1:3001`
   - 배포용: `SERVER_URL=https://your-server.com`
2. 서버는 켜지 않아도 됩니다 (빌드는 Electron 앱만 패키징)

### UI 수정 후 재빌드

renderer 폴더(HTML/CSS/JS)를 수정했다면 반드시 재빌드해야 반영됩니다.

```bash
npm start          # 먼저 개발 모드로 확인
npm run build      # 확인 후 빌드
```

### 소요 시간

- 최초 빌드: 3~5분 (Electron 바이너리 다운로드 포함)
- 이후 빌드: 1~2분

### 배포 후 구조

```
사용자 PC                        클라우드 (Render 등)
┌─────────────────────┐          ┌──────────────────────┐
│   ComDoctor.exe     │  HTTP →  │   server/index.js    │
│   (Electron 앱)     │          │   Gemini API 호출     │
│   - UI 표시         │  ← JSON  │   DB 저장             │
│   - PC 사양 수집    │          └──────────────────────┘
└─────────────────────┘
```

배포 후에는:
- **사용자**: .exe 더블클릭만 하면 됨. 터미널 없음.
- **서버**: 클라우드에서 24시간 자동 실행. 터미널 없음.

배포 시 `electron-app/.env`의 `SERVER_URL`을 클라우드 주소로 변경 후 재빌드:

```
SERVER_URL=https://comdoctor-api.onrender.com
```
