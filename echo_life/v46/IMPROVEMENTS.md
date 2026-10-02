# ECHO//LIFE v46 — Signal Gardens

100 implemented additions over v45. Calm exploration and transparent HUD remain the default; old versions are preserved.

1. Pocket Sudoku introduces row, column and box reasoning — [advanced-puzzles.js](advanced-puzzles.js).
2. Sudoku generation shuffles 1–4 deterministically — [advanced-puzzles.js](advanced-puzzles.js).
3. Sudoku clues cannot be changed — [advanced-puzzles.js](advanced-puzzles.js).
4. Sudoku accepts valid alternative solutions — [advanced-puzzles.js](advanced-puzzles.js).
5. Picture logic introduces 4×4 nonograms — [advanced-puzzles.js](advanced-puzzles.js).
6. Nonogram clues describe separated runs — [advanced-puzzles.js](advanced-puzzles.js).
7. Generated nonograms have consistent row and column clues — [advanced-puzzles.js](advanced-puzzles.js).
8. Nonograms accept any picture satisfying all clues — [advanced-puzzles.js](advanced-puzzles.js).
9. Number equations combine sum, difference and product reasoning — [advanced-puzzles.js](advanced-puzzles.js).
10. Equation clues handle negative differences — [advanced-puzzles.js](advanced-puzzles.js).
11. Equation digits cycle independently through 0–9 — [advanced-puzzles.js](advanced-puzzles.js).
12. Equation hints locate an unfinished digit — [advanced-puzzles.js](advanced-puzzles.js).
13. Compass puzzles translate landmark clues into bearings — [advanced-puzzles.js](advanced-puzzles.js).
14. Compass clues describe clockwise quarter turns — [advanced-puzzles.js](advanced-puzzles.js).
15. Compass controls cycle north, east, south and west — [advanced-puzzles.js](advanced-puzzles.js).
16. Compass hints follow landmark bearings — [advanced-puzzles.js](advanced-puzzles.js).
17. Binary beacons introduce weighted bit composition — [advanced-puzzles.js](advanced-puzzles.js).
18. Binary targets cover values 1–15 — [advanced-puzzles.js](advanced-puzzles.js).
19. Binary lamps use weights 8, 4, 2 and 1 — [advanced-puzzles.js](advanced-puzzles.js).
20. Binary completion verifies the target pattern — [advanced-puzzles.js](advanced-puzzles.js).
21. Priority dispatch introduces numeric ordering — [advanced-puzzles.js](advanced-puzzles.js).
22. Messages receive shuffled priorities — [advanced-puzzles.js](advanced-puzzles.js).
23. Dispatch prevents repeated message selections — [advanced-puzzles.js](advanced-puzzles.js).
24. Dispatch hints recover incorrect partial chains — [advanced-puzzles.js](advanced-puzzles.js).
25. Row harmonics introduces whole-row symbol changes — [advanced-puzzles.js](advanced-puzzles.js).
26. Row-harmonic scrambles use reversible shifts — [advanced-puzzles.js](advanced-puzzles.js).
27. Row-harmonic targets use three symbols — [advanced-puzzles.js](advanced-puzzles.js).
28. Row-harmonic hints identify a misaligned row — [advanced-puzzles.js](advanced-puzzles.js).
29. Echo rehearsal introduces five-note melody replay — [advanced-puzzles.js](advanced-puzzles.js).
30. Echo scores allow repeated notes — [advanced-puzzles.js](advanced-puzzles.js).
31. Echo mistakes reset immediately without a timer — [advanced-puzzles.js](advanced-puzzles.js).
32. Echo hints identify the next instrument — [advanced-puzzles.js](advanced-puzzles.js).
33. Orbital alignment introduces clockwise ring rotation — [advanced-puzzles.js](advanced-puzzles.js).
34. Orbit goals vary across seven starting offsets — [advanced-puzzles.js](advanced-puzzles.js).
35. Orbit boards maintain exactly one beacon — [advanced-puzzles.js](advanced-puzzles.js).
36. Orbit completion verifies the destination — [advanced-puzzles.js](advanced-puzzles.js).
37. Word restoration introduces five-letter city vocabulary — [advanced-puzzles.js](advanced-puzzles.js).
38. Word boards provide definition clues — [advanced-puzzles.js](advanced-puzzles.js).
39. Word positions cycle through separate letter choices — [advanced-puzzles.js](advanced-puzzles.js).
40. Word generation covers six familiar city words — [advanced-puzzles.js](advanced-puzzles.js).
41. Sudoku candidates show currently permitted values — [board-details.js](board-details.js).
42. Sudoku duplicates receive conflict outlines — [board-details.js](board-details.js).
43. Sudoku box boundaries receive thicker borders — [board-details.js](board-details.js).
44. Sudoku givens use dotted borders and distinct fill — [board-details.js](board-details.js).
45. Nonogram row and column clues appear as ordered lists — [board-details.js](board-details.js).
46. Nonogram cell tooltips describe both intersecting clues — [board-details.js](board-details.js).
47. Nonogram progress counts satisfied lines — [board-details.js](board-details.js).
48. Compass buttons combine direction letters and arrows — [board-details.js](board-details.js).
49. Binary buttons show individual lamp weights — [board-details.js](board-details.js).
50. Dispatch buttons show names and priorities — [board-details.js](board-details.js).
51. Echo scores mark the next note with an arrow — [board-details.js](board-details.js).
52. Echo buttons combine note names and music symbols — [board-details.js](board-details.js).
53. Orbit artwork distinguishes beacon and destination — [board-details.js](board-details.js).
54. Word tooltips list available letters — [board-details.js](board-details.js).
55. Row harmonics previews the affected row on hover or focus — [board-details.js](board-details.js).
56. City relay rotation includes all twenty families — [puzzle-ui.js](puzzle-ui.js).
57. Journal filters include new puzzle families — [puzzle-ui.js](puzzle-ui.js).
58. Workshop exposes every new family without run rewards — [puzzle-ui.js](puzzle-ui.js).
59. Puzzle panels display board-specific clue text — [puzzle-ui.js](puzzle-ui.js).
60. Dispatch and melody panels show the played sequence — [puzzle-ui.js](puzzle-ui.js).
61. Move meter shows the efficiency guide — [puzzle-ui.js](puzzle-ui.js).
62. Puzzle panels show hint counts and explain free help — [puzzle-ui.js](puzzle-ui.js).
63. Completed puzzle panels receive a restoration glow — [styles.css](styles.css).
64. Keyboard navigation uses four columns for Sudoku and nonograms — [puzzle-ui.js](puzzle-ui.js).
65. Gamepad undo immediately checkpoints its change — [puzzle-ui.js](puzzle-ui.js).
66. Workshop search filters puzzle names — [workshop.js](workshop.js).
67. Categories group logic, patterns, spatial and memory puzzles — [workshop.js](workshop.js).
68. Favorites can be toggled per family — [workshop.js](workshop.js).
69. Workshop can show only favorite families — [workshop.js](workshop.js).
70. Favorites persist independently of run saves — [workshop.js](workshop.js).
71. Practice records retain completion count and best moves — [workshop.js](workshop.js).
72. Practice records retain fastest elapsed time — [workshop.js](workshop.js).
73. Workshop rows display completion records or NEW labels — [puzzle-ui.js](puzzle-ui.js).
74. Practice tier selector preserves the selected tier across variants — [workshop.js](workshop.js).
75. Workshop filters show an explicit empty-result message — [puzzle-ui.js](puzzle-ui.js).
76. Workshop controls remain visible while scrolling — [styles.css](styles.css).
77. Blocked storage preserves in-memory favorites and practice — [workshop.js](workshop.js).
78. Cafe terraces add shaded umbrellas with seam lines — [gardens.js](gardens.js).
79. Cafe tables include warm tabletop lights and chairs — [gardens.js](gardens.js).
80. Raised beds add brick rims and soil — [gardens.js](gardens.js).
81. Garden beds include shaded leaves and three flower palettes — [gardens.js](gardens.js).
82. Bicycle silhouettes include wheels, frames and a parking rack — [gardens.js](gardens.js).
83. Pavement includes inset drain grates — [gardens.js](gardens.js).
84. Benches include wooden slats, legs and ground shadows — [gardens.js](gardens.js).
85. A newspaper kiosk displays an ECHO front — [gardens.js](gardens.js).
86. Crossings add dotted tactile paving — [gardens.js](gardens.js).
87. Rooftops add solar panels with divided cells — [gardens.js](gardens.js).
88. Rooftops add vent housings and grille slits — [gardens.js](gardens.js).
89. Pavement medallions add district-coloured mosaic stones — [gardens.js](gardens.js).
90. Animated pavement ripples enrich the streets — [gardens.js](gardens.js).
91. Butterflies drift around planted beds — [gardens.js](gardens.js).
92. District artwork uses a bounded four-tile cache — [gardens.js](gardens.js).
93. Garden rendering caps visible draws and respects reduced motion — [gardens.js](gardens.js).
94. Version 46 runs use independent save storage — [checkpoint.js](checkpoint.js).
95. v45 migration retains collections and exploration rewards — [checkpoint.js](checkpoint.js).
96. Checkpoints preserve all twenty completed family names — [checkpoint.js](checkpoint.js).
97. New-family imports validate immutable rules and reject completed reward states — [advanced-puzzles.js](advanced-puzzles.js).
98. Generation tests solve 800 boards across twenty families — [../../tests/echo-life/v46.test.mjs](../../tests/echo-life/v46.test.mjs).
99. Chromium exercises twenty families at four viewport sizes — [../../tests/echo-life/v46-browser.cjs](../../tests/echo-life/v46-browser.cjs).
100. Pages staging validates the full v46 dependency graph — [../../scripts/build-echo-pages.mjs](../../scripts/build-echo-pages.mjs).
