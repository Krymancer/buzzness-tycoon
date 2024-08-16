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

        //rl.drawTexture(texture, 12, 12, rl.Color.white);

        const scale = 5;

        const tileWidth: f32 = @floatFromInt(tile.width * scale);
        const tileHeight: f32 = @floatFromInt(tile.height * scale);

        const sizeX: i32 = 5; //@intCast(@divFloor(screenWidth, grassWidth + gap) - border);
        const sizeY: i32 = 5; //@intCast(@divFloor(screenHeight, grassHeight + gap) - border);

        const offsetX: f32 = @as(f32, @floatFromInt(screenWidth)) / 2.5;
        const offsetY: f32 = @floatFromInt(screenHeight / 4);

        for (0..@intCast(sizeX)) |i| {
            for (0..@intCast(sizeY)) |j| {
                const x: f32 = @floatFromInt(i);
                const y: f32 = @floatFromInt(j);

                const screenX: f32 = (x - y) * (tileWidth / 2.0) + offsetX;
                const screenY: f32 = (x + y) * (tileHeight / 4.0) + offsetY;

                const position = rl.Vector2.init(screenX, screenY);

                rl.drawTextureEx(tile, position, 0, scale, rl.Color.white);
            }
        }

        rl.clearBackground(rl.Color.init(0x1e, 0x1e, 0x2e, 0xff));
    }
}
