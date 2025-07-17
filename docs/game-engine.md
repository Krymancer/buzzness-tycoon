# Game Engine System

## Overview

The game engine (`game.zig`) serves as the central orchestrator for Buzzness Tycoon, managing the main game loop, entity lifecycle, and system coordination. It follows a traditional game engine pattern with distinct initialization, update, and render phases.

## Architecture

### Core Components

```zig
pub const Game = struct {
    // Grid configuration
    const GRID_WIDTH = 16;
    const GRID_HEIGHT = 16;
    const FLOWER_SPAWN_CHANCE = 30;
    
    // Core systems
    grid: Grid,
    textures: Textures,
    resources: Resources,
    ui: UI,
    
    // Entities
    bees: std.ArrayList(Bee),
    flowers: std.ArrayList(Flower),
    
    // Camera system
    cameraOffset: rl.Vector2,
    isDragging: bool,
    lastMousePos: rl.Vector2,
    
    // Window management
    width: f32,
    height: f32,
    windowIcon: rl.Image,
    
    allocator: std.mem.Allocator,
}
```

## Game Loop

### Initialization (`init`)

The initialization phase sets up:

1. **Window Creation** - Creates a 1080x1080 window with bee icon
2. **Random Seed** - Initializes random number generator for gameplay variety
3. **System Initialization** - Sets up grid, textures, resources, and UI
4. **Entity Spawning** - Creates initial flowers and bees

**Initial Flower Spawning:**
- Iterates through all grid positions
- 30% chance per tile to spawn a flower
- Randomly selects flower type (rose, dandelion, tulip)
- Places flowers at grid coordinates

**Initial Bee Spawning:**
- Spawns 5 bees at random positions within grid bounds
- Each bee is initialized with proper scale based on grid zoom

### Update Phase (`update`)

The update phase processes game logic in this order:

1. **Bee Processing**
   - Updates each bee's AI and movement
   - Tracks honey production from pollen collection
   - Handles flower spawning when bees carry pollen
   - Removes dead bees from the colony

2. **Flower Processing**
   - Updates flower growth and pollen production
   - Removes dead flowers from the grid

3. **Entity Cleanup**
   - Removes dead entities to prevent memory leaks
   - Uses reverse iteration to maintain array integrity

**Flower Spawning Logic:**
- Bees carrying pollen have a 10% chance per second to spawn flowers
- Spawning converts bee world position to grid coordinates
- Checks for existing flowers at the target position
- Revives dead flowers or creates new ones

### Render Phase (`draw`)

The render phase draws the game world in layers:

1. **Background** - Clears screen with dark theme color
2. **Grid** - Renders isometric grid tiles
3. **Flowers** - Draws flowers with growth states and pollen glow
4. **Bees** - Renders bees with movement and pollen indicators
5. **UI** - Displays resource counters and purchase buttons
6. **Debug Info** - Shows FPS counter

## Input System

### Camera Controls

The game supports intuitive camera controls:

**Mouse Dragging:**
- Left mouse button initiates drag mode
- Mouse movement translates the camera offset
- Updates both camera and grid offsets simultaneously

**Zoom Control:**
- Mouse wheel controls zoom level
- Zoom range: 1.0x to 6.0x
- Automatically updates bee scales to match grid zoom

**Keyboard Shortcuts:**
- Alt + Enter: Toggle fullscreen mode

## Entity Management

### Bee Management

The game maintains a dynamic list of bees with the following lifecycle:

1. **Spawning** - New bees are created via UI button (costs 10 honey)
2. **Living** - Bees collect pollen and produce honey
3. **Dying** - Bees die after 30-70 seconds of life
4. **Cleanup** - Dead bees are removed from the array

### Flower Management

Flowers follow a more complex lifecycle:

1. **Initial Spawn** - 30% chance during world generation
2. **Growth** - Flowers progress through 5 states (0-4)
3. **Pollen Production** - Mature flowers (state 4) produce pollen
4. **Death** - Flowers die after 60-120 seconds
5. **Revival** - Dead flowers can be revived by pollen-carrying bees

## Rendering System

### Isometric Rendering

The game uses a centralized rendering approach:

**Grid-Based Rendering:**
```zig
pub fn drawSpriteAtGridPosition(texture, i, j, sourceRect, scale, color)
```
- Converts grid coordinates to screen position
- Centers sprites on isometric tiles
- Applies proper scaling based on grid zoom

**World-Based Rendering:**
```zig
pub fn drawSpriteAtWorldPosition(texture, worldPos, sourceRect, scale, color)
```
- Renders sprites at absolute world positions
- Used for dynamic entities like bees

### Visual Effects

**Pollen Glow Effect:**
- Mature flowers with pollen display a yellow glow
- Implemented by drawing the flower twice with different colors
- Creates visual feedback for pollen availability

**Bee Pollen Indicator:**
- Bees carrying pollen are tinted yellow
- Provides clear visual feedback for bee state

## Memory Management

The game uses careful memory management:

- **Allocator-Based** - Uses provided allocator for dynamic arrays
- **Proper Cleanup** - All resources are freed in `deinit()`
- **Texture Management** - Textures are loaded once and reused
- **Entity Cleanup** - Dead entities are removed to prevent memory leaks

## Configuration Constants

```zig
const GRID_WIDTH = 16;           // Grid width in tiles
const GRID_HEIGHT = 16;          // Grid height in tiles
const FLOWER_SPAWN_CHANCE = 30;  // Percentage chance for initial flower spawn
```

## Future Improvements

### Planned Features

1. **Game Over Conditions** - Implement proper lose state when all bees die
2. **Upgrade System** - Add bee and flower upgrades
3. **Save System** - Persist game state between sessions
4. **Audio System** - Add sound effects and music
5. **Performance Optimization** - Spatial partitioning for large grids

### Technical Debt

1. **Entity Component System** - Consider refactoring to ECS for better modularity
2. **Event System** - The EventEmitter is unused and should be integrated or removed
3. **Configuration System** - Move magic numbers to configuration files
4. **Error Handling** - Improve error propagation and handling

## API Reference

### Core Functions

```zig
pub fn init(width: f32, height: f32, allocator: std.mem.Allocator) !Game
pub fn deinit(self: Game) void
pub fn run(self: *Game) !void
pub fn input(self: *Game) void
pub fn update(self: *Game) !void
pub fn draw(self: *Game) !void
```

### Utility Functions

```zig
pub fn drawSpriteAtGridPosition(self: *Game, texture, i, j, sourceRect, scale, color) void
pub fn drawSpriteAtWorldPosition(self: *Game, texture, worldPos, sourceRect, scale, color) void
pub fn trySpawnFlower(self: *Game, beePosition: rl.Vector2) !bool
```
