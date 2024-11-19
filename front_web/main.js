const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');

const getDataJson = require('./frontend/assets/getDataJson');

require('./frontend/assets/getDataJson');

let mainWindow;

function createWindow() {
    mainWindow = new BrowserWindow({
        width: 800,
        height: 600,
        webPreferences: {
            preload: path.join(__dirname, 'functions/preload.js'),
            contextIsolation: true
        }
    })

    mainWindow.loadFile('frontend/index.html')

    mainWindow.on('closed', () => {
        mainWindow = null
    })
}

app.on('ready', createWindow)

ipcMain.handle('getDataJson', async () => {
    return await getDataJson();
});

app.on('window-all-closed', () => {
    if (process.platform !== 'darwin') {
        app.quit()
    }
})