# ECHO//LIFE v46 — Signal Gardens

Play `../v46.html`. Twenty puzzle families, calm exploration by default, transparent HUD, preserved weapons/upgrades, richer cached city artwork.

New rule families live in `advanced-puzzles.js`, board presentation in `board-details.js`, practice preferences/records in `workshop.js`, streetscape art in `gardens.js`. The existing family engine is reused through `puzzles.js`. Fixed-step gameplay, controls, saves and rendering remain separate modules.

Version 46 has separate run saves. The title screen can import a v45 run: completed relays, memories, inventory and exploration rewards carry over; the current unfinished relay starts with v46's new puzzle schedule. Practice records and favorites are local to this build. Hints are free and there are no deadlines.

Run `node --test tests/echo-life/*.test.mjs`, then `node scripts/build-echo-pages.mjs`. The Pages workflow runs Chromium tests at desktop, landscape and small-phone sizes before deploying main. Existing versions and other public repository pages remain available.
