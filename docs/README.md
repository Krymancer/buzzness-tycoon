# Buzzness Tycoon - Game Design Document

## Overview

Buzzness Tycoon is an isometric grid-based game developed in Zig using the Raylib graphics library. The game centers around managing bees that collect pollen from flowers to produce honey, creating a simple but engaging resource management experience.

Built with an **Entity Component System (ECS)** architecture for scalability and performance.

## Game Concept

Players manage a colony of bees on an isometric grid populated with flowers. The core gameplay loop involves:

1. **Bees collect pollen** from mature flowers
2. **Pollen is converted to honey** (the primary resource)
3. **Honey is spent to purchase new bees** to expand the colony
4. **Bees have limited lifespans** but carrying pollen extends their life
5. **Flowers grow, produce pollen, and eventually die**
6. **Bees spread flowers** by pollinating empty cells while flying
7. **Empty cells automatically spawn flowers** over time
8. **Bees scatter and distribute** across flowers to prevent clustering

The challenge lies in maintaining a sustainable bee population while maximizing honey production before your colony collapses.

## Current Game State

The game is in active development with core systems implemented in an ECS architecture:

- ✅ Isometric grid system with camera controls and fullscreen support
- ✅ Entity Component System (ECS) architecture
- ✅ Bee AI with scatter behavior and density limiting
- ✅ Flower growth and pollen production
- ✅ Pollination mechanics (bees spread flowers)
- ✅ Automatic flower spawning in empty cells
- ✅ Lifespan extension (pollen extends bee life)
- ✅ Basic resource management (honey)
- ✅ Simple UI for purchasing bees
- ✅ Sprite system and asset management
- 🔄 Upgrade system (planned)
- 🔄 Game over conditions (partially implemented)

## Technical Architecture

The game uses a data-oriented **Entity Component System (ECS)** architecture for better performance and maintainability.

### ECS Architecture
- **[ECS Refactor Plan](./ecs-refactor-plan.md)** - Complete ECS architecture documentation
- **Entities** - Simple u32 IDs with component associations
- **Components** - Pure data structures (Position, BeeAI, FlowerGrowth, etc.)
- **Systems** - Pure logic operating on component data
- **World** - Central storage and query system

### Core Systems
- **[Game Engine](./game-engine.md)** - Main game loop and ECS orchestration
- **[Grid System](./grid-system.md)** - Isometric grid rendering and coordinate conversion
- **[Camera System](./camera-system.md)** - Viewport management and user controls

### ECS Systems
- **Lifespan System** - Entity aging and death, pollen life extension
- **Flower Growth System** - Flower state progression and pollen regeneration
- **Bee AI System** - Target finding, movement, pollination, scatter behavior
- **Scale Sync System** - Grid scaling synchronization
- **Flower Spawning System** - Empty cell flower generation
- **Render System** - Entity rendering with sprites

### Components
- **Position** - World position (x, y)
- **GridPosition** - Grid cell position
- **Sprite** - Texture and visual data
- **Velocity** - Movement vector
- **BeeAI** - Targeting, scatter, pollination tracking
- **FlowerGrowth** - Growth state and pollen availability
- **Lifespan** - Age tracking and death conditions
- **PollenCollector** - Pollen accumulation
- **ScaleSync** - Grid scale synchronization

### Support Systems
- **[Resource System](./resource-system.md)** - Honey management and economy
- **[UI System](./ui-system.md)** - User interface and interactions
- **[Asset System](./asset-system.md)** - Sprite management and loading
- **[Utility System](./utility-system.md)** - Mathematical helpers and coordinate conversion

## Project Structure

```
buzzness-tycoon/
├── src/
│   ├── main.zig              # Entry point
│   ├── game.zig              # Main game engine and ECS orchestration
│   ├── grid.zig              # Isometric grid system
│   ├── ui.zig                # User interface
│   ├── resources.zig         # Resource management
│   ├── assets.zig            # Asset loading
│   ├── textures.zig          # Texture management and flower types
│   ├── theme.zig             # UI theming (Catppuccin Mocha)
│   ├── utils.zig             # Utility functions
│   └── ecs/
│       ├── entity.zig        # Entity ID management
│       ├── components.zig    # Component definitions
│       ├── world.zig         # Component storage and queries
│       └── systems/
│           ├── lifespan_system.zig
│           ├── flower_growth_system.zig
│           ├── bee_ai_system.zig
│           ├── scale_sync_system.zig
│           ├── flower_spawning_system.zig
│           └── render_system.zig
├── sprites/                  # Game sprites and assets
├── docs/                     # This documentation
└── build.zig                # Build configuration
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

- **[ECS Refactor Plan](./ecs-refactor-plan.md)** - Complete ECS architecture documentation
- **[Game Engine](./game-engine.md)** - Core game loop and ECS orchestration
- **[Grid System](./grid-system.md)** - Isometric rendering and coordinates
- **[Camera System](./camera-system.md)** - Camera controls and viewport
- **[Bee System](./bee-system.md)** - Bee AI and behavior (legacy OOP reference)
- **[Flower System](./flower-system.md)** - Flower lifecycle and mechanics (legacy OOP reference)
- **[Resource System](./resource-system.md)** - Economy and resource management
- **[UI System](./ui-system.md)** - User interface design
- **[Asset System](./asset-system.md)** - Sprite and texture management
- **[Utility System](./utility-system.md)** - Math and coordinate utilities

## Key Gameplay Mechanics

### Bee Behavior
- Bees start with a 60-140 second lifespan
- Bees carrying pollen get +50% lifespan extension when they would die
- After collecting pollen, bees scatter for 2-4 seconds before targeting a new flower
- Maximum of 2 bees can target the same flower to prevent clustering
- Bees wander randomly when no flowers are available
- Bees deposit pollen as honey after carrying it for 3 seconds

### Flower Mechanics
- Flowers grow through 5 states (0-4), mature at state 4
- Mature flowers regenerate pollen after a cooldown period
- Flowers have a 60-120 second lifespan
- Empty grid cells have a 30% chance to spawn a flower every 5 seconds
- Bees carrying pollen have a 10% chance to spawn flowers when flying over empty cells

### Resource Economy
- Game starts with 25 honey and 10 bees
- Each bee costs 10 honey to purchase
- Bees generate 1 honey per pollen collected (after 3 second deposit time)
- Initial flower spawn chance: 30% per grid cell