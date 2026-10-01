/** Keyboard, mouse and independent touch contacts share one frame snapshot. */
export class Input {
  constructor({ canvas, joystick, stick, fire, dash, reload, onPause = () => {} }) {
    this.canvas = canvas;
    this.joystick = joystick;
    this.stick = stick;
    this.onPause = onPause;
    this.keys = new Set();
    this.firePointers = new Set();
    this.autoFirePointers = new Set();
    this.captures = new Map();
    this.joyPointer = null;
    this.joy = { x: 0, y: 0 };
    this.aim = null;
    this.pendingDash = false;
    this.pendingReload = false;
    this.firePulse = false;
    this.buttonFire = false;
    this.listeners = [];

    this.listen(window, 'keydown', event => this.keyDown(event));
    this.listen(window, 'keyup', event => this.keyUp(event));
    this.listen(window, 'blur', () => this.clear());
    this.listen(document, 'visibilitychange', () => {
      if (document.hidden) this.clear();
    });
    // Window release listeners also cover browsers where capture is unavailable.
    this.listen(window, 'pointerup', event => this.release(event.pointerId));
    this.listen(window, 'pointercancel', event => this.release(event.pointerId));

    if (canvas) {
      this.listen(canvas, 'pointermove', event => {
        if (event.pointerType === 'mouse') this.setAim(event);
      });
      this.listen(canvas, 'pointerdown', event => {
        if (event.pointerType !== 'mouse' || event.button !== 0) return;
        event.preventDefault();
        this.setAim(event);
        this.firePointers.add(event.pointerId);
        this.capture(canvas, event.pointerId);
      });
      this.listen(canvas, 'lostpointercapture', event => this.release(event.pointerId));
      this.listen(canvas, 'contextmenu', event => event.preventDefault());
    }

    if (joystick) {
      this.listen(joystick, 'pointerdown', event => {
        if (this.joyPointer !== null || (event.pointerType === 'mouse' && event.button !== 0)) return;
        event.preventDefault();
        this.joyPointer = event.pointerId;
        this.aim = null;
        this.capture(joystick, event.pointerId);
        this.moveJoystick(event);
      });
      this.listen(joystick, 'pointermove', event => {
        if (event.pointerId !== this.joyPointer) return;
        event.preventDefault();
        this.moveJoystick(event);
      });
      this.listen(joystick, 'lostpointercapture', event => this.release(event.pointerId));
    }

    this.bindButton(fire, 'fire');
    this.bindButton(dash, 'dash');
    this.bindButton(reload, 'reload');
  }

  listen(target, type, listener) {
    target.addEventListener(type, listener, { passive: false });
    this.listeners.push([target, type, listener]);
  }

  isEditing(target) {
    return Boolean(target?.isContentEditable || /^(INPUT|TEXTAREA|SELECT)$/.test(target?.tagName));
  }

  keyDown(event) {
    if (this.isEditing(event.target)) return;
    const code = event.code;
    if (['KeyW', 'KeyA', 'KeyS', 'KeyD', 'ArrowUp', 'ArrowLeft', 'ArrowDown', 'ArrowRight'].includes(code)) {
      event.preventDefault();
      this.keys.add(code);
    } else if (code === 'Space' && event.target?.tagName !== 'BUTTON') {
      event.preventDefault();
      this.keys.add(code);
    } else if (code === 'ShiftLeft' || code === 'ShiftRight') {
      event.preventDefault();
      if (!event.repeat && !this.keys.has(code)) this.pendingDash = true;
      this.keys.add(code);
    } else if (code === 'KeyR') {
      event.preventDefault();
      if (!event.repeat && !this.keys.has(code)) this.pendingReload = true;
      this.keys.add(code);
    } else if (code === 'Escape' && !event.repeat) {
      event.preventDefault();
      this.clear();
      this.onPause();
    }
  }

  keyUp(event) {
    this.keys.delete(event.code);
  }

