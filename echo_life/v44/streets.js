import { DISTRICTS } from './simulation.js';
// Small cached street sprites; tile iteration is limited to the visible camera bounds.
export class Streets {
 constructor(){this.lamps=new Map();this.garden=this.makeGarden();}
 makeGarden(){const c=document.createElement('canvas');c.width=96;c.height=96;const g=c.getContext('2d');
  g.fillStyle='#06131a80';g.beginPath();g.ellipse(50,67,35,15,0,0,Math.PI*2);g.fill();
  g.fillStyle='#1d383c';g.fillRect(16,31,60,40);g.fillStyle='#486260';g.fillRect(16,29,60,7);
  for(let i=0;i<13;i++){const x=27+(i*17)%41,y=24+(i*11)%24;g.fillStyle=['#385e4a','#56866a','#7fa880'][i%3];g.beginPath();g.arc(x,y,7+(i%4),0,Math.PI*2);g.fill();}
  g.fillStyle='#f3b4ba';for(let i=0;i<5;i++)g.fillRect(26+i*9,25+(i%2)*10,3,3);return c;
 }
 lamp(color){if(this.lamps.has(color))return this.lamps.get(color);const c=document.createElement('canvas');c.width=160;c.height=180;const g=c.getContext('2d');
  const glow=g.createRadialGradient(80,55,2,80,55,72);glow.addColorStop(0,color+'45');glow.addColorStop(1,color+'00');g.fillStyle=glow;g.fillRect(0,0,160,160);
  g.fillStyle='#04151b88';g.beginPath();g.ellipse(86,145,25,8,0,0,Math.PI*2);g.fill();g.fillStyle='#597172';g.fillRect(78,61,5,80);g.fillStyle='#17343a';g.fillRect(75,64,3,77);
  g.fillStyle='#2e4b50';g.fillRect(67,42,27,23);g.strokeStyle=color;g.lineWidth=2;g.strokeRect(67,42,27,23);g.fillStyle=color;g.fillRect(71,45,19,16);
  g.globalAlpha=.25;g.beginPath();g.ellipse(80,149,32,9,0,0,Math.PI*2);g.fill();this.lamps.set(color,c);return c;
 }
 draw(renderer,sim){const {g,dpr,scale,width,height,camera}=renderer,b=renderer.bounds();g.save();g.setTransform(dpr,0,0,dpr,0,0);g.translate(width/2,height/2);g.scale(scale,scale);g.translate(-camera.x,-camera.y);
  let budget=0;for(let tx=Math.floor(b.left/640);tx<=Math.floor(b.right/640);tx++)for(let ty=Math.floor(b.top/640);ty<=Math.floor(b.bottom/640);ty++){
   if(++budget>50)continue;const x=tx*640,y=ty*640,color=DISTRICTS[((tx+ty)%4+4)%4].color;
   g.drawImage(this.lamp(color),x+82,y+26);g.drawImage(this.garden,x+115,y+220);g.drawImage(this.garden,x+115,y+480);
   g.fillStyle='#415858';g.fillRect(x+145,y+360,37,7);g.fillStyle='#182e32';g.fillRect(x+149,y+367,4,10);g.fillRect(x+176,y+367,4,10);
   // Wet pavement reflections and readable block signage.
   g.globalAlpha=.16;g.fillStyle=color;for(let i=0;i<5;i++)g.fillRect(x+160-i*4,y+175+i*7,20+i*8,2);g.globalAlpha=1;
   g.fillStyle='#15323aa8';g.fillRect(x+24,y+145,116,27);g.strokeStyle=color+'66';g.strokeRect(x+24,y+145,116,27);g.fillStyle=color;g.font='9px monospace';g.textAlign='left';g.fillText(DISTRICTS[((tx+ty)%4+4)%4].name,x+30,y+161);
  }g.restore();
 }
}
