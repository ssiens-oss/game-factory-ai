const TAU=Math.PI*2;
function dot(g,x,y,r,c){g.fillStyle=c;g.beginPath();g.arc(x,y,r,0,TAU);g.fill();}
function body(g,x,y,color){g.fillStyle='#06121b99';g.beginPath();g.ellipse(x+2,y+10,15,6,0,0,TAU);g.fill();g.fillStyle=color;g.fillRect(x-7,y-5,14,18);dot(g,x,y-10,7,'#b9c4ae');g.fillStyle='#253c42';g.fillRect(x-8,y+12,6,8);g.fillRect(x+2,y+12,6,8);}
export class Scene {
 draw(renderer,sim){const {g,dpr,width:w,height:h,scale,camera}=renderer,t=renderer.low?0:sim.time,b=renderer.bounds(),color=sim.districtInfo.color;
  g.save();g.setTransform(dpr,0,0,dpr,0,0);g.translate(w/2,h/2);g.scale(scale,scale);g.translate(-camera.x,-camera.y);
  let count=0;for(let x=Math.floor(b.left/640);x<=Math.floor(b.right/640);x++)for(let y=Math.floor(b.top/640);y<=Math.floor(b.bottom/640);y++){
   if(++count>32)continue;const ox=x*640,oy=y*640;
   // Fabric banners and colourful shop awnings sit against the existing city geometry.
   g.fillStyle=color+'85';g.beginPath();g.moveTo(ox+205,oy+197);g.lineTo(ox+300,oy+197);g.lineTo(ox+291,oy+211);g.lineTo(ox+205,oy+211);g.closePath();g.fill();
   g.strokeStyle='#647c77';g.lineWidth=1;g.beginPath();g.moveTo(ox+210,oy+182);g.lineTo(ox+390,oy+182);g.stroke();for(let i=0;i<5;i++){g.fillStyle=i%2?color+'b0':'#93cab39f';g.beginPath();g.moveTo(ox+218+i*32,oy+182);g.lineTo(ox+234+i*32,oy+182);g.lineTo(ox+226+i*32,oy+201+Math.sin(t+i)*2);g.closePath();g.fill();}
   // Street mural, neon reflection and canopy shadow.
   g.fillStyle='#09192370';g.fillRect(ox+195,oy+200,125,19);g.strokeStyle=color+'66';g.lineWidth=3;g.beginPath();g.arc(ox+420,oy+402,12,0,TAU);g.stroke();g.fillStyle='#accfcf';g.font='8px monospace';g.fillText('REMEMBER / RECONNECT',ox+440,oy+404);
   g.fillStyle=color+'16';g.beginPath();g.ellipse(ox+150,oy+119,35,8,0,0,TAU);g.fill();for(let i=0;i<4;i++)g.fillRect(ox+130+i*2,oy+115+i*4,30-i*3,1);
   const restored=sim.restored.some(r=>Math.abs(r.x-(ox+320))<800&&Math.abs(r.y-(oy+320))<800);
   if(restored){for(let i=0;i<6;i++){g.fillStyle=i%2?color+'70':'#ffe7bd7f';g.fillRect(ox+234+i%3*32,oy+245+Math.floor(i/3)*27,12,16);}}
   g.fillStyle='#203d45';g.fillRect(ox+408,oy+191,130,18);g.fillStyle=color;g.font='9px monospace';g.fillText(['HOME IS A SIGNAL','FOLLOW THE LIGHT','THE CITY REMEMBERS'][Math.floor(t/6)%3],ox+414,oy+204);
   g.fillStyle=color+'38';for(let i=0;i<3;i++)g.fillRect(ox+20+i*25,oy+130,14,3);
   const tram=ox+((t*32+Math.abs(y)*83)%640);g.fillStyle='#07151b90';g.fillRect(tram-30,oy+105,66,10);g.fillStyle='#436a73';g.fillRect(tram-28,oy+72,62,26);g.fillStyle='#a3d7d577';g.fillRect(tram-21,oy+76,48,9);g.fillStyle='#f0d699';g.fillRect(tram+28,oy+79,4,5);
   if(!renderer.low&&((x+y)%4+4)%4===1)for(let i=0;i<6;i++)dot(g,ox+155+Math.sin(t*.7+i)*28,oy+270+i*32+Math.cos(t+i)*12,1.5,'#c9ef9b85');
  }
  for(const s of sim.sites){if(s.kind==='relic'&&sim.relics.includes(s.id)||s.kind==='stash'&&sim.stashes.includes(s.id))continue;
   if(s.kind==='fountain'){
    g.fillStyle='#0a1722a0';g.beginPath();g.ellipse(s.x+3,s.y+11,32,13,0,0,TAU);g.fill();g.fillStyle='#446269';g.beginPath();g.ellipse(s.x,s.y,27,15,0,0,TAU);g.fill();g.fillStyle='#70cbe07a';g.beginPath();g.ellipse(s.x,s.y-3,23,10,0,0,TAU);g.fill();g.strokeStyle='#bbf3ecaa';g.lineWidth=2;for(let i=0;i<3;i++){g.beginPath();g.moveTo(s.x-9+i*9,s.y-3);g.quadraticCurveTo(s.x-9+i*9+Math.sin(t+i)*4,s.y-33,s.x-7+i*7,s.y-5);g.stroke();}
   }else if(s.kind==='resident'){body(g,s.x,s.y,['#bc9975','#8aa58a','#9c95b5'][Math.floor(sim.relays/3)%3]);g.fillStyle='#ecddd1';g.font='9px monospace';g.fillText(['MARA','IVO','SERA'][Math.floor(sim.relays/3)%3],s.x-12,s.y-26);}
   else{dot(g,s.x,s.y,14,'#7bffe52a');g.save();g.translate(s.x,s.y-3+Math.sin(t*2)*3);g.rotate(s.kind==='relic'?Math.PI/4:0);g.fillStyle=s.kind==='relic'?'#b9a9ff':'#eac783';g.fillRect(-6,-6,12,12);g.strokeStyle='#e6fff5';g.strokeRect(-6,-6,12,12);g.restore();}
  }
  const r=sim.relay;g.strokeStyle=color+'66';g.lineWidth=2;g.beginPath();g.arc(r.x,r.y,42+Math.sin(t*2)*4,0,TAU);g.stroke();
  if(sim.restoreFlash>0){g.globalAlpha=sim.restoreFlash/1.8;g.strokeStyle='#cffff0';g.lineWidth=5;g.beginPath();g.moveTo(r.x,r.y);g.lineTo(r.x,r.y-180);g.stroke();if(!renderer.low)for(let i=0;i<18;i++)dot(g,r.x+Math.sin(i*2.1)*70*(1.8-sim.restoreFlash),r.y-20-i*4+Math.cos(i)*30*(1.8-sim.restoreFlash),2,i%2?'#edc789':'#8df4c6');g.globalAlpha=1;}
  // One ambient overlay and two fog strips: no expanding particle pool.
  g.restore();g.save();g.setTransform(dpr,0,0,dpr,0,0);g.fillStyle=`rgba(239,190,130,${.015+.018*(1+Math.sin(t/90))})`;g.fillRect(0,0,w,h);
  if(!renderer.low){g.fillStyle='#9adbd906';for(let i=0;i<2;i++)g.fillRect(((t*7+i*w*.5)% (w+300))-300,h*.35+i*90,300,28);}
  g.restore();
 }
}
