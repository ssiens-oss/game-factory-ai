/** All weapons consume magazine rounds; shotgun pellets count as one shell. */
export const WEAPONS = Object.freeze([
  { id: 'carbine', name: 'K-24 CARBINE', damage: 34, speed: 1120, interval: 0.13, magazine: 24, reload: 1, pellets: 1, spread: 0.012, pierce: 1, range: 800 },
  { id: 'scatter', name: 'S-8 SCATTER', damage: 13, speed: 900, interval: 0.58, magazine: 8, reload: 1.35, pellets: 6, spread: 0.23, pierce: 1, range: 400 },
  { id: 'lance', name: 'L-12 LANCE', damage: 58, speed: 1450, interval: 0.42, magazine: 12, reload: 1.15, pellets: 1, spread: 0, pierce: 3, range: 1000 },
]);
export function interceptAngle(player, target, speed) {
  const dx = target.x - player.x, dy = target.y - player.y, vx = target.vx || 0, vy = target.vy || 0;
  const a = vx * vx + vy * vy - speed * speed, b = 2 * (dx * vx + dy * vy), c = dx * dx + dy * dy;
  const discriminant = b * b - 4 * a * c;
  let t = Math.hypot(dx, dy) / speed;
  if (discriminant >= 0 && Math.abs(a) > 0.0001) { const root = Math.sqrt(discriminant); const candidates = [(-b + root) / (2 * a), (-b - root) / (2 * a)].filter(n => n > 0); if (candidates.length) t = Math.min(...candidates); }
  t = Math.min(0.8, t); return Math.atan2(dy + vy * t, dx + vx * t);
}
