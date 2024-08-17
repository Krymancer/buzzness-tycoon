const rl = @import("raylib");
const std = @import("std");

pub fn main() anyerror!void {
    const screenWidth = 1024;
    const screenHeight = 1024;

    rl.initWindow(screenWidth, screenHeight, "Buzzness Tycoon");
    defer rl.closeWindow();

    const beeIcon = rl.loadImage("sprites/bee.png");
    defer rl.unloadImage(beeIcon);
    rl.setWindowIcon(beeIcon);

    rl.setTargetFPS(60);

    const texture = rl.loadTexture("sprites/bee.png");
    defer rl.unloadTexture(texture);

    const tile = rl.loadTexture("sprites/grass-cube.png");
    defer rl.unloadTexture(tile);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        const scale = 5;

        const tileWidth: f32 = @floatFromInt(tile.width * scale);
        const tileHeight: f32 = @floatFromInt(tile.height * scale);

        const sizeX: i32 = 5;
        const sizeY: i32 = 5;

        const offsetX: f32 = @as(f32, @floatFromInt(screenWidth)) / 2.35;
        const offsetY: f32 = @floatFromInt(screenHeight / 4);

        const mousePosition = rl.getMousePosition();

        const adjustedX: f32 = @trunc(mousePosition.x - offsetX - 10);
        const adjustedY: f32 = @trunc(mousePosition.y - offsetY - 10);

        const gridX = @trunc(0.5 * ((adjustedX / (tileWidth / 2.0)) + (adjustedY / (tileHeight / 4.0))));
        const gridY = @trunc(0.5 * ((adjustedY / (tileHeight / 4.0)) - (adjustedX / (tileWidth / 2.0))));

        for (0..@intCast(sizeX)) |i| {
            for (0..@intCast(sizeY)) |j| {
                const x: f32 = @floatFromInt(i);
                const y: f32 = @floatFromInt(j);

                const screenX: f32 = @trunc((x - y) * (tileWidth / 2.0) + offsetX);
                const screenY: f32 = @trunc((x + y) * (tileHeight / 4.0) + offsetY);

                const position = rl.Vector2.init(screenX, screenY);

                const text = rl.textFormat("(%2.f,%2.f)", .{ x, y });
                rl.drawText(text, @intFromFloat(screenX), @intFromFloat(screenY), 20, rl.Color.white);
                rl.drawTextureEx(tile, position, 0, scale, rl.Color.white);
            }
        }

        const text = rl.textFormat("Grid: %f : %f", .{ gridX, gridY });
        rl.drawText(text, 10, 10, 20, rl.Color.white);

        const text2 = rl.textFormat("Mouse: %f : %f", .{ mousePosition.x, mousePosition.y });
        rl.drawText(text2, 10, 30, 20, rl.Color.white);

        rl.clearBackground(rl.Color.init(0x1e, 0x1e, 0x2e, 0xff));
    }
}
