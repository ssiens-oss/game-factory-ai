# ECHO//LIFE v45 — Thousand Lights

100 implemented improvements over v44. Older builds, transparent HUD, weapons and upgrades remain available. Peaceful exploration is the default.

1. Sliding-tile puzzles with a movable blank — [puzzles.js](puzzles.js).
2. Memory-pair puzzles with four symbol pairs — [puzzles.js](puzzles.js).
3. Weighted-balance puzzles with three weighted dials — [puzzles.js](puzzles.js).
4. Mosaic puzzles with coupled colour/symbol changes — [puzzles.js](puzzles.js).
5. Combination locks deduced from three sum clues — [puzzles.js](puzzles.js).
6. Navigable 4×4 relay mazes — [puzzles.js](puzzles.js).
7. Perfect-maze generation with a guaranteed path — [puzzles.js](puzzles.js).
8. Vector pipe artwork replaces text glyphs on circuit boards — [puzzle-art.js](puzzle-art.js).
9. Lights Out previews which neighbours a tile affects — [puzzle-art.js](puzzle-art.js).
10. Frequency-dial backgrounds show the current phase — [puzzle-art.js](puzzle-art.js).
11. Mosaic tiles display both current and target symbols — [puzzle-art.js](puzzle-art.js).
12. Unmatched memory cards remain revealed until the next tap — [puzzles.js](puzzles.js).
13. Hinted tiles receive a visible highlight — [puzzle-ui.js](puzzle-ui.js).
14. Redo complements undo on unfinished puzzles — [puzzles.js](puzzles.js).
15. Arrow keys navigate boards and move through mazes — [puzzle-ui.js](puzzle-ui.js).
16. Number keys 1–9 activate board tiles — [puzzle-ui.js](puzzle-ui.js).
17. One to three restoration stars reflect move efficiency — [simulation.js](simulation.js).
18. Live progress labels explain remaining pairs, lights or aligned dials — [puzzles.js](puzzles.js).
19. Elapsed puzzle time is shown without imposing a deadline — [puzzle-ui.js](puzzle-ui.js).
20. Three puzzle tiers increase sliding/mosaic scrambles across a run — [puzzles.js](puzzles.js).
21. UTC daily practice boards are reproducible — [puzzle-ui.js](puzzle-ui.js).
22. The workshop exposes all ten puzzle families for practice — [puzzle-ui.js](puzzle-ui.js).
23. Practice completion leaves run rewards and objectives unchanged — [puzzle-ui.js](puzzle-ui.js).
24. Repeated workshop selections create different deterministic variants — [puzzle-ui.js](puzzle-ui.js).
25. Expandable explanations teach each family’s rules — [puzzle-ui.js](puzzle-ui.js).
26. Checkpointed undo and redo survive reloading — [checkpoint.js](checkpoint.js).
27. Memory cards retain reveals and matches in a saved run — [puzzles.js](puzzles.js).
28. Saved mazes retain their current signal position — [puzzles.js](puzzles.js).
29. Sliding boards mark currently movable neighbours — [puzzle-ui.js](puzzle-ui.js).
30. Illegal tile actions do not increase the move count — [puzzles.js](puzzles.js).
31. An SVG atlas shows the restoration network — [puzzle-ui.js](puzzle-ui.js).
32. The atlas marks the player and the next relay — [puzzle-ui.js](puzzle-ui.js).
33. Restored relays offer free return travel — [simulation.js](simulation.js).
34. The HUD previews the next relay’s puzzle family — [puzzle-ui.js](puzzle-ui.js).
35. Explored districts are tracked and counted — [simulation.js](simulation.js).
36. Journal memories can be searched by text — [puzzle-ui.js](puzzle-ui.js).
37. Journal memories can be filtered by puzzle family — [puzzle-ui.js](puzzle-ui.js).
38. Journal memories can be sorted oldest or newest first — [puzzle-ui.js](puzzle-ui.js).
39. Eight restoration honours have explicit unlock criteria — [simulation.js](simulation.js).
40. Honours award a one-time 30-credit grant — [simulation.js](simulation.js).
41. Collectible memory fragments grant exploration score — [simulation.js](simulation.js).
42. Supply caches grant credits without combat — [simulation.js](simulation.js).
43. Healing fountains restore health with a 30-second cooldown — [simulation.js](simulation.js).
44. Named residents offer district-specific dialogue — [simulation.js](simulation.js).
45. New-district arrival messages announce exploration progress — [simulation.js](simulation.js).
46. Relay distance is consistently expressed as 32 world units per metre — [renderer.js](renderer.js).
47. The HUD shows district restoration percentage — [puzzle-ui.js](puzzle-ui.js).
48. Every ten restored relays earns a 200-credit grant — [simulation.js](simulation.js).
49. Peaceful exploration defaults on and patrol combat remains optional — [profile.js](profile.js).
50. The current relay has a pulsing restoration ring — [scene.js](scene.js).
51. Fountain basins add detailed street landmarks — [scene.js](scene.js).
52. Resident sprites have distinct district colours — [scene.js](scene.js).
53. Fabric banners animate across shopfronts — [scene.js](scene.js).
54. Coloured awnings enrich shop facades — [scene.js](scene.js).
55. Street murals add reconnect/remember signs — [scene.js](scene.js).
56. District-coloured pavement markers add street guidance — [scene.js](scene.js).
57. Two bounded fog strips add atmospheric depth — [scene.js](scene.js).
58. Garden districts include drifting fireflies — [scene.js](scene.js).
59. Ambient trams move along the road axis — [scene.js](scene.js).
60. Animated billboards cycle city messages — [scene.js](scene.js).
61. Windows illuminate near restored relays — [scene.js](scene.js).
62. Puddles reflect district neon — [scene.js](scene.js).
63. Canopy shadows ground the shopfront artwork — [scene.js](scene.js).
64. A gentle ambient dawn tint shifts over time — [scene.js](scene.js).
65. Animated fountain water jets add movement to landmarks — [scene.js](scene.js).
66. Atlas nodes use their own district colours — [puzzle-ui.js](puzzle-ui.js).
67. Memory fragments and supply caches have distinct glint artwork — [scene.js](scene.js).
68. Relay completion produces a vertical restoration beam — [scene.js](scene.js).
69. Bounded confetti celebrates completed relays — [scene.js](scene.js).
70. Each puzzle family has a distinct panel accent colour — [puzzle-ui.js](puzzle-ui.js).
71. Large-text preferences improve puzzle and journal readability — [profile.js](profile.js).
72. High-contrast preferences strengthen labels and board borders — [styles.css](styles.css).
73. A reduced-decoration option freezes added ambient motion — [profile.js](profile.js).
74. Haptic feedback can be independently enabled or disabled — [app.js](app.js).
75. Automatic, low-motion and full-detail quality settings are available — [profile.js](profile.js).
76. The relay interaction key can be remapped to F, G or Enter — [profile.js](profile.js).
77. Movement sensitivity is adjustable from 0.6 to 1.8 — [app.js](app.js).
78. Full-screen panels respect viewport height and safe-area controls — [styles.css](styles.css).
79. Board focus is preserved without scrolling after actions — [puzzle-ui.js](puzzle-ui.js).
80. Background HUD, canvas and touch controls become inert during dialogs — [puzzle-ui.js](puzzle-ui.js).
81. Dialog focus trapping includes search fields and select controls — [puzzle-ui.js](puzzle-ui.js).
82. Gamepad D-pad/A/B/bumpers navigate puzzles and dialogs — [puzzle-ui.js](puzzle-ui.js).
83. A simple peaceful touch layout centres movement and hides combat buttons — [styles.css](styles.css).
84. First-relay guidance explains finding and restoring a signal — [puzzle-ui.js](puzzle-ui.js).
85. Expanded shortcut help covers atlas, workshop and puzzle actions — [puzzle-ui.js](puzzle-ui.js).
86. A valid previous checkpoint is retained as a recovery backup — [checkpoint.js](checkpoint.js).
87. Checkpoint envelopes include an integrity checksum — [checkpoint.js](checkpoint.js).
88. Save payloads and imported files are bounded to 64 KiB — [checkpoint.js](checkpoint.js).
89. Saved currency, ammo, score and upgrade ranks require valid integers — [checkpoint.js](checkpoint.js).
90. Loaded magazines are clamped to the active weapon’s capacity — [checkpoint.js](checkpoint.js).
91. Save files are validated before gameplay state is applied — [checkpoint.js](checkpoint.js).
92. A separate v44 import preserves exploration progress in v45 — [checkpoint.js](checkpoint.js).
93. Visible save status distinguishes success and unavailable storage — [app.js](app.js).
94. A manual Save Now action complements autosave — [app.js](app.js).
95. Run exports download a portable JSON save — [app.js](app.js).
96. Run imports validate portable JSON before loading — [app.js](app.js).
97. Visibility changes save the run before pausing — [app.js](app.js).
98. Upgrade purchases immediately checkpoint their rewards and cost — [app.js](app.js).
99. Pages staging validates the complete v45 dependency graph — [../../scripts/build-echo-pages.mjs](../../scripts/build-echo-pages.mjs).
100. A dedicated v45 browser suite guards puzzle variety and both Pages paths — [../../tests/echo-life/v45-browser.cjs](../../tests/echo-life/v45-browser.cjs).

Puzzle tiers are guidance, not deadlines. Practice offers no run rewards. Local storage is required for persistence; export is available when storage is blocked.
