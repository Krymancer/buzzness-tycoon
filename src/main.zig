const rl = @import("raylib");
const std = @import("std");

const Grid = @import("grid.zig").Grid;

pub fn main() anyerror!void {
    const screenWidth = 1080;
    const screenHeight = 1080;

    rl.initWindow(screenWidth, screenHeight, "Buzzness Tycoon");
    defer rl.closeWindow();

    const beeIcon = rl.loadImage("sprites/bee.png");
    defer rl.unloadImage(beeIcon);
    rl.setWindowIcon(beeIcon);

    //rl.setTargetFPS(60);

    const offsetX: f32 = @as(f32, @floatFromInt(screenWidth)) / 2;
    const offsetY: f32 = screenHeight / 4;

    var grid = Grid.init(5, 5, offsetX, offsetY);
    defer grid.deinit();

    grid.enableDebug();

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.drawFPS(10, 10);
        grid.draw();

        rl.clearBackground(rl.Color.init(0x1e, 0x1e, 0x2e, 0xff));
    }
}
