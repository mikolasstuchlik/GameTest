#ifndef CSDL2_H
#define CSDL2_H

struct SDL_Texture {};
struct SDL_Renderer {};
struct SDL_Window {};
struct _TTF_Font {};
struct _Mix_Music {};
struct _Mix_Chunk {};
//struct SDL_RWops {};

// On M1 mac Homebrew installs the package into separate directory
#ifdef __aarch64__ && __APPLE__
#include <SDL.h>
#include <SDL_image.h>
#include <SDL_ttf.h>
#include <SDL_mixer.h>
#else
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>
#include <SDL2/SDL_ttf.h>
#include <SDL2/SDL_mixer.h>
#endif

#endif /* CSDL2_H */
