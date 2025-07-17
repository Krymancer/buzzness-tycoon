# Flower System

## Overview

The Flower system (`flower.zig`) manages the growth, pollen production, and lifecycle of flowers in the game world. Flowers serve as the primary resource nodes that bees interact with, creating a dynamic ecosystem that drives the game's core loop.

## Flower Structure

### Core Properties

```zig
pub const Flower = struct {
    // Growth and lifecycle
    state: f32,              // Growth state (0-4)
    timeAlive: f32,          // Time spent in current growth state
    totalTimeAlive: f32,     // Total time since creation
    timeSpan: f32,           // Total lifespan (60-120 seconds)
    dead: bool,              // Death state
    
    // Positioning
    gridPosition: rl.Vector2, // Grid coordinates (not world position)
    
    // Visual properties
    texture: rl.Texture,
    width: f32,              // 32 pixels
    height: f32,             // 32 pixels
    scale: f32,              // Render scale (2.0)
    
    // Growth mechanics
    randomGrowScale: f32,    // Individual growth rate (1-10)
    growTreshHold: f32,      // Time needed to advance growth state (50)
    
    // Pollen system
    hasPolen: bool,          // Current pollen availability
    polenCoolDown: f32,      // Time between pollen production (10-50 seconds)
    
    // Development
    debug: bool,
}
```

## Flower Types

### Available Species

```zig
pub const Flowers = enum { 
    rose, 
    tulip, 
    dandelion 
};
```

Each flower type has:
- Unique visual appearance
- Same mechanical properties (currently)
- Different sprites for visual variety

## Growth System

### Growth States

Flowers progress through 5 distinct growth states:

1. **State 0** - Seed/Invisible (not rendered)
2. **State 1** - Sprout (small beginning)
3. **State 2** - Growing (increasing size)
4. **State 3** - Maturing (near full size)
5. **State 4** - Mature (full size, can produce pollen)

### Growth Mechanics

**Individual Growth Rates:**
- Each flower has a `randomGrowScale` between 1-10
- This creates organic, varied growth patterns
- Prevents all flowers from growing simultaneously

**Growth Timing:**
- `timeAlive` increases by `randomGrowScale * deltaTime`
- When `timeAlive` exceeds `growTreshHold` (50), flower advances to next state
- Timer resets to 0 after each state advancement

**Growth Formula:**
```zig
if (self.state < 4) {
    self.timeAlive += self.randomGrowScale * deltaTime;
    if (self.timeAlive > self.growTreshHold) {
        self.timeAlive = 0;
        self.state += 1;
    }
}
```

## Pollen Production System

### Production Requirements

Flowers can only produce pollen when:
- Growth state equals 4 (fully mature)
- Flower is not dead
- Previous pollen has been collected

### Production Mechanics

**Pollen Cooldown:**
- Each flower has individual cooldown time (10-50 seconds)
- Cooldown is randomized to prevent synchronized production
- Creates natural scarcity and timing challenges

**Production Cycle:**
1. Mature flower starts without pollen
2. Timer accumulates: `timeAlive += randomGrowScale * deltaTime`
3. When timer exceeds cooldown, pollen becomes available
4. Pollen remains until collected by a bee
5. Cycle repeats after collection

## Lifecycle Management

### Lifespan System

**Total Lifespan:**
- Flowers live for 60-120 seconds (randomized)
- `totalTimeAlive` tracks complete lifetime
- Independent of growth state progression

**Death Mechanics:**
- When `totalTimeAlive` exceeds `timeSpan`, flower dies
- Dead flowers stop all processing
- Dead flowers can be revived by pollen-carrying bees

### Revival System

Dead flowers can be brought back to life:
- Pollen-carrying bees can revive dead flowers
- Revival resets all timers and states
- Allows for sustainable flower population

## Positioning System

### Grid-Based Positioning

**Grid Coordinates:**
- Flowers store `gridPosition` (grid coordinates)
- Not world coordinates (different from bees)
- Allows for easy grid-based logic

**World Position Calculation:**
```zig
pub fn getWorldPosition(self: Flower, offset: rl.Vector2, gridScale: f32) rl.Vector2
```

This function:
1. Converts grid coordinates to screen coordinates
2. Centers flower on isometric tile
3. Positions on tile's top surface
4. Accounts for grid scaling and offset

