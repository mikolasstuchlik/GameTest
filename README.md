# GameTest

Demonstrator for simle game in Swift using SDL2. Should build on macOS and Linux.

## TODO
- Level:
  - Add player inventory and mine replenishment
  - Add bonuses
- Fixes:
  - Fix incorrect animation timing
  - [DONE] Fix incorrect wall stick collision
  - [DONE] Fix bug with audio on game exit
  - [DONE] Add structured solution for playback (deallocate music, etc.)
  - [DONE] Fix bug with noclip and mine walking

## Known issues
 - SDL2 Mixer will crash after calling Mix_CloseAudio when in debugging session

*Notice: The aim of this repository is not full game, only proof of concept. Full game will be forked from this repo in the future.*
