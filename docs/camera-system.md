# Camera System

## Overview

The Camera system in Buzzness Tycoon is integrated into the main game engine and grid system, providing intuitive controls for navigation and zoom. Unlike traditional 3D cameras, this system manages 2D viewport transformation for the isometric world.

## Camera Architecture

### Integration Points

The camera system is distributed across multiple components:

1. **Game Engine (`game.zig`)** - Input handling and camera state
2. **Grid System (`grid.zig`)** - Offset calculation and zoom management
3. **Utility System (`utils.zig`)** - Coordinate transformation math

### Camera State

```zig
// In Game struct
cameraOffset: rl.Vector2,    // Current camera position
isDragging: bool,            // Mouse drag state
lastMousePos: rl.Vector2,    // Previous mouse position for drag calculation

// In Grid struct
offset: rl.Vector2,          // Grid rendering offset
scale: f32,                  // Current zoom level
baseScale: f32,              // Default zoom (3.0)
minScale: f32,               // Minimum zoom (1.0)
maxScale: f32,               // Maximum zoom (6.0)
```

## Input System

### Mouse Controls

**Drag to Pan:**
- Left mouse button initiates drag mode
- Mouse movement translates camera offset
- Immediate visual feedback during drag
- Smooth, responsive camera movement

**Drag Implementation:**
```zig
if (rl.isMouseButtonPressed(rl.MouseButton.left)) {
    self.isDragging = true;
    self.lastMousePos = mousePos;
}

if (self.isDragging) {
    const mouseDelta = rl.Vector2.init(mousePos.x - self.lastMousePos.x, mousePos.y - self.lastMousePos.y);
    self.cameraOffset.x += mouseDelta.x;
    self.cameraOffset.y += mouseDelta.y;
    self.grid.offset.x += mouseDelta.x;
    self.grid.offset.y += mouseDelta.y;
    self.lastMousePos = mousePos;
}
```

**Zoom Controls:**
- Mouse wheel controls zoom level
- Zoom speed: 0.3 units per wheel step
- Clamped between minimum and maximum zoom
- Automatic scale updates for all entities

### Keyboard Controls

**Fullscreen Toggle:**
- Alt + Enter toggles fullscreen mode
- Maintains camera state during transition
- Automatic viewport adjustment

## Zoom System

### Zoom Mechanics

**Zoom Range:**
- Minimum: 1.0x (zoomed out)
- Maximum: 6.0x (zoomed in)
- Default: 3.0x (balanced view)

**Zoom Effects:**
- Affects grid tile rendering size
- Triggers bee scale updates
- Maintains grid centering
- Updates coordinate transformations

**Zoom Implementation:**
```zig
const wheelMove = rl.getMouseWheelMove();
if (wheelMove != 0.0) {
    const zoomSpeed = 0.3;
    const zoomDelta = wheelMove * zoomSpeed;
    self.grid.zoom(zoomDelta);
    
    // Update all bee scales
    for (self.bees.items) |*bee| {
        bee.updateScale(self.grid.scale);
    }
}
```

### Entity Scale Management

**Automatic Scale Updates:**
- Bees update their `effectiveScale` when grid scale changes
- Flowers use grid scale for world position calculation
- Consistent scaling across all visual elements

**Scale Formula:**
```zig
effectiveScale = baseScale * (gridScale / 3.0)
```

## Coordinate System Integration

### World Space Management

**Offset Propagation:**
- Camera offset affects grid rendering
- Grid offset affects entity positioning
- Consistent coordinate system across all elements

**Coordinate Transformation:**
- All rendering uses offset-adjusted coordinates
- World positions automatically account for camera movement
- No manual coordinate adjustment needed in entity code

### Centering System

**Grid Centering:**
- `calculateCenteredGridOffset` maintains grid center
- Accounts for viewport size and zoom level
- Automatic recalculation on zoom changes

**Centering Algorithm:**
1. Calculate isometric grid bounding box
2. Determine screen-space dimensions
3. Center grid within viewport
4. Apply offset for camera position

## Viewport Management

### Screen Space Handling

**Viewport Dimensions:**
- Fixed 1080x1080 window size
- Grid system aware of viewport size
- Automatic adjustment for different resolutions

**Boundary Management:**
- No hard boundaries for camera movement
- Infinite scrolling capability
- Grid provides natural reference points

