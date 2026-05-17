const SUFFICIENCY = {
  '게임': {
    '가벼운 게임':        { t: 52, msg: '이 사양이면 가벼운 게임은 끊김 없이 즐길 수 있어요!' },
    '고사양 게임':        { t: 74, msg: '웬만한 게임도 원활하게 즐길 수 있는 사양이에요!' },
    '최신 게임 최고옵션': { t: 88, msg: '최신 게임을 최고 옵션으로 돌릴 수 있는 고사양이에요!' },
  },
  '영상 편집': {
    '간단한 영상 편집':   { t: 60, msg: '간단한 영상 편집엔 충분한 사양이에요!' },
    '4K 편집':            { t: 80, msg: '4K 편집도 부드럽게 작업할 수 있는 사양이에요!' },
    '색보정·VFX 전문작업':{ t: 88, msg: '전문 VFX 작업도 거뜬히 처리할 수 있는 고성능 PC예요!' },
  },
  '개인 방송·스트리밍': {
    '게임+방송 동시':    { t: 72, msg: '게임과 방송을 동시에 돌릴 수 있는 사양이에요!' },
    '캠+화면캡처':       { t: 55, msg: '캠·화면캡처 방송엔 충분한 사양이에요!' },
    '1080p 60fps 이상':  { t: 78, msg: '1080p 60fps 스트리밍도 원활하게 가능한 사양이에요!' },
  },
  '소프트웨어 개발': {
    '가벼운 작업':     { t: 52, msg: '가벼운 개발 작업엔 충분한 환경이에요!' },
    '대규모 프로젝트': { t: 70, msg: '대규모 프로젝트도 쾌적하게 작업할 수 있어요!' },
    'AI·ML 개발':      { t: 85, msg: 'AI·ML 개발에도 적합한 고성능 PC예요!' },
  },
  '무거운 작업': {
    '3D 모델링·렌더링':   { t: 82, msg: '3D 렌더링도 무리 없이 처리할 수 있는 사양이에요!' },
    'CAD·설계':           { t: 68, msg: 'CAD·설계 작업엔 충분한 사양이에요!' },
    '대용량 데이터 처리': { t: 75, msg: '대용량 데이터 처리도 쾌적하게 가능한 사양이에요!' },
  },
  '문서 작업':    { _: { t: 42, msg: '문서 작업엔 넘치는 사양이에요!' } },
  '콘텐츠 감상': {
    '유튜브·넷플릭스 등 스트리밍': { t: 42, msg: '스트리밍 감상엔 최적의 사양이에요!' },
    '4K·HDR 영상 재생':             { t: 60, msg: '4K·HDR 영상 재생도 거뜬한 사양이에요!' },
    '음악 감상 위주':               { t: 38, msg: '음악 감상엔 넘치는 사양이에요!' },
  },
}

const STEP4_CONFIG = {
  '게임': {
    question: '어떤 게임을 돌리실 예정인가요?',
    options: ['가벼운 게임', '고사양 게임', '최신 게임 최고옵션', '직접 입력']
  },
  '영상 편집': {
    question: '어떤 작업을 하실 예정인가요?',
    options: ['간단한 영상 편집', '4K 편집', '색보정·VFX 전문작업', '직접 입력']
  },
  '개인 방송·스트리밍': {
    question: '어떤 환경에서 방송하실 예정인가요?',
    options: ['게임+방송 동시', '캠+화면캡처', '1080p 60fps 이상', '직접 입력']
  },
  '소프트웨어 개발': {
    question: '어떤 작업을 하실 예정인가요?',
    options: ['가벼운 작업', '대규모 프로젝트', 'AI·ML 개발', '직접 입력']
  },
  '무거운 작업': {
    question: '어떤 작업을 하실 예정인가요?',
    options: ['3D 모델링·렌더링', 'CAD·설계', '대용량 데이터 처리', '직접 입력']
  },
  '문서 작업': {
    question: '주로 어떤 프로그램을 사용하시나요?',
    options: ['오피스(Word·Excel)', '브라우저 위주', '협업툴(Notion·Slack 등)', '직접 입력']
  },
  '콘텐츠 감상': {
    question: '주로 어떤 콘텐츠를 감상하시나요?',
    options: ['유튜브·넷플릭스 등 스트리밍', '4K·HDR 영상 재생', '음악 감상 위주', '직접 입력']
  },
  '직접 입력': {
    question: '어떤 작업을 주로 하실 예정인가요?',
    options: null
  }
}

