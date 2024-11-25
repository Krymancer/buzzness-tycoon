# Buzziness Tycoon

Buzziness Tycoon is a simple game that I'm working on to learn zig and have a excuse to use raylib.

## Concept

The game revolves around an isometric grid where flowers grow and potentially wither to make space for new ones. The player's task is to manage bees, collecting pollen to produce honey. Bees have a limited lifespan, so you'll need to invest in creating new bees as the older ones die off. The game ends if all your bees die and there's no pollen left to collect. I plan to implement an upgrade system to enhance the gameplay further.

## Screenshot

The current state of the game (or at least when I remember to update the screenshot) so you don't have to run the code

![Image](https://raw.githubusercontent.com/Krymancer/buzzness-tycoon/main/.github/game.png)

## Build

You can use debug for vscode if you have the C/C++ extension. 

Or if you have Zig installed:

```shell
zig build run # this will build and run the project
```

Or: 

```shell
zig build 
./zig-out/bin/buzzness-tycoon.exe # or only buzzness-tycoon if in unix
```