import { chromium } from 'playwright';
import fs from 'fs';
import path from 'path';
import http from 'http';
import { spawn } from 'child_process';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const rootDir = path.resolve(__dirname, '..');
const screenshotsDir = path.join(rootDir, 'screenshots');

if (!fs.existsSync(screenshotsDir)) {
  fs.mkdirSync(screenshotsDir, { recursive: true });
}

const sliceName = process.argv[2] || 'slice-current';
const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
const targetPort = 5173;
const url = process.env.URL || `http://localhost:${targetPort}/`;

function isServerRunning(port) {
  return new Promise((resolve) => {
    const req = http.get(`http://localhost:${port}/`, (res) => {
      resolve(true);
    });
    req.on('error', () => resolve(false));
    req.setTimeout(1000, () => {
      req.destroy();
      resolve(false);
    });
  });
}

async function waitForServer(port, maxRetries = 20) {
  for (let i = 0; i < maxRetries; i++) {
    if (await isServerRunning(port)) return true;
    await new Promise((r) => setTimeout(r, 500));
  }
  return false;
}

async function capture() {
  let devServerProcess = null;
  const running = await isServerRunning(targetPort);
  if (!running && !process.env.URL) {
    console.log(`Starting Vite dev server on port ${targetPort}...`);
    devServerProcess = spawn('npx', ['vite', '--port', String(targetPort)], {
      cwd: rootDir,
      stdio: 'pipe',
      detached: false,
    });
    const ready = await waitForServer(targetPort);
    if (!ready) {
      console.error('Failed to start Vite dev server in time.');
      if (devServerProcess) devServerProcess.kill();
      process.exit(1);
    }
  }

  console.log(`Capturing screenshots on ${url}...`);
  const browser = await chromium.launch({ headless: true });

  try {
    // 1. Desktop Viewport (1440x900)
    const desktopContext = await browser.newContext({
      viewport: { width: 1440, height: 900 },
      deviceScaleFactor: 2
    });
    const desktopPage = await desktopContext.newPage();
    await desktopPage.goto(url, { waitUntil: 'networkidle', timeout: 15000 });
    await desktopPage.waitForTimeout(1000); // Allow spring animations to settle
    const desktopFilename = `${sliceName}_${timestamp}_1440x900.png`;
    const desktopPath = path.join(screenshotsDir, desktopFilename);
    await desktopPage.screenshot({ path: desktopPath });
    console.log(`Saved desktop screenshot: ${desktopPath}`);
    await desktopContext.close();

    // 2. Mobile Viewport (390x844 - iPhone standard)
    const mobileContext = await browser.newContext({
      viewport: { width: 390, height: 844 },
      deviceScaleFactor: 3,
      isMobile: true,
      hasTouch: true
    });
    const mobilePage = await mobileContext.newPage();
    await mobilePage.goto(url, { waitUntil: 'networkidle', timeout: 15000 });
    await mobilePage.waitForTimeout(1000);
    const mobileFilename = `${sliceName}_${timestamp}_390x844.png`;
    const mobilePath = path.join(screenshotsDir, mobileFilename);
    await mobilePage.screenshot({ path: mobilePath });
    console.log(`Saved mobile screenshot: ${mobilePath}`);
    await mobileContext.close();

    console.log('Capture complete!');
  } catch (err) {
    console.error('Error capturing screenshots:', err);
    process.exit(1);
  } finally {
    await browser.close();
    if (devServerProcess) {
      devServerProcess.kill();
    }
  }
}

capture();
