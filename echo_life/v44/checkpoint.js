import { restorePuzzle } from './puzzles.js';
import { isSolid } from '../v42/world.js';
const KEY='echo-life-v44-run';
const bounded=(v,a,b)=>Number.isFinite(v)&&v>=a&&v<=b;
export class Checkpoint {
 constructor(storage){if(storage===undefined){try{storage=globalThis.localStorage;}catch{}}this.storage=storage;}
 read(){try{const d=JSON.parse(this.storage?.getItem(KEY)||'null');
  if(!d||d.version!==44||!Number.isInteger(d.relays)||!bounded(d.relays,0,10000)||!d.player||!bounded(d.player.x,-1e7,1e7)||!bounded(d.player.y,-1e7,1e7)||isSolid(d.player.x,d.player.y,15))return null;
  for(const [k,a,b] of [['hp',1,100],['cash',0,1e8],['mag',0,24],['reserve',0,1e7],['kills',0,1e7],['shield',0,71]])if(!bounded(d.player[k],a,b))return null;
  if(!bounded(d.score,0,1e10)||!bounded(d.time,0,1e8)||!Number.isInteger(d.weaponIndex)||!bounded(d.weaponIndex,0,2)||!Number.isInteger(d.medkits)||!bounded(d.medkits,0,5))return null;
  for(const k of ['damage','shield','speed','dash','magnet'])if(!Number.isInteger(d.upgrades?.[k])||!bounded(d.upgrades[k],0,3))return null;
  return d;
 }catch{return null;}}
 save(sim){
  // A solved panel checkpoints the next relay to prevent duplicate rewards on reload.
  const puzzle=sim.relay.solved?null:sim.relay.puzzle;
  const d={version:44,relays:sim.relays,player:{...sim.player,vx:0,vy:0},score:sim.score,time:sim.time,weaponIndex:sim.weaponIndex,medkits:sim.medkits,upgrades:{...sim.upgrades},restored:sim.restored.slice(-24),journal:sim.journal.slice(-12),puzzle:puzzle?{type:puzzle.type,cells:puzzle.cells,chosen:puzzle.chosen,moves:puzzle.moves}:null};
  try{this.storage?.setItem(KEY,JSON.stringify(d));return true;}catch{return false;}
 }
 restore(sim){const d=this.read();if(!d)return false;sim.reset();sim.relays=d.relays;
  for(const k of ['x','y','hp','cash','mag','reserve','kills','shield'])sim.player[k]=d.player[k];
  sim.player.obj=d.relays%3;sim.player.lvl=1+Math.floor(d.relays/3);sim.player.goal=3;sim.upgrades={...d.upgrades};sim.player.maxShield=35+12*sim.upgrades.shield;
  sim.score=d.score;sim.time=d.time;sim.weaponIndex=d.weaponIndex;sim.medkits=d.medkits;sim.makeRelay();sim.relay.puzzle=restorePuzzle(d.relays,d.puzzle);
  sim.restored=Array.isArray(d.restored)?d.restored.filter(p=>p && bounded(p.x,-1e7,1e7)&&bounded(p.y,-1e7,1e7)).slice(-24):[];
  sim.journal=Array.isArray(d.journal)?d.journal.filter(e=>e && Number.isInteger(e.relay)&&typeof e.district==='string'&&e.district.length<80&&typeof e.note==='string'&&e.note.length<250&&typeof e.type==='string').slice(-12):[];
  sim.enemies=[];sim.bullets=[];sim.nextPatrol=sim.time+12;sim.hurtTimer=2;return true;
 }
 clear(){try{this.storage?.removeItem(KEY);}catch{}}
}
