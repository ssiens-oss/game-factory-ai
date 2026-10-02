import { TYPES,META,createPuzzle,act,undo,redo,nextHint,canAct,progress } from './puzzles.js';
import { tileLabel,decorate,previewNeighbours } from './puzzle-art.js';
import { DISTRICTS } from './simulation.js';
import { TROPHIES } from './simulation.js';
const $=id=>document.getElementById(id);
const editing=e=>['INPUT','TEXTAREA','SELECT'].includes(e.target?.tagName);
export class PuzzleUI {
 constructor(sim,hooks){this.sim=sim;this.hooks=hooks;this.opened=false;this.practice=null;this.variant=0;this.mode='puzzle';this.pad=[];this.padDelay=0;this.lastUI=-1;
  for(const type of TYPES){const o=document.createElement('option');o.value=type;o.textContent=META[type].name;$('journal-type').append(o);}
  $('interact').addEventListener('click',()=>this.open());$('journal').addEventListener('click',()=>this.openJournal());$('map').addEventListener('click',()=>this.openJournal('map'));
  for(const mode of ['notes','map','library','trophies'])$('tab-'+mode).addEventListener('click',()=>this.showJournal(mode));
  $('journal-close').addEventListener('click',()=>this.close());$('puzzle-close').addEventListener('click',()=>this.close());
  $('puzzle-hint').addEventListener('click',()=>this.hint());
  for(const [id,fn]of [['puzzle-undo',undo],['puzzle-redo',redo]])$(id).addEventListener('click',()=>{if(fn(this.puzzle)){this.render();this.hooks.save();}});
  $('puzzle-reset').addEventListener('click',()=>{if(this.puzzle.solved)return;if(this.practice)this.practice=createPuzzle(this.practice.number);else sim.resetPuzzle();this.render();this.hooks.save();});
  $('puzzle-detail').addEventListener('click',()=>{$('puzzle-detail-text').hidden=!$('puzzle-detail-text').hidden;});
  for(const id of ['journal-search','journal-type','journal-sort'])$(id).addEventListener('input',()=>this.showJournal('notes'));
  $('site-action').addEventListener('click',()=>{if(sim.interactSite($('site-action').dataset.kind)){this.hooks.save();this.hooks.hud.notify(sim.lastInteraction,sim.time);this.update();}});
  window.addEventListener('keydown',e=>this.key(e));
 }
 background(block){for(const id of ['hud','game'])$(id).inert=block;document.querySelector('.touch-controls').inert=block;document.body.classList.toggle('dialog-open',block);}
 get puzzle(){return this.practice||this.sim.relay.puzzle;}
 get solved(){return this.practice?this.practice.solved:this.sim.relay.solved;}
 key(e){
  if(e.code==='Tab'&&this.opened){const panel=$(this.mode==='puzzle'?'puzzle-screen':'journal-screen'),nodes=[...panel.querySelectorAll('button:not(:disabled),input:not(:disabled),select:not(:disabled),a[href]')].filter(b=>b.getClientRects().length),first=nodes[0],last=nodes.at(-1);if(e.shiftKey&&document.activeElement===first){e.preventDefault();last.focus();}else if(!e.shiftKey&&document.activeElement===last){e.preventDefault();first.focus();}}
  if(editing(e)||e.repeat)return;
  if(!this.opened&&e.code===(this.hooks.options().interactKey||'KeyF')&&e.target?.tagName!=='BUTTON'){e.preventDefault();this.open();}
  if(!this.opened&&['KeyJ','KeyM','KeyP'].includes(e.code)){e.preventDefault();this.openJournal(e.code==='KeyM'?'map':e.code==='KeyP'?'library':'notes');}
  if(this.opened&&this.mode==='puzzle'){
   if(/^Digit[1-9]$/.test(e.code)){e.preventDefault();this.action(Number(e.code.at(-1))-1);}
   if(e.code==='KeyZ'){e.preventDefault();if(undo(this.puzzle)){this.render();this.hooks.save();}}
   if(e.code==='KeyY'){e.preventDefault();if(redo(this.puzzle)){this.render();this.hooks.save();}}
   if(e.code==='KeyH'){e.preventDefault();this.hint();}
   if(e.code.startsWith('Arrow')){e.preventDefault();const cols=this.puzzle.type==='maze'?4:this.puzzle.type==='pairs'||this.puzzle.type==='order'?2:3;
    const delta={ArrowLeft:-1,ArrowRight:1,ArrowUp:-cols,ArrowDown:cols}[e.code];
    if(this.puzzle.type==='maze'){this.action(this.puzzle.avatar+delta);return;}
    const buttons=[...$('puzzle-grid').querySelectorAll('button:not(:disabled)')],current=Number(document.activeElement.dataset?.tile)||0,target=$('puzzle-grid').querySelector(`[data-tile="${current+delta}"]`);(target&&!target.disabled?target:buttons[0])?.focus({preventScroll:true});
   }
  }
 }
 update(){const s=this.sim;if(s.time>=this.lastUI&&s.time-this.lastUI<.1)return;this.lastUI=s.time;$('interact').disabled=!s.canInteract;$('interact').textContent=s.canInteract?'RESTORE RELAY':'◇ FIND RELAY';$('mission-label').textContent='RESTORE RELAYS';$('combo').textContent=`${s.relays} ONLINE · ${s.stars}★`;$('district').textContent=s.districtInfo.name;
  $('repair-status').textContent=`DISTRICT ${Math.round(s.player.obj/3*100)}% · ${s.visited.length} VISITED`;$('route-status').textContent=`NEXT ${Math.round(Math.hypot(s.relay.x-s.player.x,s.relay.y-s.player.y)/32)}m · ${META[s.relay.puzzle.type].name.toUpperCase()}`;
  $('tutorial').hidden=s.relays>0;$('tutorial').textContent=s.canInteract?'STEP 2 / RESTORE RELAY · MATCH THE SIGNALS':'STEP 1 / FOLLOW THE GLOWING RELAY';
  const site=s.sites.find(p=>Math.hypot(p.x-s.player.x,p.y-s.player.y)<105 && !(p.kind==='relic'&&s.relics.includes(p.id) || p.kind==='stash'&&s.stashes.includes(p.id) || p.kind==='fountain'&&(s.player.hp>=100||s.fountainReady>s.time)));
  $('site-action').hidden=!site;if(site){$('site-action').dataset.kind=site.kind;$('site-action').textContent={relic:'COLLECT MEMORY',stash:'OPEN CACHE',fountain:'DRINK / +20 HP',resident:'TALK TO RESIDENT'}[site.kind];}
 }
 open(){if(this.opened||!this.sim.canInteract||!document.body.classList.contains('playing')||!$('pause-screen').hidden)return;this.practice=null;this.beginPuzzle();}
 beginPuzzle(){this.pad=[];this.hooks.pause();$('pause-screen').hidden=true;$('journal-screen').hidden=true;this.opened=true;this.mode='puzzle';this.background(true);$('puzzle-screen').hidden=false;$('puzzle-detail-text').hidden=true;this.render();$('puzzle-close').focus({preventScroll:true});}
 hint(){if(this.solved)return;this.puzzle.hints++;const h=nextHint(this.puzzle);$('puzzle-feedback').textContent=h.text;for(const b of $('puzzle-grid').children)b.classList.remove('hinted');if(h.index!==null)$('puzzle-grid').querySelector(`[data-tile="${h.index}"]`)?.classList.add('hinted');this.hooks.save();}
 action(i){const p=this.puzzle;if(!canAct(p,i))return;const done=this.practice?act(p,i):this.sim.solveAction(i);if(done){this.hooks.audio.play('level');if(!this.practice)this.hooks.hud.update(this.sim,true);}this.render();this.hooks.save();const next=$('puzzle-grid').querySelector(`[data-tile="${i}"]`);if(next&&!next.disabled)next.focus({preventScroll:true});else $('puzzle-close').focus({preventScroll:true});}
 render(){const p=this.puzzle,meta=META[p.type],solved=this.solved;document.documentElement.style.setProperty('--puzzle-accent',meta.color);
  $('puzzle-name').textContent=meta.name;$('puzzle-help').textContent=meta.help;$('puzzle-detail-text').textContent=meta.detail+' Keyboard: 1–9 choose tiles; arrows navigate; Z undoes, Y redoes, H gives a hint; Escape returns.';$('puzzle-mode').textContent=(this.practice?'PRACTICE / NO RUN REWARDS':'CITY RELAY / WORLD PAUSED')+` · TIER ${p.tier}`;
  $('puzzle-feedback').textContent=solved?(this.practice?'PRACTICE COMPLETE · Your city run is unchanged.':`RELAY ONLINE · ${'★'.repeat(Math.min(3,p.moves<=p.par?3:p.moves<=p.par*2?2:1))} · +100¢`):`${p.moves} moves · ${progress(p)} · No time limit`;
  $('puzzle-close').textContent=this.practice?'BACK TO LIBRARY':solved?'CONTINUE EXPLORING':'BACK TO CITY';
  for(const id of ['puzzle-hint','puzzle-reset'])$(id).disabled=solved;$('puzzle-undo').disabled=solved||!p.history.length;$('puzzle-redo').disabled=solved||!p.redo.length;
  $('puzzle-clues').textContent=p.clues?p.clues.join(' · '):p.type==='tune'?'TARGETS: '+p.targets.join(' / '):p.type==='balance'?'TARGET TOTAL: '+p.total:'';
  const grid=$('puzzle-grid');grid.replaceChildren();grid.className='grid-'+p.type;grid.setAttribute('aria-label',meta.name+' board');
  const values=p.type==='order'?p.labels:p.cells;
  values.forEach((v,i)=>{const b=document.createElement('button');b.dataset.tile=i;b.textContent=tileLabel(p,i);decorate(b,p,i);b.disabled=solved||(p.type==='order'&&p.chosen.includes(i))||(p.type==='pairs'&&p.matched.includes(i));b.classList.toggle('legal',p.type==='slide'&&canAct(p,i));
   const spoken=p.type==='maze'?`Square ${i+1}${i===p.avatar?', signal':''}${i===15?', goal':''}`:p.type==='order'?p.labels[i]:`Tile ${i+1}: ${tileLabel(p,i)}`;b.setAttribute('aria-label',spoken);
   b.addEventListener('click',()=>this.action(i));b.addEventListener('pointerenter',()=>previewNeighbours(grid,p,i,true));b.addEventListener('pointerleave',()=>previewNeighbours(grid,p,i,false));b.addEventListener('focus',()=>previewNeighbours(grid,p,i,true));b.addEventListener('blur',()=>previewNeighbours(grid,p,i,false));grid.append(b);
  });$('puzzle-chosen').textContent=p.type==='order'?'ORDER: '+(p.chosen.map(i=>p.labels[i]).join(' → ')||'Choose first signal'):p.type==='mosaic'?'○ → △ → □ → ○':'';
 }
 openJournal(mode='notes'){if(this.opened||!document.body.classList.contains('playing')||!$('pause-screen').hidden)return;this.pad=[];this.hooks.pause();$('pause-screen').hidden=true;this.opened=true;this.mode='journal';this.background(true);this.practice=null;$('journal-screen').hidden=false;this.showJournal(mode);$('journal-close').focus({preventScroll:true});}
 showJournal(mode){this.journalMode=mode;this.mode='journal';$('puzzle-screen').hidden=true;$('journal-screen').hidden=false;$('journal-filters').hidden=mode!=='notes';$('journal-name').textContent={notes:'The city remembers.',map:'Signal atlas.',library:'Puzzle workshop.',trophies:'Restoration honours.'}[mode];
  $('journal-summary').textContent=`${this.sim.relays} relays · ${this.sim.relics.length} memories · ${this.sim.stars}★ · ${this.sim.districtInfo.name}`;
  for(const m of ['notes','map','library','trophies'])$('tab-'+m).setAttribute('aria-pressed',String(m===mode));const list=$('journal-list');list.replaceChildren();
  if(mode==='notes'){
   const q=$('journal-search').value.toLowerCase(),filter=$('journal-type').value,entries=this.sim.journal.filter(e=>(filter==='all'||e.type===filter)&&(e.note+' '+e.district).toLowerCase().includes(q));if($('journal-sort').value==='new')entries.reverse();
   if(!entries.length){const p=document.createElement('p');p.textContent='No matching memories yet. Restore a relay or change the filters.';list.append(p);}
   for(const e of entries){const a=document.createElement('article'),h=document.createElement('strong'),p=document.createElement('p');h.textContent=`RELAY ${e.relay} / ${e.district} / ${'★'.repeat(e.stars||1)}`;p.textContent=e.note;a.append(h,p);list.append(a);}
  }else if(mode==='library'){
   const p=document.createElement('p');p.textContent='Practice any puzzle without spending credits or changing your city progress. Daily boards use the UTC date.';list.append(p);
   for(const type of TYPES){const b=document.createElement('button');b.className='library-button';b.textContent=META[type].name;b.dataset.practice=type;b.addEventListener('click',()=>{this.practice=createPuzzle(TYPES.indexOf(type)+10*(this.variant++%30));this.beginPuzzle();});list.append(b);}
   const daily=document.createElement('button');daily.className='library-button';daily.id='daily-puzzle';daily.textContent='DAILY SIGNAL / '+new Date().toISOString().slice(0,10);daily.addEventListener('click',()=>{const day=Math.floor(Date.now()/86400000);this.practice=createPuzzle(day*10+day%10);this.beginPuzzle();});list.append(daily);
  }else if(mode==='trophies'){
   for(const t of TROPHIES){const a=document.createElement('article'),h=document.createElement('strong'),p=document.createElement('p');h.textContent=(this.sim.achievements.includes(t.id)?'★ EARNED / ':'◇ ')+t.name;p.textContent=t.detail+' · +30¢ once';a.append(h,p);list.append(a);}
  }else this.renderMap(list);
  list.scrollTop=0;
 }
 renderMap(list){const points=[...this.sim.restored,this.sim.relay],minX=Math.min(...points.map(p=>p.x))-160,minY=Math.min(...points.map(p=>p.y))-160,maxX=Math.max(...points.map(p=>p.x))+160,maxY=Math.max(...points.map(p=>p.y))+160,w=maxX-minX,h=maxY-minY;
  const svg=document.createElementNS('http://www.w3.org/2000/svg','svg');svg.classList.add('atlas');svg.setAttribute('viewBox',`${minX} ${minY} ${w} ${h}`);svg.setAttribute('aria-label','Restored relays and current destination');
  points.forEach((p,i)=>{const circle=document.createElementNS(svg.namespaceURI,'circle');circle.setAttribute('cx',p.x);circle.setAttribute('cy',p.y);circle.setAttribute('r',Math.max(w,h)/55);circle.setAttribute('fill',i===points.length-1?'#f4cd92':DISTRICTS[Math.floor((this.sim.relays-this.sim.restored.length+i)/3)%4].color);svg.append(circle);if(i){const line=document.createElementNS(svg.namespaceURI,'path');line.setAttribute('d',`M${points[i-1].x} ${points[i-1].y} L${p.x} ${p.y}`);line.setAttribute('stroke','#a1d6c6');line.setAttribute('stroke-width',Math.max(w,h)/250);svg.prepend(line);}});
  const player=document.createElementNS(svg.namespaceURI,'circle');player.setAttribute('cx',this.sim.player.x);player.setAttribute('cy',this.sim.player.y);player.setAttribute('r',Math.max(w,h)/70);player.setAttribute('fill','#fff');svg.append(player);list.append(svg);
  const tip=document.createElement('p');tip.textContent=`NEXT RELAY / ${META[this.sim.relay.puzzle.type].name} · ${Math.round(Math.hypot(this.sim.player.x-this.sim.relay.x,this.sim.player.y-this.sim.relay.y)/32)}m away. Select a restored relay to return safely.`;list.append(tip);
  this.sim.restored.forEach((p,i)=>{const b=document.createElement('button');b.className='library-button';b.dataset.travel=i;b.textContent='RETURN TO RELAY '+(this.sim.relays-this.sim.restored.length+i+1);b.addEventListener('click',()=>{if(this.sim.travel(i))this.close();});list.append(b);});
 }
 close(resume=true){if(this.practice&&resume){this.practice=null;this.showJournal('library');$('journal-close').focus({preventScroll:true});return;}$('puzzle-screen').hidden=true;$('journal-screen').hidden=true;this.opened=false;this.background(false);this.practice=null;this.sim.nextRelay();this.hooks.save();if(resume)this.hooks.resume();}
 tick(dt){if(this.opened&&this.mode==='puzzle'&&!this.solved){this.puzzle.elapsed+=dt;$('puzzle-timer').textContent=`${Math.floor(this.puzzle.elapsed)}s · PAR ${this.puzzle.par} MOVES`;}
  if(!this.opened)return;let pad;try{pad=[...(navigator.getGamepads?.()||[])].find(p=>p?.connected);}catch{}if(!pad){this.pad=[];return;}const pressed=i=>!!pad.buttons[i]?.pressed,edge=i=>pressed(i)&&!this.pad[i];
  if(edge(1)){this.close();}else if(edge(0))document.activeElement?.click?.();else if(edge(4)&&this.mode==='puzzle'){if(undo(this.puzzle))this.render();}else if(edge(5)&&this.mode==='puzzle')this.hint();
  const buttons=[...$(this.mode==='puzzle'?'puzzle-screen':'journal-screen').querySelectorAll('button:not(:disabled)')].filter(b=>b.getClientRects().length),index=buttons.indexOf(document.activeElement);
  if(edge(12)||edge(14))buttons[(index-1+buttons.length)%buttons.length]?.focus({preventScroll:true});if(edge(13)||edge(15))buttons[(index+1)%buttons.length]?.focus({preventScroll:true});this.pad=pad.buttons.map(b=>b.pressed);
 }
}
