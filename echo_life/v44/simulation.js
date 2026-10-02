import { Simulation as Exploration } from '../v43/simulation.js';
import { createPuzzle, act, hint, undo } from './puzzles.js';
export const DISTRICTS=[{name:'LANTERN MARKET',color:'#ffcf8c',note:'The market lights return. A vendor left tea on the counter.'},{name:'GLASS GARDENS',color:'#92f3c2',note:'The greenhouse pumps wake. Rain no longer falls on empty soil.'},{name:'BLUE LINE',color:'#9dcfff',note:'A station board lights up: the first train is coming home.'},{name:'MEMORY QUARTER',color:'#e2aaff',note:'Windows glow again. Somewhere upstairs, a radio starts playing.'}];
export function relayPosition(n){const block=Math.floor(n/3)*640;return [{x:block+250,y:block+90},{x:block+570,y:block+90},{x:block+650,y:block+410}][n%3];}
export class Simulation extends Exploration {
 reset(){super.reset();this.journal=[];}
 makeRelay(){this.relay={...relayPosition(this.relays),puzzle:createPuzzle(this.relays),solved:false};}
 get districtInfo(){return DISTRICTS[Math.floor(this.relays/3)%DISTRICTS.length];}
 solveAction(i){
  if(!this.canInteract||this.relay.solved)return false;
  const d=this.districtInfo;
  if(!act(this.relay.puzzle,i))return false;
  this.relay.solved=true;this.restored.push({x:this.relay.x,y:this.relay.y});this.restored=this.restored.slice(-24);this.relays++;
  const p=this.player;p.obj++;p.cash+=100;p.reserve+=24;p.hp=Math.min(100,p.hp+25);p.shield=p.maxShield;this.score+=500;
  this.journal.push({relay:this.relays,district:d.name,note:d.note,type:this.relay.puzzle.type});this.journal=this.journal.slice(-12);
  if(p.obj===p.goal){p.obj=0;p.lvl++;p.cash+=120;}
  this.emit('level','RELAY RESTORED · +100¢ / +24 ROUNDS / +25 HEALTH');return true;
 }
 puzzleHint(){return hint(this.relay.puzzle);}
 undoPuzzle(){return !this.relay.solved&&undo(this.relay.puzzle);}
 resetPuzzle(){if(!this.relay.solved)this.relay.puzzle=createPuzzle(this.relays);}
}
