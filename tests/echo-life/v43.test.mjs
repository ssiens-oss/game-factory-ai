import test from 'node:test';
import assert from 'node:assert/strict';
import {Simulation} from '../../echo_life/v43/simulation.js';
import {createPuzzle,act,hint} from '../../echo_life/v43/puzzles.js';
import {isSolid} from '../../echo_life/v42/world.js';
test('all puzzle variants solve, invalid orders retry',()=>{for(const [n,steps] of [[0,[3,4,5]],[1,[0,4,8]],[2,[0,1,2,3]],[5,[3,2,1,0]]]){const p=createPuzzle(n);for(const i of steps)act(p,i);assert(p.solved);assert(!act(p,0));}const p=createPuzzle(2);for(const i of [3,2,1,0])act(p,i);assert(!p.solved);assert.deepEqual(p.chosen,[]);assert(!act(p,-1));});
test('hints solve altered light boards',()=>{const p=createPuzzle(1);act(p,2);act(p,7);for(let j=0;j<10&&!p.solved;j++)act(p,Number(hint(p).match(/tile (\d+)/)[1])-1);assert(p.solved);});
test('rewards gated by proximity, once only, relays advance levels',()=>{const s=new Simulation(43);assert(!s.solveAction(3));s.kill({x:90,y:90,type:'stalker'});assert.equal(s.player.obj,0);for(const steps of [[3,4,5],[0,4,8],[0,1,2,3]]){s.player.x=s.relay.x;for(const i of steps)s.solveAction(i);const score=s.score;assert(!s.solveAction(0));assert.equal(s.score,score);s.nextRelay();}assert.equal(s.relays,3);assert.equal(s.player.lvl,2);assert.equal(s.restored.length,3);s.reset();assert.equal(s.relays,0);assert.equal(s.player.goal,3);});
test('patrol pressure bounded, relays safe and accessible',()=>{const s=new Simulation(43);assert.equal(s.enemies.length,4);for(let i=0;i<3600;i++)s.update(1/60);assert(s.enemies.length<=6);assert.equal(s.player.hp,100);for(let n=0;n<24;n++){s.relays=n;s.makeRelay();assert(!isSolid(s.relay.x,90,15));}s.player.x=s.relay.x;s.player.shield=0;s.damagePlayer(100);assert.equal(s.player.hp,100);});
