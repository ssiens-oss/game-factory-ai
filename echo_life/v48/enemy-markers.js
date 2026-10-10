import {project} from '../v47/math3d.js';
export const ENEMY_NAMES={stalker:'SCOUT',gunner:'GUNNER',charger:'RUSHER',boss:'WARDEN'};
export function markerPosition(p,width,height,taken=[]){
 const portrait=width<560&&height>width,top=portrait?300:height<500?210:150,bottom=height-(height<500?85:115),clampX=x=>Math.max(45,Math.min(width-45,x)),clampY=y=>Math.max(top,Math.min(bottom,y));let x=clampX(p.x),y=clampY(p.y);
 const cameraBottom=portrait?330:height<500?235:275;if(x>width-110&&y<cameraBottom)y=clampY(cameraBottom);
 const options=[[x,y]];for(let i=1;i<=6;i++)options.push([x,clampY(y+i*18)],[x,clampY(y-i*18)]);for(const dx of[-80,80,-160,160])options.push([clampX(x+dx),y]);
 const pos=options.find(([a,b])=>taken.every(q=>Math.abs(a-q.x)>=75||Math.abs(b-q.y)>=17))||options[0];return{x:pos[0],y:pos[1]};
}
export class EnemyMarkers{
 constructor(){this.nodes=new Map();}
 update(s,r){const container=document.getElementById('enemy-markers');if(!container)return;const live=new Set(),positions=[];for(const e of s.enemies){if(e.hp<=0)continue;live.add(e.id);let node=this.nodes.get(e.id);if(!node){node=document.createElement('span');node.className='enemy-marker';node.dataset.enemy=e.id;container.append(node);this.nodes.set(e.id,node);}const p=project([e.x,78,e.y],r.eye,r.target,r.fov,r.width,r.height);node.hidden=!p;if(!p)continue;
  const {x,y}=markerPosition(p,r.width,r.height,positions);positions.push({x,y});node.style.left=x+'px';node.style.top=y+'px';node.classList.toggle('edge',Math.abs(x-p.x)>20||Math.abs(y-p.y)>20);node.classList.toggle('warning',e.phase==='windup'||e.phase==='rush');node.dataset.type=e.type;node.textContent=(e.spawnIn>0?'◇ ':e.phase==='windup'?'! ':node.classList.contains('edge')?(Math.abs(p.x-x)>Math.abs(p.y-y)?p.x<x?'← ':'→ ':p.y<y?'↑ ':'↓ '):'')+ENEMY_NAMES[e.type];
 }
 for(const[id,node]of this.nodes)if(!live.has(id)){node.remove();this.nodes.delete(id);}
 }
}
