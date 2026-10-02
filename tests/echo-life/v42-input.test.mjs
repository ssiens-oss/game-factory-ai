import test from 'node:test';
import assert from 'node:assert/strict';
import { Input } from '../../echo_life/v42/input.js';
class Target extends EventTarget {
  constructor(tagName = 'DIV') { super(); this.tagName = tagName; this.style = {}; }
  focus() { this.focusCount = (this.focusCount || 0) + 1; }
  setPointerCapture() {} hasPointerCapture() { return false; }
  getBoundingClientRect() { return { left: 0, top: 0, width: 100, height: 100 }; }
}
function event(target, type, data = {}) { const e = new Event(type, { cancelable: true }); for (const [key, value] of Object.entries(data)) Object.defineProperty(e, key, { value }); target.dispatchEvent(e); }
test('gamepad deadzone, trigger fire, edge actions, pause and Q/E touch shortcuts', () => {
  const window = new Target(), utilities = { weapon: new Target('BUTTON'), heal: new Target('BUTTON') }, document = new Target(); document.getElementById = id => utilities[id];
  globalThis.window = window; globalThis.document = document;
  const pad = { connected: true, axes: [0.5, -0.5], buttons: Array.from({ length: 10 }, () => ({ pressed: false })) };
  Object.defineProperty(globalThis, 'navigator', { value: { getGamepads: () => [pad] }, configurable: true });
  const canvas = new Target('CANVAS'); let pauses = 0;
  const input = new Input({ canvas, joystick: new Target(), stick: new Target(), fire: new Target('BUTTON'), dash: new Target('BUTTON'), reload: new Target('BUTTON'), onPause: () => pauses++ });
  pad.buttons[7].pressed = true; pad.buttons[4].pressed = true; pad.buttons[1].pressed = true;
  let value = input.snapshot(); assert.equal(value.mx, 0.5); assert.equal(value.my, -0.5); assert.equal(value.fire, true); assert.equal(value.weapon, true); assert.equal(value.dash, true);
  value = input.snapshot(); assert.equal(value.weapon, false); assert.equal(value.dash, false); assert.equal(value.fire, true);
  pad.axes = [0.1, -0.1]; pad.buttons[9].pressed = true; input.snapshot(); input.snapshot(); assert.equal(pauses, 1); assert.equal(input.snapshot().mx, 0);
  event(window, 'keydown', { code: 'KeyQ', target: canvas }); event(window, 'keydown', { code: 'KeyE', target: canvas }); value = input.snapshot(); assert.equal(value.weapon, true); assert.equal(value.heal, true);
  event(utilities.weapon, 'click'); event(utilities.heal, 'click'); value = input.snapshot(); assert.equal(value.weapon, true); assert.equal(value.heal, true); assert.equal(canvas.focusCount, 2);
  input.clear(); assert.equal(input.snapshot().heal, false); input.destroy();
});
