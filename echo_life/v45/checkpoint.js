import { exportPuzzle, restorePuzzle } from './puzzles.js';
import { isSolid } from '../v42/world.js';
import { Checkpoint as Legacy } from '../v44/checkpoint.js';
const KEY='echo-life-v45-run',MAX=65536;
const finite=(v,a,b)=>Number.isFinite(v)&&v>=a&&v<=b,integer=(v,a,b)=>Number.isInteger(v)&&finite(v,a,b);
export function checksum(text){let hash=2166136261;for(let i=0;i<text.length;i++)hash=Math.imul(hash^text.charCodeAt(i),16777619);return (hash>>>0).toString(16);}
const ids=(a,max=256)=>Array.isArray(a)?[...new Set(a.filter(n=>integer(n,0,10000)))].slice(-max):[];
export class Checkpoint {
 constructor(storage){if(storage===undefined){try{storage=globalThis.localStorage;}catch{}}this.storage=storage;this.status='No save yet';this.legacy=new Legacy(storage);}
 decode(raw){try{if(typeof raw!=='string'||raw.length>MAX)return null;const env=JSON.parse(raw);if(typeof env.payload!=='string'||checksum(env.payload)!==env.checksum)return null;const d=JSON.parse(env.payload),p=d.player;
  if(d.version!==45||!integer(d.relays,0,10000)||!p||!finite(p.x,-1e7,1e7)||!finite(p.y,-1e7,1e7)||isSolid(p.x,p.y,15))return null;
  for(const[k,a,b]of [['hp',1,100],['shield',0,71]])if(!finite(p[k],a,b))return null;
  for(const[k,max]of [['cash',1e8],['mag',24],['reserve',1e7],['kills',1e7]])if(!integer(p[k],0,max))return null;
  if(!integer(d.score,0,1e10)||!finite(d.time,0,1e8)||!integer(d.weaponIndex,0,2)||!integer(d.medkits,0,5))return null;
  for(const k of ['damage','shield','speed','dash','magnet'])if(!integer(d.upgrades?.[k],0,3))return null;return d;
 }catch{return null;}}
 read(){try{const main=this.decode(this.storage?.getItem(KEY));if(main)return main;const backup=this.decode(this.storage?.getItem(KEY+'-backup'));if(backup){this.status='Recovered backup';return backup;}return null;}catch{return null;}}
 encode(sim){let puzzle=sim.relay.solved?null:exportPuzzle(sim.relay.puzzle);if(puzzle){while(JSON.stringify(puzzle).length>36000&&(puzzle.history.length||puzzle.redo.length)){if(puzzle.history.length)puzzle.history.shift();else puzzle.redo.shift();}}
  const payload=JSON.stringify({version:45,relays:sim.relays,player:{...sim.player,vx:0,vy:0},score:sim.score,time:sim.time,weaponIndex:sim.weaponIndex,medkits:sim.medkits,upgrades:sim.upgrades,restored:sim.restored.slice(-24),journal:sim.journal.slice(-24),puzzle,relics:sim.relics,stashes:sim.stashes,visited:sim.visited,achievements:sim.achievements,completedTypes:sim.completedTypes,walked:sim.walked,stars:sim.stars,fountainReady:sim.fountainReady});
  const raw=JSON.stringify({payload,checksum:checksum(payload)});if(new TextEncoder().encode(raw).length>MAX)throw Error('Save exceeds limit');return raw;
 }
 save(sim){try{const raw=this.encode(sim),old=this.storage?.getItem(KEY);if(this.decode(old))this.storage?.setItem(KEY+'-backup',old);if(!this.storage)throw Error('Storage unavailable');this.storage.setItem(KEY,raw);this.status='Progress saved';return true;}catch{this.status='Save unavailable — export your run';return false;}}
 apply(sim,d){sim.reset();sim.relays=d.relays;for(const k of ['x','y','hp','cash','mag','reserve','kills','shield'])sim.player[k]=d.player[k];sim.weaponIndex=d.weaponIndex;sim.player.mag=Math.min(sim.player.mag,sim.weapon.magazine);sim.upgrades={...d.upgrades};sim.player.maxShield=35+12*sim.upgrades.shield;sim.player.shield=Math.min(sim.player.shield,sim.player.maxShield);sim.player.obj=d.relays%3;sim.player.lvl=1+Math.floor(d.relays/3);sim.player.goal=3;sim.score=d.score;sim.time=d.time;sim.medkits=d.medkits;sim.makeRelay();sim.relay.puzzle=restorePuzzle(d.relays,d.puzzle);
  sim.restored=Array.isArray(d.restored)?d.restored.filter(p=>p&&finite(p.x,-1e7,1e7)&&finite(p.y,-1e7,1e7)&&!isSolid(p.x,p.y,15)).slice(-24):[];
  sim.journal=Array.isArray(d.journal)?d.journal.filter(e=>e&&integer(e.relay,1,10000)&&typeof e.district==='string'&&e.district.length<80&&typeof e.note==='string'&&e.note.length<250&&typeof e.type==='string').map(e=>({...e,stars:integer(e.stars,1,3)?e.stars:1})).slice(-24):[];
  for(const k of ['relics','stashes','visited'])sim[k]=ids(d[k],k==='visited'?128:256);
  sim.achievements=Array.isArray(d.achievements)?d.achievements.filter(v=>typeof v==='string'&&v.length<30).slice(-16):[];sim.completedTypes=Array.isArray(d.completedTypes)?d.completedTypes.filter(v=>typeof v==='string'&&v.length<20).slice(-10):[];
  sim.walked=finite(d.walked,0,1e10)?d.walked:0;sim.stars=integer(d.stars,0,30000)?d.stars:0;sim.fountainReady=finite(d.fountainReady,0,1e8)?d.fountainReady:0;
  sim.enemies=[];sim.bullets=[];sim.hurtTimer=2;sim.updateDistrict();this.status='Run restored';return true;
 }
 restore(sim){const d=this.read();return d?this.apply(sim,d):false;}
 import(raw,sim){const d=this.decode(raw);if(!d){this.status='Invalid save file';return false;}this.apply(sim,d);this.save(sim);return true;}
 migrate(sim){if(!this.legacy.restore(sim))return false;sim.makeRelay();sim.relics=[];sim.stashes=[];sim.visited=[];sim.achievements=[];sim.completedTypes=[];sim.walked=0;sim.stars=0;sim.fountainReady=0;sim.updateDistrict();this.save(sim);return true;}
 clear(){try{this.storage?.removeItem(KEY);this.storage?.removeItem(KEY+'-backup');this.status='New run';}catch{}}
}
