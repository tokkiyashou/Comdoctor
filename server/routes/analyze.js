const express = require('express')
const router = express.Router()
const db = require('../db')
const logger = require('../logger')

const SYSTEM_PROMPT = `당신은 PC 하드웨어 업그레이드 전문가입니다.
사용자의 PC 사양, 사용 목적, 예산을 분석해 최적의 업그레이드 플랜을 제시합니다.

규칙:
1. 반드시 아래 JSON 형식으로만 출력. 설명 텍스트 절대 금지.
2. 호환성은 메인보드 소켓/칩셋/슬롯 기준으로 판단.
3. 예산 초과 추천 금지.
4. upgrades는 0~3개. 예산 내에서 실질적 성능 향상이 있는 것만 포함. 개선 효과가 없으면 빈 배열. 억지로 채우지 말 것.
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

    [GPU 성능 등급표 — 숫자 낮을수록 고성능]
    Tier 1: RTX 4090, RTX 4080 Super, RTX 4080
    Tier 2: RTX 4070 Ti Super, RTX 4070 Ti, RTX 4070 Super, RX 7900 XTX, RX 7900 XT
    Tier 3: RTX 4070, RX 7900 GRE, RTX 3090 Ti, RTX 3090, RTX 3080 Ti
    Tier 4: RTX 4060 Ti 16GB, RTX 4060 Ti, RX 7800 XT, RTX 3080 12GB, RTX 3080
    Tier 5: RTX 4060, RX 7700 XT, RX 7600 XT, RTX 3070 Ti, RTX 3070
    Tier 6: RX 7600, RTX 3060 Ti, RTX 3060 12GB, RX 6700 XT
    Tier 7: RTX 3050, RTX 2070 Super, RX 6600 XT, RX 6600
    Tier 8: RTX 2060 Super, RTX 2070, GTX 1080 Ti
    Tier 9: RTX 2060, GTX 1080, RX 6500 XT, RX 5500 XT
    Tier 10: GTX 1660 Super, GTX 1660 Ti, GTX 1070
    Tier 11: GTX 1660, GTX 1060 6GB, RTX 2050, GTX 1070 Ti
    목록에 없는 GPU는 출시연도·모델번호 기준으로 합리적으로 Tier 판단.

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
}`

const GPU_TIER_DATA = [
  ['RTX 4090', 1, 100], ['RTX 4080 Super', 1, 94], ['RTX 4080', 1, 92],
  ['RTX 4070 Ti Super', 2, 88], ['RX 7900 XTX', 2, 86], ['RTX 4070 Ti', 2, 84],
  ['RX 7900 XT', 2, 81], ['RTX 4070 Super', 2, 80],
  ['RTX 3090 Ti', 3, 79], ['RTX 3090', 3, 77], ['RX 7900 GRE', 3, 76],
  ['RTX 3080 Ti', 3, 75], ['RTX 4070', 3, 74],
  ['RTX 4060 Ti 16GB', 4, 68], ['RTX 4060 Ti', 4, 67], ['RTX 3080 12GB', 4, 66],
  ['RTX 3080', 4, 64], ['RX 7800 XT', 4, 65],
  ['RTX 3070 Ti', 5, 64], ['RTX 3070', 5, 63], ['RTX 4060', 5, 62],
  ['RX 7700 XT', 5, 60], ['RX 7600 XT', 5, 59],
  ['RTX 3060 Ti', 6, 58], ['RX 6700 XT', 6, 56], ['RTX 3060 12GB', 6, 54],
  ['RTX 3060', 6, 54], ['RX 7600', 6, 52],
  ['RX 6600 XT', 7, 47], ['RTX 3050', 7, 46], ['RX 6600', 7, 44],
  ['RTX 2070 Super', 7, 44],
  ['RTX 2070', 8, 42], ['RTX 2060 Super', 8, 41], ['GTX 1080 Ti', 8, 40],
  ['RTX 2060', 9, 36], ['GTX 1080', 9, 35], ['RX 6500 XT', 9, 28],
  ['RX 5500 XT', 9, 26],
  ['GTX 1660 Super', 10, 28], ['GTX 1660 Ti', 10, 27], ['GTX 1070 Ti', 10, 27],
  ['GTX 1070', 10, 26],
  ['GTX 1660', 11, 22], ['GTX 1060 6GB', 11, 22], ['GTX 1060', 11, 20],
  ['RTX 2050', 11, 20], ['GTX 1050 Ti', 11, 16],
]

const GEMINI_MODEL = process.env.GEMINI_MODEL || 'gemini-2.5-flash'

