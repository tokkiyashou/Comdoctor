> 이 파일은 데이터가 앱에서 AI까지 흘러가는 전체 경로와 각 단계의 정확한 양식(요청/응답 구조, 프롬프트, 가격 로직)을 정리한 API 명세서입니다.

# 컴닥터 — API 데이터 명세서

---

## 전체 흐름 요약

```
[Electron 앱]
     │
     │ ① IPC (collect-specs)
     ▼
[PowerShell] ──────────────── PC 사양 수집
     │
     │ ② specs JSON 반환
     ▼
[Electron 앱]
     │
     │ ③ IPC (analyze) → POST /api/analyze
     │   { specs, purpose, subPurpose, budget }
     ▼
[Express 서버]
     │  buildUserPrompt() → 압축된 텍스트 프롬프트 생성
     │  lookupGpuTier()  → GPU 티어/점수 추정값 프롬프트에 주입
     │
     │ ④ POST generativelanguage.googleapis.com/v1beta
     │   systemInstruction + contents 분리 전송
     ▼
[Gemini API]
     │
     │ ⑤ 응답 JSON (candidates + usageMetadata)
     │   thinking 파트 제거 후 JSON 추출 및 파싱
     │   upgrades를 점수 상승폭(delta) 기준 재정렬
     │
     │ ⑤.5 추천 제품명으로 네이버 쇼핑 API 병렬 호출
     │      → price_min / price_max 실제 시세로 덮어쓰기
     ▼
[네이버 쇼핑 API] ─────────── 실시간 최저가 조회
     │
     │ ⑥ { success, data, usage }
     ▼
[Electron 앱] → 화면 렌더링
```

---

## ① PC 사양 수집 (PowerShell → Electron)

`main.js`의 `ipcMain.handle('collect-specs')`가 PowerShell 인코딩 명령으로 WMI를 쿼리합니다.

### 수집 항목별 WMI 쿼리 출처

| 항목 | WMI 클래스 | 수집 불가 시 |
|------|-----------|-------------|
| CPU | `Win32_Processor` | `null` |
| 메인보드 | `Win32_BaseBoard` | `null` |
| RAM | `Win32_PhysicalMemory` + `Win32_PhysicalMemoryArray` | `null` |
| GPU | `Win32_VideoController` (`Microsoft Basic` 제품 제외) | `null` |
| GPU VRAM | `AdapterRAM` (**1GB 이상**인 경우만 GB 변환, 미만은 `null`) | `null` |
| 저장장치 | `Get-PhysicalDisk` → 실패 시 `Win32_DiskDrive` fallback | `null` |
| OS | `Win32_OperatingSystem` | `null` |
| PSU / 케이스 | **WMI 수집 불가** — 수동 입력 시에만 포함 | — |

> `*Error` 키(예: `gpuError`, `ramError`)는 `main.js`에서 파싱 후 자동 제거됩니다.

---

## ② specs JSON 반환 (PowerShell → Electron)

PowerShell 수집 완료 후 Electron 메인 프로세스로 반환되는 JSON 형식입니다.

```json
{
  "cpu": {
    "name": "Intel Core i5-10400",
    "manufacturer": "GenuineIntel",
    "cores": 6,
    "threads": 12,
    "maxClockMHz": 4300,
    "socket": "LGA1200"
  },
  "motherboard": {
    "manufacturer": "ASUS",
    "model": "PRIME B460M-A"
  },
  "ram": {
    "totalGB": 16,
    "totalSlots": 4,
    "usedSlots": 2,
    "modules": [
      { "capacityGB": 8, "speedMHz": 3200, "type": "DDR4", "slot": "DIMM_A1" },
      { "capacityGB": 8, "speedMHz": 3200, "type": "DDR4", "slot": "DIMM_B1" }
    ]
  },
  "gpu": [
    { "name": "NVIDIA GeForce GTX 1060", "vramGB": 6 }
  ],
  "storage": [
    { "name": "Samsung SSD 870 EVO", "busType": "SATA", "mediaType": "SSD", "sizeGB": 500 },
    { "name": "WDC WD10EZEX", "busType": "ATA", "mediaType": "HDD", "sizeGB": 1000 }
  ],
  "os": {
    "caption": "Microsoft Windows 11 Home",
    "architecture": "64-bit",
    "version": "10.0.22631"
  }
}
```

