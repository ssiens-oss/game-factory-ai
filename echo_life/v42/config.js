export const VERSION = '42';
export const SETTINGS = Object.freeze({
  step: 1 / 60, maxFrame: 0.1, maxSteps: 6, playerSpeed: 235,
  playerRadius: 15, shotInterval: 0.13, bulletSpeed: 1120,
  bulletDamage: 34, aimRange: 650, magazine: 24,
  dashSpeed: 820, dashTime: 0.18, dashCooldown: 1.35,
  tileSize: 640, maxEnemies: 36, maxParticles: 280, maxBullets: 100,
});
export const clamp = (n, a, b) => Math.max(a, Math.min(b, n));
export const distance = (a, b) => Math.hypot(a.x - b.x, a.y - b.y);
export function seeded(seed = 1) {
  return () => { seed |= 0; seed = seed + 0x6D2B79F5 | 0; let t = Math.imul(seed ^ seed >>> 15, 1 | seed); t ^= t + Math.imul(t ^ t >>> 7, 61 | t); return ((t ^ t >>> 14) >>> 0) / 4294967296; };
}
