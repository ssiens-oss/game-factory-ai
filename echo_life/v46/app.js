import { Checkpoint } from './checkpoint.js';
import { PuzzleUI } from './puzzle-ui.js';
import { SETTINGS } from '../v42/config.js';
import { Simulation } from './simulation.js';
import { Renderer } from './renderer.js';
import { Input } from '../v42/input.js';
import { AudioSystem } from '../v42/audio.js';
import { HUD } from '../v42/hud.js';
import { Profile } from './profile.js';
import { UPGRADES, upgradeCost } from '../v42/progression.js';

const $ = id => document.getElementById(id), params = new URLSearchParams(location.search);
const sim = new Simulation(params.has('seed') ? Number(params.get('seed')) : Date.now());
const profile = new Profile(), checkpoint = new Checkpoint();
const renderer = new Renderer($('game')), audio = new AudioSystem(), hud = new HUD();
let running = false, started = false, last = performance.now(), accumulator = 0, held = null, uiTick = 0;
const stats = { frames: 0, maxUpdateMs: 0, updateMs: 0, frameMs: 16.7, steps: 0 };
const input = new Input({ canvas: $('game'), joystick: $('joy'), stick: $('stick'), fire: $('fire'), dash: $('dash'), reload: $('reload'), onPause: () => puzzles.opened ? puzzles.close() : running ? pause() : started && resume() });
const saveRun = () => {const ok=checkpoint.save(sim);$('save-status').textContent=checkpoint.status;return ok;};
const puzzles = new PuzzleUI(sim, { pause, resume, hud, audio, save: saveRun, options:()=>profile.options });
document.body.classList.add('menu');
let saveTimer = 0;
function applyPreferences() {
  const settings = profile.settings, options=profile.options;
  document.body.classList.toggle('large-text',options.largeText);document.body.classList.toggle('high-contrast',options.contrast);document.body.classList.toggle('one-hand',options.oneHand);
  renderer.low=options.motion || options.quality==='low' || matchMedia('(prefers-reduced-motion: reduce)').matches;sim.calm=options.calm; if(sim.calm)sim.enemies=[];
  document.body.classList.toggle('calm-mode',options.calm);
  document.body.classList.toggle('compact-hud', settings.compact);
  document.body.classList.toggle('left-handed', settings.leftHanded);
  const smallPortrait = innerWidth < 560 && innerHeight > innerWidth;
  const fit = (innerWidth - 36) / (smallPortrait ? 285 : 330);
  document.documentElement.style.setProperty('--control-scale', Math.min(settings.controlScale, Math.max(0.8, fit)));
  renderer.zoom = settings.zoom; renderer.resize(); audio.setMuted(settings.muted);
  $('mute').setAttribute('aria-pressed', String(audio.muted)); $('mute').setAttribute('aria-label', audio.muted ? 'Unmute sound' : 'Mute sound'); $('mute').innerHTML = `SOUND <span>${audio.muted ? 'OFF' : 'ON'}</span>`;
}
for (const [id, key] of [['compact','compact'], ['left-handed','leftHanded'], ['control-scale','controlScale'], ['zoom','zoom']]) {
  const element = $(id); if (element.type === 'checkbox') element.checked = profile.settings[key]; else element.value = profile.settings[key];
  element.addEventListener('input', () => { profile.settings[key] = element.type === 'checkbox' ? element.checked : Number(element.value); applyPreferences(); profile.save(sim.score); input.clear(); });
}
for(const key of ['largeText','contrast','motion','haptics','quality','calm','oneHand','sensitivity','interactKey']){
  const el=$('option-'+key);if(el.type==='checkbox')el.checked=profile.options[key];else el.value=profile.options[key];
  el.addEventListener('input',()=>{profile.options[key]=el.type==='checkbox'?el.checked:el.type==='range'?Number(el.value):el.value;applyPreferences();profile.save(sim.score);input.clear();});
}
$('save-now').addEventListener('click',saveRun);
$('export-run').addEventListener('click',()=>{try{const raw=checkpoint.encode(sim),url=URL.createObjectURL(new Blob([raw],{type:'application/json'})),a=document.createElement('a');a.href=url;a.download='echo-life-v46-save.json';a.click();setTimeout(()=>URL.revokeObjectURL(url),1000);$('save-status').textContent='Run exported';}catch{$('save-status').textContent='Unable to export this run';}});
$('import-run').addEventListener('change',async e=>{const file=e.target.files?.[0];if(!file)return;if(file.size>65536){$('save-status').textContent='Save file is too large';return;}$('save-status').textContent='Importing run…';let raw;try{raw=await file.text();}catch{$('save-status').textContent='Unable to read this save';return;}if(checkpoint.import(raw,sim)){renderer.camera.x=sim.player.x;renderer.camera.y=sim.player.y;hud.lastUpdate=-1;hud.update(sim,true);puzzles.update();applyPreferences();} $('save-status').textContent=checkpoint.status;e.target.value='';});
$('migrate-run').hidden=!checkpoint.legacy.read();$('migrate-run').addEventListener('click',()=>{if(checkpoint.migrate(sim)){renderer.camera.x=sim.player.x;renderer.camera.y=sim.player.y;launch();}});
$('fullscreen').addEventListener('click', async () => { try { if (document.fullscreenElement) await document.exitFullscreen(); else await document.documentElement.requestFullscreen(); } catch { $('fullscreen').textContent = 'FULLSCREEN UNAVAILABLE'; } });
document.addEventListener('fullscreenchange', () => { $('fullscreen').textContent = document.fullscreenElement ? 'EXIT FULLSCREEN' : 'ENTER FULLSCREEN'; });
$('restart').addEventListener('click', () => { profile.save(sim.score); puzzles.close(false); checkpoint.clear(); sim.reset(); applyPreferences(); renderer.camera.x = renderer.camera.y = 90; saveTimer = 0; hud.lastUpdate = -1; resume(); hud.update(sim, true); });
function updateReport() {
  profile.save(sim.score); $('best').textContent = profile.best; $('run-kills').textContent = sim.player.kills;
  $('run-time').textContent = `${String(Math.floor(sim.time / 60)).padStart(2,'0')}:${String(Math.floor(sim.time % 60)).padStart(2,'0')}`;
  $('shop-cash').textContent = `${sim.player.cash}¢`; $('shop').replaceChildren();
  for (const [key, value] of Object.entries(UPGRADES)) {
    const rank = sim.upgrades[key], button = document.createElement('button'), name = document.createElement('span'), detail = document.createElement('small'), price = document.createElement('b');
    name.textContent = `${value.name} / ${rank} OF 3`; detail.textContent = value.detail; name.append(detail); price.textContent = rank >= 3 ? 'MAXED' : `${upgradeCost(key, rank)}¢`;
    button.append(name, price); button.dataset.upgrade = key; button.disabled = rank >= 3 || sim.player.cash < upgradeCost(key, rank);
    button.addEventListener('click', () => { if (sim.buy(key)) { audio.play('level'); saveRun(); updateReport(); hud.update(sim, true); } }); $('shop').append(button);
  }
}
applyPreferences();
function pause() {
  if (!started) return;
  running = false; input.clear(); held = null; accumulator = 0; saveRun(); if(puzzles.opened)return;updateReport(); $('pause-screen').hidden = false; $('resume').focus();
}
function resume() {
  if (!started || puzzles.opened) return;
  input.clear(); held = null; accumulator = 0; last = performance.now(); running = true; $('pause-screen').hidden = true; $('game').focus({ preventScroll: true });
}
function launch() {
  started = true; document.body.classList.remove('menu'); document.body.classList.add('playing'); $('title').hidden = true;
  applyPreferences(); audio.unlock(); resume(); puzzles.update(); hud.notify('F / RELAY · M / ATLAS · P / PRACTICE · J / NOTES', sim.time);
}
$('start').addEventListener('click', () => { checkpoint.clear(); sim.reset(); applyPreferences(); launch(); });
$('continue').hidden = !checkpoint.read();
$('continue').addEventListener('click', () => { if(checkpoint.restore(sim)) {renderer.camera.x=sim.player.x;renderer.camera.y=sim.player.y;launch();} });
$('pause').addEventListener('click', pause); $('resume').addEventListener('click', () => { audio.unlock(); resume(); });
$('mute').addEventListener('click', () => { audio.unlock(); audio.setMuted(!audio.muted); profile.settings.muted = audio.muted; profile.save(sim.score); $('mute').setAttribute('aria-pressed', String(audio.muted)); $('mute').setAttribute('aria-label', audio.muted ? 'Unmute sound' : 'Mute sound'); $('mute').innerHTML = `SOUND <span>${audio.muted ? 'OFF' : 'ON'}</span>`; });
window.addEventListener('blur', pause); document.addEventListener('visibilitychange', () => { if (document.hidden) {if(started)saveRun();pause();} });
window.addEventListener('resize', () => { applyPreferences(); input.clear(); });
if (window.visualViewport) window.visualViewport.addEventListener('resize', () => renderer.resize());
window.addEventListener('error', () => { $('boot-error').hidden = false; });
window.addEventListener('pagehide', () => { profile.save(sim.score); if(started) saveRun(); });
window.addEventListener('unhandledrejection', () => { $('boot-error').hidden = false; });
function frame(now) {
  try {
    const elapsed = Math.min(SETTINGS.maxFrame, Math.max(0, (now - last) / 1000)); last = now;
    stats.frameMs += (elapsed * 1000 - stats.frameMs) * 0.02;
    if (running) {
      accumulator += elapsed;
      // Preserve action edges on high refresh displays until a simulation tick consumes them.
      const next = input.snapshot();next.mx*=profile.options.sensitivity;next.my*=profile.options.sensitivity; held = { ...next, dash: next.dash || held?.dash, reload: next.reload || held?.reload, weapon: next.weapon || held?.weapon, heal: next.heal || held?.heal };
      if (held.aim) held.worldAim = renderer.screenToWorld(held.aim); else held.worldAim = null;
      let steps = 0; const before = performance.now();
      while (accumulator >= SETTINGS.step && steps < SETTINGS.maxSteps) {
        sim.update(SETTINGS.step, { ...held, aim: held.worldAim }); held.dash = held.reload = held.weapon = held.heal = false;
        accumulator -= SETTINGS.step; steps++; stats.steps++;
      }
      if (steps === SETTINGS.maxSteps) accumulator = 0;
      stats.updateMs = performance.now() - before; stats.maxUpdateMs = Math.max(stats.maxUpdateMs, stats.updateMs);
      for (const event of sim.takeEvents()) { audio.play(event.kind); if (event.text) hud.notify(event.text, sim.time); if ((event.kind === 'hurt' || event.kind === 'dash') && profile.options.haptics && !renderer.low) { try { navigator.vibrate?.(event.kind === 'hurt' ? 22 : 12); } catch {} } }
      hud.update(sim); puzzles.update();
      if (sim.time - saveTimer >= 5) { profile.save(sim.score); saveRun(); saveTimer = sim.time; }
    }
    puzzles.tick(elapsed);renderer.draw(sim, elapsed, running); stats.frames++;
    // Slow-frame quality reduction affects decorative rain and shake only.
    if (++uiTick > 300 && stats.frameMs > 28 && profile.options.quality==='auto') renderer.low = true;
    requestAnimationFrame(frame);
  } catch (error) { $('boot-error').hidden = false; running = false; console.error(error); }
}
hud.update(sim, true); requestAnimationFrame(frame);
// Explicit opt-in inspection surface for reproducible browser tests, absent in normal play.
if (params.get('test') === '1') window.__echo = { sim, renderer, input, stats, pause, resume, profile, puzzles, checkpoint, applyPreferences, get running() { return running; } };
