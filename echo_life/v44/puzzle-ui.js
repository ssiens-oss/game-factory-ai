import { pipeGlyph, createPuzzle } from './puzzles.js';
const $=id=>document.getElementById(id);
export class PuzzleUI {
  constructor(sim, hooks) {
    this.sim=sim; this.hooks=hooks; this.opened=false; this.mode='puzzle';
    $('interact').addEventListener('click',()=>this.open());
    window.addEventListener('keydown',e=>{ if(e.code==='Tab' && this.opened){const panel=$(this.mode==='journal'?'journal-screen':'puzzle-screen'),buttons=[...panel.querySelectorAll('button:not(:disabled)')].filter(b=>b.getClientRects().length),first=buttons[0],last=buttons.at(-1);if(e.shiftKey&&document.activeElement===first){e.preventDefault();last.focus();}else if(!e.shiftKey&&document.activeElement===last){e.preventDefault();first.focus();}} if(e.code==='KeyF' && !e.repeat && !['INPUT','TEXTAREA','BUTTON'].includes(e.target?.tagName)) { e.preventDefault(); this.open(); } if(e.code==='KeyJ' && !e.repeat && !['INPUT','TEXTAREA'].includes(e.target?.tagName)) {e.preventDefault();this.openJournal();} });
    $('journal').addEventListener('click',()=>this.openJournal());
    $('journal-close').addEventListener('click',()=>this.close());
    $('puzzle-undo').addEventListener('click',()=>{if(sim.undoPuzzle()){this.render();this.hooks.save();}});
    $('puzzle-close').addEventListener('click',()=>this.close());
    $('puzzle-hint').addEventListener('click',()=>{ $('puzzle-feedback').textContent=sim.puzzleHint(); });
    $('puzzle-reset').addEventListener('click',()=>{ if(!sim.relay.solved) { sim.resetPuzzle(); this.render(); this.hooks.save(); } });
  }
  update() {
    $('interact').disabled=!this.sim.canInteract; $('interact').textContent=this.sim.canInteract?'F / RESTORE RELAY':'◇ FIND RELAY';
    $('mission-label').textContent='RESTORE RELAYS';
    $('combo').textContent=`${this.sim.relays} RELAYS ONLINE`;
    $('district').textContent=this.sim.districtInfo.name;
  }
  open() {
    if (this.opened || !this.sim.canInteract || !document.body.classList.contains('playing') || !$('pause-screen').hidden) return;
    this.hooks.pause(); $('pause-screen').hidden=true; this.opened=true; this.mode='puzzle'; $('puzzle-screen').hidden=false; this.render(); $('puzzle-close').focus();
  }
  openJournal() {
    if(this.opened || !document.body.classList.contains('playing') || !$('pause-screen').hidden) return;
    this.hooks.pause();$('pause-screen').hidden=true;this.opened=true;this.mode='journal';
    $('journal-screen').hidden=false;const list=$('journal-list');list.replaceChildren();
    if(!this.sim.journal.length){const p=document.createElement('p');p.textContent='Restore a relay to discover the city’s memories. Your notes and progress save automatically.';list.append(p);}
    for(const entry of [...this.sim.journal].reverse()){const item=document.createElement('article'),h=document.createElement('strong'),p=document.createElement('p');h.textContent=`RELAY ${entry.relay} / ${entry.district}`;p.textContent=entry.note;item.append(h,p);list.append(item);}
    $('journal-summary').textContent=`${this.sim.relays} relays restored · ${this.sim.districtInfo.name} · ${this.sim.score} score`;
    $('journal-close').focus();
  }
  close(resume=true) {
    $('puzzle-screen').hidden=true; $('journal-screen').hidden=true; this.opened=false; this.sim.nextRelay(); this.hooks.save(); if(resume) this.hooks.resume();
  }
  render() {
    const p=this.sim.relay.puzzle, solved=this.sim.relay.solved;
    $('puzzle-name').textContent={pipes:'Route the current.',lights:'Quiet the grid.',order:'Rebuild the signal.',tune:'Tune the harmonics.'}[p.type];
    $('puzzle-help').textContent={pipes:'Tap tiles to rotate. Connect IN on the middle-left to OUT on the middle-right; the path may turn. Touching pipe ends must match.',lights:'Switch every light OFF. Each tap flips that tile and its immediate horizontal and vertical neighbours.',order:'Tap the four signals in the order described by these clues.',tune:'Match all three dials to their targets. Each tap raises this dial AND the next dial by one. Values wrap from 6 to 0.'}[p.type];
    $('puzzle-feedback').textContent=solved?'RELAY ONLINE · +100¢ · +24 ROUNDS · +25 HEALTH':`${p.moves} moves · No timer or penalty. Hints are free.`;
    $('puzzle-close').textContent=solved?'CONTINUE EXPLORING':'BACK TO CITY'; $('puzzle-reset').disabled=solved; $('puzzle-hint').disabled=solved;
    $('puzzle-undo').disabled=solved || !p.history.length;
    $('puzzle-clues').textContent=p.type==='order'?p.clues.join(' '):p.type==='pipes'?'IN → find the route → OUT':p.type==='tune'?'TARGETS: '+p.targets.join(' / '):'';
    const grid=$('puzzle-grid'); grid.replaceChildren(); grid.classList.toggle('order-grid',p.type==='order');grid.classList.toggle('tune-grid',p.type==='tune');
    const values=p.type==='order'?p.labels:p.cells;
    values.forEach((v,i)=>{ const b=document.createElement('button'); b.dataset.tile=i; b.textContent=p.type==='pipes'?pipeGlyph(v):p.type==='lights'?(v?'ON':'OFF'):p.type==='tune'?`${v} / ${p.targets[i]}`:v;
      b.className='puzzle-tile'; b.classList.toggle('lit',p.type==='lights' && v);b.classList.toggle('matched',p.type==='tune' && v===p.targets[i]); b.disabled=solved || (p.type==='order' && p.chosen.includes(i));
      b.setAttribute('aria-label',p.type==='order'?v:`Tile ${i+1}, ${p.type==='pipes'?pipeGlyph(v):p.type==='tune'?`dial ${v}, target ${p.targets[i]}`:v?'on':'off'}`);
      b.addEventListener('click',()=>{ const before=p.moves; const completed=this.sim.solveAction(i); if(p.moves===before) return;
        if(completed) { this.hooks.audio.play('level'); this.hooks.hud.update(this.sim,true); }
        this.render(); this.hooks.save(); const next=grid.querySelector(`[data-tile="${i}"]`); if(!next.disabled) next.focus(); else $('puzzle-close').focus();
      }); grid.append(b);
    });
    $('puzzle-chosen').textContent=p.type==='order'?'ORDER: '+(p.chosen.map(i=>p.labels[i]).join(' → ') || 'Choose the first signal'):'';
  }
}