### Resolution Independence

**Scalable Design:**
- Coordinate system independent of screen resolution
- Proportional scaling for different viewport sizes
- Consistent gameplay across different displays

## Performance Considerations

### Optimization Features

**Efficient Updates:**
- Camera state only updates when input occurs
- No continuous calculations during idle state
- Minimal coordinate transformations per frame

**Batched Updates:**
- Single scale update triggers all entity updates
- Coordinate transformations cached where possible
- Efficient rendering pipeline integration

### Memory Efficiency

**Stateless Design:**
- No dynamic allocations for camera operations
- Minimal memory overhead
- Clean separation of concerns

## User Experience Design

### Intuitive Controls

**Natural Mouse Interaction:**
- Drag to pan feels natural and responsive
- Zoom direction matches user expectations
- Smooth movement without lag or stutter

**Visual Feedback:**
- Immediate response to user input
- Smooth transitions between zoom levels
- Clear visual indicators for interactive elements

### Accessibility

**Control Flexibility:**
- Mouse-based controls for precision
- Keyboard shortcuts for common actions
- Consistent interaction patterns

## Configuration Values

```zig
const ZOOM_SPEED = 0.3;         // Mouse wheel zoom sensitivity
const MIN_ZOOM = 1.0;           // Minimum zoom level
const MAX_ZOOM = 6.0;           // Maximum zoom level
const BASE_ZOOM = 3.0;          // Default zoom level
const VIEWPORT_WIDTH = 1080.0;  // Screen width
const VIEWPORT_HEIGHT = 1080.0; // Screen height
```

## Future Improvements

### Planned Features

1. **Keyboard Navigation** - WASD or arrow key camera movement
2. **Smooth Zoom Animation** - Interpolated zoom transitions
3. **Camera Boundaries** - Optional world bounds for camera
4. **Minimap Integration** - Small overview map with camera position
5. **Camera Presets** - Quick zoom to specific areas

### Advanced Features

1. **Camera Shake** - Screen shake effects for game events
2. **Follow Camera** - Automatically track specific entities
3. **Cinematic Camera** - Scripted camera movements
4. **Split Screen** - Multiple viewport support
5. **Picture-in-Picture** - Secondary camera views

### Technical Improvements

1. **Smooth Interpolation** - Lerp camera movements for smoothness
2. **Velocity-Based Movement** - Momentum-based camera controls
3. **Gesture Support** - Touch/trackpad gesture recognition
4. **Performance Profiling** - Camera update performance metrics
5. **Multi-Resolution Support** - Dynamic viewport scaling

## API Reference

### Core Functions

```zig
// Input handling (in Game struct)
pub fn input(self: *Game) void

// Zoom control (in Grid struct)
pub fn zoom(self: *Grid, zoomDelta: f32) void
pub fn updateOffset(self: *Grid) void

// Entity scale updates
pub fn updateScale(self: *Bee, gridScale: f32) void
```

### Utility Functions

```zig
// Coordinate transformation
utils.calculateCenteredGridOffset(width, height, tileWidth, tileHeight, scale, viewportWidth, viewportHeight)
utils.isoToXY(x, y, width, height, offsetX, offsetY, scale)
utils.xyToIso(x, y, width, height, offsetX, offsetY, scale)
```

### Integration Points

```zig
// Camera state access
game.cameraOffset     // Current camera position
game.isDragging       // Drag state
grid.offset           // Grid rendering offset
grid.scale            // Current zoom level
```

## Debugging Features

### Debug Information

Potential debug features:
- Camera position display
- Zoom level indicator
- Grid bounds visualization
- Mouse position in different coordinate spaces

### Development Tools

Future debug tools could include:
- Camera state inspector
- Coordinate transformation visualizer
- Performance metrics for camera updates
- Interactive camera control panel

## Integration with Other Systems

### Entity Rendering

**Consistent Transformations:**
- All entities use the same coordinate system
- Camera offset automatically applied
- Zoom scaling handled uniformly

### UI Integration

**Screen Space UI:**
- UI elements unaffected by camera movement
- Consistent interface regardless of camera position
- Proper separation of world and screen space

### Physics Integration

**World Space Physics:**
- Future physics calculations use world coordinates
- Camera transformations don't affect game logic
- Clean separation of rendering and simulation
