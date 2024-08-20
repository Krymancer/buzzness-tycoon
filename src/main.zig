const rl = @import("raylib");
const std = @import("std");

const Grid = @import("grid.zig").Grid;
const Bee = @import("bee.zig").Bee;
const Flower = @import("flower.zig").Flower;
const Flowers = @import("flower.zig").Flowers;
const Textures = @import("textures.zig").Textures;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const rand = std.crypto.random;
    rl.setRandomSeed(rand.int(u32));

    const screenWidth = 1080;
    const screenHeight = 1080;

    rl.initWindow(screenWidth, screenHeight, "Buzzness Tycoon");
    defer rl.closeWindow();

    const beeIcon = rl.loadImage("sprites/bee.png");
    defer rl.unloadImage(beeIcon);
    rl.setWindowIcon(beeIcon);

    const offsetX: f32 = @as(f32, @floatFromInt(screenWidth)) / 2;
    const offsetY: f32 = screenHeight / 4;

    const offset = rl.Vector2.init(offsetX, offsetY);

    const width = 10;
    const height = 10;

    const gameTextures = Textures.init();
    defer gameTextures.deinit();

    var grid = Grid.init(width, height, offset);
    defer grid.deinit();

    const flowers = try allocator.alloc(Flower, width * height);
    for (flowers, 0..) |*element, index| {
        const hasFlower = rand.boolean();
        if (hasFlower) {
            const x = rl.getRandomValue(0, 3);
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

            const flowerTexture = gameTextures.getFlowerTexture(flowerType);
            const i: f32 = @floatFromInt(index / width);
            const j: f32 = @floatFromInt(@mod(index, height));
            element.* = Flower.init(flowerTexture);
            element.setPosition(i, j, offset, grid.scale);
        }
    }

    const bees = try allocator.alloc(Bee, 50);
    for (bees) |*element| {
        const x: f32 = @floatFromInt(rl.getRandomValue(100, 900));
        const y: f32 = @floatFromInt(rl.getRandomValue(200, 700));
        element.* = Bee.init(x, y, gameTextures.bee);
    }

    while (!rl.windowShouldClose()) {
        if (rl.isKeyPressed(rl.KeyboardKey.key_enter) and rl.isKeyDown(rl.KeyboardKey.key_left_alt)) {
            rl.toggleFullscreen();
        }

        const deltaTime = rl.getFrameTime();

        for (bees) |*element| {
            element.update(deltaTime);
        }

        for (flowers) |*element| {
            element.update(deltaTime);
        }

        rl.beginDrawing();
        defer rl.endDrawing();

        grid.draw();

        for (flowers) |*element| {
            element.draw();
        }

        for (bees) |*element| {
            element.draw();
        }

        rl.drawFPS(10, 10);

        rl.clearBackground(rl.Color.init(0x1e, 0x1e, 0x2e, 0xff));
    }
}
