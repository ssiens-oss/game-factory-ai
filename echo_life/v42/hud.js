import { district } from './city.js';

const $ = id => document.getElementById(id);
export class HUD {
  constructor() { this.values = new Map(); this.messageUntil = 6; this.lastUpdate = -1; }
  text(id, value) { if (this.values.get(id) !== value) { $(id).textContent = value; this.values.set(id, value); } }
  notify(message, time) { if (!message) return; this.text('msg', message); this.messageUntil = time + 3.5; $('msg').classList.remove('fade'); }
  update(sim, force = false) {
    if (!force && sim.time - this.lastUpdate < 0.1) return;
    this.lastUpdate = sim.time; const p = sim.player;
    this.text('hp', Math.ceil(p.hp)); this.text('lvl', String(p.lvl).padStart(2, '0')); this.text('cash', p.cash);
    this.text('obj', `${p.obj} / ${p.goal}`);
    this.text('score', sim.score); this.text('combo', sim.combo ? `${sim.combo} CHAIN / ×${Math.min(4, 1 + Math.floor(sim.combo / 3))}` : 'CHAIN / —'); this.text('shield', Math.ceil(p.shield)); this.text('medkits', sim.medkits);
    $('shield-bar').style.width = `${100 * p.shield / p.maxShield}%`;
    this.text('weapon', `${sim.weapon.id.toUpperCase()} / Q`);
    $('heal').disabled = !sim.medkits || sim.healCooldown > 0 || p.hp >= 100;
    $('heal').setAttribute('aria-label', sim.healCooldown > 0 ? `Medkit ready in ${Math.ceil(sim.healCooldown)} seconds` : `Use medkit, ${sim.medkits} available`);
    const ammo = `${p.mag} / ${p.reserve}`; this.text('ammo', ammo);
    this.text('weapon-status', sim.reloadTimer > 0 ? `RELOAD / ${sim.reloadTimer.toFixed(1)}s` : !p.mag ? 'R / SUPPLY + RELOAD' : sim.weapon.name);
    this.text('dash-status', sim.dashCooldown > 0 ? `${sim.dashCooldown.toFixed(1)}s` : 'DASH');
    this.text('district', district(p.x, p.y)[1]); this.text('sector', `${String(Math.floor(p.x / 640)).padStart(2, '0')} : ${String(Math.floor(p.y / 640)).padStart(2, '0')}`);
    $('health').style.width = `${p.hp}%`; $('health').style.background = p.hp < 30 ? '#ff8e93' : '#b9f8d2';
    $('progress').style.width = `${100 * p.obj / p.goal}%`;
    $('dash').setAttribute('aria-label', sim.dashCooldown ? 'Dash recharging' : 'Dash ready');
    $('msg').classList.toggle('fade', sim.time > this.messageUntil);
  }
}
