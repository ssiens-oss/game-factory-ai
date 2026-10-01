import { seeded, SETTINGS } from './config.js';
import { buildings, tileSeed } from './world.js';

const SIZE = SETTINGS.tileSize;
const PALETTES = [['#79f4d1', 'NEON WARD'], ['#ffba73', 'FOUNDRY'], ['#b6a2ff', 'LOWLINE'], ['#79cef4', 'RAIN MARKET']];
export function district(x, y) { return PALETTES[(Math.abs(Math.floor(x / (SIZE * 3))) + Math.abs(Math.floor(y / (SIZE * 3)))) % PALETTES.length]; }
const rounded = (g, x, y, w, h, r, color) => { g.fillStyle = color; g.beginPath(); g.roundRect(x, y, w, h, r); g.fill(); };
function glow(g, color, blur, fn) { g.shadowColor = color; g.shadowBlur = blur; fn(); g.shadowBlur = 0; }

export class CityRenderer {
  constructor() { this.cache = new Map(); }
  tile(tx, ty) {
    const key = `${tx}:${ty}`;
    if (this.cache.has(key)) { const value = this.cache.get(key); this.cache.delete(key); this.cache.set(key, value); return value; }
    const c = document.createElement('canvas'); c.width = c.height = SIZE;
    const g = c.getContext('2d'), random = seeded(tileSeed(tx, ty)), [neon, name] = district(tx * SIZE, ty * SIZE);
    g.fillStyle = '#111b20'; g.fillRect(0, 0, SIZE, SIZE);
    // Wet asphalt, broad roads, tiled sidewalks and gutters.
    g.fillStyle = '#233139'; g.fillRect(180, 180, 460, 460);
    g.strokeStyle = '#41545a'; g.lineWidth = 2;
    g.beginPath(); g.moveTo(178, SIZE); g.lineTo(178, 178); g.lineTo(SIZE, 178); g.stroke();
    g.strokeStyle = '#18282d'; g.lineWidth = 1;
    for (let n = 188; n < SIZE; n += 24) { g.beginPath(); g.moveTo(n, 180); g.lineTo(n, SIZE); g.moveTo(180, n); g.lineTo(SIZE, n); g.stroke(); }
    for (let i = 0; i < 1250; i++) { const x = random() * SIZE, y = random() * SIZE; g.fillStyle = random() > 0.5 ? '#a6c7cd0b' : '#00000024'; g.fillRect(x, y, 1 + random() * 2, 1); }
    // Puddles reflect broken strips of neon without obscuring combat silhouettes.
    for (let i = 0; i < 18; i++) {
      const horizontal = i % 2, x = horizontal ? random() * SIZE : random() * 155, y = horizontal ? random() * 155 : random() * SIZE;
      const w = 12 + random() * 44, h = 3 + random() * 7;
      rounded(g, x, y, w, h, 4, '#6b9da612'); g.fillStyle = neon + '18'; g.fillRect(x + 2, y + h / 2, w * 0.7, 1);
    }
    g.strokeStyle = '#ab9d6860'; g.lineWidth = 2; g.setLineDash([19, 22]);
    g.beginPath(); g.moveTo(88, 190); g.lineTo(88, SIZE); g.moveTo(190, 88); g.lineTo(SIZE, 88); g.stroke(); g.setLineDash([]);
    g.strokeStyle = '#83a6af25'; g.lineWidth = 1;
    g.beginPath(); g.moveTo(19, 180); g.lineTo(19, SIZE); g.moveTo(154, 180); g.lineTo(154, SIZE); g.moveTo(180, 19); g.lineTo(SIZE, 19); g.moveTo(180, 154); g.lineTo(SIZE, 154); g.stroke();
    // Crosswalks and lane arrows keep the grid legible as it scrolls.
    g.fillStyle = '#b7c5ba69';
    for (let i = 0; i < 7; i++) { g.fillRect(28 + i * 18, 162, 10, 24); g.fillRect(162, 28 + i * 18, 24, 10); }
    g.fillStyle = '#aebfbd38'; g.beginPath(); g.moveTo(58, 390); g.lineTo(58, 365); g.lineTo(46, 380); g.lineTo(58, 350); g.lineTo(70, 380); g.lineTo(62, 369); g.lineTo(62, 390); g.fill();
    g.strokeStyle = '#26383e'; g.lineWidth = 2; g.beginPath(); g.arc(132, 130, 13, 0, 7); g.stroke();
    for (let i = 0; i < 5; i++) { g.beginPath(); g.moveTo(122, 123 + i * 3); g.lineTo(142, 123 + i * 3); g.stroke(); }
    for (const raw of buildings(tx, ty)) {
      const r = { ...raw, x: raw.x - tx * SIZE, y: raw.y - ty * SIZE }, accent = raw.id % 2 ? neon : '#d4ab78';
      // Elevation: offset shadow, illuminated facade, bevel and textured roof.
      rounded(g, r.x + 10, r.y + 12, r.w + 7, r.h + 7, 6, '#02080dbb');
      const wall = g.createLinearGradient(r.x, r.y, r.x, r.y + r.h); wall.addColorStop(0, '#52686b'); wall.addColorStop(0.25, '#293e45'); wall.addColorStop(1, '#121f29');
      rounded(g, r.x, r.y, r.w, r.h, 4, wall);
      rounded(g, r.x + 6, r.y + 6, r.w - 13, r.h - 17, 3, ['#293e46', '#34434b', '#354747', '#283740'][raw.id]);
      g.strokeStyle = '#9ab5b92c'; g.strokeRect(r.x + 9.5, r.y + 9.5, r.w - 20, r.h - 27);
      g.fillStyle = '#a4c1bb10'; g.fillRect(r.x + 11, r.y + 11, r.w - 24, 3);
      for (let i = 0; i < 70; i++) { g.fillStyle = random() > 0.5 ? '#c5e1c509' : '#00000013'; g.fillRect(r.x + 13 + random() * (r.w - 29), r.y + 15 + random() * (r.h - 38), random() * 12, 1); }
      for (let x = r.x + 14; x < r.x + r.w - 15; x += 19) {
        g.fillStyle = random() > 0.3 ? accent + '99' : '#0b151c'; g.fillRect(x, r.y + r.h - 9, 9, 4);
        g.fillStyle = accent + '10'; g.fillRect(x - 4, r.y + r.h + 2, 16, 14);
      }
      // Roof equipment, ducts, rails and fan blades, all baked into the tile.
      rounded(g, r.x + 18, r.y + 24, 54, 39, 3, '#101e25'); rounded(g, r.x + 17, r.y + 20, 54, 38, 3, '#52616a');
      g.fillStyle = '#283a42'; g.fillRect(r.x + 23, r.y + 26, 42, 26);
      g.strokeStyle = '#93a7a450'; g.lineWidth = 1;
      for (let i = 0; i < 6; i++) { g.beginPath(); g.moveTo(r.x + 26, r.y + 29 + i * 4); g.lineTo(r.x + 62, r.y + 29 + i * 4); g.stroke(); }
      g.strokeStyle = '#1b2a31'; g.lineWidth = 8; g.beginPath(); g.moveTo(r.x + 64, r.y + 39); g.lineTo(r.x + 98, r.y + 39); g.lineTo(r.x + 98, r.y + 67); g.stroke();
      g.strokeStyle = '#67787c'; g.lineWidth = 4; g.stroke();
      const fx = r.x + r.w - 33, fy = r.y + 38;
      g.fillStyle = '#15272e'; g.beginPath(); g.arc(fx, fy, 17, 0, 7); g.fill();
      g.strokeStyle = '#889b9b'; g.lineWidth = 2; g.stroke();
      g.strokeStyle = '#4c6067'; g.lineWidth = 4;
      for (let k = 0; k < 4; k++) { const a = k * Math.PI / 2 + 0.5; g.beginPath(); g.moveTo(fx, fy); g.lineTo(fx + Math.cos(a) * 11, fy + Math.sin(a) * 11); g.stroke(); }
      // Solar panels / rooftop gardens alternate with skylights.
      if (raw.id % 2 === 0) {
        g.fillStyle = '#172a37'; g.fillRect(r.x + 20, r.y + 85, 93, 48); g.strokeStyle = '#739aaa55'; g.strokeRect(r.x + 20, r.y + 85, 93, 48);
        for (let a = 0; a < 6; a++) { g.beginPath(); g.moveTo(r.x + 21 + a * 15, r.y + 85); g.lineTo(r.x + 21 + a * 15, r.y + 133); g.stroke(); }
        g.beginPath(); g.moveTo(r.x + 20, r.y + 109); g.lineTo(r.x + 113, r.y + 109); g.stroke();
      } else {
        rounded(g, r.x + 24, r.y + 85, 78, 38, 2, '#172c28');
        for (let i = 0; i < 18; i++) { g.fillStyle = ['#43664b', '#345647', '#557359'][i % 3]; g.beginPath(); g.arc(r.x + 29 + random() * 65, r.y + 90 + random() * 28, 3 + random() * 5, 0, 7); g.fill(); }
      }
      const labels = ['ECHO', '24 / 7', 'NO SIGNAL', 'KOVA'];
      rounded(g, r.x + r.w - 59, r.y + 91, 44, 31, 2, '#0d1c26');
      g.fillStyle = accent; glow(g, accent, 10, () => { g.fillRect(r.x + r.w - 59, r.y + 91, 44, 2); g.font = 'bold 7px monospace'; g.textAlign = 'center'; g.fillText(labels[raw.id], r.x + r.w - 37, r.y + 109); });
    }
    // Street lamps, signal fixtures and parked courier cars.
    for (const [x, y] of [[192, 195], [194, 610], [610, 194]]) {
      g.fillStyle = '#101c20'; g.fillRect(x - 3, y - 2, 6, 15); g.fillStyle = '#bdeada'; glow(g, neon, 22, () => g.fillRect(x - 6, y - 5, 12, 4));
      const light = g.createRadialGradient(x, y, 1, x, y, 52); light.addColorStop(0, neon + '15'); light.addColorStop(1, neon + '00'); g.fillStyle = light; g.fillRect(x - 52, y - 52, 104, 104);
    }
    const carY = 240 + random() * 230;
    rounded(g, 123, carY + 5, 28, 64, 8, '#030a0dd0'); rounded(g, 119, carY, 27, 62, 7, random() > 0.5 ? '#5a6570' : '#324c50');
    rounded(g, 122, carY + 12, 21, 34, 5, '#111f2a'); g.fillStyle = '#82a7ac66'; g.fillRect(124, carY + 13, 17, 9); g.fillRect(124, carY + 37, 17, 5);
    g.fillStyle = '#ffe9b4'; g.fillRect(122, carY + 2, 5, 3); g.fillRect(138, carY + 2, 5, 3); g.fillStyle = '#fe776a'; g.fillRect(122, carY + 56, 4, 2); g.fillRect(139, carY + 56, 4, 2);
    g.font = 'bold 10px monospace'; g.textAlign = 'left'; g.fillStyle = neon + '88'; g.save(); g.translate(204, 160); g.fillText(`${name} / ${Math.abs(tx * 3 + ty) % 99}` , 0, 0); g.restore();
    this.cache.set(key, c); if (this.cache.size > 32) this.cache.delete(this.cache.keys().next().value);
    return c;
  }
  draw(g, bounds) {
    const minX = Math.floor(bounds.left / SIZE), maxX = Math.floor(bounds.right / SIZE), minY = Math.floor(bounds.top / SIZE), maxY = Math.floor(bounds.bottom / SIZE);
    for (let x = minX; x <= maxX; x++) for (let y = minY; y <= maxY; y++) g.drawImage(this.tile(x, y), x * SIZE, y * SIZE);
  }
}
