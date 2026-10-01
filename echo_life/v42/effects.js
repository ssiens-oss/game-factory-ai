import { buildings } from './world.js';
import { district } from './city.js';
import { SETTINGS as S } from './config.js';
let light, cloud;
function texture() {
  if (light) return;
  light = document.createElement('canvas'); light.width = light.height = 320;
  let g = light.getContext('2d'), glow = g.createRadialGradient(160, 160, 0, 160, 160, 160);
  glow.addColorStop(0, '#a0efd01a'); glow.addColorStop(0.6, '#a0efd00c'); glow.addColorStop(1, '#a0efd000'); g.fillStyle = glow; g.fillRect(0, 0, 320, 320);
  cloud = document.createElement('canvas'); cloud.width = cloud.height = 720; g = cloud.getContext('2d');
  for (let i = 0; i < 12; i++) { const x = (i * 143) % 720, y = (i * 227) % 720, r = 130; const fog = g.createRadialGradient(x, y, 1, x, y, r); fog.addColorStop(0, '#01090e18'); fog.addColorStop(1, '#01090e00'); g.fillStyle = fog; g.fillRect(x - r, y - r, r * 2, r * 2); }
}
export function scenery(g, sim, bounds, low) {
  texture(); const time = sim.time, p = sim.player;
  const minX = Math.floor(bounds.left / S.tileSize), maxX = Math.floor(bounds.right / S.tileSize), minY = Math.floor(bounds.top / S.tileSize), maxY = Math.floor(bounds.bottom / S.tileSize);
  if (!low) for (let tx = minX; tx <= maxX; tx++) for (let ty = minY; ty <= maxY; ty++) {
    const neon = district(tx * S.tileSize, ty * S.tileSize)[0];
    for (const r of buildings(tx, ty)) {
      const x = r.x + r.w - 33, y = r.y + 38;
      g.save(); g.translate(x, y); g.rotate(time * 2.2 + r.id); g.strokeStyle = '#a9c8c147'; g.lineWidth = 2;
      for (let i = 0; i < 4; i++) { const a = i * Math.PI / 2; g.beginPath(); g.moveTo(0, 0); g.lineTo(Math.cos(a) * 10, Math.sin(a) * 10); g.stroke(); } g.restore();
      g.globalAlpha = 0.2 + Math.sin(time * 1.4 + tx + ty + r.id) * 0.15; g.fillStyle = neon; g.fillRect(r.x + r.w - 59, r.y + 91, 44, 2); g.globalAlpha = 1;
    }
    // Courier drones follow the road axis. These are ambient traffic, above ground.
    const x = tx * S.tileSize + ((time * 76 + ty * 110) % S.tileSize), y = ty * S.tileSize + 44;
    g.fillStyle = '#03101750'; g.beginPath(); g.ellipse(x - 8, y + 9, 16, 7, 0, 0, 7); g.fill();
    g.save(); g.translate(x, y); g.fillStyle = '#526e72'; g.fillRect(-11, -5, 22, 10); g.fillStyle = neon; g.fillRect(8, -3, 4, 6); g.strokeStyle = '#97c8bc88'; g.lineWidth = 1;
    for (const [dx, dy] of [[-10, -7], [-10, 7], [10, -7], [10, 7]]) { g.beginPath(); g.arc(dx, dy, 4, time * 20, time * 20 + 4); g.stroke(); } g.restore();
    for (let i = 0; i < 3; i++) { const age = (time * 0.9 + i * 0.31 + tx * 0.11) % 1; g.strokeStyle = `rgba(145,201,195,${(1 - age) * 0.15})`; g.lineWidth = 0.7; g.beginPath(); g.ellipse(tx * S.tileSize + 22 + i * 45, ty * S.tileSize + 242 + i * 133, 10 * age, 4 * age, 0, 0, 7); g.stroke(); }
  }
  for (const b of sim.barrels) if (b.hp > 0 && b.x > bounds.left && b.x < bounds.right && b.y > bounds.top && b.y < bounds.bottom) {
    g.fillStyle = '#03070b88'; g.beginPath(); g.ellipse(b.x + 3, b.y + 5, 15, 10, 0, 0, 7); g.fill();
    g.fillStyle = '#7c6345'; g.beginPath(); g.arc(b.x, b.y, 11, 0, 7); g.fill(); g.strokeStyle = '#ccad6a'; g.lineWidth = 2; g.stroke();
    g.strokeStyle = '#332b28'; g.lineWidth = 3; g.beginPath(); g.moveTo(b.x - 8, b.y); g.lineTo(b.x + 8, b.y); g.stroke();
    g.fillStyle = '#ffd083'; g.font = 'bold 10px monospace'; g.textAlign = 'center'; g.fillText('!', b.x, b.y + 4);
    if (b.hp < 45) { g.strokeStyle = '#ff8469'; g.lineWidth = 1; g.beginPath(); g.arc(b.x, b.y, 15 + Math.sin(time * 7) * 2, 0, 7); g.stroke(); }
  }
  // Cached light and a directional beam make player orientation readable at night.
  g.drawImage(light, p.x - 160, p.y - 160);
  g.save(); g.translate(p.x, p.y); g.rotate(p.a); g.fillStyle = '#c1ffe610'; g.beginPath(); g.moveTo(12, 0); g.lineTo(170, -48); g.quadraticCurveTo(200, 0, 170, 48); g.closePath(); g.fill(); g.restore();
}
export function worldFeedback(g, sim, bounds) {
  const p = sim.player;
  if (p.shield > 0 || sim.shieldFlash > 0) { g.strokeStyle = sim.shieldFlash > 0 ? '#c6efff' : '#87c9ed88'; g.lineWidth = sim.shieldFlash > 0 ? 3 : 1.6; g.beginPath(); g.arc(p.x, p.y, 31, -Math.PI / 2, -Math.PI / 2 + Math.PI * 2 * p.shield / p.maxShield); g.stroke(); }
  for (const e of sim.enemies) {
    if (e.spawnIn > 0) { const f = 1 - e.spawnIn / 0.9; g.strokeStyle = '#ffad7399'; g.lineWidth = 1.5; g.setLineDash([4, 5]); g.beginPath(); g.arc(e.x, e.y, 16 + 20 * (1 - f), 0, 7); g.stroke(); g.setLineDash([]); }
    if (e.elite && e.hp > 0) { g.strokeStyle = '#f2ca88'; g.lineWidth = 1.3; g.beginPath(); g.arc(e.x, e.y, 25, 0, 7); g.stroke(); }
    if (e.type === 'boss' && e.hp > 0) { g.strokeStyle = e.hp < e.maxHp * 0.4 ? '#ff566e' : '#ffbe80'; g.lineWidth = 3; g.beginPath(); g.arc(e.x, e.y, 36, 0, 7); g.stroke(); }
  }
  for (const f of sim.explosions) { const progress = 1 - f.life / 0.35; g.globalAlpha = 1 - progress; g.fillStyle = '#ffc96c'; g.beginPath(); g.arc(f.x, f.y, 90 * progress, 0, 7); g.fill(); g.strokeStyle = '#ffefaf'; g.lineWidth = 3; g.stroke(); } g.globalAlpha = 1;
  for (const label of sim.labels) { g.globalAlpha = Math.min(1, label.life * 3); g.font = 'bold 12px monospace'; g.textAlign = 'center'; g.strokeStyle = '#08151b'; g.lineWidth = 3; g.strokeText(String(label.text), label.x, label.y); g.fillStyle = label.color; g.fillText(String(label.text), label.x, label.y); } g.globalAlpha = 1;
  if (sim.hitConfirm > 0) {
    const target = sim.target || { x: p.x + Math.cos(p.a) * 100, y: p.y + Math.sin(p.a) * 100 }; g.strokeStyle = '#fff2ca'; g.lineWidth = 1.5;
    for (const [dx, dy] of [[1, 1], [1, -1], [-1, 1], [-1, -1]]) { g.beginPath(); g.moveTo(target.x + dx * 8, target.y + dy * 8); g.lineTo(target.x + dx * 14, target.y + dy * 14); g.stroke(); }
  }
}
export function screenFeedback(g, sim, renderer) {
  const { width: w, height: h, scale, camera, low } = renderer;
  if (!low) { texture(); const x = -(sim.time * 8 + camera.x * scale * 0.08) % 720, y = -(camera.y * scale * 0.08) % 720; for (let a = x - 720; a < w; a += 720) for (let b = y - 720; b < h; b += 720) g.drawImage(cloud, a, b); }
  if (sim.player.hp < 30) { g.strokeStyle = '#ff6b7f60'; g.lineWidth = 12; g.strokeRect(0, 0, w, h); }
  let count = 0;
  for (const e of sim.enemies) {
    if (count >= 6 || e.hp <= 0 || e.spawnIn > 0 || Math.hypot(e.x - sim.player.x, e.y - sim.player.y) > 850) continue;
    const x = (e.x - camera.x) * scale + w / 2, y = (e.y - camera.y) * scale + h / 2;
    if (x > 18 && x < w - 18 && y > 18 && y < h - 18) continue;
    const a = Math.atan2(y - h / 2, x - w / 2), factor = Math.min((w / 2 - 18) / Math.max(0.001, Math.abs(x - w / 2)), (h / 2 - 18) / Math.max(0.001, Math.abs(y - h / 2)));
    g.save(); g.translate(w / 2 + (x - w / 2) * factor, h / 2 + (y - h / 2) * factor); g.rotate(a); g.fillStyle = e.type === 'boss' ? '#ffbb68' : '#fb899b'; g.beginPath(); g.moveTo(7, 0); g.lineTo(-4, -4); g.lineTo(-4, 4); g.closePath(); g.fill(); g.restore(); count++;
  }
}
