import test from 'node:test';
import assert from 'node:assert/strict';
import { Simulation } from '../../echo_life/v42/simulation.js';
import { WEAPONS, interceptAngle } from '../../echo_life/v42/weapons.js';
import { Profile } from '../../echo_life/v42/storage.js';
import { SETTINGS } from '../../echo_life/v42/config.js';
import { isSolid } from '../../echo_life/v42/world.js';
const advance = (s, seconds, input = {}) => { for (let i = 0; i < Math.round(seconds * 60); i++) s.update(1 / 60, input); };
const isolated = seed => { const s = new Simulation(seed || 42); s.enemies = []; s.barrels = []; s.spawnTimer = 10000; return s; };
const enemy = (x, y, id = 999, type = 'stalker') => ({ id, x, y, hp: 100, maxHp: 100, type, a: 0, timer: 100, plan: 100, path: [], speed: 0, phase: 'hunt', charge: 0, flash: 0, side: 1, spawnIn: 0, vx: 0, vy: 0 });

test('weapon switching conserves rounds and reloads to the selected capacity', () => {
  const s = isolated(); const total = s.player.mag + s.player.reserve; s.switchWeapon(); assert.equal(s.weapon.id, 'scatter'); advance(s, 1.5);
  assert.equal(s.player.mag, 8); assert.equal(s.player.mag + s.player.reserve, total);
  s.switchWeapon(); advance(s, 1.3); assert.equal(s.weapon.id, 'lance'); assert.equal(s.player.mag, 12); assert.equal(s.player.mag + s.player.reserve, total);
});
test('shotgun produces six damaging pellets while consuming one shell', () => {
  const s = isolated(); s.random = () => 0.5; s.weaponIndex = 1; s.player.mag = 8; s.enemies = [enemy(190, 90)]; s.shoot(0);
  assert.equal(s.bullets.length, 6); assert.equal(s.player.mag, 7); advance(s, 0.2); assert.equal(s.enemies[0].hp, 22);
});
test('lance pierces three enemies without repeatedly damaging one actor', () => {
  const s = isolated(); s.random = () => 0.5; s.weaponIndex = 2; s.enemies = [enemy(190, 90, 1), enemy(280, 90, 2), enemy(370, 90, 3)]; s.shoot(0); advance(s, 0.25);
  assert.deepEqual(s.enemies.map(e => e.hp), [42, 42, 42]); assert.equal(s.bullets.length, 0);
});
test('interception leads lateral motion and sticky auto-aim resists small target changes', () => {
  assert.ok(interceptAngle({ x: 0, y: 0 }, { x: 300, y: 0, vx: 0, vy: 200 }, 1000) > 0.15);
  const s = isolated(), lock = enemy(300, 90, 1), closer = enemy(260, 90, 2); s.target = lock; s.enemies = [lock, closer]; assert.equal(s.nearest(), lock);
  lock.hp = 0; assert.equal(s.nearest(), closer);
});
test('critical shots increase damage and distant hits use range falloff', () => {
  const close = isolated(), far = isolated(), critical = isolated(); close.random = far.random = () => 0.5; critical.random = () => 0;
  close.enemies = [enemy(190, 90)]; far.enemies = [enemy(700, 90)]; critical.enemies = [enemy(190, 90)];
  for (const s of [close, far, critical]) { s.shoot(0); advance(s, 0.65); }
  assert.ok(far.enemies[0].hp > close.enemies[0].hp); assert.ok(critical.enemies[0].hp < close.enemies[0].hp); assert.ok(close.labels.length > 0);
});
test('impact knockback respects buildings and emits a transient hit marker', () => {
  const s = isolated(); s.random = () => 0.5; const e = enemy(190, 90); s.enemies = [e]; s.shoot(0); advance(s, 0.15); assert.ok(e.x > 190); assert.ok(s.hitConfirm > 0); assert.equal(isSolid(e.x, e.y, 17), false);
});
test('shield absorbs damage, breaks visibly and regenerates only after its delay', () => {
  const s = isolated(); s.damagePlayer(20); assert.equal(s.player.hp, 100); assert.equal(s.player.shield, 15);
  advance(s, 1); assert.equal(s.player.shield, 15); s.hurtTimer = 0; s.damagePlayer(25); assert.equal(s.player.shield, 0); assert.equal(s.player.hp, 90); assert.ok(s.takeEvents().some(e => e.kind === 'shield'));
  advance(s, 4.5); assert.ok(s.player.shield > 0 && s.player.shield < 5); advance(s, 10); assert.equal(s.player.shield, s.player.maxShield);
});
test('medkits heal with bounded inventory and cooldown', () => {
  const s = isolated(); assert.equal(s.useMedkit(), false); s.player.hp = 40; assert.equal(s.useMedkit(), true); assert.equal(s.player.hp, 75); assert.equal(s.medkits, 0);
  s.medkits = 2; assert.equal(s.useMedkit(), false); advance(s, 12.1); assert.equal(s.useMedkit(), true); assert.equal(s.player.hp, 100);
});
test('chain kills increase score and credits, then expire', () => {
  const s = isolated(); for (let i = 0; i < 3; i++) { const e = enemy(500, 90, i); e.hp = 0; s.kill(e); }
  assert.equal(s.score, 400); assert.equal(s.player.cash, 165); assert.equal(s.combo, 3); advance(s, 3.6); assert.equal(s.combo, 0);
});
test('upgrade costs, rank caps, shielding and faster movement are real', () => {
  const s = isolated(); s.player.cash = 2000;
  for (let i = 0; i < 3; i++) assert.equal(s.buy('damage'), true); assert.equal(s.buy('damage'), false); assert.equal(s.buy('unknown'), false);
  assert.equal(s.buy('shield'), true); assert.equal(s.player.maxShield, 47); assert.equal(s.buy('speed'), true); assert.equal(s.buy('dash'), true); assert.equal(s.buy('magnet'), true);
  const plain = isolated(); advance(plain, 0.4, { my: -1 }); advance(s, 0.4, { my: -1 }); assert.ok(s.player.y < plain.player.y);
  s.update(1 / 60, { dash: true }); assert.ok(s.dashCooldown < SETTINGS.dashCooldown);
});
test('elite spawn and milestone Warden retain correct health and respawn magazine capacity', () => {
  const s = isolated(); s.player.lvl = 2; s.random = () => 0; s.spawn(); assert.equal(s.enemies[0].elite, true); assert.equal(s.enemies[0].hp, s.enemies[0].maxHp);
  s.enemies = []; s.player.obj = s.player.goal - 1; const e = enemy(500, 90); e.hp = 0; s.kill(e); const boss = s.enemies.find(e => e.type === 'boss'); assert.ok(boss && boss.hp >= 600);
  s.weaponIndex = 1; s.player.hp = 1; s.player.shield = 0; s.hurtTimer = 0; s.damagePlayer(10); assert.equal(s.player.mag, WEAPONS[1].magazine); assert.equal(s.player.shield, s.player.maxShield);
});
test('boss telegraphs a five-shot fan and enrages below 40 percent health', () => {
  const s = isolated(), boss = enemy(350, 90, 2, 'boss'); boss.hp = boss.maxHp = 700; boss.speed = 72; boss.timer = 0; s.enemies = [boss];
  s.update(1 / 60); assert.equal(boss.phase, 'windup'); advance(s, 0.8); assert.equal(s.bullets.filter(b => b.hostile).length, 5);
  boss.phase = 'hunt'; boss.timer = 100; boss.x = 350; const before = boss.x; s.update(1 / 60); const normal = before - boss.x;
  boss.x = 350; boss.hp = 200; s.update(1 / 60); assert.ok(350 - boss.x > normal * 1.4);
});
test('spawn warning delays attacks, and broken sightlines cancel gunner windups', () => {
  const s = isolated(), e = enemy(350, 90); e.spawnIn = 0.9; e.speed = 100; s.enemies = [e]; advance(s, 0.5); assert.equal(e.x, 350); advance(s, 0.6); assert.ok(e.x < 350);
  const gunner = enemy(450, 300, 2, 'gunner'); gunner.phase = 'windup'; gunner.charge = 0.01; s.enemies = [gunner]; s.player.x = 180; s.player.y = 300; s.update(1 / 60); assert.equal(gunner.phase, 'hunt'); assert.equal(s.bullets.length, 0);
});
test('only one blocked pursuit can plan a path per simulation tick', () => {
  const s = isolated(); s.enemies = [enemy(620, 300, 1), enemy(620, 400, 2), enemy(620, 500, 3)]; for (const e of s.enemies) e.plan = 0;
  s.update(1 / 60); assert.equal(s.enemies.filter(e => e.plan > 0).length, 1); s.update(1 / 60); assert.equal(s.enemies.filter(e => e.plan > 0).length, 2);
});
test('fuel cells chain detonate, cause splash damage and award each kill once', () => {
  const s = isolated(); s.barrels = [{ x: 164, y: 330, hp: 45 }, { x: 164, y: 380, hp: 45 }]; const e = enemy(164, 420); e.hp = 65; s.enemies = [e]; s.explode(s.barrels[0]);
  assert.equal(s.barrels.filter(b => b.hp > 0).length, 0); assert.equal(s.explosions.length, 2); assert.equal(s.player.kills, 1); assert.ok(s.particles.length > 0);
});
test('profile persists best score and settings, survives corrupt and denied storage', () => {
  const storage = { value: '', getItem() { return this.value; }, setItem(k, value) { this.value = value; } };
  const a = new Profile(storage); a.settings.leftHanded = true; a.settings.zoom = 1.2; a.save(500); a.save(10); const b = new Profile(storage);
  assert.equal(b.best, 500); assert.equal(b.settings.leftHanded, true); assert.equal(b.settings.zoom, 1.2);
  storage.value = '{broken'; assert.equal(new Profile(storage).best, 0);
  const denied = new Profile({ getItem() { throw Error('blocked'); }, setItem() { throw Error('blocked'); } }); assert.doesNotThrow(() => denied.save(100));
});
test('three-minute mixed-weapon combat keeps all simulation resources finite and bounded', () => {
  const s = new Simulation(17);
  for (let i = 0; i < 10800; i++) {
    s.update(1 / 60, { mx: Math.sin(i / 420), my: -0.8, fire: true, weapon: i % 600 === 0, heal: i % 700 === 0, dash: i % 160 === 0 }); s.takeEvents();
    assert.ok(s.enemies.length <= SETTINGS.maxEnemies); assert.ok(s.bullets.length <= SETTINGS.maxBullets); assert.ok(s.particles.length <= SETTINGS.maxParticles); assert.ok(s.labels.length <= 40); assert.ok(s.barrels.length <= 40); assert.ok(s.visitedTiles.size <= 120); assert.ok(s.explosions.length <= 12);
    for (const n of Object.values(s.player)) assert.ok(Number.isFinite(n)); assert.equal(isSolid(s.player.x, s.player.y, SETTINGS.playerRadius), false);
  }
  console.log(`v42 stress: ${s.player.kills} kills / ${s.score} score / level ${s.player.lvl}`);
});