### Electron → 서버 타임아웃

Electron의 `ipcMain.handle('analyze')`는 서버에 fetch 요청 시 **120초** AbortController를 적용합니다. 초과 시 `err.name === 'AbortError'`로 분기해 사용자에게 별도 메시지를 표시합니다.

---

## ③ 클라이언트 → 서버 요청

**Endpoint:** `POST /api/analyze`  
**Content-Type:** `application/json`

```json
{
  "specs": { /* ① 수집 사양 객체 또는 수동 입력값. 없으면 {} */ },
  "purpose": "게임",
  "subPurpose": "고사양 게임",
  "budget": 1000000
}
```

### 필드 설명

| 필드 | 타입 | 필수 | 설명 |
|------|------|------|------|
| `specs` | object | 아니오 | PC 사양 (없으면 빈 객체 `{}`) |
| `purpose` | string | **예** | 사용 목적 — 아래 8가지 중 하나 |
| `subPurpose` | string | 아니오 | 세부 목적 (선택 옵션 또는 자유입력) |
| `budget` | number | **예** | 예산 (원화, 예: `1000000`) |

### purpose 허용값

| 값 | 설명 |
|----|------|
| `게임` | Step 4 옵션: 가벼운 게임 / 고사양 게임 / 최신 게임 최고옵션 |
| `영상 편집` | 간단한 영상 편집 / 4K 편집 / 색보정·VFX 전문작업 |
| `개인 방송·스트리밍` | 게임+방송 동시 / 캠+화면캡처 / 1080p 60fps 이상 |
| `소프트웨어 개발` | 가벼운 작업 / 대규모 프로젝트 / AI·ML 개발 |
| `무거운 작업` | 3D 모델링·렌더링 / CAD·설계 / 대용량 데이터 처리 |
| `문서 작업` | Step 4 있음 (오피스 / 브라우저 / 협업툴) |
| `콘텐츠 감상` | 스트리밍 / 4K·HDR / 음악 감상 |
| `직접 입력` | Step 4 없음, 자유입력 textarea 표시 |

---

## ④ 서버 → Gemini API 요청

### 엔드포인트

```
POST https://generativelanguage.googleapis.com/v1beta/models/{GEMINI_MODEL}:generateContent?key={API_KEY}
```

> `v1beta` 사용 — `systemInstruction`, `responseMimeType` 등 최신 파라미터 지원 필요

| 변수 | 기본값 |
|------|--------|
| `GEMINI_MODEL` | `gemini-2.5-flash` (`.env`의 `GEMINI_MODEL`로 변경 가능) |
| `API_KEY` | `server/.env`의 `GEMINI_API_KEY` |

### 서버 → Gemini 타임아웃

**90초** AbortController 적용. 초과 시 `AbortError` throw → 클라이언트로 오류 전파.

---

### 요청 바디

시스템 프롬프트와 유저 프롬프트는 **반드시 분리**해서 전송합니다.  
`systemInstruction`에 시스템 프롬프트를 넣어야 `responseMimeType` 등 최신 파라미터가 올바르게 동작합니다.

```json
{
  "systemInstruction": {
    "parts": [{ "text": "<시스템 프롬프트 전문>" }]
  },
  "contents": [
    {
      "role": "user",
      "parts": [{ "text": "<유저 프롬프트 (buildUserPrompt 출력)>" }]
    }
  ],
  "generationConfig": {
    "maxOutputTokens": 8192,
    "temperature": 0.2,
    "responseMimeType": "application/json"
  }
}
```

