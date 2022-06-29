# GameTest

Demonstrator for simle game in Swift using SDL2. Should build on macOS and Linux.

## Dependencies
You need to have SDL2 with some extensions installed in order to run this program.

### macOS
On either Intel or Apple Silicone mac, use brew to install dependencies:
```bash
brew install sdl2 sdl2_image sdl2_ttf sdl2_mixer
```

### linux
Use Apt on Ubuntu to install dependencies:
```bash
sudo apt install libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev libsdl2-mixer-dev
```

## Compilation
After you have installed dependencies above, use SPM to build and run the game:
```
swift run
```

You're encouraged to experiment with build options like:

### Build mode
Use `-c` to specify build mode, default is `debug`:
```
swift run -c release
```

### Specify architecture
You may let the compiler know, that the program will run only on the same architecture as the architecture of your computer:
```
swift run -Xcc -march=native
```

*At the time of writing not supported on Apple Silicone macs*
### Measure performance
An compiled into the program measures various loop events. Use macro to enable it
```
swift run -Xswiftc -DMEASURE
```

## TODO
- Improvements:
  - Add circles to AABB detection and resolution
  - Adjust speed
  - Adjust animation timings

## Known issues
 - SDL2 Mixer will crash after calling Mix_CloseAudio when in debugging session

*Notice: The aim of this repository is not full game, only proof of concept. Full game will be forked from this repo in the future.*
