# Bee System

> **⚠️ LEGACY DOCUMENTATION**  
> This document describes the old OOP-based bee implementation that has been replaced by the ECS architecture.  
> For current implementation, see:
> - [ECS Refactor Plan](./ecs-refactor-plan.md) - Current ECS architecture
> - [Game Engine](./game-engine.md) - ECS system execution order
> - Components: `BeeAI`, `Position`, `PollenCollector`, `Lifespan` in `src/ecs/components.zig`
> - System: `bee_ai_system.zig` for current bee behavior

## Overview (Legacy OOP Implementation)

The Bee system (`bee.zig` - REMOVED) implemented autonomous bee agents that collect pollen from flowers and convert it to honey. Each bee had its own AI state machine, lifecycle, and visual representation.

**Current ECS Implementation:**
- Bees are entities with `BeeAI`, `Position`, `PollenCollector`, `Lifespan`, `Sprite`, and `ScaleSync` components
- Behavior handled by `bee_ai_system.zig`
- Key features: scatter behavior, density limiting, pollination, life extension

## Bee Structure (Legacy)

### Core Properties

```zig
pub const Bee = struct {
    // Positioning
    position: rl.Vector2,
    
    // Visual properties
    texture: rl.Texture,
    width: f32,           // 32 pixels
    height: f32,          // 32 pixels
    scale: f32,           // Base scale (1.0)
    effectiveScale: f32,  // Adjusted for grid zoom
    
    // AI and targeting
    targetFlowerIndex: ?usize,
    targetLock: bool,
    
    // Lifecycle
    timeAlive: f32,
    timeSpan: f32,        // 30-70 seconds lifespan
    dead: bool,
    
    // Gameplay mechanics
    carryingPollen: bool,
    pollenCollected: f32,
    
    // Development
    debug: bool,
}
```

## Bee Lifecycle

### Initialization

New bees are created with:
- Random position within grid bounds
- Random lifespan between 30-70 seconds
- No pollen collected initially
- Target acquisition disabled initially

### Aging and Death

Bees follow a simple aging system:
- `timeAlive` increases each frame by `deltaTime`
- When `timeAlive` exceeds `timeSpan`, bee dies
- Dead bees are removed from the game during cleanup

## AI Behavior System

### State Machine

The bee AI operates on a simple state machine:

1. **Target Acquisition** - When `targetLock` is false
2. **Movement** - When `targetLock` is true and target exists
3. **Pollen Collection** - When arriving at a flower with pollen
4. **Target Release** - When arriving at any flower

### Target Acquisition Algorithm

The `findNearestFlower` function implements a sophisticated targeting system:

**Phase 1: Priority Search**
- Scans all flowers for mature ones (state 4) with pollen
- Calculates distance to each viable flower
- Records the minimum distance found

**Phase 2: Randomization**
- Collects all flowers within 125% of minimum distance
- This creates a "close enough" group to prevent all bees targeting the same flower
- Randomly selects from this group

**Phase 3: Fallback**
- If no flowers with pollen exist, targets any living flower
- Ensures bees don't become idle when no pollen is available

### Movement System

**Leap Factor Movement:**
- Uses interpolation for smooth movement: `position += (target - position) * leapFactor * deltaTime`
- Leap factor of 0.9 creates natural, organic movement
- Accounts for frame rate variations through `deltaTime`

**Arrival Detection:**
- Arrival threshold of 5.0 pixels for reliable detection
- Prevents oscillation around target positions

## Pollen Collection Mechanics

### Collection Rules

Bees can collect pollen when:
- Target flower is mature (state == 4)
- Target flower has pollen (`hasPolen == true`)
- Bee is within arrival threshold of flower

### Collection Effects

When pollen is collected:
1. Flower's pollen is consumed (`flower.collectPolen()`)
2. Bee state changes to carrying pollen
3. Pollen counter increments by 1
4. Target lock is released for new target acquisition

## Honey Production

### Conversion System