> `temperature: 0.2` — 창의성을 낮춰 일관된 JSON 출력 유도  
> `maxOutputTokens: 8192` — gemini-2.5-flash 등 thinking 모델은 thinking 토큰도 여기서 소비되므로 충분히 설정  
> `responseMimeType: "application/json"` — Gemini에게 JSON만 출력하도록 강제

---

### 시스템 프롬프트 (전문)

```
당신은 PC 하드웨어 업그레이드 전문가입니다.
사용자의 PC 사양, 사용 목적, 예산을 분석해 최적의 업그레이드 플랜을 제시합니다.

규칙:
1. 반드시 아래 JSON 형식으로만 출력. 설명 텍스트 절대 금지.
2. 호환성은 메인보드 소켓/칩셋/슬롯 기준으로 판단.
3. 예산 초과 추천 금지.
4. upgrades는 0~3개. 예산 내에서 실질적 성능 향상이 있는 것만 포함.
   개선 효과가 없으면 빈 배열. 억지로 채우지 말 것.
   priority는 (scores_after - scores) 점수 상승폭이 큰 순서대로 1, 2, 3 배정.
5. 가격은 현재 한국 시장 기준 원화로.
6. reason은 ~요 체로 작성. 컴퓨터를 잘 모르는 분도 이해할 수 있게 쉽고 친근하게. 30자 이내.
7. detail은 전문가용 기술 설명. 규격·수치·호환 근거 포함. 50자 이내.
8. summary도 ~요 체로, 20자 이내.

9. [점수 기준표] scores는 아래 기준점을 반드시 참고하여 산정. (0~100)

   CPU 기준점 (멀티스레드 성능):
   i9-14900K / Ryzen 9 7950X = 97~99
   i7-14700K / Ryzen 9 7900X = 90~93
   i7-13700K / Ryzen 7 7700X = 85~88
   i5-14600K / Ryzen 7 5800X3D = 78~82
   i5-13600K / Ryzen 5 7600X = 72~76
   i5-12600K / Ryzen 5 5600X = 65~70
   i7-10700 / Ryzen 5 5600 = 58~63
   i5-10400 / i5-10600K / Ryzen 5 3600 = 50~56
   i5-9600K / Ryzen 5 2600 = 42~48
   i5-8400 / i7-6700 = 35~40
   i3급·구형 i5 = 20~34

   GPU 기준점 (3D 게임 성능. VRAM 용량은 점수에 반영 안 함):
   RTX 4090=100, RTX 4080 Super=94, RTX 4080=92
   RTX 4070 Ti Super=88, RX 7900 XTX=86, RTX 4070 Ti=84, RX 7900 XT=81, RTX 4070 Super=80
   RTX 4070=74, RX 7900 GRE=76, RTX 3090 Ti=79, RTX 3090=77, RTX 3080 Ti=75
   RTX 4060 Ti 16GB=68, RTX 4060 Ti=67, RX 7800 XT=65, RTX 3080 12GB=66, RTX 3080=64
   RTX 4060=62, RTX 3070 Ti=64, RTX 3070=63, RX 7700 XT=60, RX 7600 XT=59
   RTX 3060 Ti=58, RX 6700 XT=56, RTX 3060 12GB=54, RTX 3060=54, RX 7600=52
   RTX 3050=46, RX 6600 XT=47, RX 6600=44, RTX 2070 Super=44
   RTX 2060 Super=41, RTX 2070=42, GTX 1080 Ti=40
   RTX 2060=36, GTX 1080=35, RX 6500 XT=28, RX 5500 XT=26
   GTX 1660 Super=28, GTX 1660 Ti=27, GTX 1070 Ti=27, GTX 1070=26
   GTX 1660=22, GTX 1060 6GB=22, GTX 1060=20, RTX 2050=20
   GTX 1050 Ti=16, GTX 1050=13

   RAM 기준점:
   64GB DDR5-6000+ 듀얼채널=95, 32GB DDR5-5600 듀얼채널=85
   32GB DDR4-3600 듀얼채널=78, 16GB DDR5-5600 듀얼채널=72
   16GB DDR4-3200 듀얼채널=65, 16GB DDR4-2666 듀얼채널=60
   8GB DDR4-3200 싱글채널=38, 8GB DDR4-2666 싱글채널=32

   저장장치 기준점:
   NVMe Gen5(읽기 12GB/s+)=95, NVMe Gen4(읽기 7GB/s+)=88
   NVMe Gen3(읽기 3.5GB/s+)=75, SATA SSD(읽기 500MB/s+)=55
   HDD 7200RPM=22, HDD 5400RPM=15

   overall 가중 평균 (사용 목적별):
   게임: CPU×0.25 + GPU×0.50 + RAM×0.15 + 저장장치×0.10
   영상편집: CPU×0.40 + GPU×0.30 + RAM×0.20 + 저장장치×0.10
   개발: CPU×0.40 + GPU×0.10 + RAM×0.35 + 저장장치×0.15
   방송·스트리밍: CPU×0.40 + GPU×0.35 + RAM×0.15 + 저장장치×0.10
   기타/문서/감상: CPU×0.30 + GPU×0.20 + RAM×0.30 + 저장장치×0.20

10. GPU 추천 규칙 — 반드시 아래 순서대로 판단:
    ① 입력된 GPU의 TIER 값을 확인 (입력에 TIER:N 형태로 제공됨)
    ② 예산 내에서 현재 TIER보다 낮은 번호(더 고성능)의 GPU가 존재하는지 확인
    ③ 가능한 GPU가 없으면 → GPU를 upgrades에서 완전 제외, 다른 부품으로 대체
    ④ VRAM이 더 많아도 동일/상위 번호 Tier면 추천 절대 금지

11. 모든 부품 추천 규칙:
    예산 내에서 해당 부품의 실질적 성능 향상이 불가능하면 그 부품은 upgrades에서 제외.
    의미 있는 업그레이드가 0개면 upgrades: [] 반환. 억지로 채우지 말 것.

12. GPU 추천 전 내부 검토 순서 (JSON 출력 전에 반드시 머릿속으로 수행):
    ① 입력의 TIER:N 값 확인 → 현재 GPU Tier 파악
    ② 예산 내 Tier N-1 이하 GPU 존재 여부 확인
    ③ 없으면 GPU는 upgrades에서 제외, 다른 부품으로 채움
    ④ upgrades에 GPU가 포함됐다면 반드시 현재 Tier보다 낮은(고성능) 번호인지 재확인

[❌ 절대 금지 패턴]
현재: RTX 4060 (TIER:5, SCORE_EST:62), 예산 30만원
잘못된 추천: RTX 3060 12GB (Tier 6, 점수 54) → VRAM이 많아도 낮은 Tier = 다운그레이드
올바른 처리: RTX 4060 Ti(Tier 4) 약 35만원 > 예산 초과 → GPU 제외 → RAM/SSD로 대체

출력 형식:
{
  "bottleneck": "현재 가장 큰 병목 부품명",
  "summary": "20자 이내 한줄 진단 (~요 체)",
  "scores": { "cpu": 0, "gpu": 0, "ram": 0, "storage": 0, "overall": 0 },
  "scores_after": { "cpu": 0, "gpu": 0, "ram": 0, "storage": 0, "overall": 0 },
  "upgrades": [
    {
      "priority": 1,
      "part": "부품 종류",
      "current": "현재 사양",
      "recommended": "추천 모델명",
      "reason": "쉽고 친근한 이유 (~요 체, 30자 이내)",
      "detail": "전문가용 기술 설명 (규격·수치 포함, 50자 이내)",
      "compatible": true,
      "incompatible_reason": null,
      "price_min": 0,
      "price_max": 0
    }
  ],
  "total_min": 0,
  "total_max": 0,
  "caution": null
}
```

