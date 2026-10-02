# ECHO//LIFE v42 — Afterlight: 50 improvements

v42 is a separate playable release. v41 and all earlier builds retain their original files and paths. The HUD remains transparent. These are implemented changes relative to v41, not a future roadmap.

| # | Improvement | Implementation |
|---|---|---|
| 1 | Switch among three weapons using Q or the WEAPON button | `weapons.js`, `input.js`, `simulation.js` |
| 2 | Scatter shotgun with six spread pellets per shell | `weapons.js`, `simulation.js` |
| 3 | Lance rifle that pierces up to three enemies | `weapons.js`, `simulation.js` |
| 4 | Distinct magazine sizes, firing cadences and reload times for each weapon | `weapons.js`, `simulation.js` |
| 5 | Auto-aim leads moving enemies using projectile interception | `weapons.js` |
| 6 | Sticky target selection reduces flickering between similar targets | `simulation.js` |
| 7 | Critical shots deal 1.6× damage and use a distinct damage label | `simulation.js` |
| 8 | Damage falls off near the end of weapon range | `simulation.js` |
| 9 | Projectile impacts push enemies without pushing them through buildings | `simulation.js`, `world.js` |
| 10 | Floating damage numbers and score awards show hit results | `simulation.js`, `effects.js` |
| 11 | Brief hit-confirmation cross marks distinguish hits from muzzle flashes | `effects.js` |
| 12 | A shield absorbs damage before player health | `simulation.js`, `hud.js` |
| 13 | Shields regenerate after four seconds without damage | `simulation.js` |
| 14 | Shield breaks trigger a particle burst, ring flash and warning | `simulation.js`, `effects.js` |
| 15 | Timed kill chains raise the score multiplier, up to 4× | `simulation.js`, `hud.js` |
| 16 | Higher chains earn bonus credits | `simulation.js` |
| 17 | Collectible medkits add a capped consumable inventory | `simulation.js` |
| 18 | E or the MEDKIT button restores 35 health, with a cooldown | `input.js`, `simulation.js` |
| 19 | Best score survives page reloads | `storage.js` |
| 20 | Pause shows eliminations and run time, with a new-run action | `app.js`, `v42.html` |
| 21 | Ballistics purchases increase weapon damage by 15% per rank | `progression.js` |
| 22 | Shield-cell purchases increase capacity by 12 per rank | `progression.js` |
| 23 | Exosuit purchases increase movement speed by 8% per rank | `progression.js`, `simulation.js` |
| 24 | Phase-coil purchases reduce dash recharge by 10% per rank | `progression.js`, `simulation.js` |
| 25 | Recovery-link purchases increase pickup attraction distance | `progression.js`, `simulation.js` |
| 26 | Elite enemies have tougher armor, faster movement and bonus rewards | `simulation.js`, `effects.js` |
| 27 | A Warden boss enters every third level | `simulation.js`, `renderer.js` |
| 28 | Wardens telegraph a five-projectile attack fan | `simulation.js`, `renderer.js` |
| 29 | Wardens become faster and attack more often below 40% health | `simulation.js` |
| 30 | New enemies show a spawn-warning ring before they become active | `simulation.js`, `effects.js` |
| 31 | Gunners and Wardens cancel charged shots when buildings block sight | `simulation.js` |
| 32 | Pursuit pathfinding is limited to one planning request per simulation tick | `simulation.js` |
| 33 | Screen-edge arrows reveal nearby off-screen threats | `effects.js` |
| 34 | A critical-health border warns below 30 health without flashing | `effects.js` |
| 35 | Rooftop ventilation fans rotate | `effects.js` |
| 36 | Courier drones travel along city roads | `effects.js` |
| 37 | Roof signage pulses with each district's neon palette | `effects.js` |
| 38 | Cached moving cloud shadows add parallax depth | `effects.js` |
| 39 | Rain creates expanding ground ripples | `effects.js` |
| 40 | Player lighting includes a directional flashlight beam | `effects.js` |
| 41 | Shootable fuel cells explode and damage nearby actors | `simulation.js`, `effects.js` |
| 42 | Clustered fuel cells can chain-detonate | `simulation.js` |
| 43 | Radar distinguishes supply drops and explosive fuel cells | `renderer.js` |
| 44 | A compact HUD mode removes secondary information | `styles.css`, `app.js` |
| 45 | A left-handed mode swaps movement and action controls | `styles.css`, `app.js` |
| 46 | Touch control size is adjustable, capped to fit the screen | `styles.css`, `app.js` |
| 47 | Camera zoom is adjustable while preserving aspect ratio | `renderer.js`, `app.js` |
| 48 | Standard gamepads support movement, fire, dash, reload, weapons, medkits and pause | `input.js` |
| 49 | A fullscreen toggle supports browsers that expose the Fullscreen API | `app.js` |
| 50 | Display, control and sound preferences persist across reloads | `storage.js`, `app.js` |

## Controls and upgrades

WASD/arrows move. Space auto-aims and fires. Mouse aims and fires directly. Shift dashes, R reloads, Q switches weapons, E uses a medkit, and Escape pauses. Touch combines a held joystick and FIRE; weapon and medkit buttons sit above the action buttons. A standard mapped gamepad uses left stick to move, A/right trigger to fire, B to dash, X to reload, left bumper to change weapon, Y to heal, and Start to pause.

Pause and open **FIELD UPGRADES** to spend credits. Each of five upgrade types has three ranks with increasing prices. Open **DISPLAY + CONTROLS** to change HUD, handedness, control size, zoom or fullscreen. Best score and preferences are saved locally; a current run is not resumed after a reload.

## Validation

`node --test tests/echo-life/*.test.mjs` includes v41 regression checks, v42 combat/progression/AI/storage/gamepad tests, and three-minute simulations. `node scripts/build-echo-pages.mjs` validates both versions' module and asset graphs before staging. Chromium checks preserve v40/v41 gameplay and test v42 at desktop, landscape/mobile, and narrow portrait sizes, including weapon use, healing, shop purchases, saved preferences, transparent HUD and scaled left-handed controls. CI gates Pages deployment on these checks.

Effects, labels, fuel cells, bullets, enemies and visited tiles are bounded. Decorative motion honors reduced-motion/slow-frame settings. Core gameplay requires no external fonts, textures or game runtime downloads.
