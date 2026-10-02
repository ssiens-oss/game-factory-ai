// Pure puzzle rules; the UI never owns completion or rewards.
const rotate = m => ((m << 1) & 15) | (m >> 3);
export const pipeGlyph = m => ({5:'│',10:'─',3:'└',6:'┌',12:'┐',9:'┘'})[m] || '·';
function toggle(cells, i) { for (const j of [i, i-3, i+3, i%3 ? i-1 : -1, i%3<2 ? i+1 : -1]) if (j>=0 && j<9) cells[j] = !cells[j]; }
export function connected(cells) {
  if (!(cells[3] & 8)) return false;
  const queue=[3], seen=new Set(queue), directions=[[-3,1,4],[1,2,8],[3,4,1],[-1,8,2]];
  for (const i of queue) {
    if (i===5 && cells[i]&2) return true;
    for (const [offset,out,back] of directions) { const j=i+offset; if (j<0 || j>=9 || (Math.abs(offset)===1 && Math.floor(i/3)!==Math.floor(j/3))) continue;
      if (cells[i]&out && cells[j]&back && !seen.has(j)) { seen.add(j); queue.push(j); }
    }
  } return false;
}
export function createPuzzle(number) {
  const type=['pipes','lights','order'][number%3];
  if (type==='pipes') return { type, cells:[3,6,12,5,5,5,9,3,6], moves:0, solved:false };
  if (type==='lights') { const cells=Array(9).fill(false); for (const i of [0,4,8]) toggle(cells,i); return {type,cells,moves:0,solved:false}; }
  const labels=['DAWN','RAIN','ECHO','NIGHT'];
  // The city cycle reverses every other district, with explicit ordering clues.
  const solution=number%2 ? [3,2,1,0] : [0,1,2,3];
  return {type,labels,solution,chosen:[],moves:0,solved:false};
}
export function act(p,i) {
  if (p.solved || !Number.isInteger(i) || i<0 || i>=(p.type==='order'?4:9)) return false;
  p.moves++;
  if (p.type==='pipes') { p.cells[i]=rotate(p.cells[i]); p.solved=connected(p.cells); }
  else if (p.type==='lights') { toggle(p.cells,i); p.solved=p.cells.every(v=>!v); }
  else { if (p.chosen.includes(i)) return false; p.chosen.push(i); if (p.chosen.length===4) { p.solved=p.chosen.every((v,j)=>v===p.solution[j]); if (!p.solved) p.chosen=[]; } }
  return p.solved;
}
export function hint(p) {
  if (p.type==='pipes') return 'Connect IN on the left to OUT on the right. Rotate the three middle-row tiles into horizontal lines.';
  if (p.type==='order') return 'Start with '+p.labels[p.solution[0]]+'. Follow each BEFORE clue; tap all four signals in that order.';
  // Brute force just 512 states, called only on demand. Returns a valid next move from any state.
  for (let mask=0; mask<512; mask++) { const cells=[...p.cells]; for(let i=0;i<9;i++) if(mask&(1<<i)) toggle(cells,i); if(cells.every(v=>!v)) { const i=Array.from({length:9},(_,i)=>i).find(i=>mask&(1<<i)); return i===undefined?'All lights are off.':`Try tile ${i+1} (row ${Math.floor(i/3)+1}, column ${i%3+1}).`; } }
  return 'Reset this grid to try again.';
}
