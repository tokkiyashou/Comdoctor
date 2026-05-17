require('dotenv').config()
const express = require('express')
const cors = require('cors')
const analyzeRoutes = require('./routes/analyze')
const logger = require('./logger')

const app = express()
const PORT = process.env.PORT || 3001

app.use(cors())
app.use(express.json({ limit: '1mb' }))

// 접속 로그 미들웨어
app.use((req, res, next) => {
  const start = Date.now()
  res.on('finish', () => logger.access(req, res, Date.now() - start))
  next()
})

app.get('/health', (req, res) => res.json({ status: 'ok' }))
app.use('/api', analyzeRoutes)

app.listen(PORT, '127.0.0.1', () => {
  console.log(`컴닥터 서버 실행 중: http://127.0.0.1:${PORT}`)
})

// 자정에 일별 통계 요약 기록
const now = new Date()
const msToMidnight = new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1) - now
setTimeout(() => {
  logger.writeDailySummary()
  setInterval(logger.writeDailySummary, 24 * 60 * 60 * 1000)
}, msToMidnight)