---

### 유저 프롬프트 — 압축 형식

`buildUserPrompt()` 함수가 specs 객체를 토큰 절약형 텍스트로 변환합니다.  
GPU는 `lookupGpuTier()`로 티어/점수 추정값을 추가 주입합니다.

```
[PC사양]
CPU:Intel_Core_i5-10400|SOCKET:LGA1200|CORES:6C12T|CLOCK:4.3GHz
MB:ASUS_PRIME_B460M-A
RAM:16GB_DDR4-3200|SLOTS:4개중2개사용
GPU:NVIDIA_GeForce_GTX_1060-6GB|PCIE:x16|TIER:11|SCORE_EST:20
STORAGE:SSD_SATA_500GB|HDD_1000GB
OS:MicrosoftWindows11Home_64bit

[사용목적] 게임
[세부목적] 고사양_게임
[예산] 1000000원
```

### 압축 규칙

| 원본 | 변환 |
|------|------|
| 공백 | `_` (언더스코어) |
| `®`, `™`, `()` | 제거 |
| `maxClockMHz` | GHz 단위로 변환 (`4300 → 4.3GHz`) |
| 없는 항목 | `미확인` |
| 저장장치 여러 개 | `\|`로 구분 |
| GPU (인식된 경우) | `\|TIER:N\|SCORE_EST:NN` 추가 주입 |
| 예산 | 원화 단위 명시 (`1000000원`) |

