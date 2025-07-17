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

pub fn isPointInIsometricTile(x: f32, y: f32, tileX: f32, tileY: f32, tileWidth: f32, tileHeight: f32, offsetX: f32, offsetY: f32, scale: f32) bool {
    const tileScreenPos = isoToXY(tileX, tileY, tileWidth, tileHeight, offsetX, offsetY, scale);

    const halfWidth = tileWidth * scale / 2.0;
    const halfHeight = tileHeight * scale / 2.0;

    const tileCenterX = tileScreenPos.x + halfWidth;
    const tileCenterY = tileScreenPos.y + halfHeight / 2.0;

    const relX = x - tileCenterX;
    const relY = y - tileCenterY;

    const normalizedX = @abs(relX) / halfWidth;
    const normalizedY = @abs(relY) / halfHeight;

    return normalizedX + normalizedY * 2.0 <= 1.0;
}

pub fn calculateCenteredGridOffset(gridWidth: usize, gridHeight: usize, tileWidth: f32, tileHeight: f32, scale: f32, viewportWidth: f32, viewportHeight: f32) rl.Vector2 {
    const topCorner = rl.Vector2.init(0, 0);
    const rightCorner = rl.Vector2.init(@floatFromInt(gridWidth - 1), 0);
    const bottomCorner = rl.Vector2.init(@floatFromInt(gridWidth - 1), @floatFromInt(gridHeight - 1));
    const leftCorner = rl.Vector2.init(0, @floatFromInt(gridHeight - 1));

    const topScreen = isoToXY(topCorner.x, topCorner.y, tileWidth, tileHeight, 0, 0, scale);
    const rightScreen = isoToXY(rightCorner.x, rightCorner.y, tileWidth, tileHeight, 0, 0, scale);
    const bottomScreen = isoToXY(bottomCorner.x, bottomCorner.y, tileWidth, tileHeight, 0, 0, scale);
    const leftScreen = isoToXY(leftCorner.x, leftCorner.y, tileWidth, tileHeight, 0, 0, scale);

    const minX = @min(@min(topScreen.x, rightScreen.x), @min(bottomScreen.x, leftScreen.x));
    const maxX = @max(@max(topScreen.x, rightScreen.x), @max(bottomScreen.x, leftScreen.x)) + tileWidth * scale;
    const minY = @min(@min(topScreen.y, rightScreen.y), @min(bottomScreen.y, leftScreen.y));
    const maxY = @max(@max(topScreen.y, rightScreen.y), @max(bottomScreen.y, leftScreen.y)) + tileHeight * scale;

    const gridScreenWidth = maxX - minX;
    const gridScreenHeight = maxY - minY;

    const offsetX = (viewportWidth - gridScreenWidth) / 2.0 - minX;
    const offsetY = (viewportHeight - gridScreenHeight) / 2.0 - minY;

    return rl.Vector2.init(offsetX, offsetY);
}

pub fn worldToGrid(worldPos: rl.Vector2, offset: rl.Vector2, scale: f32) rl.Vector2 {
    const tileWidth = 32.0;
    const tileHeight = 32.0;
    return xyToIso(worldPos.x, worldPos.y, tileWidth, tileHeight, offset.x, offset.y, scale);
}
