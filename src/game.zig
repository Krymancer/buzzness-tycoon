const rl = @import("raylib");
const std = @import("std");

const Grid = @import("grid.zig").Grid;
const Bee = @import("bee.zig").Bee;
const Flower = @import("flower.zig").Flower;
const Flowers = @import("flower.zig").Flowers;
const Textures = @import("textures.zig").Textures;

const Resources = @import("resources.zig").Resources;
const UI = @import("ui.zig").UI;

pub const Game = struct {
    windowIcon: rl.Image,
    offset: rl.Vector2,

    textures: Textures,
    grid: Grid,

    bees: std.ArrayList(Bee),
    flowers: []Flower,

    resources: Resources,
    ui: UI,

    allocator: std.mem.Allocator,

    pub fn init(width: f32, height: f32, allocator: std.mem.Allocator) !@This() {
        const rand = std.crypto.random;
        rl.setRandomSeed(rand.int(u32));

        rl.initWindow(@intFromFloat(width), @intFromFloat(height), "Buzzness Tycoon");

        const windowIcon = rl.loadImage("sprites/bee.png");
        rl.setWindowIcon(windowIcon);

        const offsetX: f32 = width / 2;
        const offsetY: f32 = height / 4;

        const offset = rl.Vector2.init(offsetX, offsetY);

        const textures = Textures.init();

        const grid = Grid.init(4, 4, offset);

        const flowers = try allocator.alloc(Flower, grid.width * grid.height);
        for (flowers, 0..) |*element, index| {
            const hasFlower = true; // rand.boolean();
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

                const flowerTexture = textures.getFlowerTexture(flowerType);
                const i: f32 = @floatFromInt(index / grid.width);
                const j: f32 = @floatFromInt(@mod(index, grid.height));
                element.* = Flower.init(flowerTexture);
                element.setPosition(i, j, grid.offset, grid.scale);
            }
        }

        var bees = std.ArrayList(Bee).init(allocator);

        for (0..5) |index| {
            _ = index;
            const x: f32 = @floatFromInt(rl.getRandomValue(100, 900));
            const y: f32 = @floatFromInt(rl.getRandomValue(200, 700));
            try bees.append(Bee.init(x, y, textures.bee));
        }

        return .{
            .allocator = allocator,
            .windowIcon = windowIcon,
            .offset = offset,

            .textures = textures,
            .grid = grid,
            .bees = bees,
            .flowers = flowers,

            .resources = Resources.init(),
            .ui = UI.init(),
        };
    }

    pub fn deinit(self: @This()) void {
        rl.closeWindow();
        rl.unloadImage(self.windowIcon);
        self.grid.deinit();
        self.textures.deinit();
        self.ui.deinit();
        self.resources.deinit();

        self.bees.deinit();
    }

    pub fn run(self: *@This()) !void {
        while (!rl.windowShouldClose()) {
            self.input();
            try self.update();
            self.draw();
        }
    }

    pub fn input(self: @This()) void {
        _ = self;
        if (rl.isKeyPressed(rl.KeyboardKey.key_enter) and rl.isKeyDown(rl.KeyboardKey.key_left_alt)) {
            rl.toggleFullscreen();
        }
    }

    pub fn update(self: *@This()) !void {
        const deltaTime = rl.getFrameTime();

        var deadBeesIndexes = std.ArrayList(usize).init(self.allocator);
        defer deadBeesIndexes.deinit();

        for (self.bees.items, 0..self.bees.items.len) |*bee, index| {
            bee.update(deltaTime, self.flowers);

            if (bee.dead) {
                try deadBeesIndexes.append(index);
            }
        }

        for (deadBeesIndexes.items) |deadBeeIndex| {
            _ = self.bees.swapRemove(deadBeeIndex);
        }

        for (self.flowers) |*element| {
            element.update(deltaTime);
        }
    }

    pub fn draw(self: @This()) void {
        rl.beginDrawing();
        defer rl.endDrawing();

        self.grid.draw();

        for (self.flowers) |*element| {
            element.draw();
        }

        for (self.bees.items) |*bee| {
            bee.draw();
        }

        self.ui.draw(self.resources.honey, self.bees.items.len);

        //rl.drawFPS(10, 10);

        rl.clearBackground(rl.Color.init(0x1e, 0x1e, 0x2e, 0xff));
    }
};
