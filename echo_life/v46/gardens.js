// Static streetscape is cached once per district. Animated accents stay bounded.
const TAU=Math.PI*2;
const ellipse=(g,x,y,rx,ry,c)=>{g.fillStyle=c;g.beginPath();g.ellipse(x,y,rx,ry,0,0,TAU);g.fill();};
function streetTile(color){const canvas=document.createElement('canvas');canvas.width=640;canvas.height=640;const g=canvas.getContext('2d');
 // Cafe terrace: layered umbrellas, chairs and a warm table light.
 for(let i=0;i<2;i++){const x=390+i*68,y=151;ellipse(g,x+5,y+10,26,8,'#030e1680');g.fillStyle='#5c7168';g.fillRect(x-2,y-16,4,25);ellipse(g,x,y-18,26,13,color+'99');g.strokeStyle='#d7dbbb88';g.lineWidth=1;g.beginPath();g.moveTo(x-25,y-18);g.lineTo(x+25,y-18);g.moveTo(x,y-30);g.lineTo(x,y-6);g.stroke();ellipse(g,x,y+2,13,6,'#c2a578');for(const dx of [-21,17]){g.fillStyle='#44655b';g.fillRect(x+dx,y-2,8,10);}ellipse(g,x,y,2,2,'#ffe3ac');}
 // Raised community beds, brick rims, individually shaded leaves and flowers.
 for(let i=0;i<3;i++){const x=145,y=250+i*68;g.fillStyle='#071a1e77';g.fillRect(x-19,y+7,42,33);g.fillStyle='#6b6351';g.fillRect(x-22,y-10,42,37);g.fillStyle='#293c31';g.fillRect(x-18,y-7,34,28);for(let k=0;k<6;k++){ellipse(g,x-10+k%3*10,y+k%2*10,7,4,k%2?'#648861':'#3f6858');ellipse(g,x-10+k%3*10,y-2+k%2*10,2,2,['#e8b39d','#ddd09c','#bfacd8'][i]);}}
 // Bicycle silhouettes beside a metal rack.
 g.strokeStyle='#728f86';g.lineWidth=2;for(let i=0;i<3;i++){const x=228+i*25,y=155;g.beginPath();g.arc(x-7,y,7,0,TAU);g.arc(x+9,y,7,0,TAU);g.moveTo(x-7,y);g.lineTo(x,y-10);g.lineTo(x+9,y);g.lineTo(x-7,y);g.moveTo(x,y-10);g.lineTo(x+10,y-12);g.stroke();}g.strokeStyle='#b9cdbe66';g.strokeRect(214,161,86,5);
 // Pavement inset, drain grates, benches, newspaper kiosk and tactile crossing.
 g.fillStyle='#7c9e9333';g.fillRect(340,125,60,4);g.fillStyle='#0b1b2199';g.fillRect(350,113,24,7);g.strokeStyle='#728c7c';g.lineWidth=1;for(let i=0;i<6;i++){g.beginPath();g.moveTo(352+i*4,113);g.lineTo(352+i*4,120);g.stroke();}
 for(let j=0;j<2;j++){const x=440+j*62,y=135;g.fillStyle='#050f1677';g.fillRect(x,y+10,43,5);g.fillStyle='#8d7e63';for(let k=0;k<3;k++)g.fillRect(x,y+k*3,40,2);g.fillStyle='#446158';g.fillRect(x+3,y+8,3,6);g.fillRect(x+34,y+8,3,6);}
 g.fillStyle='#35565b';g.fillRect(510,146,26,27);g.fillStyle=color+'aa';g.fillRect(507,140,32,7);g.fillStyle='#e1dbc088';g.fillRect(514,151,17,12);g.fillStyle='#264842';g.font='5px monospace';g.fillText('ECHO',515,159);
 g.fillStyle='#c6b58a55';for(let i=0;i<6;i++)for(let j=0;j<2;j++)ellipse(g,27+i*5,147+j*5,1,1,'#c6b58a55');
 // Rooftop vents and panels remain inside the original building footprint.
 g.fillStyle='#0b1d2577';g.fillRect(330,257,50,27);g.fillStyle='#4f737b';g.fillRect(326,252,50,27);g.strokeStyle='#91c2cd66';for(let i=1;i<5;i++){g.beginPath();g.moveTo(326+i*10,252);g.lineTo(326+i*10,279);g.stroke();}g.beginPath();g.moveTo(326,265);g.lineTo(376,265);g.stroke();g.fillStyle='#6e8380';g.fillRect(401,260,19,14);g.fillStyle='#13282c';for(let i=0;i<3;i++)g.fillRect(404,263+i*3,13,1);
 // Hand-painted mosaic pavement medallion.
 for(let i=0;i<8;i++){const a=i*TAU/8;ellipse(g,550+Math.cos(a)*12,127+Math.sin(a)*5,3,2,i%2?color+'88':'#d9c59b88');}
 return canvas;
}
export class Gardens{
 constructor(){this.tiles=new Map();this.drawn=0;}
 draw(r,s){const {g,dpr,scale,camera,width,height}=r,b=r.bounds(),color=s.districtInfo.color;let tile=this.tiles.get(color);if(!tile){tile=streetTile(color);if(this.tiles.size>=4)this.tiles.delete(this.tiles.keys().next().value);this.tiles.set(color,tile);}this.drawn=0;
  g.save();g.setTransform(dpr,0,0,dpr,0,0);g.translate(width/2,height/2);g.scale(scale,scale);g.translate(-camera.x,-camera.y);
  for(let x=Math.floor(b.left/640);x<=Math.floor(b.right/640);x++)for(let y=Math.floor(b.top/640);y<=Math.floor(b.bottom/640);y++){if(this.drawn>=24)continue;this.drawn++;g.drawImage(tile,x*640,y*640);if(!r.low){const t=s.time;g.strokeStyle='#b2e7cf55';g.lineWidth=1;for(let i=0;i<2;i++){const px=x*640+330+i*60,py=y*640+145;g.beginPath();g.arc(px,py,((t*8+i*7)%18)+2,0,TAU);g.stroke();}for(let i=0;i<3;i++){const a=t*.5+i*2;ellipse(g,x*640+145+Math.sin(a)*26,y*640+245+i*68+Math.cos(a)*9,2,1,'#e5bc8c88');}}}
  g.restore();
 }
}