- Each pollen collected equals 1 honey unit
- Honey is tracked in the main game loop
- Production occurs during the update phase

### Production Tracking

The game engine monitors:
- Previous pollen count before update
- Current pollen count after update
- Difference is added to global honey reserves

## Visual Representation

### Rendering System

**Normal State:**
- Renders bee texture with white tint
- Uses `effectiveScale` for proper grid scaling

**Pollen Carrying State:**
- Renders bee texture with yellow tint
- Provides immediate visual feedback

### Scale Management

The `updateScale` function ensures bees:
- Scale properly with grid zoom changes
- Maintain consistent appearance ratio
- Formula: `effectiveScale = scale * (gridScale / 3.0)`

## Flower Spawning Behavior

### Spawning Mechanics

Bees carrying pollen can spawn new flowers:
- 10% chance per second while carrying pollen
- Spawning occurs at the bee's current position
- Pollen is consumed when spawning succeeds

### Spawning Logic

The spawning system:
1. Converts bee world position to grid coordinates
2. Checks for existing flowers at the target position
3. Revives dead flowers or creates new ones
4. Resets bee's pollen carrying state

## Performance Considerations

### Optimization Features

**Efficient Target Finding:**
- Uses squared distance for initial comparisons (faster than sqrt)
- Only calculates actual distance when needed
- Limits search to living flowers only

**Memory Management:**
- Uses page allocator for temporary collections
- Properly cleans up dynamic arrays
- Minimal memory allocation per frame

### Scalability

The system can handle multiple bees efficiently:
- O(n*m) complexity where n = bees, m = flowers
- Reasonable performance for typical game scales
- Could be optimized with spatial partitioning if needed

## Configuration Values

```zig
const ARRIVAL_THRESHOLD = 5.0;      // Distance for arrival detection
const LEAP_FACTOR = 0.9;            // Movement interpolation speed
const DISTANCE_TOLERANCE = 1.25;    // Randomization factor for targeting
const LIFESPAN_MIN = 30.0;          // Minimum bee lifespan (seconds)
const LIFESPAN_MAX = 70.0;          // Maximum bee lifespan (seconds)
const SPRITE_SIZE = 32.0;           // Bee sprite dimensions
```

## Future Improvements

### Planned Features

1. **Bee Types** - Different bee species with unique abilities
2. **Swarm Intelligence** - Bees communicate about flower locations
3. **Pathfinding** - Navigate around obstacles
4. **Seasonal Behavior** - Different behavior patterns over time
5. **Bee Upgrades** - Longer lifespan, faster movement, more pollen capacity

### AI Enhancements

1. **Flocking Behavior** - Bees influence each other's movement
2. **Memory System** - Remember recently visited flowers
3. **Efficiency Optimization** - Prefer closer flowers more strongly
4. **Predictive Targeting** - Target flowers likely to have pollen soon

### Technical Improvements

1. **Spatial Partitioning** - Optimize flower searching with quadtree
2. **Behavior Trees** - More complex AI decision making
3. **Animation System** - Smooth sprite animation for movement
4. **Sound Integration** - Buzzing sounds and audio feedback

## API Reference

### Core Functions

```zig
pub fn init(x: f32, y: f32, texture: rl.Texture) Bee
pub fn update(self: *Bee, deltaTime: f32, flowers: []Flower, gridOffset: rl.Vector2, gridScale: f32) void
pub fn draw(self: Bee) void
pub fn updateScale(self: *Bee, gridScale: f32) void
pub fn enableDebug(self: *Bee) void
```

### Internal Functions

```zig
pub fn findNearestFlower(self: Bee, flowers: []Flower, gridOffset: rl.Vector2, gridScale: f32) ?usize
```

## Debugging Features

### Debug Mode

When `debug` is enabled:
- Additional visual indicators could be added
- Debug information could be displayed
- Currently used for development tracking

### Development Tools

Future debug features could include:
- Bee target lines
- AI state visualization
- Performance metrics
- Behavior analysis tools