function partToScoreKey(part) {
  const p = (part || '').toLowerCase()
  if (p.includes('cpu') || p.includes('프로세서')) return 'cpu'
  if (p.includes('gpu') || p.includes('그래픽')) return 'gpu'
  if (p.includes('ram') || p.includes('메모리')) return 'ram'
  if (p.includes('저장') || p.includes('ssd') || p.includes('hdd') || p.includes('nvme')) return 'storage'
  return null
}

function sortUpgradesByDelta(upgrades, scores, scoresAfter) {
  if (!upgrades?.length) return upgrades
  return upgrades
    .map(u => {
      const key = partToScoreKey(u.part)
      const delta = key ? ((scoresAfter?.[key] || 0) - (scores?.[key] || 0)) : 0
      return { ...u, _delta: delta }
    })
    .sort((a, b) => b._delta - a._delta)
    .map(({ _delta, ...u }, i) => ({ ...u, priority: i + 1 }))
}

function lookupGpuTier(gpuName) {
  if (!gpuName) return null
  const upper = gpuName.toUpperCase()
  const sorted = [...GPU_TIER_DATA].sort((a, b) => b[0].length - a[0].length)
  for (const [kw, tier, score] of sorted) {
    if (upper.includes(kw.toUpperCase())) return { tier, score }
  }
  return null
}

function buildUserPrompt(specs, purpose, subPurpose, budget) {
  const lines = ['[PC사양]']

  if (specs.cpu) {
    const c = specs.cpu
    const name = (c.name || '').replace(/\s+/g, '_').replace(/[()®™]/g, '')
    lines.push(`CPU:${name}|SOCKET:${c.socket || '미확인'}|CORES:${c.cores || '?'}C${c.threads || '?'}T|CLOCK:${c.maxClockMHz ? (c.maxClockMHz / 1000).toFixed(1) + 'GHz' : '미확인'}`)
  } else {
    lines.push('CPU:미확인')
  }

  if (specs.motherboard) {
    const mb = specs.motherboard
    const name = `${mb.manufacturer || ''}_${mb.model || ''}`.replace(/\s+/g, '_').replace(/[()]/g, '')
    lines.push(`MB:${name}`)
  } else {
    lines.push('MB:미확인')
  }

  if (specs.ram) {
    const r = specs.ram
    const mod = r.modules && r.modules[0]
    const type = mod ? `${mod.type || 'DDR4'}-${mod.speedMHz || '미확인'}` : 'DDR4'
    const slots = r.totalSlots ? `${r.totalSlots}개중${r.usedSlots}개사용` : `${r.usedSlots}개사용`
    lines.push(`RAM:${r.totalGB}GB_${type}|SLOTS:${slots}`)
  } else {
    lines.push('RAM:미확인')
  }

  if (specs.gpu && specs.gpu.length > 0) {
    const g = specs.gpu[0]
    const vram = g.vramGB ? `${g.vramGB}GB` : '미확인'
    const gpuName = g.name || 'GPU'
    const tierInfo = lookupGpuTier(gpuName)
    const tierStr = tierInfo ? `|TIER:${tierInfo.tier}|SCORE_EST:${tierInfo.score}` : '|TIER:미확인'
    lines.push(`GPU:${gpuName.replace(/\s+/g, '_')}-${vram}|PCIE:x16${tierStr}`)
  } else {
    lines.push('GPU:미확인')
  }

  if (specs.storage && specs.storage.length > 0) {
    const storageStrs = specs.storage.map(d => {
      let type = 'HDD'
      if (d.busType === 'NVMe') type = 'NVMe'
      else if (d.mediaType === 'SSD' || d.busType === 'SATA') type = 'SSD_SATA'
      return `${type}_${d.sizeGB || '?'}GB`
    })
    lines.push(`STORAGE:${storageStrs.join('|')}`)
  }

  if (specs.psu) lines.push(`PSU:${specs.psu}W`)
  if (specs.caseType) lines.push(`CASE:${specs.caseType}`)

  if (specs.os) {
    const caption = (specs.os.caption || 'Windows').replace(/\s+/g, '')
    const arch = (specs.os.architecture || '64-bit').replace('-bit', 'bit')
    lines.push(`OS:${caption}_${arch}`)
  }

  lines.push('')
  lines.push(`[사용목적] ${purpose}`)
  if (subPurpose) lines.push(`[세부목적] ${subPurpose.replace(/\s+/g, '_')}`)
  lines.push(`[예산] ${budget}원`)

  return lines.join('\n')
}

