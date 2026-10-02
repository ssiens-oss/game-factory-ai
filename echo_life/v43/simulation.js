import { Simulation as Combat } from '../v42/simulation.js';
import { distance } from '../v42/config.js';
import { createPuzzle, act, hint } from './puzzles.js';
export class Simulation extends Combat {
  reset() { super.reset(); this.player.goal = 3; this.player.obj = 0; this.restored = []; this.relays = 0; this.nextPatrol = 12; this.makeRelay(); }
  populate(count) { for(let i=0;i<Math.min(4,count);i++){this.nextPatrol=0;this.spawn();} }
  spawn() { if (this.enemies.length >= 6 || (this.nextPatrol && this.time < this.nextPatrol)) return; super.spawn(); this.nextPatrol = this.time + 12; }
  makeRelay() { this.relay = { x: 250 + this.relays * 320, y: 90, puzzle: createPuzzle(this.relays), solved: false }; }
  get canInteract() { return distance(this.player, this.relay) <= 100; }
  solveAction(index) {
    if (!this.canInteract || this.relay.solved) return false;
    const solved = act(this.relay.puzzle, index);
    if (solved) {
      this.relay.solved = true; this.restored.push({x:this.relay.x,y:this.relay.y}); this.restored=this.restored.slice(-24); this.relays++; const p = this.player;
      p.obj++; p.cash += 100; p.reserve += 24; p.hp = Math.min(100, p.hp + 25); p.shield = p.maxShield; this.score += 500;
      if (p.obj === p.goal) { p.obj = 0; p.lvl++; p.cash += 120; }
      this.emit('level', 'RELAY RESTORED · +100¢ / +24 ROUNDS / +25 HEALTH');
    }
    return solved;
  }
  nextRelay() { if (this.relay.solved) this.makeRelay(); }
  puzzleHint() { return hint(this.relay.puzzle); }
  kill(enemy) { const p = this.player, obj = p.obj, goal = p.goal; p.goal = Infinity; super.kill(enemy); p.obj = obj; p.goal = goal; }
  updateEnemies(dt) {
    const all = this.enemies;
    this.enemies = all.filter(e => distance(e, this.player) < 300 && distance(e, this.relay) > 180);
    super.updateEnemies(dt); this.enemies = all;
  }
  damagePlayer(amount) { if (this.relay && distance(this.player, this.relay) < 180) return; super.damagePlayer(amount); }
}
