# 컴닥터 (ComDoctor)

PC 사양을 자동으로 수집하고, AI가 사용 목적과 예산에 맞는 업그레이드 플랜을 추천해주는 Windows 데스크톱 앱입니다.

---

## 주요 기능

- PC 사양 자동 수집 (CPU, GPU, RAM, 저장장치, OS)
- 사용 목적 · 예산 기반 AI 업그레이드 추천 (Google Gemini)
- 네이버 쇼핑 API를 통한 실시간 최저가 조회
- 부품별 성능 점수 및 레이더 차트 시각화

---

## 기술 스택

| 영역 | 기술 |
|------|------|
| 데스크톱 앱 | Electron v32 |
| 백엔드 서버 | Express.js |
| AI 분석 | Google Gemini API |
| 가격 조회 | 네이버 쇼핑 API |
| PC 사양 수집 | PowerShell (WMI) |
| 패키징 | electron-builder |

---

## 시작하기

### 사전 요구사항

- [Node.js 22 LTS](https://nodejs.org) 이상
- Windows 운영체제

### 설치

```bash
git clone https://github.com/tokkiyashou/Comdoctor.git
cd Comdoctor

cd server && npm install
cd ../electron-app && npm install
```

### 환경변수 설정

```bash
copy server\.env.example server\.env
copy electron-app\.env.example electron-app\.env
```

`server/.env`에 API 키를 입력합니다:

```
GEMINI_API_KEY=발급받은_Gemini_API_키
GEMINI_MODEL=gemini-2.5-flash
PORT=3001
NAVER_CLIENT_ID=네이버_클라이언트_ID
NAVER_CLIENT_SECRET=네이버_클라이언트_시크릿
```

- Gemini API 키: [Google AI Studio](https://aistudio.google.com/app/apikey)
- 네이버 API 키: [네이버 개발자 센터](https://developers.naver.com)

### 실행

```bash
# 터미널 1 — 서버
cd server
node index.js

# 터미널 2 — 앱
cd electron-app
npm start
```

---

## 빌드 (.exe 패키징)

```bash
cd electron-app
npm run build
# electron-app/dist/컴닥터 Setup x.x.x.exe 생성
```

---

## 프로젝트 구조

```
Comdoctor/
├── server/                 # Express 백엔드
│   ├── index.js
│   ├── routes/analyze.js   # Gemini 호출 및 가격 조회
│   └── logger.js
├── electron-app/           # Electron 클라이언트
│   ├── main.js
│   ├── preload.js
│   └── renderer/           # UI (HTML/CSS/JS)
├── landing/                # 소개 웹페이지
└── .guide/                 # 개발 문서
    ├── API_SPEC.md
    ├── DEVELOPER.md
    └── DEV_GUIDE.md
```

---

## 브랜치 전략

| 브랜치 | 용도 |
|--------|------|
| `main` | 배포용, 직접 push 금지 |
| `develop` | 개발 통합 |
| `feature/*` | 기능 개발 |
| `fix/*` | 버그 수정 |

### 작업 흐름

```
feature/기능명 → develop (PR) → main (PR, 릴리즈 시)
```

1. `develop`에서 `feature/기능명` 브랜치 생성
2. 작업 완료 후 `develop`으로 PR
3. 리뷰 후 머지
4. 릴리즈 시 `develop` → `main` PR

### 커밋 메시지 규칙

```
feat: 기능 추가
fix: 버그 수정
docs: 문서 수정
style: 코드 포맷
refactor: 리팩토링
```
