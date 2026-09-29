# ECHO//LIFE

A mobile-first survival strategy roguelite where the world learns from how you play.

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
