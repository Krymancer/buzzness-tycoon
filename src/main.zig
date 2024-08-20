const rl = @import("raylib");
const std = @import("std");

const Grid = @import("grid.zig").Grid;
const Bee = @import("bee.zig").Bee;
const Flower = @import("flower.zig").Flower;
const Flowers = @import("flower.zig").Flowers;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const screenWidth = 1080;
    const screenHeight = 1080;

    rl.initWindow(screenWidth, screenHeight, "Buzzness Tycoon");
    defer rl.closeWindow();

    const beeIcon = rl.loadImage("sprites/bee.png");
    defer rl.unloadImage(beeIcon);
    rl.setWindowIcon(beeIcon);

    const offsetX: f32 = @as(f32, @floatFromInt(screenWidth)) / 2;
    const offsetY: f32 = screenHeight / 4;

    const width = 10;
    const height = 10;

    const flowers = try allocator.alloc(Flower, width * height);
    const rand = std.crypto.random;
    for (flowers) |*element| {
        const hasFlower = rand.boolean();
        if (hasFlower) {
            const x = rand.intRangeAtMost(u32, 0, 3);
            var flowerType: Flowers = undefined;
            if (x == 1) {
                flowerType = Flowers.rose;
            }
            if (x == 2) {
                flowerType = Flowers.dandelion;
            }
            if (x == 3) {
                flowerType = Flowers.tulip;
            }
            element.* = Flower.init(flowerType);
        }
    }

    var grid = Grid.init(width, height, offsetX, offsetY);
    defer grid.deinit();

    var bee = Bee.init();
    defer bee.deinit();

    var flower = Flower.init(Flowers.rose);
    defer flower.deinit();

    while (!rl.windowShouldClose()) {
        if (rl.isKeyPressed(rl.KeyboardKey.key_enter) and rl.isKeyDown(rl.KeyboardKey.key_left_alt)) {
            rl.toggleFullscreen();
        }

        const deltaTime = rl.getFrameTime();

        try bee.update(deltaTime);
        flower.update(deltaTime);

        for (flowers) |*element| {
            element.update(deltaTime);
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.drawFPS(10, 10);
        rl.drawText(rl.textFormat("%f", .{deltaTime}), 10, 30, 25, rl.Color.white);

        grid.draw();
        for (flowers, 0..) |*element, index| {
            const i: f32 = @floatFromInt(index / width);
            const j: f32 = @floatFromInt(@mod(index, height));
            element.draw(i, j, grid.offsetX, grid.offsetY, grid.scale);
        }

        bee.draw();

        rl.clearBackground(rl.Color.init(0x1e, 0x1e, 0x2e, 0xff));
    }
}