### GPU 티어 테이블 (`lookupGpuTier`)

AI가 GPU 등급을 잘못 판단하는 것을 방지하기 위해 서버에서 직접 티어를 계산해 프롬프트에 삽입합니다.  
**숫자가 낮을수록 고성능.** 매칭은 이름 길이 내림차순으로 정렬 후 `includes` 비교합니다 (더 구체적인 모델명이 먼저 매칭).

| Tier | 포함 GPU | 점수 범위 |
|------|---------|----------|
| **1** | RTX 4090, RTX 4080 Super, RTX 4080 | 92~100 |
| **2** | RTX 4070 Ti Super, RX 7900 XTX, RTX 4070 Ti, RX 7900 XT, RTX 4070 Super | 80~88 |
| **3** | RTX 3090 Ti, RTX 3090, RX 7900 GRE, RTX 3080 Ti, RTX 4070 | 74~79 |
| **4** | RTX 4060 Ti 16GB, RTX 4060 Ti, RTX 3080 12GB, RTX 3080, RX 7800 XT | 64~68 |
| **5** | RTX 3070 Ti, RTX 3070, RTX 4060, RX 7700 XT, RX 7600 XT | 59~64 |
| **6** | RTX 3060 Ti, RX 6700 XT, RTX 3060 12GB, RTX 3060, RX 7600 | 52~58 |
| **7** | RX 6600 XT, RTX 3050, RX 6600, RTX 2070 Super | 44~47 |
| **8** | RTX 2070, RTX 2060 Super, GTX 1080 Ti | 40~42 |
| **9** | RTX 2060, GTX 1080, RX 6500 XT, RX 5500 XT | 26~36 |
| **10** | GTX 1660 Super, GTX 1660 Ti, GTX 1070 Ti, GTX 1070 | 26~28 |
| **11** | GTX 1660, GTX 1060 6GB, GTX 1060, RTX 2050, GTX 1050 Ti | 13~22 |
| **미확인** | 목록에 없는 GPU — `TIER:미확인` 으로 표시 | — |

---

## ⑤ Gemini API → 서버 응답 (원시)

```json
{
  "candidates": [
    {
      "content": {
        "parts": [
          {
            "thought": true,
            "text": "... (thinking 모델의 내부 추론 — 서버에서 무시됨)"
          },
          {
            "text": "{ ... 실제 결과 JSON ... }"
          }
        ]
      },
      "finishReason": "STOP"
    }
  ],
  "usageMetadata": {
    "promptTokenCount": 523,
    "candidatesTokenCount": 412,
    "totalTokenCount": 935,
    "thoughtsTokenCount": 280
  }
}
```

