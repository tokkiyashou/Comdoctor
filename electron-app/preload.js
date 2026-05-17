const { contextBridge, ipcRenderer } = require('electron')

contextBridge.exposeInMainWorld('electronAPI', {
  collectSpecs: () => ipcRenderer.invoke('collect-specs'),
  analyze: (payload) => ipcRenderer.invoke('analyze', payload)
})
