// Each family owns its rules, clue construction and legal actions.
import { seeded } from '../v42/config.js';
export const EXTRA=['sudoku','nonogram','arithmetic','compass','binary','rank','glyph','echo','orbit','word'];
export const EXTRA_META={
 sudoku:{name:'Pocket Sudoku',help:'Fill each row, column and 2×2 box with 1–4. Dotted clues cannot change.',detail:'Tap editable squares to cycle 1–4. Red outlines identify duplicate values; small candidates list numbers currently permitted.',color:'#aedab1'},
 nonogram:{name:'Picture logic',help:'Fill squares to match the run lengths shown for every row and column.',detail:'A clue such as 1·2 means one filled square, a gap, then two filled squares. Zero means an empty line. Any picture satisfying every clue wins.',color:'#91cfe5'},
 arithmetic:{name:'Number equations',help:'Find A, B and C from the sum, difference and product clues.',detail:'Digits cycle 0–9. The total fixes C once you have found A and B from their difference and product.',color:'#eac191'},
 compass:{name:'Compass bearings',help:'Turn each compass to the bearing described by its landmark.',detail:'Bearings cycle N → E → S → W. Each landmark clue specifies the number of clockwise quarter turns from north.',color:'#a6d5cf'},
 binary:{name:'Binary beacon',help:'Switch bits to make the requested decimal number.',detail:'The four lamps have weights 8, 4, 2 and 1. Add only the weights of lit lamps. No carries or negative numbers are needed.',color:'#d5df8d'},
 rank:{name:'Priority dispatch',help:'Dispatch the four messages from lowest priority number to highest.',detail:'Each message shows its own priority. A complete incorrect order resets; partial choices can be undone.',color:'#dbb2dc'},
 glyph:{name:'Row harmonics',help:'Match nine symbols. Tapping any square cycles its entire row.',detail:'Every row advances together through ○, △ and □. The target is displayed beside each square. Hover previews the affected row.',color:'#b9c9f0'},
 echo:{name:'Echo rehearsal',help:'Replay the displayed five-note melody using the four instrument buttons.',detail:'Notes may repeat. A wrong note resets the rehearsal immediately; the written score remains visible with the next position highlighted.',color:'#ecc396'},
 orbit:{name:'Orbital alignment',help:'Rotate the eight-position ring until its highlighted beacon reaches the marked slot.',detail:'Every tile rotates the entire ring clockwise by one position. The bright diamond is the beacon; the star marks its destination.',color:'#91d9e0'},
 word:{name:'Word restoration',help:'Restore the five-letter city word described by the clue.',detail:'Each position cycles through its displayed letter choices. The letters form a familiar city object or place.',color:'#c7d4a0'}
};
export const runs=a=>{const out=[];let n=0;for(const v of [...a,0]){if(v)n++;else if(n){out.push(n);n=0;}}return out.length?out:[0];};
export const candidates=(p,i)=>[1,2,3,4].filter(v=>p.cells.every((n,j)=>j===i||n!==v||!(Math.floor(i/4)===Math.floor(j/4)||i%4===j%4||Math.floor(i/8)===Math.floor(j/8)&&Math.floor(i%4/2)===Math.floor(j%4/2))));
export function createAdvanced(number,type){
 const r=seeded(number*6173+4601),pick=n=>Math.floor(r()*n);
 const p={number,type,moves:0,solved:false,history:[],redo:[],elapsed:0,hints:0,tier:Math.min(3,1+Math.floor(number/60)),par:24};
 if(type==='sudoku'){
  const order=[1,2,3,4];for(let i=3;i;i--){const j=pick(i+1);[order[i],order[j]]=[order[j],order[i]];}
  p.targets=Array.from({length:16},(_,i)=>order[(i%4+Math.floor(i/4)*2+Math.floor(i/8))%4]);p.fixed=Array.from({length:16},(_,i)=>[0,3,5,6,9,10,12,15].includes(i));p.cells=p.targets.map((v,i)=>p.fixed[i]?v:0);
 }else if(type==='nonogram'){
  p.targets=Array.from({length:16},()=>pick(2));p.targets[0]=1;p.cells=Array(16).fill(0);p.rows=Array.from({length:4},(_,i)=>runs(p.targets.slice(i*4,i*4+4)));p.columns=Array.from({length:4},(_,i)=>runs(p.targets.filter((_,j)=>j%4===i)));
 }else if(type==='arithmetic'){
  p.targets=[1+pick(8),1+pick(8),1+pick(8)];p.cells=[0,0,0];const[a,b,c]=p.targets;p.clues=[`A + B + C = ${a+b+c}`,`A − B = ${a-b}`,`A × B = ${a*b}`];
 }else if(type==='compass'){
  p.targets=Array.from({length:3},()=>1+pick(3));p.cells=[0,0,0];p.clues=p.targets.map((v,i)=>`${['Station','Garden','Harbour'][i]}: ${v} clockwise turns from N`);
 }else if(type==='binary'){p.total=1+pick(15);p.weights=[8,4,2,1];p.targets=p.weights.map(w=>p.total&w?1:0);p.cells=[0,0,0,0];p.par=4;}
 else if(type==='rank'){p.targets=[0,1,2,3];for(let i=3;i;i--){const j=pick(i+1);[p.targets[i],p.targets[j]]=[p.targets[j],p.targets[i]];}p.cells=[1,2,3,4];p.labels=['Mail','Water','Seeds','Music'];p.chosen=[];p.par=4;}
 else if(type==='glyph'){p.targets=Array.from({length:9},()=>pick(3));p.cells=p.targets.map((v,i)=>(v+1+Math.floor(i/3)%2)%3);p.par=6;}
 else if(type==='echo'){p.targets=Array.from({length:5},()=>pick(4));p.cells=[0,1,2,3];p.chosen=[];p.par=5;}
 else if(type==='orbit'){p.cells=[1,0,0,0,0,0,0,0];p.goal=1+pick(7);p.par=7;}
 else if(type==='word'){
  const words=[['LIGHT','It shines from a lantern'],['TRAIN','It arrives at the station'],['WATER','It flows in the fountain'],['PLANT','It grows in the garden'],['BRICK','It builds the city walls'],['CLOCK','It tells the station time']];const[word,clue]=words[pick(words.length)];p.word=word;p.clues=[clue];p.letters=[...word].map((c,i)=>{const opts=[c,String.fromCharCode(65+(c.charCodeAt(0)-64+i)%26),String.fromCharCode(65+(c.charCodeAt(0)-60+i)%26)];return [...new Set(opts)];});p.targets=p.letters.map(()=>0);p.cells=p.letters.map(a=>1%a.length);p.par=10;
 }
 return p;
}
export function advancedLegal(p,i){return Number.isInteger(i)&&i>=0&&i<p.cells.length&&!p.solved&&!(p.type==='sudoku'&&p.fixed[i])&&!(p.type==='rank'&&p.chosen.includes(i));}
export function advance(p,i){
 p.moves++;
 if(p.type==='sudoku')p.cells[i]=p.cells[i]%4+1;
 else if(p.type==='nonogram'||p.type==='binary')p.cells[i]^=1;
 else if(p.type==='arithmetic')p.cells[i]=(p.cells[i]+1)%10;
 else if(p.type==='compass')p.cells[i]=(p.cells[i]+1)%4;
 else if(p.type==='rank'){p.chosen.push(i);if(p.chosen.length===4&&!p.chosen.every((v,j)=>v===p.targets[j]))p.chosen=[];}
 else if(p.type==='glyph'){const row=Math.floor(i/3)*3;for(let j=row;j<row+3;j++)p.cells[j]=(p.cells[j]+1)%3;}
 else if(p.type==='echo'){if(i===p.targets[p.chosen.length])p.chosen.push(i);else p.chosen=[];}
 else if(p.type==='orbit')p.cells.unshift(p.cells.pop());
 else if(p.type==='word')p.cells[i]=(p.cells[i]+1)%p.letters[i].length;
 p.solved=advancedSolved(p);return p.solved;
}
export function advancedSolved(p){
 if(p.type==='sudoku')return p.cells.every((v,i)=>v>0&&candidates(p,i).includes(v));
 if(p.type==='nonogram')return p.rows.every((a,i)=>String(a)===String(runs(p.cells.slice(i*4,i*4+4))))&&p.columns.every((a,i)=>String(a)===String(runs(p.cells.filter((_,j)=>j%4===i))));
 if(p.type==='rank')return p.chosen.length===4&&p.chosen.every((v,i)=>v===p.targets[i]);
 if(p.type==='echo')return p.chosen.length===5;
 if(p.type==='orbit')return p.cells[p.goal]===1;
 return p.cells.every((v,i)=>v===p.targets[i]);
}
export function advancedHint(p){
 let index;if(p.type==='rank'){const mismatch=p.chosen.some((v,i)=>v!==p.targets[i]);index=mismatch?[0,1,2,3].find(i=>!p.chosen.includes(i)):p.targets[p.chosen.length];}
 else if(p.type==='echo')index=p.targets[p.chosen.length];
 else if(p.type==='orbit')index=0;
 else index=p.cells.findIndex((v,i)=>v!==p.targets[i]&&!(p.type==='sudoku'&&p.fixed[i]));
 return{index,text:`Try ${p.type==='echo'?'instrument':'tile'} ${index+1}. ${EXTRA_META[p.type].help}`};
}
export function advancedProgress(p){
 if(p.type==='rank'||p.type==='echo')return `${p.chosen.length} / ${p.targets.length} dispatched`;
 if(p.type==='binary')return `VALUE ${p.cells.reduce((s,v,i)=>s+v*p.weights[i],0)} / ${p.total}`;
 if(p.type==='nonogram')return `${p.cells.reduce((a,b)=>a+b,0)} squares filled · match all eight clues`;
 if(p.type==='orbit')return `BEACON ${p.cells.indexOf(1)+1} → SLOT ${p.goal+1}`;
 return `${p.cells.filter((v,i)=>v===p.targets[i]).length} / ${p.cells.length} aligned`;
}
export function legalAdvancedState(p,s){
 if(!s||!Number.isInteger(s.moves)||s.moves<0||s.moves>100000||!Array.isArray(s.cells)||s.cells.length!==p.cells.length)return false;
 const max={sudoku:4,nonogram:1,arithmetic:9,compass:3,binary:1,rank:4,glyph:2,echo:3,orbit:1,word:2}[p.type];
 if(!s.cells.every((v,i)=>Number.isInteger(v)&&v>=0&&v<=max&&!(p.type==='sudoku'&&p.fixed[i]&&v!==p.cells[i])&&!(p.type==='word'&&v>=p.letters[i].length)))return false;
 if(p.type==='rank'||p.type==='echo'){if(!Array.isArray(s.chosen)||s.chosen.length>=p.targets.length||!s.chosen.every(v=>Number.isInteger(v)&&v>=0&&v<4))return false;if(p.type==='rank'&&(new Set(s.chosen).size!==s.chosen.length||String(s.cells)!==String(p.cells)))return false;if(p.type==='echo'&&(!s.chosen.every((v,i)=>v===p.targets[i])||String(s.cells)!==String(p.cells)))return false;}
 if(p.type==='orbit'&&s.cells.reduce((a,b)=>a+b,0)!==1)return false;
 return !advancedSolved({...p,...s});
}