> `responseMimeType: "application/json"` 설정 시 마크다운 코드블록 없이 순수 JSON 텍스트가 반환됩니다.  
> thinking 모델(gemini-2.5-flash 등)은 `thought: true` 파트가 먼저 오고, 실제 결과 파트가 뒤에 옵니다.

### 파싱 처리

```
1. parts.find(p => !p.thought)  — thought 파트 제외, 실제 텍스트 추출
   → 없으면 parts[0] fallback

2. text가 비어있으면 → NO_TEXT 오류 throw

3. text.indexOf('{') / text.lastIndexOf('}')
   — 만약 마크다운 코드블록이 포함된 경우를 대비한 JSON 경계 추출

4. JSON.parse(...)  — 최종 객체 변환
   실패 시 → NO_JSON 오류 throw

5. NO_JSON / NO_TEXT 오류는 1회 재시도 (attempt < 2)
   그 외 오류 (네트워크, 429 등) 는 재시도 없음
```

### 서버 측 후처리 (파싱 완료 후)

```
1. sortUpgradesByDelta()
   — (scores_after[key] - scores[key]) 기준 내림차순 정렬
   — priority 1, 2, 3 재배정
   — 이유: AI가 priority를 잘못 배정하는 케이스 방어

2. enrichPrices()
   — 각 upgrade.recommended 제품명으로 네이버 쇼핑 API 병렬 호출
   — 실시간 가격으로 price_min / price_max 덮어쓰기
   — total_min / total_max 재계산
```

---

## ⑤.5 네이버 쇼핑 가격 조회

Gemini 응답 파싱 후, 각 추천 제품명으로 네이버 쇼핑 API를 **병렬** 호출해 실제 시세로 가격을 덮어씁니다.

### 엔드포인트

```
GET https://openapi.naver.com/v1/search/shop.json?query={제품명}&display=8&sort=sim
```

| 파라미터 | 값 | 이유 |
|---------|---|------|
| `display` | `8` | 충분한 가격 샘플 확보 |
| `sort` | `sim` | 연관도순 — 정확도 높은 결과 우선 |

### 인증 헤더

```
X-Naver-Client-Id: server/.env의 NAVER_CLIENT_ID
X-Naver-Client-Secret: server/.env의 NAVER_CLIENT_SECRET
```

### 쿼리 전처리 (`cleanQuery`)

```
제품명에서 괄호 및 괄호 안 내용 제거 → "(OEM)" "(벌크)" 등 검색 노이즈 제거
연속 공백 정리 → 단일 공백
encodeURIComponent 적용
```

### 가격 산출 로직

```
1. 응답 items에서 lprice 추출 및 정수 변환

2. 부품별 유효 가격 범위 필터 (floor/ceil):
   GPU: 150,000원 ~ 3,500,000원
   CPU: 80,000원 ~ 1,500,000원
   RAM: 20,000원 ~ 500,000원
   저장장치/SSD/NVMe: 25,000원 ~ 400,000원
   HDD: 25,000원 ~ 300,000원
   파워/파워서플라이: 40,000원 ~ 400,000원
   쿨러/CPU쿨러: 12,000원 ~ 200,000원
   케이스: 30,000원 ~ 500,000원
   (미분류): 10,000원 ~ 5,000,000원

3. 오름차순 정렬

4. 이상치 제거 (removeOutliers):
   prices.length > 2일 때만 적용
   median = prices[Math.floor(length / 2)]
   median * 2 초과하는 가격 제거

5. price_min = prices[0]
   price_max = prices[마지막]
   단, price_max === price_min 이면 price_max = Math.round(price_min * 1.1)
```

### 타임아웃

네이버 API 호출당 **5초** AbortController 적용. 초과 또는 실패 시 `null` 반환 → 해당 제품은 AI 추정 가격 유지.