const state = {
  screen: 'main',
  specs: null,
  inputMode: null,   // 'auto' | 'manual'
  purpose: null,
  subPurpose: null,
  budget: 500000,
  lastPayload: null
}

const App = {
  showScreen(name) {
    document.querySelectorAll('.screen').forEach(s => s.classList.remove('active'))
    document.getElementById(`screen-${name}`).classList.add('active')
    state.screen = name
  },

  resetFlow() {
    state.purpose = null
    state.subPurpose = null
    state.inputMode = null
    state.budget = 500000

    // 목적 버튼 선택 해제
    document.querySelectorAll('.purpose-btn').forEach(b => b.classList.remove('selected'))

    // step4 상태 초기화 (자유입력 숨기기, 옵션 보이기)
    const optionsEl = document.getElementById('step4-options')
    const freeEl = document.getElementById('step4-free')
    if (optionsEl) optionsEl.style.display = ''
    if (freeEl) freeEl.style.display = 'none'
    const freeInput = document.getElementById('free-input')
    if (freeInput) freeInput.value = ''
    document.querySelectorAll('#step4-options .purpose-btn').forEach(b => b.classList.remove('selected'))

    // 예산 슬라이더 초기화
    this.updateBudget(500000)
    const slider = document.getElementById('budget-slider')
    if (slider) slider.value = 500000
  },

  startDiagnosis() {
    this.resetFlow()
    this.showScreen('step1')
  },

  async viewMySpecs() {
    this.showScreen('collecting')
    const result = await window.electronAPI.collectSpecs()
    if (result.error && !result.data) {
      this.showScreen('main')
      alert('사양 수집에 실패했어요: ' + result.error)
      return
    }
    state.specs = result.data
    this.renderSpecsView(result.data)
    this.showScreen('specs')
  },

  async selectThisPC() {
    this.showScreen('collecting')
    const result = await window.electronAPI.collectSpecs()
    if (result.error && !result.data) {
      alert('사양 수집에 실패했어요. 직접 입력해주세요.')
      this.showScreen('manual')
      return
    }
    state.specs = result.data
    state.inputMode = 'auto'
    this.showScreen('step2')
  },

  goManual() {
    state.specs = null
    state.inputMode = 'manual'
    this.showScreen('manual')
  },

  submitManual() {
    const cpuName = document.getElementById('m-cpu-name').value.trim()
    const ramSize = document.getElementById('m-ram-size').value
    if (!cpuName || !ramSize) {
      alert('CPU 이름과 RAM 용량은 필수예요.')
      return
    }

    state.specs = {
      cpu: {
        name: cpuName,
        socket: document.getElementById('m-cpu-socket').value.trim() || null,
        cores: null, threads: null, maxClockMHz: null
      },
      motherboard: {
        manufacturer: document.getElementById('m-mb-maker').value.trim() || null,
        model: document.getElementById('m-mb-model').value.trim() || null
      },
      ram: {
        totalGB: parseInt(ramSize) || null,
        totalSlots: parseInt(document.getElementById('m-ram-total').value) || null,
        usedSlots: parseInt(document.getElementById('m-ram-used').value) || 1,
        modules: [{
          capacityGB: parseInt(ramSize) || null,
          speedMHz: parseInt(document.getElementById('m-ram-speed').value) || null,
          type: document.getElementById('m-ram-type').value || 'DDR4'
        }]
      },
      gpu: [{
        name: document.getElementById('m-gpu-name').value.trim() || null,
        vramGB: parseInt(document.getElementById('m-gpu-vram').value) || null
      }].filter(g => g.name),
      storage: (() => {
        const type = document.getElementById('m-storage-type').value
        const size = document.getElementById('m-storage-size').value
        if (!type && !size) return []
        return [{ busType: type, mediaType: type === 'HDD' ? 'HDD' : 'SSD', sizeGB: parseInt(size) || null }]
      })(),
      psu: parseInt(document.getElementById('m-psu').value) || null,
      caseType: document.getElementById('m-case').value || null,
      os: null
    }

    this.showScreen('step2')
  },

  selectPurpose(btn) {
    document.querySelectorAll('.purpose-btn').forEach(b => b.classList.remove('selected'))
    btn.classList.add('selected')
    state.purpose = btn.dataset.value
    setTimeout(() => this.showScreen('step3'), 200)
  },

  goBackFromStep2() {
    if (state.inputMode === 'auto') this.showScreen('step1')
    else this.showScreen('manual')
  },

  _applySliderFill(n) {
    const pct = ((n - 50000) / (2000000 - 50000)) * 100
    document.getElementById('budget-slider').style.background =
      `linear-gradient(to right, var(--primary) ${pct}%, var(--surface-2) ${pct}%)`
  },

  updateBudget(val) {
    const n = parseInt(val)
    state.budget = n
    document.getElementById('budget-display').textContent = this.formatBudget(n)
    document.getElementById('budget-input').value = Math.round(n / 10000)
    this._applySliderFill(n)
  },

  updateBudgetFromInput(val) {
    const man = parseInt(val)
    if (!man || man < 5) return
    const n = man * 10000
    state.budget = n
    document.getElementById('budget-display').textContent = this.formatBudget(n)
    const slider = document.getElementById('budget-slider')
    slider.value = Math.min(Math.max(n, 50000), 2000000)
    this._applySliderFill(n)
  },

  formatBudget(n) {
    if (n >= 10000) return Math.round(n / 10000) + '만원'
    return n.toLocaleString() + '원'
  },

  goToStep4() {
    const config = STEP4_CONFIG[state.purpose]
    if (!config) { this.submitStep4(); return }

    document.getElementById('step4-question').textContent = config.question
    const optionsEl = document.getElementById('step4-options')
    const freeEl = document.getElementById('step4-free')

    if (!config.options || state.purpose === '직접 입력') {
      optionsEl.style.display = 'none'
      freeEl.style.display = 'block'
    } else {
      freeEl.style.display = 'none'
      optionsEl.style.display = 'grid'
      optionsEl.innerHTML = config.options.map(opt =>
        `<button class="purpose-btn" data-value="${opt}" onclick="App.selectSubPurpose(this)"><span class="purpose-label">${opt}</span></button>`
      ).join('')
    }

    state.subPurpose = null
    this.showScreen('step4')
  },

  selectSubPurpose(btn) {
    if (btn.dataset.value === '직접 입력') {
      document.querySelectorAll('.purpose-btn').forEach(b => b.classList.remove('selected'))
      btn.classList.add('selected')
      document.getElementById('step4-options').style.display = 'none'
      document.getElementById('step4-free').style.display = 'block'
      state.subPurpose = null
      return
    }
    document.querySelectorAll('.purpose-btn').forEach(b => b.classList.remove('selected'))
    btn.classList.add('selected')
    state.subPurpose = btn.dataset.value
  },

  submitStep4() {
    const freeEl = document.getElementById('step4-free')
    if (freeEl.style.display !== 'none') {
      const val = document.getElementById('free-input').value.trim()
      if (!val) { alert('사용 목적을 입력해주세요!'); return }
      state.subPurpose = val
    }
    if (!state.subPurpose && freeEl.style.display === 'none') {
      alert('항목을 선택해주세요!')
      return
    }
    this.runAnalysis()
  },

  _scanInterval: null,
  _scanMessages: [
    'PC 사양 파악 중...',
    'CPU 성능 분석 중...',
    'GPU 사양 확인 중...',
    '최적 업그레이드 탐색 중...',
    '예산 대비 성능 계산 중...',
    '호환성 검토 중...',
    '결과 정리 중...'
  ],
  _scanIdx: 0,

  startScanMessages() {
    const el = document.getElementById('scan-status')
    if (!el) return
    this._scanIdx = 0
    el.style.opacity = '1'
    el.textContent = this._scanMessages[0]
    this._scanInterval = setInterval(() => {
      el.style.opacity = '0'
      setTimeout(() => {
        this._scanIdx = (this._scanIdx + 1) % this._scanMessages.length
        el.textContent = this._scanMessages[this._scanIdx]
        el.style.opacity = '1'
      }, 300)
    }, 2200)
  },

  stopScanMessages() {
    if (this._scanInterval) { clearInterval(this._scanInterval); this._scanInterval = null }
  },

  async runAnalysis() {
    const payload = {
      specs: state.specs,
      purpose: state.purpose,
      subPurpose: state.subPurpose,
      budget: state.budget
    }
    state.lastPayload = payload

    document.getElementById('btn-retry').style.display = 'none'
    document.getElementById('analysis-error').style.display = 'none'
    this.showScreen('analyzing')
    this.startScanMessages()

    const result = await window.electronAPI.analyze(payload)
    this.stopScanMessages()

    if (result.status === 429) {
      const msg = result.data?.message || '잠시 후 다시 시도해주세요'
      const retryAfter = result.data?.retryAfter
      this.showRateLimitError(msg, retryAfter)
      return
    }
    if (result.status === 0 || !result.data?.success) {
      this.showAnalysisError(result.data?.message || '분석 중 오류가 발생했어요')
      return
    }
    if (result.status >= 500) {
      this.showAnalysisError(result.data?.message || '분석 중 오류가 발생했어요')
      return
    }

    this.renderResults(result.data.data, result.data.usage)
    this.showScreen('results')
  },

  showRateLimitError(msg, retryAfter) {
    const errEl = document.getElementById('analysis-error')
    const retryBtn = document.getElementById('btn-retry')
    errEl.textContent = retryAfter
      ? `${msg} (${retryAfter}초 뒤 재시도 버튼을 눌러주세요)`
      : msg
    errEl.style.display = 'block'
    retryBtn.disabled = true
    retryBtn.style.display = 'inline-block'

    const wait = Math.min(retryAfter || 60, 120)
    setTimeout(() => { retryBtn.disabled = false }, wait * 1000)
  },

  showAnalysisError(msg) {
    const errEl = document.getElementById('analysis-error')
    errEl.textContent = msg
    errEl.style.display = 'block'
    document.getElementById('btn-retry').style.display = 'inline-block'
  },

  retryAnalysis() {
    if (state.lastPayload) this.runAnalysis()
  },

  renderResults(data, usage) {
    const scores = data.scores || {}
    const scoresAfter = data.scores_after || {}
    const overall = scores.overall || 0
    const color = this.scoreColor(overall)
    const grade = this.scoreGrade(overall)
    const C = 326.73  // 2π * 52
    const offset = +(C * (1 - overall / 100)).toFixed(2)

    document.getElementById('result-summary-box').innerHTML = `
      <div class="hero-layout">
        <div class="hero-ring-wrap">
          <svg viewBox="0 0 140 140" width="118" height="118">
            <circle cx="70" cy="70" r="52" fill="none" style="stroke:var(--border)" stroke-width="9"/>
            <circle cx="70" cy="70" r="52" fill="none"
              stroke="${color}" stroke-width="9" stroke-linecap="round"
              stroke-dasharray="${C.toFixed(2)}" stroke-dashoffset="${C.toFixed(2)}"
              class="ring-arc"
              style="transform:rotate(-90deg);transform-origin:70px 70px;transition:stroke-dashoffset 1.1s cubic-bezier(0.4,0,0.2,1)"
              data-target="${offset}"/>
            <text x="70" y="64" text-anchor="middle" dominant-baseline="middle"
              fill="${color}" font-size="30" font-weight="900" font-family="system-ui,sans-serif">${overall}</text>
            <text x="70" y="84" text-anchor="middle" dominant-baseline="middle"
              style="fill:var(--muted)" font-size="10" font-family="system-ui,sans-serif" font-weight="700" letter-spacing="1">${grade}</text>
          </svg>
        </div>
        <div class="hero-text-block">
          <div class="hero-summary-main">${data.summary || ''}</div>
          ${data.bottleneck ? `<div class="hero-bottleneck">병목 · <strong>${data.bottleneck}</strong></div>` : ''}
        </div>
      </div>`
    document.getElementById('result-bottleneck').innerHTML = ''

    this.renderScoreBars(scores, scoresAfter, data.bottleneck, data.upgrades)

    const recHeader = document.getElementById('result-rec-header')
    if (recHeader) recHeader.style.display = 'flex'

    const rows = (data.upgrades || [])
      .sort((a, b) => a.priority - b.priority)
      .map((u, i) => this.buildCard(u, i, scores, scoresAfter))
      .join('')
    document.getElementById('result-cards').innerHTML = rows

    const tMin = this.formatPrice(data.total_min)
    const tMax = this.formatPrice(data.total_max)
    document.getElementById('result-total').innerHTML =
      `<span class="total-label">총 예상 비용</span><span class="total-amount">${tMin} ~ ${tMax}</span>`

    const cautionEl = document.getElementById('result-caution')
    if (data.caution) {
      cautionEl.textContent = '⚠️ ' + data.caution
      cautionEl.style.display = 'block'
    } else {
      cautionEl.style.display = 'none'
    }

    requestAnimationFrame(() => {
      document.querySelectorAll('.ring-arc').forEach(el => {
        el.style.strokeDashoffset = el.dataset.target
      })
    })
  },

  generateAnalysisText(scores, bottleneck) {
    const label = { cpu: 'CPU', gpu: 'GPU', ram: 'RAM', storage: '저장장치' }
    const parts = Object.entries(scores).filter(([k]) => k !== 'overall')
    const sorted = [...parts].sort(([, a], [, b]) => a - b)
    const weakest = sorted[0]
    const good = parts.filter(([, v]) => v >= 70).map(([k]) => label[k])
    const overall = scores.overall || 0
    const lines = []

    // Purpose-aware sufficiency check
    const purposeMap = SUFFICIENCY[state.purpose]
    if (purposeMap) {
      const rule = purposeMap[state.subPurpose] || purposeMap['_']
      if (rule && overall >= rule.t && (!weakest || weakest[1] >= rule.t - 18)) {
        lines.push(rule.msg)
        if (good.length >= 2)
          lines.push(`특히 ${good.slice(0, 2).join(', ')} 성능이 뛰어나요!`)
        else if (good.length === 1)
          lines.push(`${good[0]} 성능도 충분한 수준이에요.`)
        return lines
      }
    }

    // Weakness analysis
    if (weakest && weakest[1] < 65)
      lines.push(`현재 ${label[weakest[0]]}가 제일 약세를 보이고 있어요!`)
    if (good.length >= 2)
      lines.push(`${good.join(', ')}은 해당 작업에 아주 적합한 상태예요!`)
    else if (good.length === 1)
      lines.push(`${good[0]}은 해당 작업에 충분한 성능이에요.`)
    if (overall >= 75)
      lines.push('전반적으로 우수한 PC 상태를 유지하고 있어요.')
    else if (overall >= 55)
      lines.push('조금만 개선하면 훨씬 쾌적하게 사용할 수 있어요!')
    else
      lines.push('핵심 부품을 업그레이드하면 확실히 달라진 성능을 느낄 수 있어요!')

    return lines
  },

  getPartScoreKey(part) {
    const p = (part || '').toLowerCase()
    if (p.includes('cpu') || p.includes('프로세서')) return 'cpu'
    if (p.includes('gpu') || p.includes('그래픽')) return 'gpu'
    if (p.includes('ram') || p.includes('메모리')) return 'ram'
    if (p.includes('저장') || p.includes('ssd') || p.includes('hdd') || p.includes('nvme')) return 'storage'
    return null
  },

  drawRadar(scores, scoresAfter) {
    const axes = ['CPU', 'GPU', 'RAM', '저장', '종합']
    const keys = ['cpu', 'gpu', 'ram', 'storage', 'overall']
    const N = 5, cx = 105, cy = 100, r = 70
    const angle = i => (Math.PI * 2 * i / N) - Math.PI / 2
    const pt = (val, i) => {
      const a = angle(i), d = (Math.min(val, 100) / 100) * r
      return [cx + d * Math.cos(a), cy + d * Math.sin(a)]
    }
    const poly = pts => pts.map(p => p.join(',')).join(' ')

    const grid = [25, 50, 75, 100].map(pct => {
      const pts = keys.map((_, i) => pt(pct, i))
      return `<polygon points="${poly(pts)}" fill="none" style="stroke:var(--border)" stroke-width="1"/>`
    }).join('')
    const axisLines = keys.map((_, i) => {
      const [x, y] = pt(100, i)
      return `<line x1="${cx}" y1="${cy}" x2="${x}" y2="${y}" style="stroke:var(--border)" stroke-width="1"/>`
    }).join('')

    const bPts = keys.map((k, i) => pt(scores[k] || 0, i))
    const beforePoly = `<polygon points="${poly(bPts)}" fill="rgba(239,68,68,0.14)" stroke="rgba(239,68,68,0.7)" stroke-width="1.5"/>`
    const aPts = keys.map((k, i) => pt(scoresAfter[k] || 0, i))
    const afterPoly = `<polygon points="${poly(aPts)}" fill="var(--p-tint-18)" stroke="var(--primary)" stroke-width="1.8"/>`

    const labelOffset = r + 20
    const labels = axes.map((name, i) => {
      const a = angle(i)
      const x = cx + labelOffset * Math.cos(a)
      const y = cy + labelOffset * Math.sin(a)
      return `<text x="${x}" y="${y}" text-anchor="middle" dominant-baseline="middle" style="fill:var(--muted)" font-size="10" font-family="system-ui" font-weight="600">${name}</text>`
    }).join('')

    return `<svg width="210" height="200" viewBox="0 0 210 200">${grid}${axisLines}${beforePoly}${afterPoly}${labels}</svg>`
  },

  renderScoreBars(scores, scoresAfter, bottleneck, upgrades) {
    const el = document.getElementById('result-radar')
    const anEl = document.getElementById('result-analysis')
    if (!el) return

    const axes = [
      { key: 'cpu', label: 'CPU' },
      { key: 'gpu', label: 'GPU' },
      { key: 'ram', label: 'RAM' },
      { key: 'storage', label: '저장장치' },
    ]
    const upgradedKeys = new Set((upgrades || []).map(u => this.getPartScoreKey(u.part)).filter(Boolean))

    const bars = axes.map(({ key, label }) => {
      const before = scores[key] || 0
      const after = scoresAfter[key] || 0
      const color = this.scoreColor(before)
      const isUpgraded = upgradedKeys.has(key)
      const afterBar = isUpgraded
        ? `<div class="sbar-fill-after" style="width:0%" data-w="${after}"></div>` : ''
      const afterLabel = isUpgraded
        ? `<span class="sbar-after-val"><svg width="10" height="10" viewBox="0 0 24 24" fill="none" style="vertical-align:middle;margin:0 2px"><path stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" d="M5 12h14M13 6l6 6-6 6"/></svg>${after}</span>` : ''
      return `
        <div class="sbar-row">
          <span class="sbar-label">${label}</span>
          <div class="sbar-track">
            ${afterBar}
            <div class="sbar-fill-before" style="width:0%;background:${color}" data-w="${before}"></div>
          </div>
          <span class="sbar-value" style="color:${color}">${before}${afterLabel}</span>
        </div>`
    }).join('')

    const legendHtml = `
      <div class="radar-legend-row">
        <div class="legend-dot-item"><div class="legend-dot" style="background:rgba(239,68,68,0.8)"></div>현재</div>
        <div class="legend-dot-item"><div class="legend-dot" style="background:var(--primary)"></div>업그레이드 후</div>
      </div>`

    el.innerHTML = `
      <div class="score-section-grid">
        <div class="score-radar-col">
          ${legendHtml}
          ${this.drawRadar(scores, scoresAfter)}
        </div>
        <div class="score-bars-col">
          <div class="sbar-section">${bars}</div>
        </div>
      </div>`
    el.style.display = 'block'

    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        el.querySelectorAll('.sbar-fill-before,.sbar-fill-after').forEach(b => {
          b.style.width = b.dataset.w + '%'
        })
      })
    })

    if (anEl) {
      const lines = this.generateAnalysisText(scores, bottleneck)
      anEl.innerHTML = lines.map(l => `<p class="analysis-line">${l}</p>`).join('')
      anEl.style.display = 'block'
    }
  },

  copyText(btn) {
    const text = btn.dataset.text
    const origHTML = btn.innerHTML
    navigator.clipboard.writeText(text).then(() => {
      btn.classList.add('copied')
      btn.innerHTML = `<svg width="13" height="13" fill="none" viewBox="0 0 24 24"><path stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" d="M20 6L9 17l-5-5"/></svg> 복사됨`
      setTimeout(() => { btn.classList.remove('copied'); btn.innerHTML = origHTML }, 2000)
    })
  },

  buildCard(u, idx, scores, scoresAfter) {
    const scoreKey = this.getPartScoreKey(u.part)
    const sb = scores && scoreKey ? (scores[scoreKey] || 0) : null
    const sa = scoresAfter && scoreKey ? (scoresAfter[scoreKey] || 0) : null
    const compatCls = u.compatible ? '' : 'ucard-incompat'

    const scoreHtml = sb !== null ? `
      <div class="ucard-score">
        <span style="color:${this.scoreColor(sb)};font-weight:700">${sb}</span>
        <svg width="11" height="11" viewBox="0 0 24 24" fill="none" style="color:var(--muted-2)"><path stroke="currentColor" stroke-width="2.5" stroke-linecap="round" d="M5 12h14M13 6l6 6-6 6"/></svg>
        <span style="color:var(--primary-light);font-weight:700">${sa}</span>
        <span class="ucard-delta">+${sa - sb}</span>
      </div>` : '<div></div>'

    const incompatHtml = !u.compatible && u.incompatible_reason
      ? `<p class="ucard-incompat-msg">⚠ ${u.incompatible_reason}</p>` : ''

    const q = encodeURIComponent(u.recommended)
    const stores = [
      { name: '쿠팡',   cls: 'coupang', url: `https://www.coupang.com/np/search?q=${q}` },
      { name: '네이버 쇼핑', cls: 'naver',   url: `https://search.shopping.naver.com/search/all?query=${q}` },
      { name: '다나와', cls: 'danawa',  url: `https://search.danawa.com/dsearch.php?query=${q}` },
      { name: '11번가', cls: 'st11',    url: `https://search.11st.co.kr/Search.tmall?kwd=${q}` },
      { name: 'G마켓',  cls: 'gmarket', url: `https://browse.gmarket.co.kr/search?keyword=${q}` },
    ]
    const storeLinks = stores.map(s => `
      <a class="ucard-store-row ucard-store-${s.cls}" href="${s.url}" target="_blank" onclick="event.stopPropagation()">
        <span class="ucard-store-name">${s.name}에서 검색하기</span>
        <svg width="13" height="13" viewBox="0 0 24 24" fill="none"><path stroke="currentColor" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round" d="M18 13v6a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h6M15 3h6v6M10 14L21 3"/></svg>
      </a>`).join('')

    return `
    <div class="ucard ${compatCls}" style="--i:${idx}" onclick="App.toggleCard(this)">
      <div class="ucard-top">
        <div class="ucard-meta">
          <span class="ucard-num">0${idx + 1}</span>
          <span class="ucard-part-chip">${u.part}</span>
        </div>
        <div class="ucard-top-right">
          <span class="ucard-price-badge">${this.formatPrice(u.price_min)} ~ ${this.formatPrice(u.price_max)}</span>
          <svg class="ucard-chevron" width="14" height="14" viewBox="0 0 24 24" fill="none"><path stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round" d="M6 9l6 6 6-6"/></svg>
        </div>
      </div>
      <div class="ucard-models">
        <div class="ucard-model-col">
          <span class="ucard-model-label">현재</span>
          <span class="ucard-model-before">${u.current || '미확인'}</span>
        </div>
        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" style="color:var(--muted-2);flex-shrink:0"><path stroke="currentColor" stroke-width="2.5" stroke-linecap="round" d="M5 12h14M13 6l6 6-6 6"/></svg>
        <div class="ucard-model-col">
          <span class="ucard-model-label">추천</span>
          <span class="ucard-model-after">${u.recommended}</span>
        </div>
      </div>
      ${u.reason ? `<p class="ucard-reason">${u.reason}</p>` : ''}
      ${u.detail ? `<p class="ucard-tech">${u.detail}</p>` : ''}
      ${incompatHtml}
      <div class="ucard-footer">
        ${scoreHtml}
        <button class="btn-copy-text" data-text="${u.recommended}" onclick="event.stopPropagation();App.copyText(this)">
          <svg width="12" height="12" fill="none" viewBox="0 0 24 24"><rect x="9" y="9" width="13" height="13" rx="2" stroke="currentColor" stroke-width="2"/><path stroke="currentColor" stroke-width="2" stroke-linecap="round" d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>
          복사
        </button>
      </div>
      <div class="ucard-links">
        <div class="ucard-links-inner">
          <p class="ucard-links-label">구매처 검색</p>
          ${storeLinks}
        </div>
      </div>
    </div>`
  },

  toggleCard(card) {
    card.classList.toggle('expanded')
  },

  formatPrice(n) {
    if (!n) return '미정'
    const man = Math.floor(n / 10000)
    const rest = n % 10000
    if (rest === 0) return man + '만원'
    return (n / 10000).toFixed(1) + '만원'
  },

  scoreColor(s) {
    if (s >= 80) return 'var(--score-good)'
    if (s >= 60) return 'var(--score-mid)'
    return 'var(--score-bad)'
  },

  scoreGrade(s) {
    if (s >= 80) return '좋음'
    if (s >= 60) return '보통'
    return '요주의'
  },

  renderSpecsView(data) {
    if (!data) { document.getElementById('specs-content').innerHTML = '<p class="error-msg">사양을 가져오지 못했어요.</p>'; return }

    const rows = []

    if (data.cpu) {
      const c = data.cpu
      rows.push(['CPU', `${c.name || '미확인'} (${c.cores || '?'}코어/${c.threads || '?'}스레드, ${c.socket || '?소켓'})`])
    } else {
      rows.push(['CPU', '<span class="na">확인 불가</span>'])
    }

    if (data.motherboard) {
      const mb = data.motherboard
      rows.push(['메인보드', `${mb.manufacturer || ''} ${mb.model || '미확인'}`])
    } else {
      rows.push(['메인보드', '<span class="na">확인 불가</span>'])
    }

    if (data.ram) {
      const r = data.ram
      const mod = r.modules && r.modules[0]
      const type = mod ? `${mod.type}-${mod.speedMHz}` : ''
      rows.push(['RAM', `${r.totalGB}GB ${type} (${r.usedSlots}/${r.totalSlots || '?'} 슬롯 사용)`])
    } else {
      rows.push(['RAM', '<span class="na">확인 불가</span>'])
    }

    if (data.gpu && data.gpu.length > 0) {
      rows.push(['GPU', data.gpu.map(g => `${g.name}${g.vramGB ? ' ' + g.vramGB + 'GB' : ''}`).join(', ')])
    } else {
      rows.push(['GPU', '<span class="na">확인 불가</span>'])
    }

    if (data.storage && data.storage.length > 0) {
      rows.push(['저장장치', data.storage.map(d => `${d.busType} ${d.mediaType} ${d.sizeGB || '?'}GB`).join(' / ')])
    } else {
      rows.push(['저장장치', '<span class="na">확인 불가</span>'])
    }

    rows.push(['파워 (PSU)', '<span class="na">직접 입력 필요</span>'])
    rows.push(['케이스', '<span class="na">직접 입력 필요</span>'])

    if (data.os) {
      const caption = (data.os.caption || '').trim().replace(/\s+/g, ' ')
      const arch = (data.os.architecture || '').trim().replace(/\s+/g, ' ')
      rows.push(['운영체제', `${caption}${arch ? ' (' + arch + ')' : ''}`])
    }

    document.getElementById('specs-content').innerHTML = `
      <table class="specs-table">
        ${rows.map(([k, v]) => `<tr><td class="spec-key">${k}</td><td class="spec-val">${v}</td></tr>`).join('')}
      </table>`
  },

  toggleTheme() {
    const isDark = document.body.classList.toggle('dark')
    localStorage.setItem('theme', isDark ? 'dark' : 'light')
    document.getElementById('icon-moon').style.display = isDark ? 'none' : ''
    document.getElementById('icon-sun').style.display = isDark ? '' : 'none'
  }
}

// init
document.addEventListener('DOMContentLoaded', () => {
  const savedTheme = localStorage.getItem('theme')
  if (savedTheme === 'dark') {
    document.body.classList.add('dark')
    document.getElementById('icon-moon').style.display = 'none'
    document.getElementById('icon-sun').style.display = ''
  }

  App.updateBudget(500000)

  // ripple on all .ripple elements
  document.addEventListener('click', e => {
    const el = e.target.closest('.ripple')
    if (!el) return
    const r = document.createElement('span')
    r.className = 'ripple-effect'
    const rect = el.getBoundingClientRect()
    r.style.left = (e.clientX - rect.left) + 'px'
    r.style.top = (e.clientY - rect.top) + 'px'
    el.appendChild(r)
    setTimeout(() => r.remove(), 560)
  })
})
