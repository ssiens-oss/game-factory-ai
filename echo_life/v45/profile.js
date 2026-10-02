import { Profile as Base } from '../v42/storage.js';
const KEY='echo-life-v45-options';
export const DEFAULTS={largeText:false,contrast:false,motion:false,haptics:false,quality:'auto',calm:true,oneHand:false,sensitivity:1,interactKey:'KeyF'};
export class Profile extends Base {
 constructor(storage){super(storage);this.options={...DEFAULTS};try{const d=JSON.parse(this.storage?.getItem(KEY)||'{}');for(const k of ['largeText','contrast','motion','haptics','calm','oneHand'])if(typeof d[k]==='boolean')this.options[k]=d[k];if(['auto','low','high'].includes(d.quality))this.options.quality=d.quality;if(['KeyF','KeyG','Enter'].includes(d.interactKey))this.options.interactKey=d.interactKey;if(Number.isFinite(d.sensitivity))this.options.sensitivity=Math.min(1.8,Math.max(.6,d.sensitivity));}catch{}}
 save(score){super.save(score);try{this.storage?.setItem(KEY,JSON.stringify(this.options));}catch{}}
}
