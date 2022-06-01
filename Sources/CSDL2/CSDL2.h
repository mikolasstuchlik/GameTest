#ifndef CSDL2_H
#define CSDL2_H

struct SDL_Texture {};
struct SDL_Renderer {};
struct SDL_Window {};
struct _TTF_Font {};

// On M1 mac Homebrew installs the package into separate directory
#ifdef __aarch64__ && __APPLE__
#include <SDL.h>
#include <SDL_image.h>
#include <SDL_ttf.h>
#else
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <SDL2/SDL_ttf.h>
#endif

#endif /* CSDL2_H */
