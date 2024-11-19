const path = require('path');
const fs = require('fs');
const { app } = require('electron');

const loadJson = async () => {
    const jsonPath = path.join(app.getAppPath(), 'frontend/assets/json/auth.json'); // Correct the path
    const data = fs.readFileSync(jsonPath, 'utf8');
    return JSON.parse(data);
};

module.exports = loadJson;