import { Streets } from './streets.js';
import { Renderer as City } from '../v42/renderer.js';
export class Renderer extends City {
  constructor(canvas){super(canvas);this.streets=new Streets();}
  draw(sim, dt, active) {
    super.draw(sim, dt, active); this.streets.draw(this,sim); const g=this.g, r=sim.relay;
    const x=(r.x-this.camera.x)*this.scale+this.width/2, y=(r.y-this.camera.y)*this.scale+this.height/2;
    g.save(); g.setTransform(this.dpr,0,0,this.dpr,0,0);
    // Holographic console and restored signal network, bounded to 24 relays.
    const t=this.low?0:sim.time;
    for(let i=0;i<sim.restored.length;i++) {
      const node=sim.restored[i], nx=(node.x-this.camera.x)*this.scale+this.width/2, ny=(node.y-this.camera.y)*this.scale+this.height/2;
      if(nx < -400 || nx > this.width+400) continue;
      const next=sim.restored[i+1] || sim.relay;
      const ex=(next.x-this.camera.x)*this.scale+this.width/2,ey=(next.y-this.camera.y)*this.scale+this.height/2;
      const corner=next.y>node.y && next.x-node.x<100 ? {x:ex,y:ny} : {x:nx,y:ey};
      g.strokeStyle=sim.districtInfo.color+'88';g.lineWidth=2;g.beginPath();g.moveTo(nx,ny+32);g.lineTo(corner.x,corner.y+32);g.lineTo(ex,ey+32);g.stroke();
      const points=[{x:nx,y:ny+32},{x:corner.x,y:corner.y+32},{x:ex,y:ey+32}],l1=Math.hypot(points[1].x-nx,points[1].y-ny-32),l2=Math.hypot(ex-points[1].x,ey+32-points[1].y),len=l1+l2;
      g.fillStyle='#d2ffe7';if(len>0)for(let j=0;j<3;j++){const dist=(t*80+j*len/3)%len,a=dist<l1?points[0]:points[1],z=dist<l1?points[1]:points[2],f=dist<l1?dist/(l1||1):(dist-l1)/(l2||1);g.fillRect(a.x+(z.x-a.x)*f-2,a.y+(z.y-a.y)*f-2,4,4);}
      g.fillStyle='#7cf5bf'; g.fillRect(nx-6,ny-6,12,12);
    }
    const glow=g.createRadialGradient(x,y,2,x,y,85); glow.addColorStop(0,'#67ffcf45');glow.addColorStop(1,'#67ffcf00');g.fillStyle=glow;g.fillRect(x-85,y-85,170,170);
    g.fillStyle='#020d17aa';g.beginPath();g.ellipse(x+4,y+14,30,13,0,0,Math.PI*2);g.fill();
    g.fillStyle='#284c51';g.beginPath();g.moveTo(x-18,y+3);g.lineTo(x,y+13);g.lineTo(x+18,y+3);g.lineTo(x+18,y+16);g.lineTo(x,y+26);g.lineTo(x-18,y+16);g.closePath();g.fill();
    g.strokeStyle='#9cffe0';g.fillStyle='#18363c';g.lineWidth=2;g.beginPath();g.moveTo(x-18,y+3);g.lineTo(x,y-7);g.lineTo(x+18,y+3);g.lineTo(x,y+13);g.closePath();g.fill();g.stroke();
    g.strokeStyle='#79f8d98c';g.lineWidth=1.5;g.beginPath();g.ellipse(x,y-18,32,12,0,t*.6,t*.6+Math.PI*1.6);g.stroke();
    g.beginPath();g.ellipse(x,y-28,24,8,0,-t*.8,-t*.8+Math.PI*1.5);g.stroke();
    g.setLineDash([3,5]);g.strokeStyle='#83ffd544';g.beginPath();g.moveTo(x-14,y-24);g.lineTo(x-14,y);g.moveTo(x+14,y-24);g.lineTo(x+14,y);g.stroke();g.setLineDash([]);
    g.strokeStyle='#86ffe0'; g.fillStyle='#153d3970'; g.lineWidth=2;
    g.beginPath(); g.arc(x,y,Math.max(12,26*this.scale),0,Math.PI*2); g.fill(); g.stroke();
    g.font='bold 14px monospace'; g.textAlign='center'; g.fillStyle='#b9ffe8'; g.fillText('◇',x,y-18);
    g.font='11px monospace'; g.fillText(r.solved?'RESTORED':'RELAY '+(sim.relays+1)+' / '+r.puzzle.type.toUpperCase(),x,y-48);
    if (!sim.canInteract) {
      const a=Math.atan2(y-this.height/2,x-this.width/2), cx=this.width/2+Math.cos(a)*Math.min(130,this.width*.3), cy=this.height/2+Math.sin(a)*90;
      g.fillText('◇ '+Math.round(Math.hypot(r.x-sim.player.x,r.y-sim.player.y))+'m',cx,cy);
    }
    g.restore();
  }
}
