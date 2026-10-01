import { CityRenderer, district } from './city.js';
import { clamp } from './config.js';

const TAU = Math.PI * 2;
function circle(g, x, y, r, color) { g.fillStyle = color; g.beginPath(); g.arc(x, y, r, 0, TAU); g.fill(); }
function rect(g, x, y, w, h, color, radius = 2) { g.fillStyle = color; g.beginPath(); g.roundRect(x, y, w, h, radius); g.fill(); }
function sprite(kind) {
  const canvas = document.createElement('canvas'); canvas.width = 112; canvas.height = 90;
  const g = canvas.getContext('2d'); g.translate(45, 45);
  const player = kind === 'player', armor = player ? '#779e94' : kind === 'gunner' ? '#a8916d' : kind === 'charger' ? '#946178' : '#766b81', trim = player ? '#90ffe0' : kind === 'gunner' ? '#ffb86c' : '#ff7398';
  // The body faces right; weapon, muzzle and projectile share the same heading.
  g.fillStyle = '#02070b80'; g.beginPath(); g.ellipse(4, 8, 24, 18, 0, 0, TAU); g.fill();
  rect(g, -18, -11, 16, 22, '#233238', 5); rect(g, -17, -9, 4, 18, armor);
  const body = g.createLinearGradient(0, -17, 0, 17); body.addColorStop(0, armor); body.addColorStop(0.55, player ? '#345855' : '#483d50'); body.addColorStop(1, '#172b31');
  rect(g, -10, -15, 27, 30, body, 8); g.strokeStyle = '#c7e5d530'; g.strokeRect(-7, -10, 20, 20);
  rect(g, -6, -13, 4, 26, '#12282a'); rect(g, 1, -13, 4, 26, '#12282a');
  rect(g, -2, -24, 17, 10, armor, 5); rect(g, -2, 14, 17, 10, armor, 5);
  rect(g, 10, -21, 20, 7, '#374647', 3); rect(g, 13, 12, 12, 7, '#293b3e', 3);
  rect(g, 20, -15, 30, 7, '#a3b7b5', 1); rect(g, 20, -13, 38, 4, '#2c3f43', 1); rect(g, 28, -17, 12, 3, '#1b292d', 1); rect(g, 25, -8, 6, 8, '#1b2d30');
  circle(g, 5, 0, 12, '#0f252c'); circle(g, 5, -1, 10, player ? '#739e97' : '#89808b');
  g.fillStyle = '#16282f'; g.beginPath(); g.arc(5, -1, 10, -1.15, 1.15); g.fill();
  g.strokeStyle = trim; g.lineWidth = 2; g.shadowColor = trim; g.shadowBlur = 6; g.beginPath(); g.arc(5, -1, 10, -0.65, 0.65); g.stroke(); g.shadowBlur = 0;
  rect(g, -3, -5, 7, 4, '#b7c8c480', 1); rect(g, -3, 2, 7, 3, '#3b5459', 1);
  rect(g, -9, -23, 9, 2, trim, 1); rect(g, -9, 21, 9, 2, trim, 1);
  return canvas;
}

