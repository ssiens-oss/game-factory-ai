import assert from 'node:assert/strict';
import { Input } from '../../echo_life/v41/input.js';
import { AudioSystem } from '../../echo_life/v41/audio.js';
class Target extends EventTarget {
  constructor(tagName = 'DIV') { super(); this.tagName = tagName; this.style = {}; this.captured = new Set(); }
  setPointerCapture(id) { this.captured.add(id); }
  hasPointerCapture(id) { return this.captured.has(id); }
  releasePointerCapture(id) { this.captured.delete(id); }
  getBoundingClientRect() { return { left: 0, top: 0, width: 100, height: 100 }; }
}
function send(target, type, data = {}) {
  const event = new Event(type, { cancelable: true });
  for (const [key, value] of Object.entries(data)) Object.defineProperty(event, key, { value });
  target.dispatchEvent(event);
}
globalThis.window = new Target();
globalThis.document = new Target();
const canvas = new Target('CANVAS'), joystick = new Target(), stick = new Target(), fire = new Target('BUTTON'), dash = new Target('BUTTON'), reload = new Target('BUTTON');
let pauses = 0;
const input = new Input({ canvas, joystick, stick, fire, dash, reload, onPause: () => pauses++ });
send(joystick, 'pointerdown', { pointerId: 1, pointerType: 'touch', clientX: 84, clientY: 50 });
assert.equal(input.snapshot().mx, 1);
assert.equal(input.snapshot().mx, 1, 'stationary finger keeps moving each frame');
send(joystick, 'pointerdown', { pointerId: 2, pointerType: 'touch', clientX: 16, clientY: 50 });
assert.equal(input.snapshot().mx, 1, 'secondary finger cannot replace the joystick contact');
send(fire, 'pointerdown', { pointerId: 2, pointerType: 'touch' });
assert.equal(input.snapshot().fire, true, 'second finger fires while moving');
send(dash, 'pointerdown', { pointerId: 3, pointerType: 'touch' });
send(dash, 'click', { detail: 1 });
assert.equal(input.snapshot().dash, true);
assert.equal(input.snapshot().dash, false, 'tap action drains once');
send(window, 'pointercancel', { pointerId: 1 });
assert.equal(input.snapshot().mx, 0);
assert.equal(input.snapshot().fire, true, 'canceling the joystick preserves independent fire contact');
send(fire, 'lostpointercapture', { pointerId: 2 });
assert.equal(input.snapshot().fire, false);
send(window, 'keydown', { code: 'KeyW', repeat: false });
send(window, 'keydown', { code: 'KeyD', repeat: false });
assert(Math.abs(Math.hypot(input.snapshot().mx, input.snapshot().my) - 1) < 1e-9);
send(window, 'keydown', { code: 'ShiftLeft', repeat: false });
assert.equal(input.snapshot().dash, true);
send(window, 'keydown', { code: 'ShiftLeft', repeat: true });
assert.equal(input.snapshot().dash, false);
send(window, 'blur');
assert.deepEqual(input.snapshot(), { mx: 0, my: 0, fire: false, dash: false, reload: false, aim: null });
send(reload, 'click', { detail: 0 });
assert.equal(input.snapshot().reload, true, 'assistive/keyboard activation works');
send(canvas, 'pointerdown', { pointerId: 9, pointerType: 'mouse', button: 0, clientX: 150, clientY: 200 });
assert.deepEqual(input.snapshot().aim, { x: 150, y: 200 });
assert.equal(input.snapshot().fire, true);
send(window, 'keydown', { code: 'Escape', repeat: false });
assert.equal(pauses, 1);
assert.equal(input.snapshot().fire, false);
send(fire, 'keydown', { code: 'Enter' });
assert.equal(input.snapshot().fire, true, 'keyboard fire is sustained');
send(fire, 'keyup', { code: 'Enter' });
assert.equal(input.snapshot().fire, false);
send(window, 'keydown', { code: 'KeyD', repeat: false });
document.hidden = true;
send(document, 'visibilitychange');
assert.equal(input.snapshot().mx, 0);
input.destroy();
const unsupported = new AudioSystem();
assert.equal(await unsupported.unlock(), false);
unsupported.play('shot');
class Param { setValueAtTime(value) { this.value = value; } exponentialRampToValueAtTime(value) { this.value = value; } setTargetAtTime(value) { this.value = value; } }
class Node { constructor() { this.gain = new Param(); this.frequency = new Param(); this.threshold = new Param(); this.ratio = new Param(); } connect() {} disconnect() {} start() {} stop() {} }
class Context {
 constructor() { this.state = 'suspended'; this.sampleRate = 8000; this.currentTime = 0; this.destination = new Node(); }
 createGain() { return new Node(); } createDynamicsCompressor() { return new Node(); }
 createOscillator() { return new Node(); } createBufferSource() { return new Node(); } createBiquadFilter() { return new Node(); }
 createBuffer(channels, length) { return { getChannelData: () => new Float32Array(length) }; }
 async resume() { this.state = 'running'; }
}
globalThis.AudioContext = Context;
const sound = new AudioSystem();
assert.equal(await sound.unlock(), true);
for (let i = 0; i < 100; i++) for (const kind of ['shot', 'hit', 'kill', 'dash', 'reload', 'hurt', 'level']) sound.play(kind);
assert(sound.voices.size <= 16, 'audio polyphony is bounded under a combat burst');
sound.setMuted(true);
assert.equal(sound.muted, true);
assert.equal(sound.master.gain.value, 0);
console.log('PASS: sustained/multitouch movement and fire, one-shot actions, keyboard access, pointer cancellation, focus clearing, unsupported audio and bounded sound polyphony.');