const PART_PRICE_RANGE = {
  'GPU':      { floor: 150000, ceil: 3500000 }, '그래픽카드': { floor: 150000, ceil: 3500000 },
  'CPU':      { floor:  80000, ceil: 1500000 }, '프로세서':   { floor:  80000, ceil: 1500000 },
  'RAM':      { floor:  20000, ceil:  500000 }, '메모리':     { floor:  20000, ceil:  500000 },
  '저장장치': { floor:  25000, ceil:  400000 }, 'SSD':        { floor:  25000, ceil:  400000 },
  'HDD':      { floor:  25000, ceil:  300000 }, 'NVMe':       { floor:  25000, ceil:  400000 },
  '파워':     { floor:  40000, ceil:  400000 }, '파워서플라이': { floor: 40000, ceil:  400000 },
  '쿨러':     { floor:  12000, ceil:  200000 }, 'CPU쿨러':    { floor:  12000, ceil:  200000 },
  '케이스':   { floor:  30000, ceil:  500000 },
}
const DEFAULT_RANGE = { floor: 10000, ceil: 5000000 }

function cleanQuery(name) {
  return name
    .replace(/\s*\(.*?\)/g, '')   // 괄호 및 괄호 안 내용 제거
    .replace(/\s*\[.*?\]/g, '')   // 대괄호 제거
    .replace(/\s{2,}/g, ' ')
    .trim()
}

function removeOutliers(prices) {
  if (prices.length <= 2) return prices
  const median = prices[Math.floor(prices.length / 2)]
  return prices.filter(p => p <= median * 2)
}

async function fetchNaverPrice(productName, partType) {
  const id     = process.env.NAVER_CLIENT_ID
  const secret = process.env.NAVER_CLIENT_SECRET
  if (!id || !secret) return null

  const { floor, ceil } = PART_PRICE_RANGE[partType] || DEFAULT_RANGE

  try {
    const q   = encodeURIComponent(cleanQuery(productName))
    const url = `https://openapi.naver.com/v1/search/shop.json?query=${q}&display=8&sort=sim`
    const ctrl = new AbortController()
    const timer = setTimeout(() => ctrl.abort(), 5000)
    const res = await fetch(url, {
      headers: { 'X-Naver-Client-Id': id, 'X-Naver-Client-Secret': secret },
      signal: ctrl.signal
    })
    clearTimeout(timer)
    if (!res.ok) return null

    const data   = await res.json()
    const raw    = (data.items || []).map(i => parseInt(i.lprice))
    const prices = removeOutliers(raw.filter(p => p >= floor && p <= ceil).sort((a, b) => a - b))
    if (!prices.length) return null

    const min = prices[0]
    const max = prices[prices.length - 1]
    return { price_min: min, price_max: max > min ? max : Math.round(min * 1.1) }
  } catch (_) {
    return null
  }
}

async function enrichPrices(upgrades) {
  if (!upgrades?.length) return upgrades
  const results = await Promise.all(upgrades.map(u => fetchNaverPrice(u.recommended, u.part)))
  const enriched = upgrades.map((u, i) => results[i] ? { ...u, ...results[i] } : u)

  // total_min/max 재계산
  const totalMin = enriched.reduce((s, u) => s + (u.price_min || 0), 0)
  const totalMax = enriched.reduce((s, u) => s + (u.price_max || 0), 0)
  return { upgrades: enriched, totalMin, totalMax }
}

async function callGemini(userPrompt) {
  const url = `https://generativelanguage.googleapis.com/v1beta/models/${GEMINI_MODEL}:generateContent?key=${process.env.GEMINI_API_KEY}`

  const ctrl = new AbortController()
  const timer = setTimeout(() => ctrl.abort(), 90000)
  const response = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      systemInstruction: { parts: [{ text: SYSTEM_PROMPT }] },
      contents: [{ role: 'user', parts: [{ text: userPrompt }] }],
      generationConfig: { maxOutputTokens: 8192, temperature: 0.2, responseMimeType: 'application/json' }
    }),
    signal: ctrl.signal
  })
  clearTimeout(timer)

  if (!response.ok) {
    const body = await response.json().catch(() => ({}))
    const error = new Error(body.error?.message || 'API Error')
    error.status = response.status
    if (response.status === 429) {
      const retryInfo = body.error?.details?.find(d => d['@type']?.includes('RetryInfo'))
      const rawDelay = retryInfo?.retryDelay || ''
      const seconds = Math.ceil(parseFloat(rawDelay) || 60)
      error.retryAfter = seconds
    }
    throw error
  }

  const data = await response.json()
  // thinking 모델은 parts[0]이 thought, parts[1]이 실제 텍스트일 수 있음
  const parts = data.candidates?.[0]?.content?.parts || []
  const text = (parts.find(p => !p.thought) || parts[0])?.text
  if (!text) throw new Error('NO_TEXT')

  const start = text.indexOf('{')
  const end = text.lastIndexOf('}')
  if (start === -1 || end === -1 || end < start) {
    console.error('[NO_JSON] 응답 끝부분:', text.substring(text.length - 200))
    throw new Error('NO_JSON')
  }
  const jsonStr = text.slice(start, end + 1)
  try {
    return { result: JSON.parse(jsonStr), usage: data.usageMetadata || null }
  } catch (e) {
    console.error('[JSON_PARSE_ERR] 위치:', e.message)
    console.error('[JSON_PARSE_ERR] 전체 응답:\n', jsonStr)
    throw new Error('NO_JSON')
  }
}

