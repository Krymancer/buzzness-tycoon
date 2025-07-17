# Asset System

## Overview

The Asset system manages all game sprites, textures, and visual resources in Buzzness Tycoon. It's built around embedded assets and efficient texture management, providing a clean interface for loading and accessing game graphics.

## Architecture

### Component Overview

The asset system consists of three main components:

1. **Sprite Index (`sprites/sprite_index.zig`)** - Embedded file definitions
2. **Assets Module (`assets.zig`)** - Loading utilities and public interface
3. **Textures Module (`textures.zig`)** - Texture management and organization

## Sprite Management

### Embedded Assets

```zig
// In sprites/sprite_index.zig
pub const bee_png = @embedFile("bee.png");
pub const rose_png = @embedFile("rose.png");
pub const dandelion_png = @embedFile("dandelion.png");
pub const tulip_png = @embedFile("tulip.png");
pub const grass_cube_png = @embedFile("grass-cube.png");
```

**Asset Embedding:**
- Assets are embedded directly into the executable
- No external file dependencies at runtime
- Guaranteed asset availability
- Simplified distribution

### Asset Organization

**Sprite Categories:**
- **Entities:** `bee.png` - Bee sprite
- **Flowers:** `rose.png`, `dandelion.png`, `tulip.png` - Flower sprites
- **Environment:** `grass-cube.png` - Grid tile texture

**Sprite Specifications:**
- Format: PNG with transparency support
- Size: 32x32 pixels (standard sprite size)
- Flower sprites: 5-frame horizontal sprite sheets (states 0-4)
- Bee sprite: Single frame animation

## Loading System

### Core Loading Functions

```zig
pub fn loadImageFromMemory(fileData: []const u8) !rl.Image
pub fn loadTextureFromMemory(fileData: []const u8) !rl.Texture
```

**Image Loading:**
- Loads PNG data from embedded bytes
- Creates Raylib Image structure
- Handles PNG format specifically
- Error handling for corrupted data

**Texture Loading:**
- Converts Image to GPU texture
- Automatically unloads intermediate Image
- Returns ready-to-use Texture
- Optimized for rendering performance

### Asset Interface

```zig
// In assets.zig
pub const bee_png = sprites.bee_png;
pub const rose_png = sprites.rose_png;
pub const dandelion_png = sprites.dandelion_png;
pub const tulip_png = sprites.tulip_png;
pub const grass_cube_png = sprites.grass_cube_png;
```

**Public Interface:**
- Re-exports sprite data for easy access
- Provides centralized asset access point
- Maintains clean separation between storage and interface

## Texture Management

### Texture Structure

```zig
pub const Textures = struct {
    bee: rl.Texture,
    rose: rl.Texture,
    dandelion: rl.Texture,
    tulip: rl.Texture,
}
```

**Texture Organization:**
- One texture per asset type
- Loaded once during initialization
- Reused throughout game lifetime
- Proper cleanup on shutdown

### Texture Lifecycle

**Initialization:**
```zig
pub fn init() !Textures {
    return .{
        .rose = try assets.loadTextureFromMemory(assets.rose_png),
        .tulip = try assets.loadTextureFromMemory(assets.tulip_png),
        .dandelion = try assets.loadTextureFromMemory(assets.dandelion_png),
        .bee = try assets.loadTextureFromMemory(assets.bee_png),
    };
}
```

**Cleanup:**
```zig
pub fn deinit(self: Textures) void {
    rl.unloadTexture(self.rose);
    rl.unloadTexture(self.dandelion);
    rl.unloadTexture(self.tulip);
    rl.unloadTexture(self.bee);
}
```

### Texture Access

**Flower Texture Selection:**
```zig
pub fn getFlowerTexture(self: Textures, flower: Flowers) rl.Texture {
    return switch (flower) {
        .rose => self.rose,
        .tulip => self.tulip,
        .dandelion => self.dandelion,
    };
}
```

**Dynamic Texture Access:**
- Runtime flower type resolution
- Type-safe texture selection
- Extensible for new flower types

## Build System Integration

### Module Configuration

```zig
// In build.zig
const sprites_module = b.addModule("sprites", .{
    .root_source_file = b.path("sprites/sprite_index.zig"),
});

exe.root_module.addImport("sprites", sprites_module);
exe.addIncludePath(b.path(".")); // Makes project root accessible
```

**Build Integration:**
- Sprites module provides embedded assets
- Include path allows @embedFile access
- Compile-time asset validation

### Asset Validation

**Compile-time Checks:**
- Missing assets cause compilation errors
- Invalid PNG files detected at build time
- Type safety for asset access

