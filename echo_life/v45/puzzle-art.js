import { pipeGlyph } from './puzzles.js';
const symbols=['○','△','□'],pairSymbols=['☀','☂','◇','✦'];
export function tileLabel(p,i){const v=p.cells?.[i];
 if(p.type==='order')return p.labels[i];
 if(p.type==='pairs')return p.matched.includes(i)||p.revealed.includes(i)?pairSymbols[v]:'?';
 if(p.type==='slide')return v?String(v):'·';
 if(p.type==='mosaic')return `${symbols[v]} → ${symbols[p.targets[i]]}`;
 if(p.type==='maze')return i===p.avatar?'◆':i===15?'★':'·';
 if(p.type==='balance')return `${v} ×${p.weights[i]}`;
 if(p.type==='lock')return `${'ABC'[i]}: ${v}`;
 return p.type==='pipes'?pipeGlyph(v):p.type==='lights'?(v?'ON':'OFF'):`${v} / ${p.targets[i]}`;
}
export function decorate(b,p,i){b.className='puzzle-tile';const v=p.cells?.[i];
 b.classList.toggle('lit',p.type==='lights'&&v);b.classList.toggle('matched',p.type==='pairs'&&p.matched.includes(i)||['tune','mosaic','lock'].includes(p.type)&&v===p.targets[i]);
 if(p.type==='pipes'){
  const svg=document.createElementNS('http://www.w3.org/2000/svg','svg');svg.setAttribute('viewBox','0 0 60 60');svg.setAttribute('aria-hidden','true');
  const dirs=[[30,4],[56,30],[30,56],[4,30]];dirs.forEach(([x,y],j)=>{if(v&(1<<j)){const line=document.createElementNS(svg.namespaceURI,'line');for(const[k,z]of Object.entries({x1:30,y1:30,x2:x,y2:y,stroke:'currentColor','stroke-width':6,'stroke-linecap':'round'}))line.setAttribute(k,z);svg.append(line);}});b.textContent='';b.append(svg);
 }
 if(p.type==='maze'){for(const[k,bit]of [['Top',1],['Right',2],['Bottom',4],['Left',8]])b.style['border'+k]=v&bit?'3px solid #c8f5e1':'1px solid #75b39a22';}
 if(p.type==='lights')b.title='Flips this tile and its horizontal/vertical neighbours';
 if(p.type==='tune')b.style.backgroundImage=`conic-gradient(from 0deg,#83bed733 ${(v/7)*360}deg,transparent 0deg)`;
}
export function previewNeighbours(grid,p,i,on){if(p.type!=='lights')return;for(const j of [i,i-3,i+3,i%3?i-1:-1,i%3<2?i+1:-1])if(j>=0&&j<9)grid.querySelector(`[data-tile="${j}"]`)?.classList.toggle('affected',on);}
