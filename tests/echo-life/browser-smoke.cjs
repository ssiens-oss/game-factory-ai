#!/usr/bin/env node
'use strict';
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const http = require('node:http');
let playwright;
try { playwright = require('playwright'); }
catch { playwright = require('/opt/codex/runtimes/codex-primary-runtime/dependencies/node/node_modules/playwright'); }
const base = process.env.ECHO_BASE_URL || 'http://127.0.0.1:4173';
const shots = process.env.ECHO_SCREENSHOTS;
const servedRoot = path.resolve(process.env.ECHO_SERVE_ROOT || '.pages-stage');
let server, browser;

function serve() {
  const mime = { '.html': 'text/html', '.js': 'text/javascript', '.css': 'text/css', '.svg': 'image/svg+xml', '.json': 'application/json', '.webmanifest': 'application/manifest+json' };
  server = http.createServer((req, res) => {
    const name = decodeURIComponent(new URL(req.url, base).pathname);
    const file = path.resolve(servedRoot, '.' + name + (name.endsWith('/') ? 'index.html' : ''));
    if (!file.startsWith(servedRoot + path.sep)) { res.writeHead(403); res.end(); return; }
    fs.readFile(file, (err, bytes) => { if (err) { res.writeHead(404); res.end('Not found'); return; } res.setHeader('Content-Type', mime[path.extname(file)] || 'application/octet-stream'); res.end(bytes); });
  });
  const url = new URL(base);
  return new Promise((resolve, reject) => { server.once('error', reject); server.listen(Number(url.port || 80), url.hostname, resolve); });
}
async function screenshot(page, name) {
  if (!shots) return;
  fs.mkdirSync(shots, { recursive: true });
  await page.screenshot({ path: path.join(shots, name + '.png') });
}
async function bounds(page, selectors) {
  for (const selector of selectors) {
    const box = await page.locator(selector).boundingBox();
    assert(box, selector + ' is visible');
    const { width, height } = page.viewportSize();
    assert(box.x >= -1 && box.y >= -1 && box.x + box.width <= width + 1 && box.y + box.height <= height + 1, selector + ' stays in viewport ' + JSON.stringify(box));
  }
  assert(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), 'No horizontal page overflow');
}
async function touch(page, selector, type, id, x, y) {
  await page.locator(selector).dispatchEvent(type, { pointerId: id, pointerType: 'touch', isPrimary: id === 11, clientX: x, clientY: y, button: 0, buttons: type === 'pointerup' || type === 'pointercancel' ? 0 : 1, bubbles: true });
}
async function newPage(options) {
  const context = await browser.newContext(options);
  const page = await context.newPage();
  const errors = [], bad = [];
  page.on('pageerror', e => errors.push(e.message));
  page.on('console', m => { if (m.type() === 'error' && !m.location().url?.endsWith('/favicon.ico')) errors.push(m.text()); });
  page.on('response', r => { if (r.status() >= 400 && !r.url().endsWith('/favicon.ico')) bad.push(r.status() + ' ' + r.url()); });
  return { context, page, errors, bad };
}
async function ready(page, url) {
  await page.goto(base + url + '?test=1&seed=41', { waitUntil: 'networkidle' });
  await page.waitForFunction(() => window.__echo && window.__echo.stats.frames > 2);
  assert(await page.locator('#boot-error').isHidden(), 'No game boot failure');
}
async function clean(record) {
  assert.deepEqual(record.errors, [], 'No JavaScript/console errors');
  assert.deepEqual(record.bad, [], 'All requested resources exist');
  await record.context.close();
}

