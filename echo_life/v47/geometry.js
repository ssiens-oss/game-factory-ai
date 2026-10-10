// Batches opaque meshes into a single draw; no external renderer or CDN.
export function rgb(hex){const s=hex.replace('#','');return[0,2,4].map(i=>parseInt(s.slice(i,i+2),16)/255);}
export class Mesh {
 constructor(){this.data=[];this.boxes=0;}
 vertex(p,n,c){this.data.push(...p,...n,...c);}
 quad(a,b,c,d,n,color){for(const p of [a,b,c,a,c,d])this.vertex(p,n,color);}
 box(x,y,z,w,h,d,color){this.boxes++;const c=typeof color==='string'?rgb(color):color,l=x-w/2,r=x+w/2,b=y,t=y+h,n=z-d/2,f=z+d/2;
 this.quad([l,t,n],[l,t,f],[r,t,f],[r,t,n],[0,1,0],c);
 this.quad([l,b,f],[l,t,f],[l,t,n],[l,b,n],[-1,0,0],c);
 this.quad([r,b,n],[r,t,n],[r,t,f],[r,b,f],[1,0,0],c);
 this.quad([r,b,f],[r,t,f],[l,t,f],[l,b,f],[0,0,1],c);
 this.quad([l,b,n],[l,t,n],[r,t,n],[r,b,n],[0,0,-1],c);
 }
 pyramid(x,y,z,w,h,d,color){const c=rgb(color),top=[x,y+h,z],a=[x-w/2,y,z-d/2],b=[x+w/2,y,z-d/2],e=[x+w/2,y,z+d/2],f=[x-w/2,y,z+d/2];for(const[p,q,n]of [[a,b,[0,.6,-.8]],[b,e,[.8,.6,0]],[e,f,[0,.6,.8]],[f,a,[-.8,.6,0]]])for(const v of[p,q,top])this.vertex(v,n,c);}
 array(){return new Float32Array(this.data);}
}
