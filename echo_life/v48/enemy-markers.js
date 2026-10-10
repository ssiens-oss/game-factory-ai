import {project} from '../v47/math3d.js';
export const ENEMY_NAMES={stalker:'SCOUT',gunner:'GUNNER',charger:'RUSHER',boss:'WARDEN'};
export class EnemyMarkers{
 constructor(){this.nodes=new Map();}
 update(s,r){const container=document.getElementById('enemy-markers');if(!container)return;const live=new Set();for(const e of s.enemies){if(e.hp<=0)continue;live.add(e.id);let node=this.nodes.get(e.id);if(!node){node=document.createElement('span');node.className='enemy-marker';node.dataset.enemy=e.id;container.append(node);this.nodes.set(e.id,node);}const p=project([e.x,78,e.y],r.eye,r.target,r.fov,r.width,r.height);node.hidden=!p;if(!p)continue;
  const margin=45,top=r.width<560&&r.height>r.width?260:r.height<500?174:150,x=Math.max(margin,Math.min(r.width-margin,p.x)),y=Math.max(top,Math.min(r.height-(r.height<500?85:115),p.y));node.style.left=x+'px';node.style.top=y+'px';node.classList.toggle('edge',Math.abs(x-p.x)>20||Math.abs(y-p.y)>20);node.classList.toggle('warning',e.phase==='windup'||e.phase==='rush');node.dataset.type=e.type;node.textContent=(e.spawnIn>0?'◇ ':e.phase==='windup'?'! ':node.classList.contains('edge')?(Math.abs(p.x-x)>Math.abs(p.y-y)?p.x<x?'← ':'→ ':p.y<y?'↑ ':'↓ '):'')+ENEMY_NAMES[e.type];
 }
 for(const[id,node]of this.nodes)if(!live.has(id)){node.remove();this.nodes.delete(id);}
 }
}
