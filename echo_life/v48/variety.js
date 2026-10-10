import { Mesh } from '../v47/geometry.js';
export const THEMES=[
 {name:'MARKET',wall:['#695951','#785e50','#686552','#72544b'],pavement:'#595c52',accent:'#efc281'},
 {name:'GARDENS',wall:['#3e6a60','#517d68','#537a77','#5e806f'],pavement:'#425e53',accent:'#a8e1be'},
 {name:'STATION',wall:['#435d72','#526578','#4c6273','#647584'],pavement:'#485968',accent:'#a7cee5'},
 {name:'MEMORY',wall:['#695b78','#725d75','#685c72','#7b6b80'],pavement:'#5b5466',accent:'#d9b6ec'}
];
export const themeFor=(x,y)=>THEMES[((x+y)%4+4)%4];
export function districtDetails(tx,ty){const m=new Mesh(),ox=tx*640,oz=ty*640,theme=themeFor(tx,ty),kind=THEMES.indexOf(theme);
 if(kind===0){for(let i=0;i<3;i++){const x=ox+250+i*65,z=oz+185;m.box(x,6,z,45,18,16,'#907556');m.box(x,24,z,43,3,20,'#d1b085');m.box(x,26,z,37,4,13,['#cd896f','#b3c78a','#d9bca2'][i]);for(const dx of[-23,23])m.box(x+dx,6,z,3,38,3,'#b8ac86');m.pyramid(x,43,z,52,10,27,theme.accent);}}
 if(kind===1){for(let i=0;i<3;i++){const x=ox+340+i*65,z=oz+184;m.box(x,6,z,40,9,22,'#8f9d7b');for(let j=0;j<3;j++){m.box(x-12+j*12,15,z,3,15,3,'#92b58a');m.pyramid(x-12+j*12,22,z,14,12,14,theme.accent);}}m.pyramid(ox+490,84,oz+280,120,45,95,'#91b8bd');}
 if(kind===2){m.box(ox+350,6,oz+179,80,45,17,'#536878');m.box(ox+350,52,oz+179,84,8,22,theme.accent);m.box(ox+350,20,oz+168,50,24,3,'#9ebcbd');for(let i=0;i<5;i++)m.box(ox+326+i*12,25,oz+166,7,4,2,'#e9c883');for(let i=0;i<7;i++)m.box(ox+470+i*13,6,oz+175,3,22,3,'#a4b8b2');m.box(ox+509,28,oz+175,80,3,3,'#a4b8b2');}
 if(kind===3){m.box(ox+340,6,oz+175,36,48,20,'#725b68');m.box(ox+340,54,oz+175,40,4,24,theme.accent);m.box(ox+340,27,oz+163,25,20,2,'#b9ccb2');m.box(ox+340,37,oz+161,2,8,2,'#465560');m.box(ox+346,36,oz+160,13,2,2,'#465560');for(let i=0;i<3;i++)m.box(ox+425+i*45,6,oz+177,28,36,18,['#a08a93','#977f95','#a99487'][i]);}
 return m.array();
}
export function ambient(sim,low){const m=new Mesh(),t=low?0:sim.time,tx=Math.floor(sim.player.x/640),ty=Math.floor(sim.player.y/640);
 for(let x=tx-1;x<=tx+1;x++)for(let y=ty-1;y<=ty+1;y++){const ox=x*640,oz=y*640;
  // Trams and service carts are decorative and keep to the road's opposite lane.
  const z=oz+((t*20+(x-y)*93)%640+640)%640;m.box(ox+40,3,z,26,20,55,'#729b99');m.box(ox+40,24,z,24,3,53,'#c2d2bf');m.box(ox+40,13,z-29,20,9,2,'#c4decd');
  for(let i=0;i<2;i++){const px=ox+160,py=oz+100+i*50+Math.sin(t*.35+i)*14;m.box(px,7,py,8,14,8,'#b6a98d');m.box(px,21,py,7,7,7,'#e0cfaf');}
 }
 return m.array();
}
