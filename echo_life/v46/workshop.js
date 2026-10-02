import { TYPES,META } from './puzzles.js';
const KEY='echo-life-v46-workshop';
export const CATEGORIES={logic:['pipes','lights','order','balance','lock','sudoku','nonogram','arithmetic','rank'],patterns:['tune','mosaic','compass','binary','glyph','orbit','word'],spatial:['slide','maze'],memory:['pairs','echo']};
export class Workshop {
 constructor(storage){try{this.storage=storage||globalThis.localStorage;const s=JSON.parse(this.storage?.getItem(KEY)||'{}');this.favorites=(Array.isArray(s.favorites)?s.favorites:[]).filter(t=>TYPES.includes(t));this.records=s.records&&typeof s.records==='object'?s.records:{};}catch{this.favorites=[];this.records={};}this.query='';this.category='all';this.onlyFavorites=false;this.tier=1;}
 save(){try{this.storage?.setItem(KEY,JSON.stringify({favorites:this.favorites,records:this.records}));}catch{}}
 favorite(t){if(!TYPES.includes(t))return;this.favorites=this.favorites.includes(t)?this.favorites.filter(v=>v!==t):[...this.favorites,t];this.save();}
 complete(p){if(!p.solved)return;const old=this.records[p.type]||{},count=Number.isInteger(old.count)?old.count:0;this.records[p.type]={count:Math.min(100000,count+1),best:Math.min(Number.isFinite(old.best)?old.best:Infinity,p.moves),time:Math.min(Number.isFinite(old.time)?old.time:Infinity,Math.floor(p.elapsed))};this.save();}
 visible(){return TYPES.filter(t=>(this.category==='all'||CATEGORIES[this.category]?.includes(t))&&(!this.onlyFavorites||this.favorites.includes(t))&&META[t].name.toLowerCase().includes(this.query.toLowerCase()));}
 number(t,variant){return TYPES.indexOf(t)+20*(variant%3+(this.tier-1)*3);}
 controls(container,render){const bar=document.createElement('div');bar.className='workshop-controls';
  const input=document.createElement('input');input.type='search';input.id='workshop-search';input.placeholder='Find a puzzle';input.setAttribute('aria-label','Search workshop');input.value=this.query;input.oninput=()=>{this.query=input.value;render();document.getElementById('workshop-search')?.focus();};bar.append(input);
  const select=document.createElement('select');select.id='workshop-category';select.setAttribute('aria-label','Puzzle category');for(const c of ['all',...Object.keys(CATEGORIES)])select.add(new Option(c.toUpperCase(),c));select.value=this.category;select.onchange=()=>{this.category=select.value;render();};bar.append(select);
  const tier=document.createElement('select');tier.id='workshop-tier';tier.setAttribute('aria-label','Practice tier');for(let i=1;i<=3;i++)tier.add(new Option('TIER '+i,i));tier.value=this.tier;tier.onchange=()=>{this.tier=Number(tier.value);};bar.append(tier);
  const favorites=document.createElement('button');favorites.id='workshop-favorites';favorites.textContent='★ FAVORITES';favorites.setAttribute('aria-pressed',this.onlyFavorites);favorites.onclick=()=>{this.onlyFavorites=!this.onlyFavorites;render();};bar.append(favorites);container.append(bar);
 }
}
