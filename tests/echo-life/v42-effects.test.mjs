import test from 'node:test';
import assert from 'node:assert/strict';
import { scenery, worldFeedback, screenFeedback } from '../../echo_life/v42/effects.js';
import { Simulation } from '../../echo_life/v42/simulation.js';
test('city effects render across negative world coordinates with valid canvas geometry', () => {
  let calls = 0;
  const gradient = { addColorStop() {} };
  const g = new Proxy({}, { get(o, k) {
    if (k in o) return o[k];
    if (k === 'ellipse') return (x, y, rx, ry) => { assert.ok(rx >= 0 && ry >= 0 && [x,y,rx,ry].every(Number.isFinite)); calls++; };
    if (k === 'arc') return (x, y, r) => { assert.ok(r >= 0 && [x,y,r].every(Number.isFinite)); calls++; };
    if (k.startsWith('create')) return () => gradient;
    return () => {};
  }});
  globalThis.document = { createElement: () => ({ getContext: () => g }) };
  const sim = new Simulation(42), bounds = { left: -1500, top: -1200, right: 800, bottom: 800 };
  for (const time of [0, 0.1, 1, 20]) { sim.time = time; scenery(g, sim, bounds, false); worldFeedback(g, sim, bounds); screenFeedback(g, sim, { width: 844, height: 390, scale: 0.6, camera: { x: -80, y: -90 }, low: false }); }
  assert.ok(calls > 100); assert.doesNotThrow(() => scenery(g, sim, bounds, true));
});
