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
