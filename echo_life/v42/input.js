import { Input as BaseInput } from '../v41/input.js';
export class Input extends BaseInput {
  constructor(options) {
    super(options); this.pendingWeapon = false; this.pendingHeal = false; this.padButtons = [];
    this.listen(window, 'keydown', e => { if (this.isEditing(e.target) || e.repeat) return; if (e.code === 'KeyQ') { e.preventDefault(); this.pendingWeapon = true; } if (e.code === 'KeyE') { e.preventDefault(); this.pendingHeal = true; } });
    for (const [id, action] of [['weapon', 'pendingWeapon'], ['heal', 'pendingHeal']]) { const button = document.getElementById(id); if (button) this.listen(button, 'click', () => { this[action] = true; }); }
  }
  snapshot() {
    const value = super.snapshot(); let pad;
    try { pad = [...(navigator.getGamepads?.() || [])].find(p => p?.connected); } catch {}
    if (pad) {
      const dead = n => Math.abs(n) < 0.18 ? 0 : n;
      if (!value.mx && !value.my) { value.mx = dead(pad.axes[0] || 0); value.my = dead(pad.axes[1] || 0); const m = Math.hypot(value.mx, value.my); if (m > 1) { value.mx /= m; value.my /= m; } }
      const pressed = index => !!pad.buttons[index]?.pressed, edge = index => pressed(index) && !this.padButtons[index];
      if (pressed(7) || pressed(0)) { value.fire = true; value.aim = null; }
      value.dash ||= edge(1); value.reload ||= edge(2); this.pendingWeapon ||= edge(4); this.pendingHeal ||= edge(3);
      if (edge(9)) this.onPause(); this.padButtons = pad.buttons.map(b => b.pressed);
    } else this.padButtons = [];
    value.weapon = this.pendingWeapon; value.heal = this.pendingHeal; this.pendingWeapon = this.pendingHeal = false; return value;
  }
  clear() { super.clear(); this.pendingWeapon = this.pendingHeal = false; }
}
