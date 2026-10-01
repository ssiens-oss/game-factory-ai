import { SETTINGS } from './config.js';
import { Simulation } from './simulation.js';
import { Renderer } from './renderer.js';
import { Input } from './input.js';
import { AudioSystem } from './audio.js';
import { HUD } from './hud.js';

const $ = id => document.getElementById(id), params = new URLSearchParams(location.search);
const sim = new Simulation(params.has('seed') ? Number(params.get('seed')) : Date.now());
const renderer = new Renderer($('game')), audio = new AudioSystem(), hud = new HUD();
let running = false, started = false, last = performance.now(), accumulator = 0, held = null, uiTick = 0;
const stats = { frames: 0, maxUpdateMs: 0, updateMs: 0, frameMs: 16.7, steps: 0 };
const input = new Input({ canvas: $('game'), joystick: $('joy'), stick: $('stick'), fire: $('fire'), dash: $('dash'), reload: $('reload'), onPause: () => running ? pause() : started && resume() });
document.body.classList.add('menu');
function pause() {
  if (!started) return;
  running = false; input.clear(); held = null; accumulator = 0; $('pause-screen').hidden = false; $('resume').focus();
}
function resume() {
  if (!started) return;
  input.clear(); held = null; accumulator = 0; last = performance.now(); running = true; $('pause-screen').hidden = true; $('game').focus({ preventScroll: true });
}
$('start').addEventListener('click', () => {
  started = true; document.body.classList.remove('menu'); document.body.classList.add('playing'); $('title').hidden = true;
  audio.unlock(); resume(); hud.notify('OPERATION LIVE · HOLD FIRE TO AUTO-AIM', sim.time);
});
$('pause').addEventListener('click', pause); $('resume').addEventListener('click', () => { audio.unlock(); resume(); });
$('mute').addEventListener('click', () => { audio.unlock(); audio.setMuted(!audio.muted); $('mute').setAttribute('aria-pressed', String(audio.muted)); $('mute').setAttribute('aria-label', audio.muted ? 'Unmute sound' : 'Mute sound'); $('mute').innerHTML = `SOUND <span>${audio.muted ? 'OFF' : 'ON'}</span>`; });
window.addEventListener('blur', pause); document.addEventListener('visibilitychange', () => { if (document.hidden) pause(); });
window.addEventListener('resize', () => { renderer.resize(); input.clear(); });
if (window.visualViewport) window.visualViewport.addEventListener('resize', () => renderer.resize());
window.addEventListener('error', () => { $('boot-error').hidden = false; });
window.addEventListener('unhandledrejection', () => { $('boot-error').hidden = false; });
function frame(now) {
  try {
    const elapsed = Math.min(SETTINGS.maxFrame, Math.max(0, (now - last) / 1000)); last = now;
    stats.frameMs += (elapsed * 1000 - stats.frameMs) * 0.02;
    if (running) {
      accumulator += elapsed;
      // Preserve action edges on high refresh displays until a simulation tick consumes them.
      const next = input.snapshot(); held = { ...next, dash: next.dash || held?.dash, reload: next.reload || held?.reload };
      if (held.aim) held.worldAim = renderer.screenToWorld(held.aim); else held.worldAim = null;
      let steps = 0; const before = performance.now();
      while (accumulator >= SETTINGS.step && steps < SETTINGS.maxSteps) {
        sim.update(SETTINGS.step, { ...held, aim: held.worldAim }); held.dash = held.reload = false;
        accumulator -= SETTINGS.step; steps++; stats.steps++;
      }
      if (steps === SETTINGS.maxSteps) accumulator = 0;
      stats.updateMs = performance.now() - before; stats.maxUpdateMs = Math.max(stats.maxUpdateMs, stats.updateMs);
      for (const event of sim.takeEvents()) { audio.play(event.kind); if (event.text) hud.notify(event.text, sim.time); if ((event.kind === 'hurt' || event.kind === 'dash') && !renderer.low) { try { navigator.vibrate?.(event.kind === 'hurt' ? 22 : 12); } catch {} } }
      hud.update(sim);
    }
    renderer.draw(sim, elapsed, running); stats.frames++;
    // Slow-frame quality reduction affects decorative rain and shake only.
    if (++uiTick > 300 && stats.frameMs > 28) renderer.low = true;
    requestAnimationFrame(frame);
  } catch (error) { $('boot-error').hidden = false; running = false; console.error(error); }
}
hud.update(sim, true); requestAnimationFrame(frame);
// Explicit opt-in inspection surface for reproducible browser tests, absent in normal play.
if (params.get('test') === '1') window.__echo = { sim, renderer, input, stats, pause, resume, get running() { return running; } };
