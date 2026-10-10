import { Simulation as Exploration,DISTRICTS,relayPosition,TROPHIES } from '../v46/simulation.js';
import { Simulation as Combat } from '../v42/simulation.js';
import { isSolid,clearLine,moveBody } from '../v42/world.js';
import { distance } from '../v42/config.js';
export {DISTRICTS,relayPosition,TROPHIES};
export const ENEMY_TYPES=['stalker','gunner','charger'];
const SAFE=180;
export class Simulation extends Exploration{
 // Populate only after the exploration relay and all reset fields exist.
 populate(){}
 reset(){super.reset();this.calm=false;this.spawnSerial=0;this.nextPatrol=0;this.enemies=[];this.ensurePatrols();}
 setCalm(value){const changed=this.calm!==!!value;this.calm=!!value;if(this.calm){this.enemies=[];this.bullets=this.bullets.filter(b=>!b.hostile);}else if(changed||!this.enemies.length)this.ensurePatrols();}
 ensurePatrols(){if(this.calm)return;for(let i=this.enemies.length;i<3;i++)this.spawn(true);}
 spawn(force=false){if(this.calm||!this.relay||this.enemies.length>=6||!force&&this.time<this.nextPatrol)return false;
  const p=this.player;let point;const preferred=[[-260,0],[0,-280],[0,300],[320,0],[-340,0],[0,-400]];
  for(let i=0;i<80;i++){const offset=i<preferred.length?preferred[(i+this.spawnSerial)%preferred.length]:[Math.cos(i*2.399)*this.randomBetween(240,420),Math.sin(i*2.399)*this.randomBetween(240,420)];const q={x:p.x+offset[0],y:p.y+offset[1]};if(!isSolid(q.x,q.y,20)&&distance(q,this.relay)>SAFE+40&&clearLine(p,q,4)&&this.enemies.every(e=>distance(e,q)>55)){point=q;break;}}
  if(!point){this.nextPatrol=this.time+2;return false;}
  const serial=this.spawnSerial++,type=this.relays>=6&&serial%8===7?'boss':ENEMY_TYPES[serial%3],hp=type==='boss'?220:type==='charger'?95:type==='gunner'?68:62;
  this.enemies.push({id:this.nextId++, ...point,type,hp,maxHp:hp,a:0,speed:type==='boss'?55:type==='charger'?86:type==='gunner'?63:74,timer:1.5,plan:0,path:[],flash:0,phase:'hunt',charge:0,side:serial%2?1:-1,spawnIn:1.2,elite:this.relays>=3&&serial%5===4,vx:0,vy:0,patrolOrigin:{...point},patrolAngle:serial%2?Math.PI/2:0,patrolTime:0});
  const e=this.enemies.at(-1);if(e.elite){e.maxHp=Math.round(e.maxHp*1.35);e.hp=e.maxHp;e.speed*=1.08;}this.nextPatrol=this.time+14;return true;
 }
 updateEnemies(dt){const all=this.enemies,p=this.player,safe=distance(p,this.relay)<SAFE;
  const fighting=[];for(const e of all){if(e.hp<=0)continue;if(distance(e,p)>1400){e.hp=0;continue;}
   if(safe||distance(e,this.relay)<SAFE+15){e.spawnIn=Math.max(0,e.spawnIn-dt);e.phase='patrol';e.charge=0;e.flash=Math.max(0,e.flash-dt);e.patrolTime=(e.patrolTime||0)+dt;
    if(e.patrolTime>3){e.patrolTime=0;e.patrolAngle=(e.patrolAngle||0)+Math.PI;}
    let a=e.patrolAngle||0;if(distance(e,this.relay)<SAFE+35)a=Math.atan2(e.y-this.relay.y,e.x-this.relay.x);
    const x=e.x,y=e.y;moveBody(e,Math.cos(a)*25*dt,Math.sin(a)*25*dt,17);if(distance(e,this.relay)<SAFE){e.x=x;e.y=y;e.patrolAngle=a+Math.PI;}e.vx=(e.x-x)/dt;e.vy=(e.y-y)/dt;e.a=a;
   }else if(distance(e,p)<900){if(e.phase==='patrol'){e.phase='hunt';e.timer=1.2;}fighting.push(e);}
  }
  const signal=this.signal;this.enemies=fighting;Combat.prototype.updateEnemies.call(this,dt);if(this.signal===signal)this.enemies=all;else this.ensurePatrols();
 }
 update(dt,input){if(!this.calm&&!this.enemies.some(e=>e.hp>0))this.ensurePatrols();super.update(dt,input);}
 get encounterInfo(){if(this.calm)return 'PEACEFUL / ENEMIES OFF';const count=this.enemies.filter(e=>e.hp>0).length;return `${count} PATROLS · ${distance(this.player,this.relay)<SAFE?'SAFE RELAY ZONE':'STREETS ACTIVE'}`;}
}
