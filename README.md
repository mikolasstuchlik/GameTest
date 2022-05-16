# GameTest

Demonstrator for simle game in Swift using SDL2

## TODO
- General Refactoring:
  - Use single SystemLibrary for SDL
  - Use separate module for SDL extensions with inlining
- Audio:
  - Wrap AdPlug and use it to play sound
  - Use SDL Mixer to finalize output
- Collision:
  - Implement AABB
  - Implement immovable items
  - Implement collision resolution
- Sprites:
  - Implement animation
  - Implement custom color
  - Implement layers
- System:
  - Remove static collections and references
  - Use Entity pools
  - Use unowned(unsafe)