  bindButton(button, action) {
    if (!button) return;
    this.listen(button, 'pointerdown', event => {
      if (event.pointerType === 'mouse' && event.button !== 0) return;
      event.preventDefault();
      if (event.pointerType !== 'mouse') this.aim = null;
      this.capture(button, event.pointerId);
      if (action === 'fire') { this.firePointers.add(event.pointerId); this.autoFirePointers.add(event.pointerId); this.aim = null; }
      else if (action === 'dash') this.pendingDash = true;
      else this.pendingReload = true;
    });
    this.listen(button, 'lostpointercapture', event => this.release(event.pointerId));
    // detail=0 is keyboard/assistive activation; pointerdown already handles taps.
    this.listen(button, 'click', event => {
      if (event.detail !== 0) return;
      if (action === 'fire') this.firePulse = true;
      else if (action === 'dash') this.pendingDash = true;
      else this.pendingReload = true;
    });
    if (action === 'fire') {
      this.listen(button, 'keydown', event => {
        if (event.code !== 'Space' && event.code !== 'Enter') return;
        event.preventDefault();
        this.buttonFire = true;
      });
      this.listen(button, 'keyup', event => {
        if (event.code !== 'Space' && event.code !== 'Enter') return;
        event.preventDefault();
        this.buttonFire = false;
      });
      this.listen(button, 'blur', () => { this.buttonFire = false; });
    }
  }

  capture(element, id) {
    this.captures.set(id, element);
    try { element.setPointerCapture(id); } catch { /* Window releases remain active. */ }
  }

  release(id) {
    this.firePointers.delete(id);
    this.autoFirePointers.delete(id);
    if (id === this.joyPointer) {
      this.joyPointer = null;
      this.joy.x = this.joy.y = 0;
      this.drawStick(0, 0);
    }
    const element = this.captures.get(id);
    this.captures.delete(id);
    try {
      if (element?.hasPointerCapture(id)) element.releasePointerCapture(id);
    } catch { /* A detached element has already lost its capture. */ }
  }

  setAim(event) {
    this.aim = { x: event.clientX, y: event.clientY };
  }

  moveJoystick(event) {
    const rect = this.joystick.getBoundingClientRect();
    const radius = Math.max(1, Math.min(rect.width, rect.height) * 0.34);
    const dx = event.clientX - rect.left - rect.width / 2;
    const dy = event.clientY - rect.top - rect.height / 2;
    const distance = Math.hypot(dx, dy);
    const amount = Math.min(1, distance / radius);
    const strength = amount <= 0.12 ? 0 : (amount - 0.12) / 0.88;
    this.joy.x = distance ? dx / distance * strength : 0;
    this.joy.y = distance ? dy / distance * strength : 0;
    const visualScale = distance > radius ? radius / distance : 1;
    this.drawStick(dx * visualScale, dy * visualScale);
  }

  drawStick(x, y) {
    if (this.stick) this.stick.style.transform = `translate(${x}px, ${y}px)`;
  }

  snapshot() {
    const left = this.keys.has('KeyA') || this.keys.has('ArrowLeft');
    const right = this.keys.has('KeyD') || this.keys.has('ArrowRight');
    const up = this.keys.has('KeyW') || this.keys.has('ArrowUp');
    const down = this.keys.has('KeyS') || this.keys.has('ArrowDown');
    let mx = Number(right) - Number(left) + this.joy.x;
    let my = Number(down) - Number(up) + this.joy.y;
    const magnitude = Math.hypot(mx, my);
    if (magnitude > 1) { mx /= magnitude; my /= magnitude; }
    const result = {
      mx, my,
      fire: this.keys.has('Space') || this.firePointers.size > 0 || this.buttonFire || this.firePulse,
      dash: this.pendingDash,
      reload: this.pendingReload,
      aim: this.keys.has('Space') || this.buttonFire || this.firePulse || this.autoFirePointers.size ? null : this.aim ? { ...this.aim } : null,
    };
    this.pendingDash = this.pendingReload = this.firePulse = false;
    return result;
  }

  clear() {
    this.keys.clear();
    for (const id of [...this.captures.keys()]) this.release(id);
    this.firePointers.clear();
    this.autoFirePointers.clear();
    this.joyPointer = null;
    this.joy.x = this.joy.y = 0;
    this.pendingDash = this.pendingReload = this.firePulse = this.buttonFire = false;
    this.aim = null;
    this.drawStick(0, 0);
  }

  destroy() {
    this.clear();
    for (const [target, type, listener] of this.listeners) target.removeEventListener(type, listener);
    this.listeners.length = 0;
  }
}

export default Input;