(async () => {
  if (process.argv.includes('--serve')) await serve();
  let executablePath = process.env.ECHO_CHROMIUM_PATH;
  if (!executablePath && fs.existsSync('/usr/bin/chromium')) executablePath = '/usr/bin/chromium';
  browser = await playwright.chromium.launch({ headless: true, ...(executablePath ? { executablePath } : {}), args: ['--no-sandbox', '--disable-dev-shm-usage'] });

  // Keep the historical top-down build independently playable.
  const baseline = await newPage({ viewport: { width: 1280, height: 720 } });
  await baseline.page.goto(base + '/echo_life/v40.html');
  assert.match(await baseline.page.title(), /v40 Top Down/);
  await baseline.page.locator('#start').click();
  assert.equal(await baseline.page.locator('#title').evaluate(el => getComputedStyle(el).display), 'none');
  assert.equal(await baseline.page.locator('#c').evaluate(el => !!el.getContext('2d')), true);
  await screenshot(baseline.page, 'v40-desktop');
  await clean(baseline);
  console.log('PASS v40 preserved playable top-down baseline');

  const desktop = await newPage({ viewport: { width: 1440, height: 900 } });
  const page = desktop.page;
  await ready(page, '/echo_life/v41.html');
  await bounds(page, ['#start']);
  assert.equal(await page.evaluate(() => window.__echo.sim.time), 0, 'Menu freezes simulation');
  await screenshot(page, 'v41-desktop-title');
  await page.locator('#start').click();
  await page.waitForFunction(() => window.__echo.running && window.__echo.sim.time > 0);
  await bounds(page, ['.topbar', '.telemetry', '#pause', '#mute']);
  await page.evaluate(() => { const s = window.__echo.sim; s.enemies = []; s.spawnTimer = 100; s.player.x = s.player.y = 90; s.player.vx = s.player.vy = 0; });
  const before = await page.evaluate(() => window.__echo.sim.player.y);
  await page.keyboard.down('w');
  await page.waitForTimeout(350);
  await page.keyboard.up('w');
  assert(await page.evaluate(y => y - window.__echo.sim.player.y > 35, before), 'Held movement advances continuously');
  await page.keyboard.press('Escape');
  assert(await page.locator('#pause-screen').isVisible(), 'Escape opens pause');
  const paused = await page.evaluate(() => window.__echo.sim.time);
  await page.waitForTimeout(150);
  assert.equal(await page.evaluate(() => window.__echo.sim.time), paused, 'Pause freezes simulation');
  await page.locator('#resume').click();
  await page.waitForFunction(t => window.__echo.sim.time > t, paused);
  await page.locator('#mute').click();
  assert.equal(await page.locator('#mute').getAttribute('aria-pressed'), 'true');

  // Projectile travel is real: ammunition is spent before the target takes damage.
  const projectile = await page.evaluate(() => {
    const { sim: s, pause } = window.__echo; pause(); s.player.x = s.player.y = 90; s.player.vx = s.player.vy = 0; s.player.mag = 24; s.bullets = [];
    const e = { id: 900, x: 330, y: 90, type: 'stalker', hp: 61, maxHp: 61, speed: 0, timer: 100, plan: 100, path: [], flash: 0, phase: 'hunt', charge: 0, side: 1 };
    s.enemies = [e]; s.shoot(0); const immediate = e.hp; s.updateBullets(1 / 60); const early = e.hp;
    for (let i = 0; i < 18; i++) s.updateBullets(1 / 60);
    return { immediate, early, after: e.hp, mag: s.player.mag };
  });
  assert.deepEqual(projectile, { immediate: 61, early: 61, after: 27, mag: 23 });
  await page.evaluate(() => { const s = window.__echo.sim; s.player.mag = 1; s.player.reserve = 36; s.bullets = []; });
  await page.locator('#resume').click();
  await page.keyboard.press('r');
  await page.waitForFunction(() => window.__echo.sim.reloadTimer > 0);
  await page.waitForFunction(() => window.__echo.sim.reloadTimer === 0, null, { timeout: 4000 });
  assert.equal(await page.evaluate(() => window.__echo.sim.player.mag), 24, 'Reload transfers reserve into magazine');
  await page.evaluate(() => { const s = window.__echo.sim; s.enemies = []; s.spawnTimer = 100; });
  await page.waitForFunction(() => document.getElementById('ammo').textContent.startsWith('24 /'));
  await screenshot(page, 'v41-desktop-game');
  assert(await page.evaluate(() => window.__echo.renderer.city.cache.size <= 32), 'City tile cache is bounded');
  const performance = await page.evaluate(() => ({ frameMs: Number(window.__echo.stats.frameMs.toFixed(2)), maxUpdateMs: Number(window.__echo.stats.maxUpdateMs.toFixed(2)), cachedCityTiles: window.__echo.renderer.city.cache.size, canvasPixels: window.__echo.renderer.canvas.width * window.__echo.renderer.canvas.height }));
  assert(performance.canvasPixels < 2205000, 'Canvas backing pixels stay within rendering budget');
  console.log('Desktop rendering measurements: ' + JSON.stringify(performance));
  await clean(desktop);
  console.log('PASS v41 desktop imports, HUD, movement, pause, audio, projectile hits and reload');

  for (const viewport of [{ width: 844, height: 390 }, { width: 390, height: 844 }, { width: 667, height: 375 }, { width: 320, height: 568 }]) {
    const mobile = await newPage({ viewport, hasTouch: true, isMobile: true, deviceScaleFactor: 2 });
    const p = mobile.page;
    // Both equivalent GitHub Pages paths must load their relative module graph.
    await ready(p, viewport.width === 844 ? '/v41.html' : '/echo_life/v41.html');
    await bounds(p, ['#start']);
    await screenshot(p, `v41-${viewport.width}x${viewport.height}-title`);
    await p.locator('#start').click();
    await bounds(p, ['.topbar', '.mission', '.telemetry', '#joy', '#fire', '#dash', '#reload', '#pause']);
    assert(await p.locator('.mission').evaluate(el => el.scrollWidth <= el.clientWidth), 'Mission content fits its panel');
    const headerBox = await p.locator('.topbar').boundingBox(), hudBox = await p.locator('.telemetry').boundingBox();
    assert(headerBox.y + headerBox.height <= hudBox.y + 1, 'Mission header does not overlap telemetry');
    const boxes = await Promise.all(['#joy', '#fire', '#dash', '#reload'].map(s => p.locator(s).boundingBox()));
    for (let a = 0; a < boxes.length; a++) for (let b = a + 1; b < boxes.length; b++) {
      const x = boxes[a], y = boxes[b];
      assert(x.x + x.width <= y.x || y.x + y.width <= x.x || x.y + x.height <= y.y || y.y + y.height <= x.y, 'Touch targets do not overlap');
    }
    await p.evaluate(() => {
      const s = window.__echo.sim; s.player.x = s.player.y = 90; s.player.mag = 24; s.player.vx = s.player.vy = 0; s.spawnTimer = 100; s.bullets = [];
      s.enemies = [250, 390, 530].map((x, i) => ({ id: 910 + i, x, y: 90, type: 'stalker', hp: 61, maxHp: 61, speed: 0, timer: 100, plan: 100, path: [], flash: 0, phase: 'hunt', charge: 0, side: 1 }));
    });
    const joy = boxes[0], fire = boxes[1];
    await touch(p, '#joy', 'pointerdown', 11, joy.x + joy.width * .8, joy.y + joy.height / 2);
    await touch(p, '#fire', 'pointerdown', 12, fire.x + fire.width / 2, fire.y + fire.height / 2);
    await p.waitForTimeout(650);
    assert(await p.evaluate(() => window.__echo.sim.player.x > 155), 'Held joystick keeps moving without pointermove');
    assert(await p.evaluate(() => window.__echo.sim.player.kills >= 1 && window.__echo.sim.player.mag < 22), 'Independent fire contact shoots repeatedly while moving');
    await touch(p, '#joy', 'pointercancel', 11, 0, 0);
    await touch(p, '#fire', 'pointerup', 12, 0, 0);
    assert(await p.evaluate(() => window.__echo.input.joyPointer === null && window.__echo.input.firePointers.size === 0), 'Touch cancel/release clears contacts');
    await p.locator('#dash').click();
    await p.waitForFunction(() => window.__echo.sim.dashCooldown > 0);
    await screenshot(p, `v41-${viewport.width}x${viewport.height}-game`);
    await p.evaluate(() => window.dispatchEvent(new Event('blur')));
    assert(await p.locator('#pause-screen').isVisible(), 'Focus loss pauses on mobile');
    await clean(mobile);
    console.log(`PASS v41 ${viewport.width}x${viewport.height} title/HUD bounds, multi-contact controls, hold fire, dash and focus pause`);
  }
  console.log('All ECHO//LIFE browser checks passed.');
})().catch(error => { console.error(error); process.exitCode = 1; }).finally(async () => { if (browser) await browser.close(); if (server) await new Promise(resolve => server.close(resolve)); });