### 실패 시 동작

API 호출 실패(네트워크 오류, 결과 없음, 범위 내 가격 없음 등) 시 해당 제품의 AI 추정 가격을 그대로 유지합니다.

### 한도

| 항목 | 값 |
|------|-----|
| 무료 할당량 | 25,000건/일 |
| 키 위치 | `server/.env` |

---

## ⑥ 서버 → 클라이언트 응답

### 성공 시

```json
{
  "success": true,
  "data": {
    "bottleneck": "GPU",
    "summary": "GPU가 발목을 잡고 있어요",
    "scores": {
      "cpu": 53,
      "gpu": 20,
      "ram": 65,
      "storage": 55,
      "overall": 41
    },
    "scores_after": {
      "cpu": 53,
      "gpu": 54,
      "ram": 65,
      "storage": 75,
      "overall": 60
    },
    "upgrades": [
      {
        "priority": 1,
        "part": "GPU",
        "current": "GTX 1060 6GB",
        "recommended": "RTX 3060 12GB",
        "reason": "최신 게임을 원활하게 즐길 수 있어요",
        "detail": "GDDR6 12GB, PCIe 4.0 x16, DLSS 3.0 — B460 호환",
        "compatible": true,
        "incompatible_reason": null,
        "price_min": 260000,
        "price_max": 320000
      },
      {
        "priority": 2,
        "part": "저장장치",
        "current": "SATA SSD 500GB",
        "recommended": "Samsung 970 EVO Plus 1TB NVMe",
        "reason": "로딩이 훨씬 빨라져요",
        "detail": "NVMe PCIe 3.0, 순차읽기 3,500MB/s — M.2 슬롯 필요",
        "compatible": true,
        "incompatible_reason": null,
        "price_min": 80000,
        "price_max": 110000
      }
    ],
    "total_min": 340000,
    "total_max": 430000,
    "caution": null
  },
  "usage": {
    "promptTokenCount": 523,
    "candidatesTokenCount": 412,
    "totalTokenCount": 935
  }
}
```

### AI 응답 필드 명세

#### 최상위

| 필드 | 타입 | 설명 |
|------|------|------|
| `bottleneck` | string | 현재 가장 큰 병목 부품명 |
| `summary` | string | 20자 이내 한줄 진단 (~요 체) |
| `scores` | object | 현재 PC 성능 점수 (0~100) |
| `scores_after` | object | 업그레이드 적용 후 예상 점수 |
| `upgrades` | array | 업그레이드 추천 **0~3개** (delta 내림차순 정렬, priority 재배정) |
| `total_min` | number | 전체 최소 예상 비용 (원) — 네이버 가격 기준 재계산 |
| `total_max` | number | 전체 최대 예상 비용 (원) — 네이버 가격 기준 재계산 |
| `caution` | string \| null | 주의사항 (없으면 `null`) |

#### scores / scores_after

| 키 | 설명 |
|----|------|
| `cpu` | CPU 성능 점수 (0~100) |
| `gpu` | GPU 성능 점수 (0~100) |
| `ram` | RAM 성능 점수 (0~100) |
| `storage` | 저장장치 성능 점수 (0~100) |
| `overall` | 종합 성능 점수 (0~100, 사용 목적별 가중 평균) |

#### upgrades 항목

| 필드 | 타입 | 제약 | 설명 |
|------|------|------|------|
| `priority` | number | 1~3 | 점수 상승폭(delta) 내림차순. 서버에서 재배정 |
| `part` | string | — | 부품 종류 (GPU / RAM / 저장장치 / CPU 등) |
| `current` | string | — | 현재 장착 사양 |
| `recommended` | string | — | 추천 모델명 (네이버 쇼핑 검색 쿼리로도 사용됨) |
| `reason` | string | 30자 이내, ~요 체 | 비전문가용 이유 |
| `detail` | string | 50자 이내 | 전문가용 기술 설명 (규격·수치·호환 근거 포함) |
| `compatible` | boolean | — | 현재 시스템과의 호환 여부 |
| `incompatible_reason` | string \| null | — | `compatible: false` 일 때만 비호환 이유 기재 |
| `price_min` | number | — | 최저 가격 (원) — 네이버 쇼핑 실시간 조회, 실패 시 AI 추정값 |
| `price_max` | number | — | 최고 가격 (원) — 네이버 쇼핑 실시간 조회, 실패 시 AI 추정값 |