router.post('/analyze', async (req, res) => {
  const { specs, purpose, subPurpose, budget } = req.body
  console.log(`[analyze] 요청 수신 — 목적: ${purpose}, 예산: ${budget}`)

  if (!process.env.GEMINI_API_KEY || process.env.GEMINI_API_KEY === 'your_gemini_api_key_here') {
    console.error('[analyze] GEMINI_API_KEY 미설정')
    return res.status(500).json({ success: false, error: 'NO_API_KEY', message: 'server/.env에 GEMINI_API_KEY를 설정해주세요' })
  }

  if (!purpose || !budget) {
    return res.status(400).json({ success: false, error: 'MISSING_FIELDS' })
  }

  const userPrompt = buildUserPrompt(specs || {}, purpose, subPurpose, budget)
  let analysisResult = null
  let usageInfo = null
  let lastError = null

  const callStart = Date.now()

  for (let attempt = 0; attempt < 2; attempt++) {
    try {
      console.log(`[analyze] Gemini 호출 중... (시도 ${attempt + 1})`)
      const { result, usage } = await callGemini(userPrompt)
      analysisResult = result
      usageInfo = usage
      const duration = Date.now() - callStart
      console.log('[analyze] 성공 — 토큰:', usage?.totalTokenCount ?? '?')
      logger.api({ purpose, budget, model: GEMINI_MODEL, usage, durationMs: duration, success: true })
      break
    } catch (err) {
      lastError = err
      console.error(`[analyze] 오류 (시도 ${attempt + 1}):`, err.message, err.status ?? '')
      if (err.status === 429) {
        const wait = err.retryAfter || 60
        const msg = wait >= 3600
          ? `일일 한도 초과 — 오전 9시(KST)에 초기화됩니다`
          : `요청이 너무 많아요 — ${wait}초 후 다시 시도해주세요`
        console.warn(`[analyze] 한도 초과 — ${wait}초 대기 필요`)
        logger.api({ purpose, budget, model: GEMINI_MODEL, usage: null, durationMs: Date.now() - callStart, success: false, error: 'RATE_LIMIT' })
        return res.status(429).json({ success: false, error: 'RATE_LIMIT', message: msg, retryAfter: wait })
      }
      if (attempt === 0 && (err.message === 'NO_JSON' || err.message === 'NO_TEXT')) continue
      logger.error('analyze', err)
      break
    }
  }

  if (!analysisResult) {
    const isNetwork = lastError?.code === 'ENOTFOUND' || lastError?.code === 'ECONNREFUSED'
    return res.status(500).json({
      success: false,
      error: 'ANALYSIS_FAILED',
      message: isNetwork ? '인터넷 연결을 확인해주세요' : '분석 중 오류가 발생했어요'
    })
  }

  // 점수 상승폭 기준 정렬 + priority 재배정
  if (analysisResult.upgrades?.length) {
    analysisResult.upgrades = sortUpgradesByDelta(
      analysisResult.upgrades,
      analysisResult.scores,
      analysisResult.scores_after
    )
  }

  // 네이버 쇼핑 실제 가격으로 덮어쓰기
  if (analysisResult.upgrades?.length) {
    console.log('[analyze] 네이버 쇼핑 가격 조회 중...')
    const { upgrades, totalMin, totalMax } = await enrichPrices(analysisResult.upgrades)
    analysisResult.upgrades = upgrades
    analysisResult.total_min = totalMin
    analysisResult.total_max = totalMax
    console.log('[analyze] 가격 갱신 완료')
  }

  try { await db.saveAnalysis({ specs, purpose, subPurpose, budget, result: analysisResult, timestamp: new Date() }) } catch (_) {}

  res.json({ success: true, data: analysisResult, usage: usageInfo })
})

module.exports = router
