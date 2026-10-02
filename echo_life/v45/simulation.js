import { Simulation as City, DISTRICTS, relayPosition } from '../v44/simulation.js';
import { distance } from '../v42/config.js';
import { createPuzzle, act, undo, redo, nextHint } from './puzzles.js';
export { DISTRICTS, relayPosition };
export const TROPHIES=[
 {id:'first',name:'First light',detail:'Restore one relay',test:s=>s.relays>=1},
 {id:'district',name:'Neighbourhood keeper',detail:'Restore three relays',test:s=>s.relays>=3},
 {id:'ten',name:'City of ten signals',detail:'Restore ten relays',test:s=>s.relays>=10},
 {id:'collector',name:'Memory collector',detail:'Find three relics',test:s=>s.relics.length>=3},
 {id:'walker',name:'Street wanderer',detail:'Walk 100 metres',test:s=>s.walked>=3200},
 {id:'variety',name:'Circuit polymath',detail:'Solve five different puzzle families',test:s=>new Set(s.completedTypes).size>=5},
 {id:'pacifist',name:'Quiet restoration',detail:'Restore five relays with no eliminations',test:s=>s.relays>=5&&s.player.kills===0},
 {id:'star',name:'Signal artisan',detail:'Earn a three-star relay',test:s=>s.journal.some(e=>e.stars===3)}
];
const memories={pipes:'Power returns beneath the pavement.',lights:'Windows shine through the rain.',order:'A message says: we are still here.',tune:'An old radio finds a familiar song.',slide:'The delivery board shows the way home.',pairs:'Someone remembered every face.',balance:'Water flows evenly through the gardens.',mosaic:'The mural’s colours tell a story again.',lock:'A forgotten door opens onto sunlight.',maze:'The lost signal finds its station.'};
export class Simulation extends City {
 reset(){super.reset();Object.assign(this,{relics:[],stashes:[],visited:[],achievements:[],completedTypes:[],walked:0,stars:0,fountainReady:0,calm:true,restoreFlash:0,lastDistrict:null,lastInteraction:''});this.updateDistrict();}
 makeRelay(){this.relay={...relayPosition(this.relays),puzzle:createPuzzle(this.relays),solved:false};}
 get sites(){const r=this.relay,n=this.relay.puzzle.number;return [{kind:'relic',id:n,x:r.x+60,y:r.y},{kind:'stash',id:n,x:r.x+40,y:r.y-55},{kind:'fountain',id:n,x:r.x,y:r.y+65},{kind:'resident',id:n,x:r.x,y:r.y-65}];}
 updateDistrict(){const key=Math.floor(this.relays/3);if(!this.visited.includes(key))this.visited.push(key);this.visited=this.visited.slice(-128);if(this.lastDistrict!==key){this.lastDistrict=key;this.emit('level',this.districtInfo.name+' · SIGNALS RETURN');}}
 solveAction(i){if(!this.canInteract||this.relay.solved)return false;if(!act(this.relay.puzzle,i))return false;
  const p=this.player,districtName=this.districtInfo.name,type=this.relay.puzzle.type,stars=this.relay.puzzle.moves<=this.relay.puzzle.par?3:this.relay.puzzle.moves<=this.relay.puzzle.par*2?2:1;
  this.relay.solved=true;this.restored.push({x:this.relay.x,y:this.relay.y});this.restored=this.restored.slice(-24);this.relays++;this.completedTypes=[...new Set([...this.completedTypes,type])];this.stars+=stars;
  p.obj++;p.cash+=100;p.reserve+=24;p.hp=Math.min(100,p.hp+25);p.shield=p.maxShield;this.score+=500;
  this.journal.push({relay:this.relays,district:districtName,note:memories[type],type,stars,moves:this.relay.puzzle.moves,elapsed:this.relay.puzzle.elapsed});this.journal=this.journal.slice(-24);
  if(p.obj>=p.goal){p.obj=0;p.lvl++;p.cash+=120;}if(this.relays%10===0){p.cash+=200;this.emit('level','TEN SIGNALS · +200¢ RESTORATION GRANT');}
  this.restoreFlash=1.8;this.emit('level','RELAY RESTORED · '+ '★'.repeat(stars)+' · +100¢');this.updateDistrict();this.checkTrophies();return true;
 }
 checkTrophies(){for(const t of TROPHIES)if(!this.achievements.includes(t.id)&&t.test(this)){this.achievements.push(t.id);this.player.cash+=30;this.emit('level',t.name.toUpperCase()+' · +30¢');}}
 puzzleHint(){this.relay.puzzle.hints++;return nextHint(this.relay.puzzle);}
 undoPuzzle(){return !this.relay.solved&&undo(this.relay.puzzle);}
 redoPuzzle(){return !this.relay.solved&&redo(this.relay.puzzle);}
 resetPuzzle(){if(!this.relay.solved)this.relay.puzzle=createPuzzle(this.relays);}
 interactSite(kind){const site=this.sites.find(s=>s.kind===kind);if(!site||distance(site,this.player)>110)return false;
  if(kind==='relic'){if(this.relics.includes(site.id))return false;this.relics.push(site.id);this.relics=this.relics.slice(-256);this.score+=75;this.lastInteraction='MEMORY FRAGMENT · +75 SCORE';}
  if(kind==='stash'){if(this.stashes.includes(site.id))return false;this.stashes.push(site.id);this.stashes=this.stashes.slice(-256);this.player.cash+=35;this.lastInteraction='SUPPLY CACHE · +35¢';}
  if(kind==='fountain'){if(this.fountainReady>this.time||this.player.hp>=100)return false;this.player.hp=Math.min(100,this.player.hp+20);this.fountainReady=this.time+30;this.lastInteraction='GARDEN WATER · +20 HEALTH';}
  if(kind==='resident'){this.lastInteraction=['MARA: Follow the lanterns. The circuits still remember us.','IVO: The dials change together. Listen for their common note.','SERA: Every signal brings someone closer to home.'][Math.floor(this.relays/3)%3];}
  this.emit('pickup',this.lastInteraction);this.checkTrophies();return true;
 }
 travel(index){const p=this.restored[index];if(!p)return false;this.player.x=p.x;this.player.y=p.y;this.player.vx=this.player.vy=0;this.bullets=[];this.hurtTimer=2;this.emit('pickup','RETURNED TO RESTORED RELAY');return true;}
 update(dt,input){const x=this.player.x,y=this.player.y;if(this.calm){this.enemies=[];this.bullets=this.bullets.filter(b=>!b.hostile);this.nextPatrol=this.time+30;}super.update(dt,input);this.walked+=Math.hypot(this.player.x-x,this.player.y-y);this.restoreFlash=Math.max(0,this.restoreFlash-dt);if(Math.floor(this.time)!==Math.floor(this.time-dt))this.checkTrophies();}
}
