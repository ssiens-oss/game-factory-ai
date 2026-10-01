# ECHO//LIFE

A mobile-first survival strategy roguelite where the world learns from how you play.

## Playable top-down shooter

**v40 is the preserved baseline.** It is the newest existing top-down scrolling build; earlier versions include different prototypes and camera experiments. Its HTML remains unchanged.

**v41 is the new development version.** Open `v41.html` through an HTTP server. Its small HTML entry loads native browser modules and a separate responsive stylesheet from `v41/`. There is no bundler, framework, CDN, or runtime package dependency.

The upgrade preserves the scrolling city, auto-aim shooting, hostile waves, health, ammunition, credits, district objectives, level progression, dash, and signal restoration. Movement, touch input, simulation, combat, rendering, and the HUD now have separate responsibilities so each can be developed and tested without editing a giant HTML file.

v41 adds detailed wet city tiles, rooftop equipment, neon signs, animated armored actors, rain, lighting, a radar, impact effects, and synthesized combat audio. Stalkers flank, gunners telegraph aimed shots, and chargers telegraph rushes; pursuit paths and projectiles respect building collision. Ammunition and health drops, reloading, and a credit-funded supply refill support continued play. Graphics use a bounded tile cache, cached actor art, visible-entity culling, capped canvas resolution, and capped effects. The fixed simulation step keeps movement and combat consistent across display refresh rates.

Controls: WASD or arrow keys to move, hold Space or FIRE for auto-aim shooting, mouse to aim and fire, Shift or DASH to dash, and R or RELOAD to reload. Escape or the pause button pauses the operation; losing focus pauses automatically. On touch devices, hold the left movement pad and the right FIRE button together. The HUD and touch controls adapt to portrait and landscape displays and respect safe-area insets. Sound can be muted from the HUD.

### Module map

| File | Responsibility |
| --- | --- |
| `v41.html`, `v41/styles.css` | Entry document, menus, responsive HUD and touch-control layout |
| `v41/app.js` | Startup, fixed-step loop, pause/resume, and module wiring |
| `v41/config.js` | Gameplay tuning, resource caps, shared math, and seeded randomness |
| `v41/simulation.js` | Player movement, combat, enemy behavior, pickups, progression, and respawn |
| `v41/world.js` | Building footprints, collision, line of sight, and bounded pursuit pathfinding |
| `v41/city.js` | Procedural district appearance and cached scrolling city tiles |
| `v41/renderer.js` | Camera, cached actor art, combat effects, weather, radar, and canvas sizing |
| `v41/input.js` | Keyboard, mouse, independent touch contacts, and input cancellation |
| `v41/hud.js` | Changed-value HUD updates and operation notifications |
| `v41/audio.js` | Gesture-unlocked synthesized sound, mute, and capped voices |

### Run locally

From the repository root:

```sh
python3 -m http.server 8080
```

Open `http://localhost:8080/echo_life/v41.html`. Native ES modules require HTTP; opening the HTML as a `file://` URL will fail in browsers. The historical build is available at `http://localhost:8080/echo_life/v40.html`.

### Validate and stage

```sh
node --test tests/echo-life/*.test.mjs
node scripts/build-echo-pages.mjs
```

The staging script follows v41's module imports and referenced stylesheet/assets, rejects missing files and URLs that would break on a GitHub project subpath, and copies the complete `echo_life` directory without changing old game files. The artifact contains both the original root paths and a nested `echo_life/` directory. Existing public Sudoku, frontend, and dashboard paths are copied unchanged when present: `sudoku.html`, `sudoku/`, `frontend/`, `dashboard/`, `saas/frontend/`, and `backend/dashboard/`.

For browser checks, install Playwright and Chromium, serve the staged artifact, and run the smoke script:

```sh
npm install --no-save --package-lock=false playwright@1.56.1
npx playwright install chromium
python3 -m http.server 4173 --directory .pages-stage
# In another terminal:
ECHO_BASE_URL=http://127.0.0.1:4173 node tests/echo-life/browser-smoke.cjs
```

### GitHub Pages

`.github/workflows/pages.yml` is the only Pages deployment workflow. It runs the Node tests, validates the staged asset graph, and checks the staged game in Chromium before uploading `.pages-stage`. A failed validation or smoke test blocks deployment. Changes to preserved public applications also trigger deployment. Concurrent runs share one Pages queue. Repository settings must use **GitHub Actions** as the Pages source.

Playable paths for `ssiens-oss/game-factory-ai`:

- Upgrade: `https://ssiens-oss.github.io/game-factory-ai/echo_life/v41.html`
- Equivalent root path: `https://ssiens-oss.github.io/game-factory-ai/v41.html`
- Preserved baseline: `https://ssiens-oss.github.io/game-factory-ai/v40.html` and `https://ssiens-oss.github.io/game-factory-ai/echo_life/v40.html`

All historical `echo_life` versions remain in the artifact at both root and nested paths. The original `index.html` remains the earlier survival prototype. The v41 entry does not register its service worker, avoiding stale cached modules from previous prototype releases.

### v41 release validation

The completed upgrade passed 11 simulation tests, 8 Pages staging tests, input/audio behavior assertions, and Chromium browser checks before publication. Browser coverage includes preserved v40, desktop 1440×900, landscape 844×390 and 667×375, portrait 390×844 and 320×568, both Pages paths, sustained multi-contact movement/fire, real projectile damage, reload, dash, pause, resource loading, and rendering caps.

The development validation run is [GitHub Actions 36897528796](https://github.com/ssiens-oss/game-factory-ai/actions/runs/36897528796). Its desktop sample measured 17.43ms average frame time, 27.1ms maximum simulation update, six cached city tiles, and 1,296,000 canvas backing pixels. These are CI measurements, not a guarantee for every phone. A deterministic three-minute combat test remained within all resource caps.

## Prototype v0.1

The first vertical slice is designed around a 72-hour countdown before The Collapse.

### Core loop
1. Explore a neighborhood.
2. Scavenge, trade, help, steal, fight, repair, or avoid.
3. Spend limited time and resources preparing for The Collapse.
4. Hidden behavior traits learn from player decisions.
5. At the end of a run, save an Echo profile that can influence later runs.

### Initial systems
- 72-hour game clock
- Health, energy, cash, inventory
- Top-down player movement
- Scavenging and randomized loot
- NPC encounters and decisions
- Hidden behavior model: empathy, aggression, greed, courage, deception, curiosity
- Collapse clues
- Echo profile generation
- Persistent previous-run memory

## Design rule
There is no universal good/evil meter. Actions build a behavioral fingerprint. Later NPCs, encounters, and Echoes react to that fingerprint.

## Android direction
Mobile-first, portrait/landscape adaptable, touch controls, offline core gameplay. The prototype should remain lightweight enough to build through GitHub Actions and install as an APK.
