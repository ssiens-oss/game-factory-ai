const KEY = 'echo-life-v42';
const defaults = { best: 0, settings: { compact: false, leftHanded: false, controlScale: 1, zoom: 1, muted: false } };
export class Profile {
  constructor(storage) {
    if (storage === undefined) { try { storage = globalThis.localStorage; } catch {} }
    this.storage = storage; this.best = 0; this.settings = { ...defaults.settings };
    try {
      const data = JSON.parse(storage?.getItem(KEY) || '{}');
      if (Number.isFinite(data.best)) this.best = Math.max(0, data.best);
      for (const key of ['compact', 'leftHanded', 'muted']) if (typeof data.settings?.[key] === 'boolean') this.settings[key] = data.settings[key];
      for (const key of ['controlScale', 'zoom']) if (Number.isFinite(data.settings?.[key])) this.settings[key] = Math.max(0.8, Math.min(1.3, data.settings[key]));
    } catch { /* Corrupted or blocked storage must never prevent a run. */ }
  }
  save(score) {
    if (Number.isFinite(score)) this.best = Math.max(this.best, Math.floor(score));
    try { this.storage?.setItem(KEY, JSON.stringify({ best: this.best, settings: this.settings })); } catch {}
  }
}
