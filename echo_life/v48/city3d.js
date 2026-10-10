import { themeFor,districtDetails,ambient } from './variety.js';
import { Mesh } from '../v47/geometry.js';
import { buildings,tileSeed } from '../v42/world.js';
import { seeded } from '../v42/config.js';
export function cityTile(tx,ty){const m=new Mesh(),ox=tx*640,oz=ty*640,r=seeded(tileSeed(tx,ty)),theme=themeFor(tx,ty),colors=theme.wall;
 m.box(ox+320,-5,oz+320,640,5,640,'#172a31');m.box(ox+396,0,oz+396,472,6,472,theme.pavement);
 for(let i=0;i<8;i++){m.box(ox+80,1,oz+i*80+25,3,1,30,'#a39873');m.box(ox+i*80+25,1,oz+80,30,1,3,'#a39873');}
 for(let i=0;i<6;i++){m.box(ox+25+i*18,1,oz+170,10,1,34,'#a5b7ae');m.box(ox+170,1,oz+25+i*18,34,1,10,'#a5b7ae');}
 for(const b of buildings(tx,ty)){const height=65+Math.floor(r()*6)*23,c=colors[b.id],x=b.x+b.w/2,z=b.y+b.h/2;
  m.box(x,6,z,b.w,height,b.h,c);m.box(x,height+6,z,b.w+6,5,b.h+6,'#6b807e');m.box(x,height+11,z,b.w-12,2,b.h-12,'#334c50');if((tx+ty+b.id)%3===0)m.pyramid(x,height+13,z,b.w-18,28,b.h-18,theme.accent);
  m.box(x-28,height+13,z,45,5,35,'#355768');for(let i=0;i<4;i++)m.box(x-44+i*11,height+18,z,1,1,34,'#91caca');m.box(x+37,height+13,z+14,24,18,24,'#647774');
  for(let floor=0;floor<3;floor++)for(let col=0;col<4;col++){const lit=r()>.35?'#edcf94':'#456875';m.box(b.x+18+col*37,22+floor*25,b.y-1,19,13,2,lit);m.box(b.x-1,22+floor*25,b.y+18+col*37,2,13,19,lit);}
  m.box(x,7,b.y-3,28,28,3,'#1a343c');m.box(x,37,b.y-5,68,9,4,['#88e3c2','#d6b2e6','#e8be83','#8ecddb'][b.id]);
  m.box(x,43,b.y-11,78,3,26,'#778c71');m.pyramid(x,46,b.y-11,78,8,26,'#9fad85');
 }
 // Actual 3D trees, lamps, cafe tables and benches along the clear pavement.
 for(let i=0;i<4;i++){const x=ox+183,z=oz+235+i*95;m.box(x,6,z,8,38,8,'#7d7458');m.box(x,38,z,38,22,38,'#4e826d');m.pyramid(x,60,z,38,20,38,'#74a187');m.box(x,6,z,45,8,45,'#6d7160');}
 for(let i=0;i<3;i++){const x=ox+220+i*150,z=oz+175;m.box(x,6,z,4,65,4,'#90a7a0');m.box(x+8,68,z,20,5,10,'#e6daa5');m.box(x+8,6.1,z,35,1,30,'#6c796c');}
 for(let i=0;i<2;i++){const x=ox+440+i*75,z=oz+185;m.box(x,6,z,24,3,9,'#9c8c69');m.box(x-9,6,z,3,9,3,'#334d51');m.box(x+9,6,z,3,9,3,'#334d51');m.box(x,15,z+5,24,8,2,'#b2a580');}
 m.box(ox+340,6,oz+180,3,25,3,'#9bb3a4');m.box(ox+340,28,oz+180,28,3,28,'#baac84');m.pyramid(ox+340,31,oz+180,45,12,45,'#bcaf83');
 m.data.push(...districtDetails(tx,ty));return m.array();
}
export function actors(sim,low){const m=new Mesh(),t=low?0:sim.time;
 const person=(p,color,heading=0,armed=false)=>{m.box(p.x,.5,p.y,28,1,24,'#112a2b');const stride=Math.sin(t*9)*3*(Math.hypot(p.vx||0,p.vy||0)>10?1:0);m.box(p.x-6,1,p.y+stride,8,15,9,'#273f49');m.box(p.x+6,1,p.y-stride,8,15,9,'#273f49');m.box(p.x,15,p.y,21,22,15,color);m.box(p.x,37,p.y,14,13,14,'#bed6bb');m.box(p.x+Math.cos(heading)*9,39,p.y+Math.sin(heading)*9,5,5,5,'#a5ffe0');if(armed)m.rotatedBox(p.x+Math.cos(heading)*17,25,p.y+Math.sin(heading)*17,23,5,5,heading,'#879f9e');};
 person(sim.player,'#83b9a4',sim.player.a,true);for(const e of sim.enemies)if(e.hp>0){const color=e.flash>0?'#fff1d1':e.type==='gunner'?'#e9a268':e.type==='charger'?'#e27b9d':e.type==='boss'?'#aa9ad9':'#d89584';person(e,color,e.a,true);
  if(e.type==='stalker')m.pyramid(e.x,43,e.y,23,18,23,'#db857a');if(e.type==='gunner'){m.box(e.x,17,e.y-11,20,24,9,'#ab8557');m.rotatedBox(e.x+Math.cos(e.a)*24,28,e.y+Math.sin(e.a)*24,35,5,6,e.a,'#efc896');}if(e.type==='charger'){for(const d of[-17,17])m.pyramid(e.x+d,32,e.y,12,18,13,'#e99baa');}if(e.type==='boss'){m.box(e.x,15,e.y,38,30,28,'#8c78a8');m.pyramid(e.x,49,e.y,31,21,31,'#cfb4ef');}
  m.box(e.x,69,e.y,34,3,3,'#492d35');const width=32*Math.max(0,e.hp/e.maxHp);m.box(e.x-16+width/2,70,e.y,width,2,4,e.type==='boss'?'#d6baef':'#ffc4aa');if(e.spawnIn>0)m.box(e.x,1,e.y,43,1,43,'#c19b6d');
  if(e.phase==='windup'){const a=e.aim||e.a;m.rotatedBox(e.x+Math.cos(a)*58,1,e.y+Math.sin(a)*58,110,1,7,a,e.type==='charger'?'#e898b0':'#d7a16d');}
 }
 const r=sim.relay;m.box(r.x,1,r.y,40,9,40,'#517470');m.box(r.x,10,r.y,26,19,26,'#305556');m.pyramid(r.x,35+Math.sin(t*2)*3,r.y,26,20,26,'#9bf7d4');m.box(r.x,58,r.y,4,70,4,'#83ddbc');
 for(const s of sim.sites){if(s.kind==='resident')person(s,'#bea989');else if(s.kind==='fountain'){m.box(s.x,1,s.y,45,11,35,'#829791');m.box(s.x,12,s.y,36,1,26,'#77cde0');m.box(s.x,13,s.y,3,22,3,'#a2e5e7');}else if(!(s.kind==='relic'&&sim.relics.includes(s.id)||s.kind==='stash'&&sim.stashes.includes(s.id))){m.box(s.x,4+Math.sin(t*2)*3,s.y,12,12,12,s.kind==='relic'?'#c8b7f2':'#eed195');}}
 for(const p of sim.restored){m.box(p.x,1,p.y,22,8,22,'#5c8d75');m.box(p.x,9,p.y,8,12,8,'#b3f7bf');}
 for(const b of sim.bullets)m.box(b.x,24,b.y,5,4,5,b.hostile?'#ffa7a1':'#fff2b0');
 for(const p of sim.pickups)m.box(p.x,3,p.y,10,7,10,p.kind==='ammo'?'#edd496':'#b1d9b8');
 if(sim.muzzle>0)m.box(sim.player.x+Math.cos(sim.player.a)*28,26,sim.player.y+Math.sin(sim.player.a)*28,9,9,9,'#fff0b8');
 m.data.push(...ambient(sim,low));return m.array();
}
