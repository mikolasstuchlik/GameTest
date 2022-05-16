# GameTest

Demonstrator for simle game in Swift using SDL2. Should build on macOS and Linux.

## TODO
- General Refactoring:
  - DONE Use single SystemLibrary for SDL
  - CANT Use separate module for SDL extensions with inlining - We want extensions on Pointers
- Audio:
  - Wrap AdPlug and use it to play sound
  - Use SDL Mixer to finalize output
- Collision:
  - DONE Implement AABB
  - DONE Implement immovable items
  - Implement collision resolution
- Sprites:
  - Implement animation
  - DONE Implement layers
  - DONE Use shared texture instances (avoid superfluous texture loadings)
- System:
  - Use RTC based system to compute movements
  - DONE Remove static collections and references
  - DONE Use Entity pools
  - DONE Use unowned(unsafe)
  - DONE Use inout instead of pointers
