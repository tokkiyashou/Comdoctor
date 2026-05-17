# 컴닥터 — Electron 앱

## 실행 방법

1. `server/` 먼저 실행
2. `electron-app/` 실행

```bash
# 터미널 1: 서버
cd server
npm install
node index.js

# 터미널 2: 앱
cd electron-app
npm install
npm start
```

## Gemini API 키 설정

### 1. API 키 발급

1. [Google AI Studio](https://aistudio.google.com/app/apikey) 접속
2. **Create API key** 클릭
3. 키 복사

### 2. 서버에 키 등록

`server/.env` 파일을 생성하고 아래 내용을 입력:

```
GEMINI_API_KEY=발급받은_키를_여기에_붙여넣기
GEMINI_MODEL=gemini-2.5-flash
PORT=3001
NAVER_CLIENT_ID=네이버_클라이언트_ID
NAVER_CLIENT_SECRET=네이버_클라이언트_시크릿
```

### 3. 앱 서버 URL 설정 (선택)

`electron-app/.env` 파일을 생성:

```
SERVER_URL=http://127.0.0.1:3001
```

서버를 다른 포트나 원격으로 배포했다면 이 URL을 변경하세요.

## API 키 변경 방법

`server/.env` 파일을 열고 `GEMINI_API_KEY=` 뒤의 값을 새 키로 교체한 후 서버를 재시작하면 됩니다:

```bash
# 서버 재시작
Ctrl+C  # 서버 중지
node index.js  # 재시작
```

## 빌드 (.exe 패키징)

```bash
cd electron-app
npm run build
# dist/ 폴더에 ComDoctor Setup.exe 생성됨
```

## 프로젝트 구조

```
comdoctor/
├── server/              # Express 백엔드 서버
│   ├── index.js
│   ├── routes/
│   │   └── analyze.js   # Gemini API 호출, 프롬프트 빌더
│   └── db.js            # DB stub (나중에 채울 것)
├── electron-app/        # Electron 클라이언트
│   ├── main.js          # 메인 프로세스 + PowerShell IPC
│   ├── preload.js       # 보안 IPC 브릿지
│   └── renderer/        # UI (HTML/CSS/JS)
└── landing/             # 정적 웹사이트
```
