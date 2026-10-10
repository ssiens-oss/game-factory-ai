# ECHO//LIFE v47 — City in Depth

Play `../v47.html`. Native WebGL renders an elevated perspective city with solid buildings, lit facades, rooftops, trees, street furniture, animated residents, fountain water, floating relays and projectiles. OVERLOOK and STREET camera presets follow the player. Movement stays aligned with the streets; mouse aiming projects onto the ground plane.

The working v46 simulation, twenty puzzle families, workshop, inventory, collision, peaceful default and transparent HUD are reused. v47 run saves are separate. Import v46 exploration and unfinished puzzle state from the title screen. v46 and earlier builds remain playable.

Modules: `renderer.js` handles GPU buffers and context recovery, `city3d.js` builds scenery and actors, `math3d.js` handles perspective/rays, `geometry.js` batches solid meshes. Static tile GPU buffers are cached and deleted outside the visible 25-tile area (9 in low detail). Pixel density is capped. Paused scenes reuse the last rendered frame until state, camera or viewport changes. No CDN dependencies. WebGL support is required; the error panel links to v46 if unavailable.

Validation: `node --test tests/echo-life/*.test.mjs`, Pages dependency staging, and Chromium at desktop/landscape/portrait/small-phone sizes. Browser tests verify actual WebGL pixels, both cameras, all puzzle families, controller actions, save/import and both Pages URLs before main deployment.
