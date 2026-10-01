import { SETTINGS as S, clamp, distance, seeded } from './config.js';
import { WEAPONS, interceptAngle } from './weapons.js';
import { buyUpgrade } from './progression.js';
import { isSolid, moveBody, clearLine, route } from './world.js';

export class Simulation {
  constructor(seed = Date.now()) { this.random = seeded(seed); this.reset(); }
  reset() {
    this.time = 0; this.player = { x: 90, y: 90, hp: 100, lvl: 1, mag: 24, reserve: 36, cash: 100, kills: 0, obj: 0, goal: 12, a: -Math.PI / 2, vx: 0, vy: 0 };
    this.enemies = []; this.bullets = []; this.particles = []; this.pickups = []; this.events = [];
    this.fireTimer = 0; this.dashTimer = 0; this.dashCooldown = 0; this.reloadTimer = 0;
    this.hurtTimer = 0; this.muzzle = 0; this.shake = 0; this.hit = 0; this.spawnTimer = 0;
    this.signal = 0; this.nextId = 1; this.target = null;
    this.weaponIndex = 0; this.score = 0; this.combo = 0; this.comboTimer = 0;
    this.medkits = 1; this.healCooldown = 0; this.shieldDelay = 0; this.shieldFlash = 0; this.hitConfirm = 0;
    this.upgrades = { damage: 0, shield: 0, speed: 0, dash: 0, magnet: 0 };
    this.labels = []; this.barrels = []; this.explosions = []; this.visitedTiles = new Set(); this.navBudget = 1;
    this.player.shield = this.player.maxShield = 35; this.bossPending = false;
    this.populate(24); this.addBarrels();
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
    const boss = this.bossPending; this.bossPending = false;
    this.enemies.push({ id: this.nextId++, x, y, type, hp: maxHp, maxHp, a: 0,
      speed: type === 'gunner' ? 68 : type === 'charger' ? 92 : this.randomBetween(76, 105),
      timer: this.randomBetween(0.5, 2), plan: this.random(), path: [], flash: 0, phase: 'hunt', charge: 0, side: this.random() < 0.5 ? -1 : 1, spawnIn: 0.9, elite: !boss && p.lvl > 1 && this.random() < 0.16, vx: 0, vy: 0 });
    const e = this.enemies.at(-1);
    if (e.elite) { e.maxHp = Math.round(e.maxHp * 1.7); e.hp = e.maxHp; e.speed *= 1.12; }
    if (boss) { e.type = 'boss'; e.maxHp = 450 + p.lvl * 80; e.hp = e.maxHp; e.speed = 72; e.timer = 1.5; this.emit('boss', 'WARDEN SIGNAL · ELIMINATE THE DISTRICT GUARD'); }
  }
  populate(count) { for (let i = 0; i < count; i++) this.spawn(); }
  get weapon() { return WEAPONS[this.weaponIndex]; }
  buy(key) { return buyUpgrade(this, key); }
  switchWeapon() {
    if (this.reloadTimer) this.reloadTimer = 0;
    const p = this.player; p.reserve += p.mag; p.mag = 0;
    this.weaponIndex = (this.weaponIndex + 1) % WEAPONS.length; this.startReload();
    this.emit('weapon', this.weapon.name); return this.weapon;
  }
  useMedkit() {
    if (!this.medkits || this.healCooldown > 0 || this.player.hp >= 100) return false;
    this.medkits--; this.player.hp = Math.min(100, this.player.hp + 35); this.healCooldown = 12;
    this.emit('pickup', 'MEDKIT · +35 HEALTH'); this.label(this.player.x, this.player.y - 26, '+35', '#b9f8d2'); return true;
  }
  label(x, y, text, color = '#fbe7b9') {
    if (this.labels.length >= 40) this.labels.shift(); this.labels.push({ x, y, text, color, life: 0.8 });
  }
  nearest() {
    let best = null, bestDist = Math.min(S.aimRange, this.weapon.range);
    for (const e of this.enemies) {
      if (e.hp <= 0 || e.spawnIn > 0) continue;
      const d = distance(e, this.player);
      if (d < bestDist && clearLine(this.player, e)) { best = e; bestDist = d; }
    }
    const lock = this.target;
    if (lock?.hp > 0 && !(lock.spawnIn > 0) && distance(lock, this.player) < Math.min(S.aimRange, this.weapon.range) && clearLine(this.player, lock) && (!best || distance(lock, this.player) < bestDist * 1.25)) return lock;
    return best;
  }
  addBarrels() {
    const p = this.player, tx = Math.floor(p.x / S.tileSize), ty = Math.floor(p.y / S.tileSize);
    for (let x = tx - 1; x <= tx + 1; x++) for (let y = ty - 1; y <= ty + 1; y++) {
      const key = `${x}:${y}`; if (this.visitedTiles.has(key)) continue; this.visitedTiles.add(key);
      this.barrels.push({ x: x * S.tileSize + 164, y: y * S.tileSize + 330, hp: 45, radius: 13 });
      if ((Math.abs(x) + Math.abs(y)) % 3 === 0) this.barrels.push({ x: x * S.tileSize + 164, y: y * S.tileSize + 380, hp: 45, radius: 13 });
    }
    this.barrels = this.barrels.filter(b => distance(b, p) < 1900 && b.hp > 0).slice(-40);
    if (this.visitedTiles.size > 120) { const keep = [...this.visitedTiles].slice(-100); this.visitedTiles = new Set(keep); }
  }
  explode(barrel) {
    if (barrel.hp === -999) return; barrel.hp = -999;
    this.explosions.push({ x: barrel.x, y: barrel.y, life: 0.35 }); if (this.explosions.length > 12) this.explosions.shift();
    this.burst(barrel.x, barrel.y, '#ffbd70', 28, 300); this.shake = 8; this.emit('kill', 'FUEL CELL DETONATED');
    const hit = distance(barrel, this.player); if (hit < 130 && clearLine(barrel, this.player)) this.damagePlayer(Math.round(25 * (1 - hit / 140)));
    for (const e of this.enemies) if (e.hp > 0 && !(e.spawnIn > 0) && distance(barrel, e) < 150 && clearLine(barrel, e)) {
      const damage = Math.round(100 * (1 - distance(barrel, e) / 170)); e.hp -= damage; e.flash = 0.12; this.label(e.x, e.y - 30, damage);
      if (e.hp <= 0) this.kill(e);
    }
    for (const other of this.barrels) if (other !== barrel && other.hp > 0 && distance(other, barrel) < 100 && clearLine(other, barrel)) this.explode(other);
  }
  startReload() {
    const p = this.player;
    if (this.reloadTimer || p.mag === this.weapon.magazine) return;
    if (!p.reserve && p.cash >= 20) { p.cash -= 20; p.reserve += 48; this.emit('supply', 'SUPPLY LINK · 48 ROUNDS / −20¢'); }
    if (p.reserve) { this.reloadTimer = this.weapon.reload; this.emit('reload', 'RELOADING'); }
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
    const p = this.player;
    this.shieldDelay = 4; const absorbed = Math.min(p.shield, amount); p.shield -= absorbed; amount -= absorbed;
    if (absorbed) { this.shieldFlash = 0.25; if (p.shield === 0) { this.emit('shield', 'SHIELD BROKEN · FIND COVER'); this.burst(p.x, p.y, '#9bceff', 18, 180); } }
    p.hp = Math.max(0, p.hp - amount); this.hurtTimer = 0.5; this.hit = 0.3; this.shake = 7; this.emit('hurt');
    if (p.hp === 0) {
      p.hp = 100; p.cash = Math.max(0, p.cash - 40); p.x = p.y = 90; p.mag = this.weapon.magazine; p.reserve = Math.max(36, p.reserve);
      this.enemies = []; this.bullets = []; this.pickups = []; this.populate(24); this.signal++;
      p.shield = p.maxShield; this.combo = 0; this.comboTimer = 0; this.hurtTimer = 2; this.reloadTimer = 0; this.emit('respawn', 'SIGNAL RESTORED · −40¢');
    }
  }
  kill(e) {
    const p = this.player; p.kills++; p.obj++; p.cash += 20;
    this.combo = this.comboTimer > 0 ? this.combo + 1 : 1; this.comboTimer = 3.5;
    const multiplier = Math.min(4, 1 + Math.floor(this.combo / 3)), points = (e.type === 'boss' ? 500 : e.elite ? 160 : 100) * multiplier; this.score += points;
    p.cash += (multiplier - 1) * 5 + (e.elite ? 15 : 0) + (e.type === 'boss' ? 100 : 0);
    if (p.kills % 5 === 0) this.pickups.push({ x: e.x + 12, y: e.y, kind: 'medkit', life: 25 });
    this.label(e.x, e.y - 50, `+${points} / ${this.combo} CHAIN`, '#b9f8d2');
    this.burst(e.x, e.y, e.type === 'gunner' ? '#ffb15c' : '#fa668f', 25, 210); this.shake = Math.max(this.shake, 3);
    this.pickups.push({ x: e.x, y: e.y, kind: this.random() < 0.18 ? 'health' : 'ammo', life: 25 });
    if (this.pickups.length > 60) this.pickups.splice(0, this.pickups.length - 60);
    this.emit('kill', `+${20 + (multiplier - 1) * 5 + (e.elite ? 15 : 0) + (e.type === 'boss' ? 100 : 0)}¢ · HOSTILE DOWN`);
    if (p.obj >= p.goal) {
      p.obj = 0; p.goal = Math.min(30, p.goal + 3); p.lvl++; p.cash += 120; p.reserve += 30; p.hp = Math.min(100, p.hp + 20);
      if (p.lvl % 3 === 0) this.bossPending = true;
      this.populate(Math.min(S.maxEnemies - this.enemies.length, p.goal)); this.emit('level', `DISTRICT CLEARED · LEVEL ${p.lvl} / +120¢ / +30 ROUNDS`);
    }
  }
  shoot(angle) {
    const p = this.player, weapon = this.weapon;
    if (!p.mag) { this.startReload(); return; }
    if (this.bullets.length + weapon.pellets > S.maxBullets) return;
    p.mag--; this.fireTimer = weapon.interval; this.muzzle = 0.065; this.shake = Math.max(this.shake, weapon.pellets > 1 ? 4 : 1.5); p.a = angle;
    for (let i = 0; i < weapon.pellets; i++) {
      const a = angle + (weapon.pellets === 1 ? this.randomBetween(-weapon.spread, weapon.spread) : (i / (weapon.pellets - 1) - 0.5) * weapon.spread);
      const critical = this.random() < 0.12, dx = Math.cos(a), dy = Math.sin(a);
      this.bullets.push({ x: p.x + dx * 24, y: p.y + dy * 24, originX: p.x, originY: p.y, vx: dx * weapon.speed, vy: dy * weapon.speed, life: weapon.range / weapon.speed,
        hostile: false, damage: weapon.damage * (1 + this.upgrades.damage * 0.15) * (critical ? 1.6 : 1), critical, pierce: weapon.pierce, hitIds: new Set(), range: weapon.range });
    }
    this.burst(p.x + Math.cos(angle) * 29, p.y + Math.sin(angle) * 29, '#fff2b0', 3, 80); this.emit('shot');
  }
  update(dt, input = {}) {
    const p = this.player; this.time += dt;
    if (input.weapon) this.switchWeapon(); if (input.heal) this.useMedkit();
    this.navBudget = 1; this.comboTimer = Math.max(0, this.comboTimer - dt); if (!this.comboTimer) this.combo = 0;
    this.healCooldown = Math.max(0, this.healCooldown - dt); this.shieldDelay = Math.max(0, this.shieldDelay - dt);
    this.shieldFlash = Math.max(0, this.shieldFlash - dt); this.hitConfirm = Math.max(0, this.hitConfirm - dt);
    if (!this.shieldDelay) p.shield = Math.min(p.maxShield, p.shield + dt * 6);
    for (const label of this.labels) { label.life -= dt; label.y -= dt * 22; } this.labels = this.labels.filter(l => l.life > 0);
    for (const f of this.explosions) f.life -= dt; this.explosions = this.explosions.filter(f => f.life > 0);
    if (Math.floor(this.time / 0.5) !== Math.floor((this.time - dt) / 0.5)) this.addBarrels();
    for (const name of ['fireTimer', 'dashCooldown', 'hurtTimer', 'muzzle', 'hit']) this[name] = Math.max(0, this[name] - dt);
    this.shake *= Math.exp(-16 * dt);
    if (input.reload) this.startReload();
    if (this.reloadTimer > 0) {
      this.reloadTimer -= dt;
      if (this.reloadTimer <= 0) { const n = Math.min(this.weapon.magazine - p.mag, p.reserve); p.mag += n; p.reserve -= n; this.reloadTimer = 0; this.emit('loaded', 'MAGAZINE READY'); }
    }
    let mx = input.mx || 0, my = input.my || 0, m = Math.hypot(mx, my);
    if (m > 1) { mx /= m; my /= m; }
    if (input.aim) p.a = Math.atan2(input.aim.y - p.y, input.aim.x - p.x);
    else if (m > 0.05 && !input.fire) p.a = Math.atan2(my, mx);
    this.target = input.aim ? null : this.nearest();
    if (input.dash && !this.dashCooldown) {
      const a = m > 0.05 ? Math.atan2(my, mx) : p.a;
      this.dashVx = Math.cos(a) * S.dashSpeed; this.dashVy = Math.sin(a) * S.dashSpeed;
      this.dashTimer = S.dashTime; this.dashCooldown = S.dashCooldown * 0.9 ** this.upgrades.dash; this.emit('dash', 'PHASE DASH');
    }
    if (this.dashTimer > 0) {
      p.vx = this.dashVx; p.vy = this.dashVy; this.dashTimer = Math.max(0, this.dashTimer - dt);
      this.burst(p.x, p.y, '#79f9dd', 2, 40);
    } else {
      const smoothing = 1 - Math.exp(-22 * dt);
      p.vx += (mx * S.playerSpeed * (1 + this.upgrades.speed * 0.08) - p.vx) * smoothing; p.vy += (my * S.playerSpeed * (1 + this.upgrades.speed * 0.08) - p.vy) * smoothing;
    }
    moveBody(p, p.vx * dt, p.vy * dt, S.playerRadius);
    if (input.fire && !this.fireTimer && !this.reloadTimer) {
      // Touch / space retain v40 auto-aim. Mouse aims directly and can fire without a target.
      if (input.aim || this.target) this.shoot(input.aim ? p.a : interceptAngle(p, this.target, this.weapon.speed));
    }
    this.updateEnemies(dt);
    this.updateBullets(dt);
    this.enemies = this.enemies.filter(e => e.hp > 0);
    this.spawnTimer -= dt;
    if (this.spawnTimer <= 0) { if (this.enemies.length < Math.min(30, 16 + p.lvl * 2)) this.spawn(); this.spawnTimer = 0.8; }
    for (const drop of this.pickups) {
      drop.life -= dt; const d = distance(drop, p);
      if (d < 105 + 25 * this.upgrades.magnet) { drop.x += (p.x - drop.x) * dt * 6; drop.y += (p.y - drop.y) * dt * 6; }
      if (d < 28) { if (drop.kind === 'ammo') p.reserve += 8; else if (drop.kind === 'medkit') this.medkits = Math.min(5, this.medkits + 1); else p.hp = Math.min(100, p.hp + 18); drop.life = 0; this.emit('pickup', drop.kind === 'ammo' ? '+8 ROUNDS' : drop.kind === 'medkit' ? '+1 MEDKIT' : '+18 HEALTH'); }
    }
    this.pickups = this.pickups.filter(e => e.life > 0);
    for (const f of this.particles) { f.life -= dt; f.x += f.vx * dt; f.y += f.vy * dt; f.vx *= Math.exp(-4 * dt); f.vy *= Math.exp(-4 * dt); }
    this.particles = this.particles.filter(f => f.life > 0);
  }
  updateEnemies(dt) {
    const p = this.player;
    for (const e of this.enemies) {
      if (e.hp <= 0) continue;
      const oldX = e.x, oldY = e.y;
      if (e.spawnIn > 0) { e.spawnIn -= dt; continue; }
      if ((e.type === 'gunner' || e.type === 'boss') && e.phase === 'windup' && !clearLine(e, p, 4)) { e.phase = 'hunt'; e.timer = 0.7; e.charge = 0; }
      e.flash = Math.max(0, e.flash - dt); e.timer -= dt; e.plan -= dt;
      const d = distance(e, p); if (d > 1600) { e.hp = 0; continue; }
      if (d > 950) continue;
      const los = clearLine(e, p, 4); e.a = Math.atan2(p.y - e.y, p.x - e.x);
      let target = p, speed = e.speed;
      if (!los) {
        if (e.plan <= 0 && this.navBudget > 0) { this.navBudget--; e.path = route(e, p); e.plan = 0.9 + this.random() * 0.4; }
        while (e.path.length && distance(e, e.path[0]) < 24) e.path.shift();
        target = e.path[0] || p;
      } else e.path.length = 0;
      if (e.type === 'boss' && los && d < 650) {
        const enraged = e.hp < e.maxHp * 0.4;
        speed *= enraged ? 1.5 : 1;
        if (e.phase === 'windup') {
          speed = 0; e.charge -= dt;
          if (e.charge <= 0) {
            for (let i = -2; i <= 2; i++) if (this.bullets.length < S.maxBullets) { const a = e.aim + i * 0.13; this.bullets.push({ x: e.x + Math.cos(a) * 30, y: e.y + Math.sin(a) * 30, vx: Math.cos(a) * 350, vy: Math.sin(a) * 350, hostile: true, life: 2 }); }
            e.phase = 'hunt'; e.timer = enraged ? 0.95 : 1.8;
          }
        } else if (e.timer <= 0) { e.phase = 'windup'; e.charge = 0.75; e.aim = e.a; }
      } else if (e.type === 'gunner' && los && d < 550) {
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
          if (d < 36) this.damagePlayer(16); e.vx = (e.x - oldX) / dt; e.vy = (e.y - oldY) / dt; continue;
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
      e.vx = (e.x - oldX) / dt; e.vy = (e.y - oldY) / dt;
      if (d < 34) this.damagePlayer(e.type === 'boss' ? 20 : e.type === 'gunner' ? 7 : 10);
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
        else {
          for (const barrel of this.barrels) if (barrel.hp > 0 && distance(b, barrel) < 15) { barrel.hp -= b.damage || S.bulletDamage; b.life = 0; if (barrel.hp <= 0) this.explode(barrel); break; }
          if (b.life <= 0) continue;
          for (const e of this.enemies) if (e.hp > 0 && !(e.spawnIn > 0) && !b.hitIds?.has(e.id) && distance(b, e) < (e.type === 'boss' ? 28 : 20)) {
          const travelled = Math.hypot(b.x - (b.originX ?? b.x), b.y - (b.originY ?? b.y));
          const falloff = Math.max(0.55, 1 - Math.max(0, travelled / (b.range || 800) - 0.45) * 0.6);
          const damage = Math.round((b.damage || S.bulletDamage) * falloff); e.hp -= damage; e.flash = 0.09; this.hitConfirm = 0.12;
          this.label(e.x, e.y - 32, `${damage}${b.critical ? '!' : ''}`, b.critical ? '#ffd18a' : '#d6e8dc');
          const v = Math.hypot(b.vx, b.vy) || 1; moveBody(e, b.vx / v * (e.type === 'boss' ? 2 : 9), b.vy / v * (e.type === 'boss' ? 2 : 9), 17);
          b.hitIds?.add(e.id); b.pierce = (b.pierce || 1) - 1; if (!b.pierce) b.life = 0;
          this.burst(b.x, b.y, '#ffb975', 7, 130); this.emit('hit'); if (e.hp <= 0) this.kill(e); break;
          }
        }
      }
    }
    this.bullets = this.bullets.filter(b => b.life > 0);
  }
}
