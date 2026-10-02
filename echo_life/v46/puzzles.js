import * as legacy from '../v45/puzzles.js';
import { EXTRA,EXTRA_META,createAdvanced,advancedLegal,advance,advancedHint,advancedProgress,legalAdvancedState } from './advanced-puzzles.js';
export { pipeGlyph,connected } from '../v45/puzzles.js';
export const TYPES=[...legacy.TYPES,...EXTRA],META={...legacy.META,...EXTRA_META};
const extra=p=>EXTRA.includes(p.type),clone=v=>JSON.parse(JSON.stringify(v));
const legacyNumber=n=>Math.floor(n/20)*10+n%20;
export function createPuzzle(n){if(n%20>=10)return createAdvanced(n,TYPES[n%20]);const p=legacy.createPuzzle(legacyNumber(n));p.number=n;return p;}
export const state=p=>legacy.state(p);
export const canAct=(p,i)=>extra(p)?advancedLegal(p,i):legacy.canAct(p,i);
export function act(p,i){if(!extra(p))return legacy.act(p,i);if(!canAct(p,i))return false;p.history.push(state(p));if(p.history.length>50)p.history.shift();p.redo=[];return advance(p,i);}
export const undo=p=>legacy.undo(p),redo=p=>legacy.redo(p);
export const nextHint=p=>extra(p)?advancedHint(p):legacy.nextHint(p);
export const progress=p=>extra(p)?advancedProgress(p):legacy.progress(p);
export const exportPuzzle=p=>legacy.exportPuzzle(p);
export function restorePuzzle(n,data){if(n%20<10){const p=legacy.restorePuzzle(legacyNumber(n),data);p.number=n;return p;}const p=createPuzzle(n);if(data?.type!==p.type||!legalAdvancedState(p,data))return p;Object.assign(p,state(data));p.history=Array.isArray(data.history)?data.history.filter(s=>legalAdvancedState(createPuzzle(n),s)).slice(-50).map(clone):[];p.redo=Array.isArray(data.redo)?data.redo.filter(s=>legalAdvancedState(createPuzzle(n),s)).slice(-50).map(clone):[];p.elapsed=Number.isFinite(data.elapsed)?Math.max(0,Math.min(86400,data.elapsed)):0;p.hints=Number.isInteger(data.hints)?Math.max(0,Math.min(10000,data.hints)):0;return p;}
