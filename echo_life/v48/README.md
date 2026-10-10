# ECHO//LIFE v48 — Living Districts

Play `../v48.html`. This version fixes the vanished-enemy experience: light encounters are enabled by default, three distinct nearby patrols appear immediately, and their AI operates at the actual spawn distances. At most six enemies are active, with a 14-second reinforcement interval. Relays protect a 180-unit safe area; enemies visibly patrol outside it instead of being removed. Puzzle dialogs still pause the world. Peaceful exploration remains available in Display + Controls and is clearly labelled ENEMIES OFF.

Scouts pursue and flank, gunners keep range and telegraph shots, rushers telegraph charges. Rare wardens join after six restored relays. Distinct 3D silhouettes, health bars, ground attack warnings, and on-screen/edge name markers make encounters visible. Continue/import immediately restore nearby patrols without resetting inventory or puzzles.

Market stalls, planted gardens, station ticket kiosks and railings, and memory-quarter clock monuments create four distinct streetscape themes. Building heights, colours and roof profiles vary; service trams and unarmed pedestrians add ambient street life. Cosmetic scenery shares the existing traversable road layout. Twenty working puzzle families, transparent HUD, two 3D cameras, weapons, shops, touch controls, cached rendering and context recovery remain.

Run saves are separate from v47. Import v47 at the title screen, including unfinished puzzles. Existing display preferences carry over; patrols start enabled in this version. Your v48 peaceful choice persists if you deliberately enable it. All older versions remain available.

`node --test tests/echo-life/*.test.mjs` and Pages graph validation run before Chromium gameplay checks at four viewport sizes. Static tile GPU buffers remain bounded to 25 (9 at low quality), marker elements to six, and paused scenes reuse the last frame.
