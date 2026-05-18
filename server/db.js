const { Pool } = require('pg')

let pool = null

function getPool() {
  if (!pool && process.env.DATABASE_URL) {
    pool = new Pool({ connectionString: process.env.DATABASE_URL })
    pool.on('error', (err) => console.error('[DB] 풀 오류:', err.message))
  }
  return pool
}

// result.bottleneck 문자열 → diagnosis_session CHECK 제약 값으로 변환
function mapBottleneck(raw) {
  const r = (raw || '').toUpperCase()
  if (r.includes('CPU') || r.includes('프로세서')) return 'CPU'
  if (r.includes('GPU') || r.includes('그래픽')) return 'GPU'
  if (r.includes('RAM') || r.includes('메모리')) return 'RAM'
  if (r.includes('SSD') || r.includes('HDD') || r.includes('저장')) return 'STORAGE'
  return 'NONE'
}

const db = {
  async saveAnalysis({ specs, purpose, subPurpose, budget, result }) {
    const p = getPool()
    if (!p) return  // DATABASE_URL 미설정 시 무시

    try {
      const fitIndex = result?.scores?.overall != null
        ? Math.min(100, Math.max(0, Math.round(result.scores.overall)))
        : null

      const budgetInt = budget != null ? parseInt(budget, 10) : null
      const budgetVal = (budgetInt !== null && !isNaN(budgetInt)) ? budgetInt : null

      await p.query(
        `INSERT INTO diagnosis_session
           (detected_specs, use_case_id, budget_krw, fit_index, bottleneck)
         VALUES ($1, $2, $3, $4, $5)`,
        [
          JSON.stringify(specs || {}),
          null,                          // use_case_id: 목적 매핑 구현 후 연결
          budgetVal,
          fitIndex,
          mapBottleneck(result?.bottleneck),
        ]
      )
    } catch (err) {
      console.error('[DB] saveAnalysis 오류:', err.message)
    }
  },

  // 연결 테스트용
  async ping() {
    const p = getPool()
    if (!p) return false
    try {
      await p.query('SELECT 1')
      return true
    } catch {
      return false
    }
  },
}

module.exports = db
