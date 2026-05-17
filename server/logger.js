const fs = require('fs')
const path = require('path')

const LOG_DIR = path.join(__dirname, 'logs')
;['access', 'api', 'error', 'stats'].forEach(sub =>
  fs.mkdirSync(path.join(LOG_DIR, sub), { recursive: true })
)

function monthKey() {
  const d = new Date()
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`
}

function logFile(type) {
  return path.join(LOG_DIR, type, `${monthKey()}.log`)
}

function append(type, line) {
  fs.appendFile(logFile(type), line + '\n', err => {
    if (err) console.error('[logger] 쓰기 실패:', err.message)
  })
}

function ts() {
  return new Date().toISOString()
}

// HTTP 접속 로그
// [정보통신망법] 서비스 접속 기록 — 3개월 이상 보관 권고
function access(req, res, durationMs) {
  const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress || '-'
  const line = `[${ts()}] ${req.method} ${req.path} ${res.statusCode} ${durationMs}ms ${ip}`
  append('access', line)
}

// Gemini API 사용 로그 — 비용·한도 추적
function api({ purpose, budget, model, usage, durationMs, success, error }) {
  const entry = {
    ts: ts(),
    success,
    model: model || '-',
    purpose: purpose || '-',
    budget: budget || 0,
    promptTokens: usage?.promptTokenCount ?? null,
    outputTokens: usage?.candidatesTokenCount ?? null,
    totalTokens: usage?.totalTokenCount ?? null,
    durationMs: durationMs ?? null,
    error: error || null
  }
  append('api', JSON.stringify(entry))
}

// 에러 로그
function error(context, err) {
  const line = `[${ts()}] [${context}] ${err?.message || err}\n  ${err?.stack || ''}`
  append('error', line)
  console.error(`[error] ${context}:`, err?.message || err)
}

// 일별 통계 요약 — stats/YYYY-MM.log 에 하루 1줄씩 추가
// 별도 집계 프로세스 없이 API 로그 파일을 파싱해 생성
function writeDailySummary() {
  const today = new Date().toISOString().slice(0, 10)
  const apiLogPath = logFile('api')

  if (!fs.existsSync(apiLogPath)) return

  const lines = fs.readFileSync(apiLogPath, 'utf8').split('\n').filter(Boolean)
  const todayLines = lines
    .map(l => { try { return JSON.parse(l) } catch { return null } })
    .filter(e => e && e.ts && e.ts.startsWith(today))

  if (todayLines.length === 0) return

  const total = todayLines.length
  const succeeded = todayLines.filter(e => e.success).length
  const totalTokens = todayLines.reduce((s, e) => s + (e.totalTokens || 0), 0)
  const avgDuration = Math.round(todayLines.reduce((s, e) => s + (e.durationMs || 0), 0) / total)

  const summary = JSON.stringify({ date: today, total, succeeded, failed: total - succeeded, totalTokens, avgDurationMs: avgDuration })
  append('stats', summary)
}

module.exports = { access, api, error, writeDailySummary }
