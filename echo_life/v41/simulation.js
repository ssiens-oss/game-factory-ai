import { SETTINGS as S, clamp, distance, seeded } from './config.js';
import { isSolid, moveBody, clearLine, route } from './world.js';

export class Simulation {
  constructor(seed = Date.now()) { this.random = seeded(seed); this.reset(); }
  reset() {
    this.time = 0; this.player = { x: 90, y: 90, hp: 100, lvl: 1, mag: 24, reserve: 36, cash: 100, kills: 0, obj: 0, goal: 12, a: -Math.PI / 2, vx: 0, vy: 0 };
    this.enemies = []; this.bullets = []; this.particles = []; this.pickups = []; this.events = [];
    this.fireTimer = 0; this.dashTimer = 0; this.dashCooldown = 0; this.reloadTimer = 0;
    this.hurtTimer = 0; this.muzzle = 0; this.shake = 0; this.hit = 0; this.spawnTimer = 0;
    this.signal = 0; this.nextId = 1; this.target = null; this.populate(24);
  }
  randomBetween(a, b) { return a + this.random() * (b - a); }
  emit(kind, text = '') { this.events.push({ kind, text }); }
  takeEvents() { return this.events.splice(0); }
  spawn() {
    if (this.enemies.length >= S.maxEnemies) return;
    const p = this.player;
    let x, y;
    for (let tries = 0; tries < 60; tries++) {
      const a = this.random() * Math.PI * 2, d = this.randomBetween(500, 1000);
      x = p.x + Math.cos(a) * d; y = p.y + Math.sin(a) * d;
      if (!isSolid(x, y, 18)) break;
      x = undefined;
    }
    if (x === undefined) return;
    const roll = this.random(), type = roll < 0.25 ? 'gunner' : roll < 0.43 ? 'charger' : 'stalker';
    const maxHp = 55 + p.lvl * 6 + (type === 'charger' ? 25 : 0);
    this.enemies.push({ id: this.nextId++, x, y, type, hp: maxHp, maxHp, a: 0,
      speed: type === 'gunner' ? 68 : type === 'charger' ? 92 : this.randomBetween(76, 105),
      timer: this.randomBetween(0.5, 2), plan: this.random(), path: [], flash: 0, phase: 'hunt', charge: 0, side: this.random() < 0.5 ? -1 : 1 });
  }
  populate(count) { for (let i = 0; i < count; i++) this.spawn(); }
  nearest() {
    let best = null, bestDist = S.aimRange;
    for (const e of this.enemies) { const d = distance(e, this.player); if (e.hp > 0 && d < bestDist && clearLine(this.player, e)) { best = e; bestDist = d; } }
    return best;
  }
  startReload() {
    const p = this.player;
    if (this.reloadTimer || p.mag === S.magazine) return;
    if (!p.reserve && p.cash >= 20) { p.cash -= 20; p.reserve += 48; this.emit('supply', 'SUPPLY LINK · 48 ROUNDS / −20¢'); }
    if (p.reserve) { this.reloadTimer = 1; this.emit('reload', 'RELOADING'); }
    else this.emit('empty', 'FIND AMMO · DOWNED HOSTILES DROP SUPPLIES');
  }
  burst(x, y, color, count = 12, speed = 150) {
    for (let i = 0; i < count && this.particles.length < S.maxParticles; i++) {
      const a = this.random() * Math.PI * 2, v = this.randomBetween(25, speed), life = this.randomBetween(0.18, 0.55);
      this.particles.push({ x, y, vx: Math.cos(a) * v, vy: Math.sin(a) * v, life, maxLife: life, color, size: this.randomBetween(1.4, 3.6) });
    }
  }
  damagePlayer(amount) {
    if (this.dashTimer > 0 || this.hurtTimer > 0) return;
    const p = this.player; p.hp = Math.max(0, p.hp - amount); this.hurtTimer = 0.5; this.hit = 0.3; this.shake = 7; this.emit('hurt');
    if (p.hp === 0) {
      p.hp = 100; p.cash = Math.max(0, p.cash - 40); p.x = p.y = 90; p.mag = 24; p.reserve = Math.max(36, p.reserve);
      this.enemies = []; this.bullets = []; this.pickups = []; this.populate(24); this.signal++;
      this.hurtTimer = 2; this.reloadTimer = 0; this.emit('respawn', 'SIGNAL RESTORED · −40¢');
    }
  }
  kill(e) {
    const p = this.player; p.kills++; p.obj++; p.cash += 20;
    this.burst(e.x, e.y, e.type === 'gunner' ? '#ffb15c' : '#fa668f', 25, 210); this.shake = Math.max(this.shake, 3);
    this.pickups.push({ x: e.x, y: e.y, kind: this.random() < 0.18 ? 'health' : 'ammo', life: 25 });
    if (this.pickups.length > 60) this.pickups.shift();
    this.emit('kill', '+20¢ · HOSTILE DOWN');
    if (p.obj >= p.goal) {
      p.obj = 0; p.goal = Math.min(30, p.goal + 3); p.lvl++; p.cash += 120; p.reserve += 30; p.hp = Math.min(100, p.hp + 20);
      this.populate(Math.min(S.maxEnemies - this.enemies.length, p.goal)); this.emit('level', `DISTRICT CLEARED · LEVEL ${p.lvl} / +120¢ / +30 ROUNDS`);
    }
  }
  shoot(angle, enemy = null) {
    const p = this.player;
    if (!p.mag) { this.startReload(); return; }
    if (this.bullets.length >= S.maxBullets) return;
    p.mag--; this.fireTimer = S.shotInterval; this.muzzle = 0.065; this.shake = Math.max(this.shake, 1.5); p.a = angle;
    const dx = Math.cos(angle), dy = Math.sin(angle);
    this.bullets.push({ x: p.x + dx * 22, y: p.y + dy * 22, vx: dx * S.bulletSpeed, vy: dy * S.bulletSpeed, life: 0.75, hostile: false });
    this.burst(p.x + dx * 29, p.y + dy * 29, '#fff2b0', 3, 80); this.emit('shot');
  }
  update(dt, input = {}) {
    const p = this.player; this.time += dt;
    for (const name of ['fireTimer', 'dashCooldown', 'hurtTimer', 'muzzle', 'hit']) this[name] = Math.max(0, this[name] - dt);
    this.shake *= Math.exp(-16 * dt);
    if (input.reload) this.startReload();
    if (this.reloadTimer > 0) {
      this.reloadTimer -= dt;
      if (this.reloadTimer <= 0) { const n = Math.min(S.magazine - p.mag, p.reserve); p.mag += n; p.reserve -= n; this.reloadTimer = 0; this.emit('loaded', 'MAGAZINE READY'); }
    }
    let mx = input.mx || 0, my = input.my || 0, m = Math.hypot(mx, my);
    if (m > 1) { mx /= m; my /= m; }
    if (input.aim) p.a = Math.atan2(input.aim.y - p.y, input.aim.x - p.x);
    else if (m > 0.05 && !input.fire) p.a = Math.atan2(my, mx);
    this.target = input.aim ? null : this.nearest();
    if (input.dash && !this.dashCooldown) {
      const a = m > 0.05 ? Math.atan2(my, mx) : p.a;
      this.dashVx = Math.cos(a) * S.dashSpeed; this.dashVy = Math.sin(a) * S.dashSpeed;
      this.dashTimer = S.dashTime; this.dashCooldown = S.dashCooldown; this.emit('dash', 'PHASE DASH');
    }
    if (this.dashTimer > 0) {
      p.vx = this.dashVx; p.vy = this.dashVy; this.dashTimer = Math.max(0, this.dashTimer - dt);
      this.burst(p.x, p.y, '#79f9dd', 2, 40);
    } else {
      const smoothing = 1 - Math.exp(-22 * dt);
      p.vx += (mx * S.playerSpeed - p.vx) * smoothing; p.vy += (my * S.playerSpeed - p.vy) * smoothing;
    }
    moveBody(p, p.vx * dt, p.vy * dt, S.playerRadius);
    if (input.fire && !this.fireTimer && !this.reloadTimer) {
      // Touch / space retain v40 auto-aim. Mouse aims directly and can fire without a target.
      if (input.aim || this.target) this.shoot(input.aim ? p.a : Math.atan2(this.target.y - p.y, this.target.x - p.x));
    }
    this.updateEnemies(dt);
    this.updateBullets(dt);
    this.enemies = this.enemies.filter(e => e.hp > 0);
    this.spawnTimer -= dt;
    if (this.spawnTimer <= 0) { if (this.enemies.length < Math.min(30, 16 + p.lvl * 2)) this.spawn(); this.spawnTimer = 0.8; }
    for (const drop of this.pickups) {
      drop.life -= dt; const d = distance(drop, p);
      if (d < 105) { drop.x += (p.x - drop.x) * dt * 6; drop.y += (p.y - drop.y) * dt * 6; }
      if (d < 28) { if (drop.kind === 'ammo') p.reserve += 8; else p.hp = Math.min(100, p.hp + 18); drop.life = 0; this.emit('pickup', drop.kind === 'ammo' ? '+8 ROUNDS' : '+18 HEALTH'); }
    }
    this.pickups = this.pickups.filter(e => e.life > 0);
    for (const f of this.particles) { f.life -= dt; f.x += f.vx * dt; f.y += f.vy * dt; f.vx *= Math.exp(-4 * dt); f.vy *= Math.exp(-4 * dt); }
    this.particles = this.particles.filter(f => f.life > 0);
  }
  updateEnemies(dt) {
    const p = this.player;
    for (const e of this.enemies) {
      if (e.hp <= 0) continue;
      e.flash = Math.max(0, e.flash - dt); e.timer -= dt; e.plan -= dt;
      const d = distance(e, p); if (d > 1600) { e.hp = 0; continue; }
      if (d > 950) continue;
      const los = clearLine(e, p, 4); e.a = Math.atan2(p.y - e.y, p.x - e.x);
      let target = p, speed = e.speed;
      if (!los) {
        if (e.plan <= 0) { e.path = route(e, p); e.plan = 0.9 + this.random() * 0.4; }
        while (e.path.length && distance(e, e.path[0]) < 24) e.path.shift();
        target = e.path[0] || p;
      } else e.path.length = 0;
      if (e.type === 'gunner' && los && d < 550) {
        speed = d < 220 ? -e.speed : d > 340 ? e.speed : 0;
        if (e.phase === 'windup') {
          speed = 0; e.charge -= dt;
          if (e.charge <= 0) {
            const a = e.aim, v = 330;
            if (this.bullets.length < S.maxBullets) this.bullets.push({ x: e.x + Math.cos(a) * 24, y: e.y + Math.sin(a) * 24, vx: Math.cos(a) * v, vy: Math.sin(a) * v, hostile: true, life: 2 });
            e.phase = 'hunt'; e.timer = 1.9;
          }
        } else if (e.timer <= 0) { e.phase = 'windup'; e.charge = 0.65; e.aim = Math.atan2(p.y + p.vy * 0.25 - e.y, p.x + p.vx * 0.25 - e.x); }
      } else if (e.type === 'charger') {
        if (e.phase === 'rush') {
          moveBody(e, Math.cos(e.aim) * 450 * dt, Math.sin(e.aim) * 450 * dt, 17);
          e.charge -= dt; if (e.charge <= 0) { e.phase = 'hunt'; e.timer = 2.4; }
          if (d < 36) this.damagePlayer(16); continue;
        }
        if (e.phase === 'windup') {
          speed = 0; e.charge -= dt;
          if (e.charge <= 0) { e.phase = 'rush'; e.charge = 0.48; }
        } else if (los && d < 300 && d > 90 && e.timer <= 0) { e.phase = 'windup'; e.charge = 0.65; e.aim = e.a; }
      }
      let dx = target.x - e.x, dy = target.y - e.y, len = Math.hypot(dx, dy) || 1;
      dx /= len; dy /= len;
      if (los && e.type === 'stalker' && d > 90 && d < 300) { dx += -Math.sin(e.a) * e.side * 0.35; dy += Math.cos(e.a) * e.side * 0.35; }
      // Separation keeps pursuing enemies from collapsing into one unreadable pile.
      let sx = 0, sy = 0;
      for (const other of this.enemies) if (other !== e && other.hp > 0) { const q = distance(e, other); if (q > 0 && q < 38) { sx += (e.x - other.x) / q * (38 - q) * 3; sy += (e.y - other.y) / q * (38 - q) * 3; } }
      moveBody(e, (dx * speed + sx) * dt, (dy * speed + sy) * dt, 17);
      if (d < 34) this.damagePlayer(e.type === 'gunner' ? 7 : 10);
    }
  }
  updateBullets(dt) {
    // Sweep substeps prevent tunnelling at high projectile speed / low frame rate.
    for (const b of this.bullets) {
      b.life -= dt; const n = Math.max(1, Math.ceil(Math.hypot(b.vx, b.vy) * dt / 8));
      for (let i = 0; i < n && b.life > 0; i++) {
        b.x += b.vx * dt / n; b.y += b.vy * dt / n;
        if (isSolid(b.x, b.y, 2)) { b.life = 0; this.burst(b.x, b.y, '#c2f1df', 5, 80); break; }
        if (b.hostile) { if (distance(b, this.player) < 17) { b.life = 0; this.damagePlayer(12); } }
        else for (const e of this.enemies) if (e.hp > 0 && distance(b, e) < 20) {
          b.life = 0; e.hp -= S.bulletDamage; e.flash = 0.09; this.hit = 0.07;
          this.burst(b.x, b.y, '#ffb975', 7, 130); this.emit('hit'); if (e.hp <= 0) this.kill(e); break;
        }
      }
    }
    this.bullets = this.bullets.filter(b => b.life > 0);
  }
}
