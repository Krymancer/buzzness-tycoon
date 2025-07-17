# Buzzness Tycoon - Game Design Document

## Overview

Buzzness Tycoon is an isometric grid-based game developed in Zig using the Raylib graphics library. The game centers around managing bees that collect pollen from flowers to produce honey, creating a simple but engaging resource management experience.

## Game Concept

Players manage a colony of bees on an isometric grid populated with flowers. The core gameplay loop involves:

1. **Bees collect pollen** from mature flowers
2. **Pollen is converted to honey** (the primary resource)
3. **Honey is spent to purchase new bees** to expand the colony
4. **Bees have limited lifespans** and die after a certain time
5. **Flowers grow, produce pollen, and eventually die**
6. **Carrying pollen allows bees to spawn new flowers**

The challenge lies in maintaining a sustainable bee population while maximizing honey production before your colony collapses.

## Current Game State

The game is in active development with core systems implemented but room for expansion. Key features include:

- ✅ Isometric grid system with camera controls
- ✅ Bee AI and lifecycle management
- ✅ Flower growth and pollen production
- ✅ Basic resource management (honey)
- ✅ Simple UI for purchasing bees
- ✅ Sprite system and asset management
- 🔄 Upgrade system (planned)
- 🔄 Game over conditions (partially implemented)

## Technical Architecture

The game is built with a modular architecture using the following main systems:

### Core Systems
- **[Game Engine](./game-engine.md)** - Main game loop and state management
- **[Grid System](./grid-system.md)** - Isometric grid rendering and coordinate conversion
- **[Camera System](./camera-system.md)** - Viewport management and user controls

### Entities
- **[Bee System](./bee-system.md)** - Bee AI, behavior, and lifecycle
- **[Flower System](./flower-system.md)** - Flower growth, pollen production, and death

### Support Systems
- **[Resource System](./resource-system.md)** - Honey management and economy
- **[UI System](./ui-system.md)** - User interface and interactions
- **[Asset System](./asset-system.md)** - Sprite management and loading
- **[Utility System](./utility-system.md)** - Mathematical helpers and coordinate conversion

## Project Structure

```
buzzness-tycoon/
├── src/
│   ├── main.zig          # Entry point
│   ├── game.zig          # Main game engine
│   ├── bee.zig           # Bee entity system
│   ├── flower.zig        # Flower entity system
│   ├── grid.zig          # Isometric grid system
│   ├── ui.zig            # User interface
│   ├── resources.zig     # Resource management
│   ├── assets.zig        # Asset loading
│   ├── textures.zig      # Texture management
│   ├── utils.zig         # Utility functions
│   └── eventEmmiter.zig  # Event system (unused)
├── sprites/              # Game sprites and assets
├── docs/                 # This documentation
└── build.zig            # Build configuration
```

## Build System

The project uses Zig's build system with the following key dependencies:
- **raylib-zig** - Zig bindings for Raylib graphics library
- **Custom sprites module** - Embedded game assets

## Future Development

The documentation in this folder serves as a living design document for continued development. Each system is documented with:
- Current implementation details
- Planned features and improvements
- Technical considerations
- API documentation

## Documentation Files

- **[Game Engine](./game-engine.md)** - Core game loop and architecture
- **[Grid System](./grid-system.md)** - Isometric rendering and coordinates
- **[Camera System](./camera-system.md)** - Camera controls and viewport
- **[Bee System](./bee-system.md)** - Bee AI and behavior
- **[Flower System](./flower-system.md)** - Flower lifecycle and mechanics
- **[Resource System](./resource-system.md)** - Economy and resource management
- **[UI System](./ui-system.md)** - User interface design
- **[Asset System](./asset-system.md)** - Sprite and texture management
- **[Utility System](./utility-system.md)** - Math and coordinate utilities