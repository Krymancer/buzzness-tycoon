# Utility System

## Overview

The Utility system (`utils.zig`) provides essential mathematical functions and coordinate transformations that support the game's isometric rendering system. It serves as the foundation for coordinate conversion, positioning calculations, and geometric operations.

## Core Functions

### Coordinate Transformation

The utility system provides bidirectional coordinate transformation between different coordinate spaces:

**Isometric to Cartesian:**
```zig
pub fn isoToXY(i: f32, j: f32, width: f32, height: f32, offsetX: f32, offsetY: f32, scale: f32) rl.Vector2
```

**Cartesian to Isometric:**
```zig
pub fn xyToIso(x: f32, y: f32, width: f32, height: f32, offsetX: f32, offsetY: f32, scale: f32) rl.Vector2
```

### Isometric Coordinate System

#### Mathematical Foundation

The isometric projection uses a diamond-shaped grid where:
- **i-axis** runs diagonally down-right
- **j-axis** runs diagonally down-left
- Standard 2:1 aspect ratio for isometric tiles

#### Transformation Math

**Grid to Screen (isoToXY):**
```zig
const isoX = (i - j) * (width * scale / 2.0);
const isoY = (i + j) * (height * scale / 4.0);
return rl.Vector2.init(isoX + offsetX, isoY + offsetY);
```

**Screen to Grid (xyToIso):**
```zig
const half_scaled_width = width * scale / 2.0;
const quarter_scaled_height = height * scale / 4.0;
const adjusted_x = x - offsetX + half_scaled_width;
const adjusted_y = y - offsetY;
const i = (adjusted_x / half_scaled_width + adjusted_y / quarter_scaled_height) / 2.0;
const j = (adjusted_y / quarter_scaled_height - adjusted_x / half_scaled_width) / 2.0;
```

### Point-in-Tile Detection

```zig
pub fn isPointInIsometricTile(x: f32, y: f32, tileX: f32, tileY: f32, tileWidth: f32, tileHeight: f32, offsetX: f32, offsetY: f32, scale: f32) bool
```

**Diamond Shape Detection:**
- Converts tile coordinates to screen position
- Creates diamond-shaped hit area
- Uses normalized coordinates for efficient testing
- Formula: `normalizedX + normalizedY * 2.0 <= 1.0`

**Algorithm:**
1. Calculate tile center in screen coordinates
2. Transform mouse position relative to tile center
3. Normalize coordinates by tile dimensions
4. Apply diamond shape formula for hit detection

### Grid Layout Calculations

```zig
pub fn calculateCenteredGridOffset(gridWidth: usize, gridHeight: usize, tileWidth: f32, tileHeight: f32, scale: f32, viewportWidth: f32, viewportHeight: f32) rl.Vector2
```

**Grid Centering Algorithm:**
1. Calculate screen positions of grid corner tiles
2. Determine bounding box of entire grid
3. Calculate offset to center grid in viewport
4. Return offset for rendering system

**Corner Calculation:**
- Top corner: (0, 0)
- Right corner: (gridWidth-1, 0)
- Bottom corner: (gridWidth-1, gridHeight-1)
- Left corner: (0, gridHeight-1)

### World Coordinate Utilities

```zig
pub fn worldToGrid(worldPos: rl.Vector2, offset: rl.Vector2, scale: f32) rl.Vector2
```

**World to Grid Conversion:**
- Converts world coordinates to grid coordinates
- Uses standard tile dimensions (32x32)
- Accounts for current camera offset and scale
- Essential for bee-to-flower positioning

## Mathematical Concepts

### Isometric Projection

**Projection Matrix:**
The isometric transformation can be represented as:
```
[x']   [0.5  -0.5 ] [i]
[y'] = [0.25  0.25] [j]
```

**Inverse Transformation:**
```
[i]   [1.0   2.0] [x']
[j] = [1.0  -2.0] [y']
```

### Coordinate Spaces

**Grid Space:**
- Integer coordinates (0,0) to (width-1, height-1)
- Logical game positions
- Used for flower placement and game logic

**World Space:**
- Floating-point isometric coordinates
- Continuous movement space
- Used for bee positioning and movement

**Screen Space:**
- Final pixel coordinates
- Includes camera offset and zoom
- Used for rendering and mouse interaction

## Performance Considerations

### Optimization Features

**Efficient Calculations:**
- Minimal trigonometric operations
- Pre-calculated scale factors
- Inline mathematical operations
- No dynamic memory allocation

**Cached Values:**
- Half-width and quarter-height calculations
- Reused transformation factors
- Minimized redundant calculations

### Numerical Stability

**Precision Handling:**
- Uses f32 for consistency with graphics APIs
- Avoids precision loss in repeated transformations
- Stable coordinate conversion for large worlds

## Integration with Game Systems

### Grid System Integration

**Rendering Pipeline:**
- Grid uses `isoToXY` for tile positioning
- Supports dynamic offset and scale changes
- Maintains visual consistency across zoom levels

**Mouse Interaction:**
- `isPointInIsometricTile` enables tile selection
- Supports hover effects and click detection
- Accurate hit testing for diamond-shaped tiles

### Entity Positioning