---

### 실패 응답

| 상황 | HTTP | `error` 코드 | `message` |
|------|------|-------------|-----------|
| API 키 미설정 | 500 | `NO_API_KEY` | `server/.env에 GEMINI_API_KEY를 설정해주세요` |
| 필수 필드 누락 (`purpose` 또는 `budget`) | 400 | `MISSING_FIELDS` | — |
| API 한도 초과 | 429 | `RATE_LIMIT` | `요청이 너무 많아요 — N초 후 다시 시도해주세요` |
| 일일 한도 초과 | 429 | `RATE_LIMIT` | `일일 한도 초과 — 오전 9시(KST)에 초기화됩니다` |
| 분석 실패 (2회 재시도 후) | 500 | `ANALYSIS_FAILED` | `분석 중 오류가 발생했어요` |
| 네트워크 오류 | 500 | `ANALYSIS_FAILED` | `인터넷 연결을 확인해주세요` |
| Electron 타임아웃 (120초) | 0 | `TIMEOUT` | `분석 시간이 너무 오래 걸려요. 잠시 후 다시 시도해주세요.` |
| 서버 연결 불가 | 0 | `SERVER_UNAVAILABLE` | `서버에 연결할 수 없어요. 서버가 실행 중인지 확인해주세요.` |

```json
{
  "success": false,
  "error": "RATE_LIMIT",
  "message": "요청이 너무 많아요 — 60초 후 다시 시도해주세요",
  "retryAfter": 60
}
```

> Electron 타임아웃(TIMEOUT)과 서버 연결 불가(SERVER_UNAVAILABLE)는 HTTP status가 `0`으로 반환됩니다 (fetch 자체 실패).  
> 429 응답의 `retryAfter`는 Gemini의 `RetryInfo.retryDelay` 파싱값이며, 없을 경우 `60`초로 기본 처리합니다.

---

## 토큰 사용량 기준

| 항목 | 평균 |
|------|------|
| 시스템 프롬프트 | ~450~550 토큰 |
| 유저 프롬프트 (사양 + 목적 + 예산) | ~80~150 토큰 |
| AI 출력 (JSON 결과) | ~300~500 토큰 |
| thinking 토큰 (gemini-2.5-flash 등) | ~200~800 토큰 (모델·난이도에 따라 가변) |
| **총계** | **~1,000~2,000 토큰 / 요청** |

**Gemini 무료 한도** (2026년 기준):
- 1,500 요청/일
- 100만 토큰/일
- 분당 10~15 요청

> 실제 사용량은 `server/logs/api/YYYY-MM.log`에서 확인 가능합니다.

---

## 로깅 구조

`server/logger.js`가 `server/logs/` 하위에 월별 파일을 생성합니다.

| 로그 종류 | 경로 | 내용 |
|---------|------|------|
| 접속 로그 | `logs/access/YYYY-MM.log` | `[ts] METHOD /path STATUS NNNms IP` |
| API 로그 | `logs/api/YYYY-MM.log` | JSON 1줄 — 목적/예산/모델/토큰/소요시간/성공여부 |
| 에러 로그 | `logs/error/YYYY-MM.log` | `[ts] [context] message\nstack` |
| 일별 통계 | `logs/stats/YYYY-MM.log` | JSON 1줄 — 총 요청/성공/실패/토큰/평균시간 |

> `server/logs/**/*.log`는 `.gitignore`에 의해 Git 추적에서 제외됩니다.
