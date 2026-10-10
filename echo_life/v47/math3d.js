export const sub=(a,b)=>a.map((v,i)=>v-b[i]);
export const dot=(a,b)=>a.reduce((s,v,i)=>s+v*b[i],0);
export const cross=(a,b)=>[a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]];
export const unit=a=>{const n=Math.hypot(...a);return n?a.map(v=>v/n):[0,0,0];};
export function basis(eye,target){const forward=unit(sub(target,eye)),right=unit(cross(forward,[0,1,0])),up=cross(right,forward);return{forward,right,up};}
export function view(eye,target){const{forward:f,right:r,up:u}=basis(eye,target);return new Float32Array([r[0],u[0],-f[0],0,r[1],u[1],-f[1],0,r[2],u[2],-f[2],0,-dot(r,eye),-dot(u,eye),dot(f,eye),1]);}
export function perspective(fov,aspect,near=10,far=5500){const f=1/Math.tan(fov/2),n=1/(near-far);return new Float32Array([f/aspect,0,0,0,0,f,0,0,0,0,(far+near)*n,-1,0,0,2*far*near*n,0]);}
export function multiply(a,b){const m=new Float32Array(16);for(let c=0;c<4;c++)for(let r=0;r<4;r++)for(let k=0;k<4;k++)m[c*4+r]+=a[k*4+r]*b[c*4+k];return m;}
export function project(point,eye,target,fov,width,height){const b=basis(eye,target),d=sub(point,eye),z=dot(d,b.forward),f=1/Math.tan(fov/2);if(z<=10)return null;return{x:width/2+dot(d,b.right)*f*height/2/z,y:height/2-dot(d,b.up)*f*height/2/z,depth:z};}
export function groundPoint(x,y,eye,target,fov,width,height){const b=basis(eye,target),t=Math.tan(fov/2),sx=(x-width/2)*2/height*t,sy=-(y-height/2)*2/height*t,ray=b.forward.map((v,i)=>v+b.right[i]*sx+b.up[i]*sy);if(ray[1]>=-.001)return null;const distance=-eye[1]/ray[1];if(distance<0||distance>8000)return null;return{x:eye[0]+ray[0]*distance,y:eye[2]+ray[2]*distance};}
export const visibleTiles=(x,y,radius=2)=>{const out=[];for(let a=-radius;a<=radius;a++)for(let b=-radius;b<=radius;b++)out.push([Math.floor(x/640)+a,Math.floor(y/640)+b]);return out;};
