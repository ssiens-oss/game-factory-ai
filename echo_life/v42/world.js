import { SETTINGS } from './config.js';
const TILE = SETTINGS.tileSize;
const footprints = [
  { x: 212, y: 214, w: 164, h: 168 }, { x: 408, y: 214, w: 180, h: 168 },
  { x: 212, y: 422, w: 164, h: 168 }, { x: 408, y: 422, w: 180, h: 168 },
];
export function tileSeed(x, y) { return Math.imul(x, 73856093) ^ Math.imul(y, 19349663) ^ 1947; }
export function buildings(tx, ty) {
  return footprints.map((r, i) => ({ ...r, x: r.x + tx * TILE, y: r.y + ty * TILE, id: i, seed: tileSeed(tx, ty), tx, ty }));
}
export function isSolid(x, y, radius = 0) {
  // Every footprint has at least 50px clearance from tile edges. Game bodies
  // are <=20px, so only the current tile can intersect them.
  const lx = ((x % TILE) + TILE) % TILE, ly = ((y % TILE) + TILE) % TILE;
  if (radius <= 40) {
    for (const r of footprints) {
      const nx = Math.max(r.x, Math.min(lx, r.x + r.w)), ny = Math.max(r.y, Math.min(ly, r.y + r.h));
      if ((lx - nx) ** 2 + (ly - ny) ** 2 <= radius ** 2) return true;
    }
  } else {
    const tx = Math.floor(x / TILE), ty = Math.floor(y / TILE);
    for (let i = tx - 1; i <= tx + 1; i++) for (let j = ty - 1; j <= ty + 1; j++) {
      for (const r of footprints) {
        const rx = r.x + i * TILE, ry = r.y + j * TILE;
        const nx = Math.max(rx, Math.min(x, rx + r.w)), ny = Math.max(ry, Math.min(y, ry + r.h));
        if ((x - nx) ** 2 + (y - ny) ** 2 <= radius ** 2) return true;
      }
    }
  }
  return false;
}
export function moveBody(body, dx, dy, radius = 15) {
  const steps = Math.max(1, Math.ceil(Math.hypot(dx, dy) / 10));
  for (let i = 0; i < steps; i++) {
    if (!isSolid(body.x + dx / steps, body.y, radius)) body.x += dx / steps;
    if (!isSolid(body.x, body.y + dy / steps, radius)) body.y += dy / steps;
  }
}
export function clearLine(a, b, radius = 2) {
  const steps = Math.max(1, Math.ceil(Math.hypot(b.x - a.x, b.y - a.y) / 12));
  for (let i = 1; i <= steps; i++) if (isSolid(a.x + (b.x - a.x) * i / steps, a.y + (b.y - a.y) * i / steps, radius)) return false;
  return true;
}
// Short, bounded A* on the same collision map used by players and projectiles.
// Only blocked pursuit needs a route. Agents reuse it until their next planning tick.
export function route(start, goal) {
  const cell = 40, sx = Math.floor(start.x / cell), sy = Math.floor(start.y / cell);
  const gx = Math.floor(goal.x / cell), gy = Math.floor(goal.y / cell);
  const key = (x, y) => `${x},${y}`, open = [{ x: sx, y: sy, cost: 0, score: 0, parent: null }], seen = new Map();
  seen.set(key(sx, sy), 0);
  for (let count = 0; open.length && count < 700; count++) {
    let best = 0; for (let i = 1; i < open.length; i++) if (open[i].score < open[best].score) best = i;
    const n = open.splice(best, 1)[0];
    if (Math.abs(n.x - gx) + Math.abs(n.y - gy) <= 1) {
      const result = []; for (let p = n; p.parent; p = p.parent) result.unshift({ x: p.x * cell + cell / 2, y: p.y * cell + cell / 2 });
      return result;
    }
    for (const [dx, dy] of [[1, 0], [-1, 0], [0, 1], [0, -1]]) {
      const x = n.x + dx, y = n.y + dy, cost = n.cost + 1;
      if (Math.abs(x - sx) > 24 || Math.abs(y - sy) > 24 || isSolid(x * cell + 20, y * cell + 20, 17)) continue;
      if ((seen.get(key(x, y)) ?? Infinity) <= cost) continue;
      seen.set(key(x, y), cost); open.push({ x, y, cost, score: cost + Math.abs(x - gx) + Math.abs(y - gy), parent: n });
    }
  }
  return [];
}
