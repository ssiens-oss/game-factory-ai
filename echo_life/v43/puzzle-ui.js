import { pipeGlyph, createPuzzle } from './puzzles.js';
const $=id=>document.getElementById(id);
export class PuzzleUI {
  constructor(sim, hooks) {
    this.sim=sim; this.hooks=hooks; this.opened=false;
    $('interact').addEventListener('click',()=>this.open());
    window.addEventListener('keydown',e=>{ if(e.code==='KeyF' && !e.repeat && !['INPUT','TEXTAREA','BUTTON'].includes(e.target?.tagName)) { e.preventDefault(); this.open(); } if(e.code==='Escape' && this.opened) this.close(); });
    $('puzzle-close').addEventListener('click',()=>this.close());
    $('puzzle-hint').addEventListener('click',()=>{ $('puzzle-feedback').textContent=sim.puzzleHint(); });
    $('puzzle-reset').addEventListener('click',()=>{ if(!sim.relay.solved) { sim.relay.puzzle=createPuzzle(sim.relays); this.render(); } });
  }
  update() {
    $('interact').disabled=!this.sim.canInteract; $('interact').textContent=this.sim.canInteract?'F / RESTORE RELAY':'◇ FIND RELAY';
    $('mission-label').textContent='RESTORE RELAYS';
    $('combo').textContent=`${this.sim.relays} RELAYS ONLINE`;
  }
  open() {
    if (this.opened || !this.sim.canInteract || !document.body.classList.contains('playing') || !$('pause-screen').hidden) return;
    this.hooks.pause(); $('pause-screen').hidden=true; this.opened=true; $('puzzle-screen').hidden=false; this.render(); $('puzzle-close').focus();
  }
  close(resume=true) {
    $('puzzle-screen').hidden=true; this.opened=false; this.sim.nextRelay(); if(resume) this.hooks.resume();
  }
  render() {
    const p=this.sim.relay.puzzle, solved=this.sim.relay.solved;
    $('puzzle-name').textContent={pipes:'Route the current.',lights:'Quiet the grid.',order:'Rebuild the signal.'}[p.type];
    $('puzzle-help').textContent={pipes:'Tap tiles to rotate. Connect IN → OUT across the middle row. Touching pipe ends must match.',lights:'Switch every light OFF. Each tap flips that tile and its immediate horizontal and vertical neighbours.',order:'Tap the four signals in the order described by these clues.'}[p.type];
    $('puzzle-feedback').textContent=solved?'RELAY ONLINE · +100¢ · +24 ROUNDS · +25 HEALTH':`${p.moves} moves · No timer or penalty. Hints are free.`;
    $('puzzle-close').textContent=solved?'CONTINUE EXPLORING':'BACK TO CITY'; $('puzzle-reset').disabled=solved; $('puzzle-hint').disabled=solved;
    $('puzzle-clues').textContent=p.type==='order'?p.solution.slice(0,-1).map((v,i)=>`${p.labels[v]} comes before ${p.labels[p.solution[i+1]]}.`).join(' '):p.type==='pipes'?'IN → middle row → OUT':'';
    const grid=$('puzzle-grid'); grid.replaceChildren(); grid.classList.toggle('order-grid',p.type==='order');
    const values=p.type==='order'?p.labels:p.cells;
    values.forEach((v,i)=>{ const b=document.createElement('button'); b.dataset.tile=i; b.textContent=p.type==='pipes'?pipeGlyph(v):p.type==='lights'?(v?'ON':'OFF'):v;
      b.className='puzzle-tile'; b.classList.toggle('lit',p.type==='lights' && v); b.disabled=solved || (p.type==='order' && p.chosen.includes(i));
      b.setAttribute('aria-label',p.type==='order'?v:`Tile ${i+1}, ${p.type==='pipes'?pipeGlyph(v):v?'on':'off'}`);
      b.addEventListener('click',()=>{ const before=p.moves; const completed=this.sim.solveAction(i); if(p.moves===before) return;
        if(completed) { this.hooks.audio.play('level'); this.hooks.hud.update(this.sim,true); }
        this.render(); const next=grid.querySelector(`[data-tile="${i}"]`); if(!next.disabled) next.focus(); else $('puzzle-close').focus();
      }); grid.append(b);
    });
    $('puzzle-chosen').textContent=p.type==='order'?'ORDER: '+(p.chosen.map(i=>p.labels[i]).join(' → ') || 'Choose the first signal'):'';
  }
}
