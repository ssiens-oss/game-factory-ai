import { createPuzzle as classic, act as classicAct, nextHint as classicHint, pipeGlyph, connected } from '../v44/puzzles.js';
import { seeded } from '../v42/config.js';
export { pipeGlyph, connected };
export const TYPES=['pipes','lights','order','tune','slide','pairs','balance','mosaic','lock','maze'];
export const META={
 pipes:{name:'Circuit routing',help:'Rotate pipes. Connect IN at middle-left to OUT at middle-right.',detail:'A current crosses a border only when both touching pipe ends are open. Paths can turn around the upper or lower rows.',color:'#8ceac1'},
 lights:{name:'Lights Out',help:'Switch every light OFF. Each tap flips this tile and its neighbours.',detail:'Only horizontal and vertical neighbours change. Diagonals do not. Tap a tile again to reverse that move.',color:'#efce7c'},
 order:{name:'Signal ordering',help:'Choose signals in the order described by the BEFORE clues.',detail:'Combine the three clues into one chain. A wrong four-signal chain resets your selections; undo is always available before completion.',color:'#cca6ef'},
 tune:{name:'Frequency dials',help:'Match the targets. A tap raises this dial AND the next one; 6 wraps to 0.',detail:'The rightmost dial also raises the first. Plan for their shared changes rather than tuning them independently.',color:'#8ccbea'},
 slide:{name:'Sliding tiles',help:'Tap a tile beside the blank. Arrange 1–8 in order, with the blank last.',detail:'Only a tile directly above, below, left or right of the blank can move. Every generated board is scrambled by legal moves.',color:'#e6ab82'},
 pairs:{name:'Memory pairs',help:'Reveal two cards. Match all four symbol pairs.',detail:'Unmatched cards stay visible until your next tap, so there is no timer. Matching pairs remain revealed. Hints identify the next matching card.',color:'#edadd0'},
 balance:{name:'Weighted balance',help:'Match the total. Taps cycle values 0–4; each dial has a different weight.',detail:'The displayed total is value × weight for each dial, added together. More than one correct combination may exist.',color:'#bdd38b'},
 mosaic:{name:'Signal mosaic',help:'Match the target pattern. A tap changes this tile AND its right neighbour.',detail:'Symbols cycle ○ → △ → □ → ○. The right edge wraps around within its own row. Colour and symbol both identify each state.',color:'#9bcfe7'},
 lock:{name:'Combination lock',help:'Use the sum clues to find three digits. Taps cycle digits 0–9.',detail:'From A+B, B+C and A+C, solve each digit. For example A = ((A+B)+(A+C)−(B+C))/2.',color:'#e5b674'},
 maze:{name:'Relay maze',help:'Move the signal to the star. Tap a neighbouring square through an open wall.',detail:'Bright borders are walls. The generated maze always has a route. Arrow keys can move the signal directly.',color:'#8fddca'}
};
const clone=v=>JSON.parse(JSON.stringify(v));
const neighbours=i=>[i-3,i+3,i%3?i-1:-1,i%3<2?i+1:-1].filter(j=>j>=0&&j<9);
const shuffle=(a,r)=>{for(let i=a.length-1;i>0;i--){const j=Math.floor(r()*(i+1));[a[i],a[j]]=[a[j],a[i]];}return a;};
export function createPuzzle(number){
 const type=TYPES[number%10],tier=Math.min(3,1+Math.floor(number/30)),random=seeded(number*3911+4501);
 let p;if(number%10<4){p=classic(Math.floor(number/10)*4+number%10);p.number=number;}else p={number,type,moves:0,solved:false,history:[]};
 Object.assign(p,{tier,redo:[],elapsed:0,hints:0});
 if(type==='slide'){
  p.cells=[1,2,3,4,5,6,7,8,0];p.trail=[];let previous=-1;
  for(let k=0;k<14+tier*6;k++){const blank=p.cells.indexOf(0),options=neighbours(blank).filter(j=>j!==previous),i=options[Math.floor(random()*options.length)];[p.cells[blank],p.cells[i]]=[p.cells[i],p.cells[blank]];p.trail.push(blank);previous=blank;}
  if(p.cells.every((v,i)=>v===(i+1)%9)){const blank=8;[p.cells[7],p.cells[8]]=[p.cells[8],p.cells[7]];p.trail.push(blank);}
 }else if(type==='pairs'){p.cells=shuffle([0,0,1,1,2,2,3,3],random);p.matched=[];p.revealed=[];}
 else if(type==='balance'){p.weights=[1,2,3];p.targets=Array.from({length:3},()=>Math.floor(random()*5));p.total=p.targets.reduce((sum,v,i)=>sum+v*p.weights[i],0);p.cells=[0,0,0];if(!p.total){p.targets[2]=3;p.total=9;}}
 else if(type==='mosaic'){p.targets=Array.from({length:9},()=>Math.floor(random()*3));p.cells=[...p.targets];for(let k=0;k<7+tier*3;k++)mosaic(p.cells,Math.floor(random()*9));if(p.cells.every((v,i)=>v===p.targets[i]))mosaic(p.cells,0);}
 else if(type==='lock'){p.targets=Array.from({length:3},()=>1+Math.floor(random()*8));p.cells=[0,0,0];p.clues=[`A + B = ${p.targets[0]+p.targets[1]}`,`B + C = ${p.targets[1]+p.targets[2]}`,`A + C = ${p.targets[0]+p.targets[2]}`];}
 else if(type==='maze'){
  p.cells=Array(16).fill(15);p.avatar=0;const seen=new Set([0]),stack=[0];
  while(stack.length){const i=stack.at(-1),options=mazeNeighbours(i).filter(([j])=>!seen.has(j));if(!options.length){stack.pop();continue;}const [j,out,back]=options[Math.floor(random()*options.length)];p.cells[i]&=~out;p.cells[j]&=~back;seen.add(j);stack.push(j);}
 }
 p.par={pipes:18,lights:8,order:4,tune:15,slide:36,pairs:12,balance:10,mosaic:18,lock:18,maze:24}[type]+(tier-1)*6;
 return p;
}
function mosaic(c,i){const j=Math.floor(i/3)*3+(i+1)%3;c[i]=(c[i]+1)%3;c[j]=(c[j]+1)%3;}
export function mazeNeighbours(i){return [[i-4,1,4],[i%4<3?i+1:-1,2,8],[i+4,4,1],[i%4?i-1:-1,8,2]].filter(([j])=>j>=0&&j<16);}
const fields=['cells','chosen','moves','matched','revealed','avatar','trail'];
export function state(p){const s={};for(const k of fields)if(p[k]!==undefined)s[k]=clone(p[k]);return s;}
function remember(p){p.history.push(state(p));if(p.history.length>50)p.history.shift();p.redo=[];}
export function canAct(p,i){const count=p.type==='order'?4:['tune','balance','lock'].includes(p.type)?3:p.cells?.length||0;
 if(p.solved||!Number.isInteger(i)||i<0||i>=count)return false;
 if(p.type==='slide')return p.trail.length<2048&&neighbours(p.cells.indexOf(0)).includes(i);
 if(p.type==='pairs')return !p.matched.includes(i)&&!(p.revealed.length<2&&p.revealed.includes(i));
 if(p.type==='maze')return mazeNeighbours(p.avatar).some(([j,out])=>j===i&&!(p.cells[p.avatar]&out));
 return !(p.type==='order'&&p.chosen.includes(i));
}
export function act(p,i){
 if(!canAct(p,i))return false;
 const before=state(p),oldHistory=p.history;
 if(TYPES.indexOf(p.type)<4){classicAct(p,i);p.history=oldHistory;p.history.splice(-1,1);p.history.push(before);if(p.history.length>50)p.history.shift();p.redo=[];return p.solved;}
 remember(p);p.moves++;
 if(p.type==='slide'){const blank=p.cells.indexOf(0);[p.cells[blank],p.cells[i]]=[p.cells[i],p.cells[blank]];if(p.trail.at(-1)===i)p.trail.pop();else p.trail.push(blank);p.solved=p.cells.every((v,j)=>v===(j+1)%9);}
 else if(p.type==='pairs'){if(p.revealed.length===2)p.revealed=[];p.revealed.push(i);if(p.revealed.length===2&&p.cells[p.revealed[0]]===p.cells[i]){p.matched.push(...p.revealed);p.revealed=[];}p.solved=p.matched.length===8;}
 else if(p.type==='balance'){p.cells[i]=(p.cells[i]+1)%5;p.solved=p.cells.reduce((sum,v,j)=>sum+v*p.weights[j],0)===p.total;}
 else if(p.type==='mosaic'){mosaic(p.cells,i);p.solved=p.cells.every((v,j)=>v===p.targets[j]);}
 else if(p.type==='lock'){p.cells[i]=(p.cells[i]+1)%10;p.solved=p.cells.every((v,j)=>v===p.targets[j]);}
 else if(p.type==='maze'){p.avatar=i;p.solved=i===15;}
 return p.solved;
}
export function undo(p){if(p.solved||!p.history.length)return false;p.redo.push(state(p));Object.assign(p,p.history.pop());return true;}
export function redo(p){if(p.solved||!p.redo.length)return false;p.history.push(state(p));Object.assign(p,p.redo.pop());return true;}
export function nextHint(p){
 if(p.solved)return {index:null,text:'Relay restored.'};
 if(TYPES.indexOf(p.type)<4)return classicHint(p);
 let index=null;
 if(p.type==='slide')index=p.trail.at(-1);
 else if(p.type==='pairs'){const visible=p.revealed.length===1?p.revealed[0]:null;index=p.cells.findIndex((v,i)=>!p.matched.includes(i)&&i!==visible&&(visible===null||v===p.cells[visible]));}
 else if(p.type==='balance'){let goal;for(let a=0;a<5&&!goal;a++)for(let b=0;b<5&&!goal;b++)for(let c=0;c<5&&!goal;c++)if(a+2*b+3*c===p.total)goal=[a,b,c];index=p.cells.findIndex((v,i)=>v!==goal[i]);}
 else if(p.type==='lock')index=p.cells.findIndex((v,i)=>v!==p.targets[i]);
 else if(p.type==='mosaic'){
  for(let row=0;row<3&&index===null;row++){if(p.cells.slice(row*3,row*3+3).every((v,j)=>v===p.targets[row*3+j]))continue;
   for(let mask=1;mask<27;mask++){const cells=[...p.cells];let n=mask,first=null;for(let j=0;j<3;j++){const presses=n%3;n=Math.floor(n/3);if(presses&&first===null)first=row*3+j;for(let k=0;k<presses;k++)mosaic(cells,row*3+j);}if(cells.slice(row*3,row*3+3).every((v,j)=>v===p.targets[row*3+j])){index=first;break;}}
  }
 }else if(p.type==='maze'){
  const queue=[p.avatar],seen=new Set(queue),parents=new Map();for(const i of queue){if(i===15)break;for(const [j,out]of mazeNeighbours(i))if(!(p.cells[i]&out)&&!seen.has(j)){seen.add(j);parents.set(j,i);queue.push(j);}}
  let j=15;while(parents.has(j)&&parents.get(j)!==p.avatar)j=parents.get(j);index=j;
 }
 return {index,text:`Try tile ${index+1}. ${META[p.type].help}`};
}
export const progress=p=>{
 if(p.type==='pairs')return `${p.matched.length/2} / 4 pairs`;
 if(p.type==='maze')return `Square ${p.avatar+1} / goal 16`;
 if(p.type==='balance')return `TOTAL ${p.cells.reduce((s,v,i)=>s+v*p.weights[i],0)} / ${p.total}`;
 if(p.type==='lights')return `${p.cells.filter(v=>!v).length} / 9 lights off`;
 if(p.type==='order')return `${p.chosen.length} / 4 signals`;
 if(['tune','lock','mosaic'].includes(p.type))return `${p.cells.filter((v,i)=>v===p.targets[i]).length} / ${p.cells.length} aligned`;
 if(p.type==='slide')return `${p.cells.filter((v,i)=>v===(i+1)%9).length} / 9 in place`;
 return 'IN → OUT';
};
export function exportPuzzle(p){return{type:p.type,...state(p),elapsed:p.elapsed,hints:p.hints,history:p.history,redo:p.redo};}
// Stored state must match regenerated immutable rules and remain solvable.
export function restorePuzzle(number,data){
 const p=createPuzzle(number);if(!data||data.type!==p.type)return p;
 const legalState=s=>{
  if(!s||!Number.isInteger(s.moves)||s.moves<0||s.moves>100000)return false;
  if(p.type==='order')return Array.isArray(s.chosen)&&s.chosen.length<=3&&new Set(s.chosen).size===s.chosen.length&&s.chosen.every(v=>Number.isInteger(v)&&v>=0&&v<4);
  if(!Array.isArray(s.cells)||s.cells.length!==p.cells.length)return false;
  if(p.type==='lights')return s.cells.every(v=>typeof v==='boolean');
  if(!s.cells.every(v=>Number.isInteger(v)&&v>=0))return false;
  if(p.type==='pipes')return s.cells.every((v,i)=>{let m=p.solution[i];for(let k=0;k<4;k++){if(v===m)return true;m=((m<<1)&15)|(m>>3);}return false;});
  if(p.type==='slide'){
   if(new Set(s.cells).size!==9||s.cells.some(v=>v>8)||!Array.isArray(s.trail)||s.trail.length>2048)return false;
   const c=[...s.cells];for(const i of [...s.trail].reverse()){const b=c.indexOf(0);if(!neighbours(b).includes(i))return false;[c[b],c[i]]=[c[i],c[b]];}return c.every((v,i)=>v===(i+1)%9);
  }
  if(p.type==='pairs')return s.cells.every((v,i)=>v===p.cells[i])&&['matched','revealed'].every(k=>Array.isArray(s[k])&&new Set(s[k]).size===s[k].length&&s[k].every(v=>Number.isInteger(v)&&v>=0&&v<8))&&s.matched.length<=6&&s.matched.length%2===0&&s.revealed.length<=2&&s.revealed.every(v=>!s.matched.includes(v))&&s.matched.every((v,i)=>s.cells[v]===s.cells[s.matched[i^1]]);
  if(p.type==='maze')return s.cells.every((v,i)=>v===p.cells[i])&&Number.isInteger(s.avatar)&&s.avatar>=0&&s.avatar<15;
  return s.cells.every(v=>v<=(p.type==='lock'?9:p.type==='balance'?4:p.type==='mosaic'?2:6));
 };
 if(!legalState(data))return p;Object.assign(p,state(data));
 p.history=Array.isArray(data.history)?data.history.filter(legalState).slice(-50):[];p.redo=Array.isArray(data.redo)?data.redo.filter(legalState).slice(-50):[];
 p.elapsed=Number.isFinite(data.elapsed)?Math.max(0,Math.min(86400,data.elapsed)):0;p.hints=Number.isInteger(data.hints)?Math.max(0,Math.min(10000,data.hints)):0;return p;
}