export class Renderer {
  constructor(canvas) {
    this.canvas = canvas; this.g = canvas.getContext('2d', { alpha: false }); this.city = new CityRenderer();
    this.camera = { x: 90, y: 90 }; this.sprites = new Map(['player', 'stalker', 'gunner', 'charger'].map(k => [k, sprite(k)]));
    this.width = 0; this.height = 0; this.scale = 1; this.dpr = 1; this.low = matchMedia('(prefers-reduced-motion: reduce)').matches;
    this.resize();
  }
  resize() {
    const r = this.canvas.getBoundingClientRect(); this.width = r.width; this.height = r.height;
    this.dpr = Math.min(window.devicePixelRatio || 1, 1.75, Math.sqrt(2200000 / Math.max(1, r.width * r.height)));
    this.canvas.width = Math.round(r.width * this.dpr); this.canvas.height = Math.round(r.height * this.dpr);
    this.scale = Math.max(0.3, Math.min(r.width / 1080, r.height / 680));
    const g = this.g; this.vignette = g.createRadialGradient(r.width / 2, r.height / 2, r.height * 0.2, r.width / 2, r.height / 2, Math.max(r.width, r.height) * 0.7);
    this.vignette.addColorStop(0, '#00000000'); this.vignette.addColorStop(1, '#02080d99');
  }
  screenToWorld(aim) { const r = this.canvas.getBoundingClientRect(); return { x: (aim.x - r.left - this.width / 2) / this.scale + this.camera.x, y: (aim.y - r.top - this.height / 2) / this.scale + this.camera.y }; }
  bounds() { return { left: this.camera.x - this.width / this.scale / 2 - 70, right: this.camera.x + this.width / this.scale / 2 + 70, top: this.camera.y - this.height / this.scale / 2 - 70, bottom: this.camera.y + this.height / this.scale / 2 + 70 }; }
  visible(e, b) { return e.x > b.left && e.x < b.right && e.y > b.top && e.y < b.bottom; }
  draw(sim, dt, active) {
    const { g, width: w, height: h, scale, dpr } = this, p = sim.player;
    const smooth = 1 - Math.exp(-7 * dt);
    this.camera.x += (p.x + p.vx * 0.18 - this.camera.x) * smooth; this.camera.y += (p.y + p.vy * 0.18 - this.camera.y) * smooth;
    if (Math.hypot(p.x - this.camera.x, p.y - this.camera.y) > 1500) { this.camera.x = p.x; this.camera.y = p.y; }
    const b = this.bounds();
    g.setTransform(dpr, 0, 0, dpr, 0, 0); g.fillStyle = '#101b21'; g.fillRect(0, 0, w, h); g.save();
    const shake = this.low || !active ? 0 : sim.shake * scale;
    g.translate(w / 2 + Math.sin(sim.time * 130) * shake, h / 2 + Math.cos(sim.time * 117) * shake); g.scale(scale, scale); g.translate(-this.camera.x, -this.camera.y);
    this.city.draw(g, b);
    for (const e of sim.enemies) if (e.hp > 0 && this.visible(e, b) && e.phase === 'windup') {
      g.save(); g.translate(e.x, e.y); g.rotate(e.aim);
      if (e.type === 'gunner') { g.strokeStyle = '#ffb47199'; g.lineWidth = 1.4; g.setLineDash([6, 9]); g.beginPath(); g.moveTo(28, 0); g.lineTo(550, 0); g.stroke(); }
      else { g.fillStyle = '#ff7b942b'; g.beginPath(); g.moveTo(0, 0); g.lineTo(255, -26); g.lineTo(255, 26); g.closePath(); g.fill(); }
      g.restore();
    }
    for (const drop of sim.pickups) if (this.visible(drop, b)) {
      g.save(); g.translate(drop.x, drop.y); g.translate(0, Math.sin(sim.time * 3 + drop.x) * 2);
      const color = drop.kind === 'ammo' ? '#ffd18a' : '#9af5cc'; circle(g, 0, 0, 17, color + '10'); rect(g, -7, -6, 14, 12, '#183336', 2); g.strokeStyle = color; g.lineWidth = 1.5; g.strokeRect(-7, -6, 14, 12);
      g.fillStyle = color; if (drop.kind === 'health') { g.fillRect(-1.5, -4, 3, 8); g.fillRect(-4, -1.5, 8, 3); } else { for (let i = -1; i <= 1; i++) g.fillRect(i * 4 - 1, -3, 2, 6); } g.restore();
    }
    const entities = sim.enemies.filter(e => e.hp > 0 && this.visible(e, b)); entities.push({ ...p, type: 'player' }); entities.sort((a, e) => a.y - e.y);
    for (const e of entities) {
      const player = e.type === 'player';
      if (player) { g.strokeStyle = '#a4ffe450'; g.lineWidth = 1; g.beginPath(); g.arc(e.x, e.y, 28, 0, TAU); g.stroke(); }
      if (player && sim.hurtTimer > 0 && Math.floor(sim.time * 16) % 2 === 0) g.globalAlpha = 0.5;
      g.save(); g.translate(e.x, e.y); g.rotate(e.a);
      // Separate articulated legs animate with speed; armor art is pre-rendered.
      const walk = Math.sin(sim.time * (player ? 15 : 11) + (e.id || 0)) * (player ? Math.min(8, Math.hypot(p.vx, p.vy) / 30) : 6);
      rect(g, -15 + walk, -12, 15, 7, '#13282b', 3); rect(g, -15 - walk, 6, 15, 7, '#102124', 3);
      g.drawImage(this.sprites.get(e.type), -45, -45);
      if (!player && e.flash > 0) { circle(g, 0, 0, 19, '#fff3b678'); }
      if (player && sim.muzzle > 0) {
        g.fillStyle = '#fff7c4'; g.shadowColor = '#ffc260'; g.shadowBlur = 20; g.beginPath(); g.moveTo(56, -11); g.lineTo(80, -19); g.lineTo(70, -9); g.lineTo(83, -3); g.lineTo(58, -7); g.fill(); g.shadowBlur = 0;
      }
      g.restore(); g.globalAlpha = 1;
      if (!player) {
        const color = e.type === 'gunner' ? '#ffc583' : '#ef849e';
        rect(g, e.x - 16, e.y - 38, 32, 3, '#071117', 1); rect(g, e.x - 16, e.y - 38, 32 * Math.max(0, e.hp / e.maxHp), 3, color, 1);
        if (e.phase === 'windup') { g.strokeStyle = color; g.lineWidth = 2; g.beginPath(); g.arc(e.x, e.y, 26, -Math.PI / 2, -Math.PI / 2 + TAU * (1 - e.charge / 0.65)); g.stroke(); }
      }
    }
    if (sim.target && sim.target.hp > 0) {
      const e = sim.target; g.strokeStyle = '#fff5b4ad'; g.lineWidth = 1.3;
      for (let i = 0; i < 4; i++) { const a = Math.PI / 4 + i * Math.PI / 2; g.beginPath(); g.arc(e.x, e.y, 27, a - 0.13, a + 0.13); g.stroke(); }
    }
    for (const bullet of sim.bullets) if (this.visible(bullet, b)) {
      g.strokeStyle = bullet.hostile ? '#ff957f' : '#fff7bd'; g.lineWidth = bullet.hostile ? 4 : 2;
      const speed = Math.hypot(bullet.vx, bullet.vy); g.beginPath(); g.moveTo(bullet.x - bullet.vx / speed * 17, bullet.y - bullet.vy / speed * 17); g.lineTo(bullet.x, bullet.y); g.stroke(); circle(g, bullet.x, bullet.y, bullet.hostile ? 3 : 1.8, '#fff9de');
    }
    for (const f of sim.particles) if (this.visible(f, b)) { g.globalAlpha = clamp(f.life / f.maxLife, 0, 1); g.fillStyle = f.color; g.fillRect(f.x, f.y, f.size, f.size); } g.globalAlpha = 1;
    g.restore();
    if (!this.low) {
      g.strokeStyle = '#d8eee61b'; g.lineWidth = 1; g.beginPath();
      const count = w < 800 ? 36 : 70;
      for (let i = 0; i < count; i++) { const x = (i * 137.2 + sim.time * 28) % (w + 50) - 25, y = (i * 73.8 + sim.time * 400) % (h + 50) - 25; g.moveTo(x, y); g.lineTo(x - 5, y + 17); } g.stroke();
    }
    g.fillStyle = this.vignette; g.fillRect(0, 0, w, h);
    if (sim.hurtTimer > 0 && sim.hit > 0.07) { g.fillStyle = '#ff667518'; g.fillRect(0, 0, w, h); }
    this.drawRadar(sim);
  }
  drawRadar(sim) {
    const { g, width: w, height: h } = this;
    if (w < 720 || h < 490) return;
    const x = w - 86, y = 143, r = 51, zoom = r / 600;
    g.save(); g.translate(x, y); circle(g, 0, 0, r, '#07151d00'); g.strokeStyle = '#a1dac42b'; g.lineWidth = 1;
    g.beginPath(); g.arc(0, 0, r, 0, TAU); g.stroke(); g.beginPath(); g.arc(0, 0, r / 2, 0, TAU); g.moveTo(-r, 0); g.lineTo(r, 0); g.moveTo(0, -r); g.lineTo(0, r); g.stroke();
    for (const e of sim.enemies) { const dx = (e.x - sim.player.x) * zoom, dy = (e.y - sim.player.y) * zoom; if (Math.hypot(dx, dy) < r - 4) circle(g, dx, dy, 2, e.type === 'gunner' ? '#f3b774' : '#f97b94'); }
    circle(g, 0, 0, 3, '#aaffd9'); g.font = '8px monospace'; g.fillStyle = '#a1c9bd'; g.textAlign = 'center'; g.fillText('SIGNAL / 600M', 0, r + 14); g.restore();
  }
}
