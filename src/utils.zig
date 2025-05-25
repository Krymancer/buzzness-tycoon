const std = @import("std");
const rl = @import("raylib");

pub fn isoToXY(i: f32, j: f32, width: f32, height: f32, offsetX: f32, offsetY: f32, scale: f32) rl.Vector2 {
    const halfScaledWidth: f32 = width * scale / 2.0;
    const quarterScaledHeight: f32 = height * scale / 4.0;

    const screenX: f32 = (i - j) * halfScaledWidth - halfScaledWidth + offsetX;
    const screenY: f32 = (i + j) * quarterScaledHeight + offsetY;

    return rl.Vector2.init(screenX, screenY);
}

pub fn xyToIso(x: f32, y: f32, width: f32, height: f32, offsetX: f32, offsetY: f32, scale: f32) rl.Vector2 {
    const half_scaled_width = width * scale / 2.0;
    const quarter_scaled_height = height * scale / 4.0;

    const adjusted_x = x - offsetX + half_scaled_width;
    const adjusted_y = y - offsetY;

    const i = (adjusted_x / half_scaled_width + adjusted_y / quarter_scaled_height) / 2.0;
    const j = (adjusted_y / quarter_scaled_height - adjusted_x / half_scaled_width) / 2.0;

    return rl.Vector2.init(i, j);
}

// Determines if a point (x, y) in screen coordinates is inside an isometric tile
pub fn isPointInIsometricTile(x: f32, y: f32, tileX: f32, tileY: f32, tileWidth: f32, tileHeight: f32, offsetX: f32, offsetY: f32, scale: f32) bool {
    // Get the position of the tile in screen coordinates
    const tileScreenPos = isoToXY(tileX, tileY, tileWidth, tileHeight, offsetX, offsetY, scale);

    // Calculate the half dimensions of the tile
    const halfWidth = tileWidth * scale / 2.0;
    const halfHeight = tileHeight * scale / 2.0;

    // Calculate the center of the tile
    const tileCenterX = tileScreenPos.x + halfWidth;
    const tileCenterY = tileScreenPos.y + halfHeight / 2.0; // Adjust center for isometric view

    // Calculate relative position from center
    const relX = x - tileCenterX;
    const relY = y - tileCenterY;

    // Diamond shape test for isometric tile
    // For a diamond/rhombus shape, we check if the point is within the shape
    // using a transformed coordinate system
    const normalizedX = @abs(relX) / halfWidth;
    const normalizedY = @abs(relY) / halfHeight;

    // This creates a diamond-shaped hitbox, which is better for isometric tiles
    return normalizedX + normalizedY * 2.0 <= 1.0;
}