## Performance Considerations

### Memory Efficiency

**Embedded Assets:**
- Assets stored in executable binary
- No file I/O overhead at runtime
- Immediate asset availability
- Reduced memory fragmentation

**Texture Reuse:**
- Single texture instance per asset
- Shared across all entity instances
- Minimal GPU memory usage
- Efficient rendering pipeline

### Loading Performance

**Initialization Time:**
- All assets loaded during game startup
- No runtime loading delays
- Predictable initialization performance
- No streaming or lazy loading needed

## Asset Specifications

### Sprite Requirements

**Format Requirements:**
- PNG format with transparency
- 32x32 pixel dimensions
- RGBA color channels
- Optimized for pixel art

**Flower Sprites:**
- 5 frames horizontal layout (160x32 total)
- Frame 0: Invisible/seed state
- Frame 1: Small sprout
- Frame 2: Growing plant
- Frame 3: Maturing flower
- Frame 4: Full bloom with pollen

**Bee Sprites:**
- Single frame (32x32)
- Clear bee design
- Suitable for tinting (pollen indication)

### File Organization

```
sprites/
├── sprite_index.zig    # Embedded asset definitions
├── bee.png            # Bee sprite
├── rose.png           # Rose flower sprite sheet
├── dandelion.png      # Dandelion flower sprite sheet
├── tulip.png          # Tulip flower sprite sheet
└── grass-cube.png     # Isometric grass tile
```

## Future Improvements

### Planned Features

1. **Animation System** - Multi-frame sprite animation
2. **Asset Streaming** - Load assets on demand
3. **Texture Atlasing** - Combine sprites into single texture
4. **Compression** - Asset compression for smaller executables
5. **Asset Variants** - Multiple versions of same asset

### Enhanced Organization

1. **Asset Categories** - Folder-based organization
2. **Asset Metadata** - JSON descriptions for assets
3. **Asset Validation** - Automated asset checking
4. **Asset Pipeline** - Build-time asset processing
5. **Asset Editor** - Visual asset management tools

### Performance Optimizations

1. **Texture Streaming** - Dynamic texture loading/unloading
2. **Mipmap Generation** - Automatic detail levels
3. **Format Optimization** - Best format selection per asset
4. **Batch Loading** - Load multiple assets efficiently
5. **Memory Pooling** - Efficient texture memory management

## API Reference

### Core Functions

```zig
// Asset loading
pub fn loadImageFromMemory(fileData: []const u8) !rl.Image
pub fn loadTextureFromMemory(fileData: []const u8) !rl.Texture

// Texture management
pub fn init() !Textures
pub fn deinit(self: Textures) void
pub fn getFlowerTexture(self: Textures, flower: Flowers) rl.Texture
```

### Asset Access

```zig
// Direct asset access
const bee_data = assets.bee_png;
const rose_data = assets.rose_png;

// Texture access
const bee_texture = textures.bee;
const rose_texture = textures.rose;
```

## Error Handling

### Loading Errors

**Error Types:**
- Invalid PNG format
- Memory allocation failures
- GPU texture creation failures
- Missing asset files (compile-time)

**Error Handling:**
```zig
const image = try assets.loadImageFromMemory(assets.bee_png);
defer rl.unloadImage(image);
const texture = try rl.loadTextureFromImage(image);
```

## Integration Examples

### Game Engine Integration

```zig
// In game initialization
const textures = try Textures.init();
defer textures.deinit();

// Entity creation
const bee = Bee.init(x, y, textures.bee);
const flower = Flower.init(textures.getFlowerTexture(.rose), i, j);
```

### Rendering Integration

```zig
// Flower rendering with sprite sheets
const source = rl.Rectangle.init(flower.state * flower.width, 0, flower.width, flower.height);
rl.drawTexturePro(flower.texture, source, destination, origin, rotation, color);

// Bee rendering
rl.drawTextureEx(bee.texture, bee.position, 0, bee.scale, color);
```

## Development Tools

### Asset Pipeline

**Current Pipeline:**
1. Create PNG assets in graphics editor
2. Place in sprites/ directory
3. Add to sprite_index.zig
4. Build embeds assets automatically

**Future Pipeline:**
- Automated asset processing
- Format conversion and optimization
- Asset validation and testing
- Batch asset operations

### Debugging Features

**Debug Information:**
- Asset loading success/failure
- Texture memory usage
- Asset format validation
- Performance metrics

This asset system provides a solid foundation for game graphics while maintaining simplicity and room for future expansion.
