import { seeded } from '../v42/config.js';
import { connected, pipeGlyph } from '../v43/puzzles.js';
export { connected, pipeGlyph };
const rotate=m=>((m<<1)&15)|(m>>3);
function toggle(c,i){for(const j of [i,i-3,i+3,i%3?i-1:-1,i%3<2?i+1:-1])if(j>=0&&j<9)c[j]=!c[j];}
function shuffle(a,random){for(let i=a.length-1;i>0;i--){const j=Math.floor(random()*(i+1));[a[i],a[j]]=[a[j],a[i]];}return a;}
export function createPuzzle(number){
 const random=seeded(number*1951+4401),type=['pipes','lights','order','tune'][number%4];
 const p={number,type,moves:0,solved:false,history:[]};
 if(type==='pipes'){
  const path=[[3,4,5],[3,0,1,2,5],[3,6,7,8,5]][Math.floor(number/4)%3];
  p.solution=Array.from({length:9},()=>[3,6,9,12][Math.floor(random()*4)]);
  const direction=(a,b)=>b===a-3?1:b===a+1?2:b===a+3?4:8;
  path.forEach((v,i)=>{p.solution[v]=(i?direction(v,path[i-1]):8)|(i===path.length-1?2:direction(v,path[i+1]));});
  p.cells=p.solution.map(m=>{for(let j=Math.floor(random()*4);j>0;j--)m=rotate(m);return m;});
  if(connected(p.cells))p.cells[3]=rotate(p.cells[3]);
 }else if(type==='lights'){
  p.cells=Array(9).fill(false);const press=shuffle([0,1,2,3,4,5,6,7,8],random).slice(0,3+Math.floor(random()*4));for(const i of press)toggle(p.cells,i);if(p.cells.every(v=>!v))toggle(p.cells,4);
 }else if(type==='order'){
  p.labels=['DAWN','RAIN','ECHO','NIGHT'];p.solution=shuffle([0,1,2,3],random);p.chosen=[];
  p.clues=shuffle(p.solution.slice(0,-1).map((v,i)=>`${p.labels[v]} comes before ${p.labels[p.solution[i+1]]}.`),random);
 }else{
  p.targets=Array.from({length:3},()=>Math.floor(random()*7));p.cells=[...p.targets];
  for(let i=0;i<3;i++)for(let j=0;j<1+Math.floor(random()*5);j++)tune(p.cells,i);
  if(p.cells.every((v,i)=>v===p.targets[i]))tune(p.cells,0);
 }return p;
}
function tune(c,i){c[i]=(c[i]+1)%7;c[(i+1)%3]=(c[(i+1)%3]+1)%7;}
export function act(p,i){
 const count=p.type==='order'?4:p.type==='tune'?3:9;
 if(p.solved||!Number.isInteger(i)||i<0||i>=count||(p.type==='order'&&p.chosen.includes(i)))return false;
 p.history.push({cells:p.cells?[...p.cells]:undefined,chosen:p.chosen?[...p.chosen]:undefined,moves:p.moves});if(p.history.length>50)p.history.shift();p.moves++;
 if(p.type==='pipes'){p.cells[i]=rotate(p.cells[i]);p.solved=connected(p.cells);}
 else if(p.type==='lights'){toggle(p.cells,i);p.solved=p.cells.every(v=>!v);}
 else if(p.type==='tune'){tune(p.cells,i);p.solved=p.cells.every((v,j)=>v===p.targets[j]);}
 else{p.chosen.push(i);if(p.chosen.length===4){p.solved=p.chosen.every((v,j)=>v===p.solution[j]);if(!p.solved)p.chosen=[];}}
 return p.solved;
}
export function undo(p){if(p.solved||!p.history.length)return false;Object.assign(p,p.history.pop());return true;}
export function nextHint(p){
 if(p.solved)return {index:null,text:'Relay restored.'};
 if(p.type==='pipes'){const i=p.cells.findIndex((v,i)=>v!==p.solution[i]);return{index:i,text:`Rotate tile ${i+1}. Connect matching pipe ends from IN on the left to OUT on the right.`};}
 if(p.type==='order'){if(p.chosen.some((v,j)=>v!==p.solution[j]))return {index:null,text:'That signal is out of order. Undo the last choice, or reset and follow the BEFORE clues.'};const i=p.solution[p.chosen.length];return{index:i,text:`Next signal: ${p.labels[i]}. Follow the BEFORE clues.`};}
 const limit=p.type==='lights'?512:343,base=p.type==='lights'?2:7,count=p.type==='lights'?9:3;
 for(let mask=0;mask<limit;mask++){
  const cells=[...p.cells];let n=mask,first=null;
  for(let i=0;i<count;i++){const steps=n%base;n=Math.floor(n/base);if(steps&&first===null)first=i;for(let j=0;j<steps;j++)p.type==='lights'?toggle(cells,i):tune(cells,i);}
  if(cells.every((v,i)=>p.type==='lights'?!v:v===p.targets[i]))return{index:first,text:`Try ${p.type==='lights'?'tile':'dial'} ${first+1}. ${p.type==='lights'?'Switch all lights off.':'Each tap raises this dial and the next dial; values wrap from 6 to 0.'}`};
 }return{index:null,text:'Reset the relay to try again.'};
}
export const hint=p=>nextHint(p).text;
// Checkpoint validation replays legal moves rather than trusting stored completion.
export function restorePuzzle(number,data){
 const p=createPuzzle(number);if(!data||data.type!==p.type)return p;
 const cells=data.cells;
 if(p.type==='order'){if(Array.isArray(data.chosen)&&data.chosen.length<=3&&new Set(data.chosen).size===data.chosen.length&&data.chosen.every(v=>Number.isInteger(v)&&v>=0&&v<4))p.chosen=[...data.chosen];}
 else if(Array.isArray(cells)&&cells.length===p.cells.length&&cells.every(v=>p.type==='lights'?typeof v==='boolean':Number.isInteger(v)&&v>=0&&v<=(p.type==='pipes'?15:6))){
  if(p.type!=='pipes'||cells.every((v,i)=>{let m=p.solution[i];for(let k=0;k<4;k++){if(v===m)return true;m=rotate(m);}return false;}))p.cells=[...cells];
 }
 p.moves=Number.isInteger(data.moves)&&data.moves>=0?Math.min(data.moves,100000):0;return p;
}
