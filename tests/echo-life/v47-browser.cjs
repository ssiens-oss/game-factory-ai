'use strict';
const assert=require('node:assert/strict'),fs=require('node:fs'),path=require('node:path');
const {chromium}=require('playwright'),base=process.env.ECHO_BASE_URL||'http://127.0.0.1:4173',shots=process.env.ECHO_SCREENSHOTS;
const types=['pipes','lights','order','tune','slide','pairs','balance','mosaic','lock','maze','sudoku','nonogram','arithmetic','compass','binary','rank','glyph','echo','orbit','word'];
let browser;
async function screenshot(p,name){if(shots){fs.mkdirSync(shots,{recursive:true});await p.screenshot({path:path.join(shots,name+'.png')});}}
async function bounds(p,selectors){const {width,height}=p.viewportSize();for(const s of selectors){const b=await p.locator(s).boundingBox();assert(b,s+' visible');assert(b.x>=-1&&b.y>=-1&&b.x+b.width<=width+1&&b.y+b.height<=height+1,s+' fits '+JSON.stringify(b));}assert(await p.evaluate(()=>document.documentElement.scrollWidth<=innerWidth));}
async function solve(p){for(let n=0;n<300;n++){if(await p.evaluate(()=>window.__echo.puzzles.solved))return;await p.locator('#puzzle-hint').click();const b=p.locator('#puzzle-grid .hinted');assert.equal(await b.count(),1,'Hint marks a tile');await b.click();}throw Error('Puzzle failed to finish');}
async function moveToRelay(p){await p.evaluate(()=>{const s=window.__echo.sim;s.player.x=s.relay.x;s.player.y=s.relay.y;s.player.vx=s.player.vy=0;});await p.waitForFunction(()=>!document.getElementById('interact').disabled);}
(async()=>{
 browser=await chromium.launch({headless:true,args:['--no-sandbox','--disable-dev-shm-usage','--enable-unsafe-swiftshader']});
 for(const viewport of [{width:1440,height:900},{width:844,height:390},{width:390,height:844},{width:320,height:568}]){
  const c=await browser.newContext({viewport,hasTouch:viewport.width<900,isMobile:viewport.width<900,acceptDownloads:true}),p=await c.newPage(),errors=[],bad=[];
  p.on('pageerror',e=>{errors.push(e.message);console.error(e.message);});p.on('response',r=>{if(r.status()>=400&&!r.url().endsWith('favicon.ico'))bad.push(r.status()+' '+r.url());});
  await p.goto(base+'/echo_life/v47.html?test=1&seed=47');await p.waitForFunction(()=>window.__echo||!document.getElementById('boot-error').hidden);assert(await p.evaluate(()=>!!window.__echo),'v47 boot');
  assert(await p.evaluate(()=>!!window.__echo.renderer.gl),'Native WebGL context');
  await bounds(p,['#start']);await p.locator('#start').click();await p.keyboard.down('KeyD');await p.waitForFunction(()=>window.__echo.sim.player.x>115);await p.keyboard.up('KeyD');
  assert.equal(await p.evaluate(()=>window.__echo.sim.enemies.length),0,'Peaceful default');
  await p.waitForFunction(()=>window.__echo.renderer.tilesDrawn>0);assert.equal(await p.evaluate(()=>window.__echo.renderer.gl.getError()),0);
  const rendered=await p.evaluate(()=>{const r=window.__echo.renderer,gl=r.gl;r.draw(window.__echo.sim,0);const pixel=new Uint8Array(4);let count=0;for(let x=1;x<8;x++)for(let y=1;y<8;y++){gl.readPixels(Math.floor(gl.drawingBufferWidth*x/8),Math.floor(gl.drawingBufferHeight*y/8),1,1,gl.RGBA,gl.UNSIGNED_BYTE,pixel);if(Math.abs(pixel[0]-19)>5||Math.abs(pixel[1]-36)>5||Math.abs(pixel[2]-43)>5)count++;}return count;});assert(rendered>8,'3D geometry changes pixels');
  await p.locator('#camera-view').click();assert.equal(await p.evaluate(()=>window.__echo.renderer.overlook),false);await screenshot(p,`v47-${viewport.width}x${viewport.height}-street`);await p.locator('#camera-view').click();assert.equal(await p.evaluate(()=>window.__echo.renderer.overlook),true);
  if(viewport.width===1440){await p.evaluate(()=>{window.__lost=window.__echo.renderer.gl.getExtension('WEBGL_lose_context');window.__lost.loseContext();});await p.waitForFunction(()=>window.__echo.renderer.lost);assert.equal(await p.evaluate(()=>window.__echo.running),false);await p.evaluate(()=>window.__lost.restoreContext());await p.waitForFunction(()=>!window.__echo.renderer.lost);await p.locator('#resume').click();assert(await p.evaluate(()=>window.__echo.running));}
  await moveToRelay(p);await p.locator('#interact').click();assert.equal(await p.evaluate(()=>window.__echo.running),false);
  assert(await p.locator('#game').evaluate(el=>el.inert),'Dialog blocks background');
  await bounds(p,['.puzzle-card','#puzzle-grid','#puzzle-close']);
  const before=await p.evaluate(()=>window.__echo.sim.relay.puzzle.cells);
  await p.locator('#puzzle-hint').click();await p.locator('#puzzle-grid .hinted').click();
  await p.locator('#puzzle-undo').click();assert.deepEqual(await p.evaluate(()=>window.__echo.sim.relay.puzzle.cells),before);
  await p.locator('#puzzle-redo').click();assert.equal(await p.evaluate(()=>window.__echo.sim.relay.puzzle.moves),1);
  await solve(p);assert.equal(await p.evaluate(()=>window.__echo.sim.relays),1);await p.locator('#puzzle-close').click();assert(await p.evaluate(()=>window.__echo.running));
  for(const kind of ['relic','stash','fountain','resident']){
   await p.evaluate(kind=>{const s=window.__echo.sim,site=s.sites.find(p=>p.kind===kind);s.player.x=site.x;s.player.y=site.y;s.player.vx=s.player.vy=0;if(kind==='fountain')s.player.hp=50;},kind);
   await p.waitForFunction(kind=>{const b=document.getElementById('site-action');return !b.hidden&&b.dataset.kind===kind;},kind);await p.locator('#site-action').click();
  }
  assert.equal(await p.evaluate(()=>window.__echo.sim.relics.length),1);assert.equal(await p.evaluate(()=>window.__echo.sim.stashes.length),1);assert.equal(await p.evaluate(()=>window.__echo.sim.player.hp),70);
  await p.locator('#map').click();assert.equal(await p.locator('.atlas').count(),1);await bounds(p,['.journal-card','#journal-close']);await screenshot(p,`v47-${viewport.width}x${viewport.height}-atlas`);
  await p.locator('[data-travel="0"]').click();assert.equal(await p.evaluate(()=>window.__echo.sim.player.x),250);
  await p.locator('#journal').click();await p.locator('#journal-search').fill('Power');assert.equal(await p.locator('#journal-list article').count(),1);await p.locator('#journal-type').selectOption('pairs');assert.equal(await p.locator('#journal-list article').count(),0);await p.locator('#journal-type').selectOption('all');await p.locator('#journal-search').fill('');
  await p.locator('#tab-trophies').click();assert.equal(await p.locator('#journal-list article').count(),8);await screenshot(p,`v47-${viewport.width}x${viewport.height}-honours`);
  await p.locator('#tab-library').click();const cash=await p.evaluate(()=>window.__echo.sim.player.cash);
  for(const type of types){
   const b=p.locator(`[data-practice="${type}"]`);await b.scrollIntoViewIfNeeded();await b.click();
   assert.equal(await p.evaluate(()=>window.__echo.puzzles.puzzle.type),type);
   await bounds(p,['.puzzle-card','#puzzle-grid','#puzzle-close']);
   if(['sudoku','nonogram','echo','word','orbit'].includes(type))await screenshot(p,`v47-${viewport.width}x${viewport.height}-${type}`);
   await solve(p);await p.locator('#puzzle-close').click();assert.equal(await p.evaluate(()=>window.__echo.sim.relays),1);assert.equal(await p.evaluate(()=>window.__echo.sim.player.cash),cash);
  }
  await p.locator('[data-favorite="sudoku"]').scrollIntoViewIfNeeded();await p.locator('[data-favorite="sudoku"]').click();await p.locator('#workshop-favorites').click();assert.equal(await p.locator('[data-practice]').count(),1);await p.locator('#workshop-favorites').click();await p.locator('#workshop-category').selectOption('memory');assert.equal(await p.locator('[data-practice]').count(),2);await p.locator('#workshop-category').selectOption('all');await p.locator('#workshop-search').fill('binary');assert.equal(await p.locator('[data-practice]').count(),1);await p.locator('#workshop-search').fill('');
  await p.locator('#daily-puzzle').scrollIntoViewIfNeeded();await p.locator('#daily-puzzle').click();assert(await p.evaluate(()=>!!window.__echo.puzzles.practice));await p.locator('#puzzle-close').click();
  // Exercise paused controller input through the actual polling path.
  await p.locator('[data-practice="pipes"]').scrollIntoViewIfNeeded();await p.locator('[data-practice="pipes"]').click();await p.locator('#puzzle-hint').click();await p.locator('.hinted').focus();
  await p.evaluate(()=>{window.__testPad={connected:true,axes:[0,0],buttons:Array.from({length:16},()=>({pressed:false}))};navigator.getGamepads=()=>[window.__testPad];window.__testPad.buttons[0].pressed=true;});
  await p.waitForFunction(()=>window.__echo.puzzles.puzzle.moves===1);await p.evaluate(()=>{window.__testPad.buttons[0].pressed=false;});await p.waitForTimeout(50);
  await p.evaluate(()=>{window.__testPad.buttons[1].pressed=true;});await p.waitForFunction(()=>window.__echo.puzzles.mode==='journal');await p.evaluate(()=>{navigator.getGamepads=()=>[];});
  await p.locator('#journal-close').click();assert(await p.evaluate(()=>window.__echo.running));
  await p.locator('#pause').click();await p.locator('#preferences summary').click();
  await p.locator('#option-contrast').check();await p.locator('#option-largeText').check();await p.locator('#option-motion').check();await p.locator('#option-oneHand').check();await p.locator('#option-quality').selectOption('low');await p.locator('#option-interactKey').selectOption('KeyG');
  await p.locator('#save-tools summary').click();await p.locator('#save-now').click();assert.match(await p.locator('#save-status').textContent(),/saved/);
  const download=p.waitForEvent('download');await p.locator('#export-run').click();const file=await download;assert.equal(file.suggestedFilename(),'echo-life-v47-save.json');
  const portable=await p.evaluate(()=>window.__echo.checkpoint.encode(window.__echo.sim));
  await p.locator('#import-run').setInputFiles({name:'saved.json',mimeType:'application/json',buffer:Buffer.from(portable)});await p.waitForFunction(()=>document.getElementById('save-status').textContent==='Progress saved');assert.match(await p.locator('#save-status').textContent(),/saved/);
  await p.locator('#resume').click();assert(await p.evaluate(()=>document.body.classList.contains('high-contrast')&&document.body.classList.contains('large-text')));
  await bounds(p,['.topbar','#interact','.scoreline','.explore-status']);if(viewport.width<900)await bounds(p,['#joy']);const scoreBox=await p.locator('.scoreline').boundingBox(),exploreBox=await p.locator('.explore-status').boundingBox();assert(scoreBox.y+scoreBox.height<=exploreBox.y||exploreBox.y+exploreBox.height<=scoreBox.y,'Score and exploration rows do not overlap');await screenshot(p,`v47-${viewport.width}x${viewport.height}-city`);
  await moveToRelay(p);await p.keyboard.press('KeyG');assert(await p.locator('#puzzle-screen').isVisible());await p.keyboard.press('Escape');
  await p.reload();await p.waitForFunction(()=>window.__echo);await p.locator('#continue').click();assert.equal(await p.evaluate(()=>window.__echo.sim.relays),1);assert.equal(await p.evaluate(()=>window.__echo.sim.relics.length),1);
  await p.goto(base+'/v47.html?test=1&seed=47');await p.waitForFunction(()=>window.__echo||!document.getElementById('boot-error').hidden);assert(await p.evaluate(()=>!!window.__echo),'Root Pages alias boots');
  assert(await p.evaluate(()=>window.__echo.renderer.cache.size<=25),'3D tile cache bounded');assert.equal(await p.evaluate(()=>window.__echo.renderer.gl.getError()),0);assert.deepEqual(errors,[]);assert.deepEqual(bad,[]);console.log(`PASS v47 ${viewport.width}x${viewport.height}: twenty puzzles, practice, honours, atlas, sites, save/import, controller, accessibility`);await c.close();
 }
})().catch(e=>{console.error(e);process.exitCode=1;}).finally(async()=>{if(browser)await browser.close();});
