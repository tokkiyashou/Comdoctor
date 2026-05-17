require('dotenv').config()
const { app, BrowserWindow, ipcMain, Menu, shell } = require('electron')
const { execFile } = require('child_process')
const path = require('path')

const SERVER_URL = process.env.SERVER_URL || 'http://127.0.0.1:3001'

let mainWindow

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 960,
    height: 720,
    minWidth: 800,
    minHeight: 600,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false
    },
    title: '컴닥터',
    icon: path.join(__dirname, 'assets', 'Logo.png'),
    show: false
  })

  mainWindow.loadFile(path.join(__dirname, 'renderer', 'index.html'))
  mainWindow.once('ready-to-show', () => mainWindow.show())

  mainWindow.webContents.setWindowOpenHandler(({ url }) => {
    shell.openExternal(url)
    return { action: 'deny' }
  })
}

app.whenReady().then(() => { Menu.setApplicationMenu(null); createWindow() })
app.on('window-all-closed', () => { if (process.platform !== 'darwin') app.quit() })
app.on('activate', () => { if (BrowserWindow.getAllWindows().length === 0) createWindow() })

// PowerShell spec collection
const PS_SCRIPT = `
$result = @{}
$memTypeMap = @{17='SDRAM';24='DDR3';25='DDR';26='DDR4';34='DDR5'}

try {
  $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1
  $result.cpu = @{
    name = $cpu.Name.Trim()
    manufacturer = if ($cpu.Manufacturer) { $cpu.Manufacturer.Trim() } else { $null }
    cores = $cpu.NumberOfCores
    threads = $cpu.NumberOfLogicalProcessors
    maxClockMHz = $cpu.MaxClockSpeed
    socket = $cpu.SocketDesignation
  }
} catch { $result.cpu = $null; $result.cpuError = $_.Exception.Message }

try {
  $mb = Get-CimInstance Win32_BaseBoard | Select-Object -First 1
  $result.motherboard = @{
    manufacturer = if ($mb.Manufacturer) { $mb.Manufacturer.Trim() } else { $null }
    model = if ($mb.Product) { $mb.Product.Trim() } else { $null }
  }
} catch { $result.motherboard = $null; $result.motherboardError = $_.Exception.Message }

try {
  $rams = @(Get-CimInstance Win32_PhysicalMemory)
  $memArr = Get-CimInstance Win32_PhysicalMemoryArray | Select-Object -First 1
  $totalBytes = ($rams | Measure-Object -Property Capacity -Sum).Sum
  $result.ram = @{
    totalGB = [math]::Round($totalBytes / 1GB, 0)
    totalSlots = if ($memArr) { $memArr.MemoryDevices } else { $null }
    usedSlots = $rams.Count
    modules = @($rams | ForEach-Object {
      $t = [int]$_.SMBIOSMemoryType
      $type = if ($memTypeMap.ContainsKey($t)) { $memTypeMap[$t] } else { 'Unknown' }
      @{ capacityGB=[math]::Round($_.Capacity/1GB,0); speedMHz=$_.Speed; type=$type; slot=$_.DeviceLocator }
    })
  }
} catch { $result.ram = $null; $result.ramError = $_.Exception.Message }

try {
  $gpus = @(Get-CimInstance Win32_VideoController | Where-Object { $_.Name -notmatch 'Microsoft Basic' })
  $result.gpu = @($gpus | ForEach-Object {
    $vram = if ($_.AdapterRAM -ge 1073741824) { [math]::Round($_.AdapterRAM/1GB,0) } else { $null }
    @{ name=$_.Name; vramGB=$vram }
  })
} catch { $result.gpu = $null; $result.gpuError = $_.Exception.Message }

try {
  $pds = @(Get-PhysicalDisk | Select-Object FriendlyName,BusType,MediaType,Size)
  $btMap = @{3='ATA';11='SATA';17='NVMe';10='SAS'}
  $mtMap = @{3='HDD';4='SSD'}
  $result.storage = @($pds | ForEach-Object {
    $bt = if ($btMap.ContainsKey([int]$_.BusType)) { $btMap[[int]$_.BusType] } else { 'Unknown' }
    $mt = if ($mtMap.ContainsKey([int]$_.MediaType)) { $mtMap[[int]$_.MediaType] } else { 'Unknown' }
    @{ name=$_.FriendlyName; busType=$bt; mediaType=$mt; sizeGB=if($_.Size){[math]::Round($_.Size/1GB,0)}else{$null} }
  })
} catch {
  try {
    $disks = @(Get-CimInstance Win32_DiskDrive)
    $result.storage = @($disks | ForEach-Object {
      $mt = if ($_.Model -match 'SSD|NVMe|M\\.2') { 'SSD' } else { 'HDD' }
      $bt = if ($_.Model -match 'NVMe') { 'NVMe' } elseif ($_.InterfaceType -match 'SATA') { 'SATA' } else { $_.InterfaceType }
      @{ name=$_.Model; busType=$bt; mediaType=$mt; sizeGB=if($_.Size){[math]::Round([long]$_.Size/1GB,0)}else{$null} }
    })
  } catch { $result.storage = $null }
}

try {
  $osInfo = Get-CimInstance Win32_OperatingSystem | Select-Object -First 1
  $result.os = @{ caption=$osInfo.Caption; architecture=$osInfo.OSArchitecture; version=$osInfo.Version }
} catch { $result.os = $null }

$result | ConvertTo-Json -Depth 6 -Compress
`

ipcMain.handle('collect-specs', async () => {
  return new Promise((resolve) => {
    const encoded = Buffer.from(PS_SCRIPT, 'utf16le').toString('base64')
    execFile('powershell.exe',
      ['-NonInteractive', '-NoProfile', '-EncodedCommand', encoded],
      { timeout: 30000, maxBuffer: 2 * 1024 * 1024 },
      (err, stdout) => {
        if (err) return resolve({ error: err.message })
        try {
          const raw = JSON.parse(stdout.trim())
          // strip non-critical error fields (e.g. gpuError, ramError) — not needed downstream
          Object.keys(raw).forEach(k => { if (k.endsWith('Error')) delete raw[k] })
          resolve({ success: true, data: raw })
        } catch {
          resolve({ error: 'parse_failed' })
        }
      }
    )
  })
})

ipcMain.handle('analyze', async (_event, payload) => {
  try {
    const ctrl = new AbortController()
    const timer = setTimeout(() => ctrl.abort(), 120000)
    const response = await fetch(`${SERVER_URL}/api/analyze`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
      signal: ctrl.signal
    })
    clearTimeout(timer)
    const data = await response.json()
    return { status: response.status, data }
  } catch (err) {
    const isTimeout = err.name === 'AbortError'
    const isOffline = err.cause?.code === 'ECONNREFUSED' || err.cause?.code === 'ENOTFOUND'
    return {
      status: 0,
      data: {
        success: false,
        error: isTimeout ? 'TIMEOUT' : isOffline ? 'SERVER_UNAVAILABLE' : err.message,
        message: isTimeout ? '분석 시간이 너무 오래 걸려요. 잠시 후 다시 시도해주세요.'
          : isOffline ? '서버에 연결할 수 없어요. 서버가 실행 중인지 확인해주세요.'
          : '인터넷 연결을 확인해주세요'
      }
    }
  }
})