**Positioning Logic:**
- Uses `utils.isoToXY` for coordinate conversion
- Centers horizontally on tile
- Positions at top 25% of tile height
- Accounts for sprite size and scaling

## Visual Representation

### Sprite System

**Sprite Sheets:**
- Each flower type has a horizontal sprite sheet
- 5 frames representing growth states 0-4
- Frame selection: `source.x = state * width`

**Rendering Position:**
- Flowers are rendered at calculated world positions
- Proper isometric positioning on grid tiles
- Scaling adjusts based on grid zoom level

### Visual Effects

**Pollen Glow:**
- Flowers with pollen display a yellow glow effect
- Implemented by drawing flower twice with different colors
- Provides immediate visual feedback for pollen availability

## Interaction System

### Bee Interaction

**Pollen Collection:**
```zig
pub fn collectPolen(self: *Flower) void {
    self.hasPolen = false;
}
```

Simple interface for bee interaction:
- Bees call this when collecting pollen
- Immediately removes pollen availability
- Starts new pollen production cycle

### Spawn System Integration

Flowers integrate with the spawn system:
- Initial world generation creates flowers randomly
- Bees can spawn new flowers when carrying pollen
- Dead flowers can be revived rather than creating new ones

## Performance Considerations

### Optimization Features

**Efficient Updates:**
- Dead flowers skip all processing
- Early returns prevent unnecessary calculations
- State-based logic minimizes work

**Memory Efficiency:**
- Flowers store minimal state
- No dynamic allocations during updates
- Reuse of dead flowers prevents memory fragmentation

## Configuration Values

```zig
const GROWTH_THRESHOLD = 50.0;       // Time to advance growth state
const MATURE_STATE = 4.0;           // Growth state for maturity
const LIFESPAN_MIN = 60.0;          // Minimum flower lifespan
const LIFESPAN_MAX = 120.0;         // Maximum flower lifespan
const POLLEN_COOLDOWN_MIN = 10.0;   // Minimum pollen production time
const POLLEN_COOLDOWN_MAX = 50.0;   // Maximum pollen production time
const GROWTH_RATE_MIN = 1.0;        // Minimum growth rate multiplier
const GROWTH_RATE_MAX = 10.0;       // Maximum growth rate multiplier
const SPRITE_SIZE = 32.0;           // Flower sprite dimensions
const RENDER_SCALE = 2.0;           // Default render scale
```

## Future Improvements

### Planned Features

1. **Flower Varieties** - Different mechanics per flower type
2. **Seasonal Growth** - Weather and time-based growth rates
3. **Flower Diseases** - Challenges that affect growth
4. **Pollination Requirements** - Flowers need bees to reproduce
5. **Soil Quality** - Grid tiles affect growth rates

### Enhanced Mechanics

1. **Nutrient System** - Flowers compete for soil resources
2. **Flower Aging** - Visual changes as flowers age
3. **Seed Production** - Flowers create seeds for new growth
4. **Flower Communication** - Chemical signals between flowers
5. **Environmental Factors** - Weather affects growth and pollen

### Technical Improvements

1. **Animation System** - Smooth growth transitions
2. **Particle Effects** - Pollen particles and visual effects
3. **Audio Integration** - Sound effects for growth and collection
4. **Procedural Generation** - More varied flower placement
5. **Optimization** - Spatial partitioning for large flower counts

## API Reference

### Core Functions

```zig
pub fn init(texture: rl.Texture, i: f32, j: f32) Flower
pub fn update(self: *Flower, deltaTime: f32) void
pub fn getWorldPosition(self: Flower, offset: rl.Vector2, gridScale: f32) rl.Vector2
pub fn collectPolen(self: *Flower) void
```

### Utility Functions

```zig
// Position calculation helpers
const tilePosition = utils.isoToXY(gridPosition.x, gridPosition.y, width, height, offset.x, offset.y, gridScale);
const effectiveScale = scale * (gridScale / 3.0);
```

## Debugging Features

### Debug Mode

When `debug` is enabled:
- Additional information could be displayed
- Growth state visualization
- Pollen production timing
- Lifespan indicators

### Development Tools

Future debug features could include:
- Growth rate visualization
- Pollen production timers
- Lifespan countdown
- Grid position indicators
- State transition logging
