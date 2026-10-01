import test from 'node:test';
import assert from 'node:assert/strict';
import { Simulation } from '../../echo_life/v41/simulation.js';
import { SETTINGS } from '../../echo_life/v41/config.js';
import { isSolid, moveBody, clearLine, route } from '../../echo_life/v41/world.js';
const advance = (sim, seconds, input = {}) => { for (let i = 0; i < Math.round(seconds * 60); i++) sim.update(1 / 60, input); };
const isolate = sim => { sim.enemies = []; sim.spawnTimer = 1000; };
function enemy(x, y, type = 'stalker') { return { id: 777, x, y, hp: 61, maxHp: 61, type, a: 0, timer: 10, plan: 10, speed: 0, flash: 0, path: [], side: 1, phase: 'hunt', charge: 0 }; }

test('world remains solid across negative tile coordinates, movement slides and dash cannot tunnel', () => {
  assert.equal(isSolid(250, 250), true); assert.equal(isSolid(250 - 640, 250 - 640), true); assert.equal(isSolid(90, 90), false);
  const p = { x: 190, y: 250 }; moveBody(p, 300, 35, 15); assert.ok(p.x < 200); assert.ok(p.y > 250); assert.equal(isSolid(p.x, p.y, 15), false);
  const s = new Simulation(1); isolate(s); s.player.x = 180; s.player.y = 250; advance(s, 0.2, { mx: 1, dash: true }); assert.ok(s.player.x < 198); assert.ok(s.dashCooldown > 0);
});
test('pursuit route finds a walkable detour around rooftops', () => {
  const start = { x: 180, y: 300 }, goal = { x: 620, y: 300 };
  assert.equal(clearLine(start, goal), false); const path = route(start, goal); assert.ok(path.length > 0);
  for (const p of path) assert.equal(isSolid(p.x, p.y, 17), false);
  assert.ok(Math.hypot(path.at(-1).x - goal.x, path.at(-1).y - goal.y) < 80);
});
test('continuous movement covers the same distance independent of render frequency, diagonals normalize', () => {
  const a = new Simulation(1), b = new Simulation(1), c = new Simulation(1), d = new Simulation(1); [a, b, c, d].forEach(isolate);
  advance(a, 1, { my: -1 }); for (let frame = 0; frame < 30; frame++) { b.update(1 / 60, { my: -1 }); b.update(1 / 60, { my: -1 }); }
  advance(c, 0.5, { mx: -1, my: -1 }); advance(d, 0.5, { my: -1 }); assert.equal(a.player.y, b.player.y);
  assert.ok(Math.abs(Math.hypot(c.player.x - 90, c.player.y - 90) - (90 - d.player.y)) < 0.01);
});
test('shots cause damage only on projectile impact, reward kill once, drop supplies', () => {
  const s = new Simulation(2); isolate(s); s.enemies = [enemy(350, 90)]; s.shoot(0);
  assert.equal(s.enemies[0].hp, 61); assert.equal(s.player.mag, 23);
  advance(s, 0.3); assert.equal(s.enemies[0].hp, 27); s.shoot(0); advance(s, 0.3);
  assert.equal(s.player.kills, 1); assert.equal(s.player.obj, 1); assert.equal(s.player.cash, 120); assert.equal(s.pickups.length, 1);
  advance(s, 1); assert.equal(s.player.kills, 1);
});
test('buildings block fire and auto-aim line of sight', () => {
  const s = new Simulation(3); isolate(s); s.player.x = 180; s.player.y = 250; s.enemies = [enemy(400, 250)];
  assert.equal(s.nearest(), null); s.shoot(0); advance(s, 0.5); assert.equal(s.enemies[0].hp, 61); assert.equal(s.bullets.length, 0);
});
test('reload conserves ammunition and supply link prevents an empty-ammo softlock', () => {
  const s = new Simulation(4); isolate(s); s.player.mag = 0; s.player.reserve = 8; s.startReload(); advance(s, 1.1);
  assert.equal(s.player.mag, 8); assert.equal(s.player.reserve, 0);
  s.player.mag = 0; s.startReload(); advance(s, 1.1); assert.equal(s.player.mag, 24); assert.equal(s.player.reserve, 24); assert.equal(s.player.cash, 80);
});
test('pickup magnet grants real ammo and heals without exceeding full health', () => {
  const s = new Simulation(4); isolate(s); s.player.hp = 95; s.pickups = [{ x: 91, y: 91, kind: 'ammo', life: 10 }, { x: 91, y: 91, kind: 'health', life: 10 }];
  s.update(1 / 60); assert.equal(s.player.reserve, 44); assert.equal(s.player.hp, 100); assert.equal(s.pickups.length, 0);
});
test('district clear preserves baseline level, objective, cash and ammo rewards', () => {
  const s = new Simulation(5); isolate(s); s.player.obj = 11; s.player.hp = 60; const e = enemy(300, 90); e.hp = 0; s.kill(e);
  assert.equal(s.player.lvl, 2); assert.equal(s.player.goal, 15); assert.equal(s.player.obj, 0); assert.equal(s.player.cash, 240); assert.equal(s.player.reserve, 66); assert.equal(s.player.hp, 80);
  assert.ok(s.enemies.length > 0 && s.enemies.length <= SETTINGS.maxEnemies);
});
test('dash has cooldown and invulnerability; death restores signal without losing progression', () => {
  const s = new Simulation(6); isolate(s); s.update(1 / 60, { dash: true }); s.damagePlayer(30); assert.equal(s.player.hp, 100);
  advance(s, 0.3); s.hurtTimer = 0; s.player.hp = 1; s.player.lvl = 3; s.player.obj = 8; s.damagePlayer(10);
  assert.equal(s.player.hp, 100); assert.equal(s.player.cash, 60); assert.equal(s.player.lvl, 3); assert.equal(s.player.obj, 8); assert.equal(s.player.x, 90); assert.equal(s.signal, 1);
});
test('ranged and charging AI telegraph before attacking', () => {
  const s = new Simulation(7); isolate(s); const gun = enemy(380, 90, 'gunner'); gun.timer = 0; s.enemies = [gun];
  s.update(1 / 60); assert.equal(gun.phase, 'windup'); assert.equal(s.bullets.length, 0); advance(s, 0.7); assert.ok(s.bullets.some(b => b.hostile));
  const charge = enemy(300, 90, 'charger'); charge.timer = 0; s.enemies = [charge]; s.update(1 / 60); assert.equal(charge.phase, 'windup'); advance(s, 0.7); assert.equal(charge.phase, 'rush');
});
test('long deterministic combat is finite with bounded enemies, bullets, effects and drops', () => {
  const s = new Simulation(123); let maxMs = 0;
  for (let i = 0; i < 10800; i++) {
    const t = performance.now(); s.update(1 / 60, { mx: Math.sin(i / 350), my: -0.8, fire: true, dash: i % 150 === 0 }); maxMs = Math.max(maxMs, performance.now() - t); s.takeEvents();
    assert.ok(s.enemies.length <= SETTINGS.maxEnemies); assert.ok(s.bullets.length <= SETTINGS.maxBullets); assert.ok(s.particles.length <= SETTINGS.maxParticles); assert.ok(s.pickups.length <= 60);
    for (const v of Object.values(s.player)) assert.ok(Number.isFinite(v)); assert.equal(isSolid(s.player.x, s.player.y, SETTINGS.playerRadius), false);
  }
  console.log(`3-minute combat simulation: ${s.player.kills} kills; worst update ${maxMs.toFixed(1)}ms`);
});