**Flower Positioning:**
- Flowers use grid coordinates internally
- `getWorldPosition` converts to screen coordinates
- Consistent positioning across different zoom levels

**Bee Movement:**
- Bees use world coordinates for movement
- `worldToGrid` converts for collision detection
- Smooth movement independent of grid structure

### Camera System Integration

**Viewport Management:**
- `calculateCenteredGridOffset` maintains grid centering
- Supports dynamic zoom and pan operations
- Automatic recalculation on viewport changes

## Configuration Constants

```zig
const STANDARD_TILE_WIDTH = 32.0;   // Standard tile width
const STANDARD_TILE_HEIGHT = 32.0;  // Standard tile height
const ISO_ASPECT_RATIO = 2.0;       // Isometric aspect ratio (width/height)
const DIAMOND_FORMULA_FACTOR = 2.0; // Diamond detection formula factor
```

## Future Improvements

### Planned Features

1. **3D Isometric** - Height-based coordinate system
2. **Coordinate Caching** - Cache frequent transformations
3. **Batch Transformations** - Process multiple coordinates efficiently
4. **Precision Improvements** - Higher precision for large worlds
5. **Optimization** - SIMD acceleration for bulk operations

### Advanced Mathematics

1. **Projection Matrices** - Full matrix-based transformations
2. **Perspective Correction** - More realistic isometric projection
3. **Collision Geometry** - Advanced shape intersection
4. **Spatial Indexing** - Efficient spatial queries
5. **Interpolation** - Smooth coordinate transitions

### Performance Enhancements

1. **Vectorization** - SIMD coordinate transformations
2. **Lookup Tables** - Pre-calculated transformation values
3. **Approximations** - Fast approximate calculations
4. **Memory Pooling** - Efficient coordinate vector management
5. **Profiling** - Performance analysis and optimization

## API Reference

### Core Functions

```zig
pub fn isoToXY(i: f32, j: f32, width: f32, height: f32, offsetX: f32, offsetY: f32, scale: f32) rl.Vector2
pub fn xyToIso(x: f32, y: f32, width: f32, height: f32, offsetX: f32, offsetY: f32, scale: f32) rl.Vector2
pub fn isPointInIsometricTile(x: f32, y: f32, tileX: f32, tileY: f32, tileWidth: f32, tileHeight: f32, offsetX: f32, offsetY: f32, scale: f32) bool
pub fn calculateCenteredGridOffset(gridWidth: usize, gridHeight: usize, tileWidth: f32, tileHeight: f32, scale: f32, viewportWidth: f32, viewportHeight: f32) rl.Vector2
pub fn worldToGrid(worldPos: rl.Vector2, offset: rl.Vector2, scale: f32) rl.Vector2
```

### Usage Examples

```zig
// Convert grid position to screen coordinates
const screenPos = utils.isoToXY(gridX, gridY, 32, 32, offset.x, offset.y, scale);

// Convert mouse position to grid coordinates
const gridPos = utils.xyToIso(mouseX, mouseY, 32, 32, offset.x, offset.y, scale);

// Check if mouse is over a tile
const isHovered = utils.isPointInIsometricTile(mouseX, mouseY, tileX, tileY, 32, 32, offset.x, offset.y, scale);

// Calculate centered grid offset
const offset = utils.calculateCenteredGridOffset(16, 16, 32, 32, 3.0, 1080, 1080);
```

## Mathematical Validation

### Coordinate Consistency

**Bidirectional Transformation:**
```zig
// Should return original coordinates
const original = rl.Vector2.init(5.0, 3.0);
const world = utils.isoToXY(original.x, original.y, 32, 32, 0, 0, 1.0);
const back = utils.xyToIso(world.x, world.y, 32, 32, 0, 0, 1.0);
// back should equal original
```

**Precision Testing:**
- Transformation accuracy within floating-point precision
- Stable for repeated conversions
- Maintains accuracy across different scales

### Geometric Validation

**Diamond Shape Accuracy:**
- Hit detection matches visual tile boundaries
- Consistent behavior across different scales
- Accurate for all tile positions

## Error Handling

### Numerical Stability

**Division by Zero:**
- Scale parameter validation
- Tile dimension validation
- Safe default values

**Range Validation:**
- Coordinate bounds checking
- Scale factor limits
- Viewport dimension validation

## Integration Examples

### Grid Rendering

```zig
// In grid draw function
for (0..width) |i| {
    for (0..height) |j| {
        const position = utils.isoToXY(@floatFromInt(i), @floatFromInt(j), 32, 32, offset.x, offset.y, scale);
        rl.drawTextureEx(texture, position, 0, scale, color);
    }
}
```

### Mouse Interaction

```zig
// In mouse hover detection
const mousePos = rl.getMousePosition();
const isHovered = utils.isPointInIsometricTile(mousePos.x, mousePos.y, tileX, tileY, 32, 32, offset.x, offset.y, scale);
```

### Entity Positioning

```zig
// In flower world position calculation
const worldPos = utils.isoToXY(gridPosition.x, gridPosition.y, width, height, offset.x, offset.y, scale);
```

This utility system provides the mathematical foundation that makes the isometric game world possible, enabling accurate coordinate transformations and spatial calculations throughout the game.
