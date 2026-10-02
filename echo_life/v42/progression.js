export const UPGRADES = Object.freeze({
  damage: { name: 'Ballistics', detail: '+15% weapon damage', cost: 160 },
  shield: { name: 'Shield cell', detail: '+12 shield capacity', cost: 140 },
  speed: { name: 'Exosuit', detail: '+8% movement speed', cost: 160 },
  dash: { name: 'Phase coil', detail: '10% faster dash recharge', cost: 180 },
  magnet: { name: 'Recovery link', detail: '+25m pickup attraction', cost: 100 },
});
export function upgradeCost(key, rank) { return Math.round(UPGRADES[key].cost * (1 + rank * 0.75)); }
export function buyUpgrade(sim, key) {
  const spec = UPGRADES[key], rank = sim.upgrades[key]; if (!spec || rank === undefined || rank >= 3) return false;
  const cost = upgradeCost(key, rank); if (sim.player.cash < cost) return false;
  sim.player.cash -= cost; sim.upgrades[key]++;
  if (key === 'shield') { sim.player.maxShield += 12; sim.player.shield = Math.min(sim.player.maxShield, sim.player.shield + 12); }
  sim.emit('upgrade', `${spec.name.toUpperCase()} · RANK ${rank + 1}`); return true;
}
