import { candidates,runs } from './advanced-puzzles.js';
export function boardDetails(p){
 if(p.type==='nonogram')return `ROWS: ${p.rows.map(a=>a.join('·')).join(' / ')} · COLUMNS: ${p.columns.map(a=>a.join('·')).join(' / ')}`;
 if(p.type==='binary')return `TARGET ${p.total} · WEIGHTS 8 / 4 / 2 / 1`;
 if(p.type==='rank')return p.labels.map((v,i)=>`${v}: priority ${p.targets.indexOf(i)+1}`).join(' · ');
 if(p.type==='echo')return 'SCORE: '+p.targets.map((v,i)=>`${i===p.chosen.length?'▶ ':''}${['DO','RE','MI','SO'][v]}`).join(' → ');
 if(p.type==='sudoku')return '1–4 once in every row, column and outlined box';
 if(p.type==='orbit')return `DESTINATION: SLOT ${p.goal+1} · tap anywhere to rotate clockwise`;
 return p.clues?.join(' · ')||'';
}
export function label(p,i){const v=p.cells[i];
 if(p.type==='sudoku')return `${v||'·'}`;
 if(p.type==='nonogram')return v?'■':'·';
 if(p.type==='arithmetic')return `${'ABC'[i]} = ${v}`;
 if(p.type==='compass')return ['N ↑','E →','S ↓','W ←'][v];
 if(p.type==='binary')return `${v?'ON':'OFF'} / ${p.weights[i]}`;
 if(p.type==='rank')return `${p.labels[i]} / ${p.targets.indexOf(i)+1}`;
 if(p.type==='glyph')return `${['○','△','□'][v]} → ${['○','△','□'][p.targets[i]]}`;
 if(p.type==='echo')return ['DO ♩','RE ♪','MI ♫','SO ♬'][i];
 if(p.type==='orbit')return `${v?'◆':'○'}${i===p.goal?' ★':''}`;
 if(p.type==='word')return p.letters[i][v];
}
export function embellish(b,p,i){b.className='puzzle-tile';b.classList.toggle('matched',p.targets?.[i]===p.cells[i]&&!['rank','echo','nonogram'].includes(p.type));
 if(p.type==='sudoku'){
  b.classList.toggle('given',p.fixed[i]);b.classList.toggle('conflict',!!p.cells[i]&&!candidates(p,i).includes(p.cells[i]));
  if(!p.fixed[i]){const s=document.createElement('small');s.textContent=candidates(p,i).join(' ');s.className='candidates';b.append(s);}
  b.style.borderRightWidth=i%4===1?'3px':'1px';b.style.borderBottomWidth=Math.floor(i/4)===1?'3px':'1px';
 }
 if(p.type==='nonogram'){b.classList.toggle('lit',!!p.cells[i]);b.title=`Row ${Math.floor(i/4)+1}: ${p.rows[Math.floor(i/4)].join('·')}; column ${i%4+1}: ${p.columns[i%4].join('·')}`;}
 if(p.type==='binary')b.classList.toggle('lit',!!p.cells[i]);
 if(p.type==='orbit'){b.classList.toggle('beacon',!!p.cells[i]);b.classList.toggle('destination',i===p.goal);b.style.setProperty('--slot',i);}
 if(p.type==='word')b.title='Letter choices: '+p.letters[i].join(' / ');
 if(p.type==='rank'||p.type==='echo')b.classList.toggle('selected',p.chosen.includes(i));
}
export function extraPreview(grid,p,i,on){if(p.type==='glyph')for(let j=Math.floor(i/3)*3;j<Math.floor(i/3)*3+3;j++)grid.querySelector(`[data-tile="${j}"]`)?.classList.toggle('affected',on);}
export function lineStatus(p){if(p.type!=='nonogram')return '';const lines=[...p.rows.map((a,i)=>String(a)===String(runs(p.cells.slice(i*4,i*4+4)))),...p.columns.map((a,i)=>String(a)===String(runs(p.cells.filter((_,j)=>j%4===i))))];return `${lines.filter(Boolean).length} / 8 line clues satisfied`;}
