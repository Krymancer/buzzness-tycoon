const rl = @import("raylib");
const std = @import("std");

const Grid = @import("grid.zig").Grid;
const Bee = @import("bee.zig").Bee;
const Flower = @import("flower.zig").Flower;
const Flowers = @import("flower.zig").Flowers;
const Textures = @import("textures.zig").Textures;
const assets = @import("assets.zig");
const utils = @import("utils.zig");

const Resources = @import("resources.zig").Resources;
const UI = @import("ui.zig").UI;

pub const Game = struct {
    const GRID_WIDTH = 16;
    const GRID_HEIGHT = 16;
    const FLOWER_SPAWN_CHANCE = 30;

    width: f32,
    height: f32,

    windowIcon: rl.Image,

    textures: Textures,
    grid: Grid,

    bees: std.ArrayList(Bee),
    flowers: std.ArrayList(Flower),

    resources: Resources,
    ui: UI,

    cameraOffset: rl.Vector2,
    isDragging: bool,
    lastMousePos: rl.Vector2,

    allocator: std.mem.Allocator,

    pub fn init(width: f32, height: f32, allocator: std.mem.Allocator) !@This() {
        const rand = std.crypto.random;
        rl.setRandomSeed(rand.int(u32));

        rl.initWindow(@intFromFloat(width), @intFromFloat(height), "Buzzness Tycoon");
        const windowIcon = try assets.loadImageFromMemory(assets.bee_png);
        rl.setWindowIcon(windowIcon);

        const textures = try Textures.init();

        const grid = try Grid.init(GRID_WIDTH, GRID_HEIGHT, width, height);

        var flowers = std.ArrayList(Flower).init(allocator);

        for (0..grid.width) |i| {
            for (0..grid.height) |j| {
                const shouldHaveFlower = rl.getRandomValue(1, 100) <= FLOWER_SPAWN_CHANCE;
                if (shouldHaveFlower) {
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
                    const gridI: f32 = @as(f32, @floatFromInt(i));
                    const gridJ: f32 = @as(f32, @floatFromInt(j));
                    const flower = Flower.init(flowerTexture, gridI, gridJ);
                    try flowers.append(flower);
                }
            }
        }

        var bees = std.ArrayList(Bee).init(allocator);

        for (0..5) |_| {
            const randomPos = grid.getRandomPositionInBounds();
            var bee = Bee.init(randomPos.x, randomPos.y, textures.bee);
            bee.updateScale(grid.scale);
            try bees.append(bee);
        }

        return .{
            .allocator = allocator,
            .windowIcon = windowIcon,

            .textures = textures,
            .grid = grid,
            .bees = bees,
            .flowers = flowers,

            .resources = Resources.init(),
            .ui = UI.init(),

            .cameraOffset = rl.Vector2.init(0, 0),
            .isDragging = false,
            .lastMousePos = rl.Vector2.init(0, 0),

            .width = width,
            .height = height,
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
        self.flowers.deinit();
    }

    pub fn drawSpriteAtGridPosition(self: *@This(), texture: rl.Texture, i: f32, j: f32, sourceRect: rl.Rectangle, scale: f32, color: rl.Color) void {
        const tilePosition = utils.isoToXY(i, j, 32, 32, self.grid.offset.x, self.grid.offset.y, self.grid.scale);
        const effectiveScale = scale * (self.grid.scale / 3.0);

        // Calculate the center of the tile's top surface
        const tileWidth = 32 * self.grid.scale;
        const tileHeight = 32 * self.grid.scale;

        // Center horizontally on the tile
        const centeredX = tilePosition.x + (tileWidth - sourceRect.width * effectiveScale) / 2.0;

        // Position on the top surface of the isometric cube (top 1/4 of the tile)
        const centeredY = tilePosition.y + (tileHeight * 0.25) - (sourceRect.height * effectiveScale);

        const destination = rl.Rectangle.init(centeredX, centeredY, sourceRect.width * effectiveScale, sourceRect.height * effectiveScale);

        rl.drawTexturePro(texture, sourceRect, destination, rl.Vector2.init(0, 0), 0, color);
    }

    pub fn drawSpriteAtWorldPosition(self: *@This(), texture: rl.Texture, worldPos: rl.Vector2, sourceRect: rl.Rectangle, scale: f32, color: rl.Color) void {
        const effectiveScale = scale * (self.grid.scale / 3.0);

        const destination = rl.Rectangle.init(worldPos.x, worldPos.y, sourceRect.width * effectiveScale, sourceRect.height * effectiveScale);

        rl.drawTexturePro(texture, sourceRect, destination, rl.Vector2.init(0, 0), 0, color);
    }

    pub fn trySpawnFlower(self: *@This(), beePosition: rl.Vector2) !bool {
        // Convert bee world position to grid coordinates
        const gridPos = utils.worldToGrid(beePosition, self.grid.offset, self.grid.scale);
        const gridI = @as(usize, @intFromFloat(@max(0, @min(@as(f32, @floatFromInt(self.grid.width - 1)), gridPos.x))));
        const gridJ = @as(usize, @intFromFloat(@max(0, @min(@as(f32, @floatFromInt(self.grid.height - 1)), gridPos.y))));

        // Check if there's already a live flower at this position
        for (self.flowers.items) |*flower| {
            if (!flower.dead and
                @as(usize, @intFromFloat(flower.gridPosition.x)) == gridI and
                @as(usize, @intFromFloat(flower.gridPosition.y)) == gridJ)
            {
                return false; // Already has a live flower
            }
        }

        // Look for a dead flower at this position to revive
        for (self.flowers.items) |*flower| {
            if (flower.dead and
                @as(usize, @intFromFloat(flower.gridPosition.x)) == gridI and
                @as(usize, @intFromFloat(flower.gridPosition.y)) == gridJ)
            {

                // Revive the flower with a random type
                const flowerType = self.getRandomFlowerType();
                flower.texture = self.textures.getFlowerTexture(flowerType);
                flower.* = Flower.init(flower.texture, @as(f32, @floatFromInt(gridI)), @as(f32, @floatFromInt(gridJ)));
                return true;
            }
        }

        // If no dead flower found, spawn a new one
        const flowerType = self.getRandomFlowerType();
        const flowerTexture = self.textures.getFlowerTexture(flowerType);
        const flower = Flower.init(flowerTexture, @as(f32, @floatFromInt(gridI)), @as(f32, @floatFromInt(gridJ)));
        try self.flowers.append(flower);
        return true;
    }

    fn getRandomFlowerType(self: *@This()) Flowers {
        _ = self;
        const x = rl.getRandomValue(1, 3);
        return switch (x) {
            1 => Flowers.rose,
            2 => Flowers.dandelion,
            3 => Flowers.tulip,
            else => Flowers.rose,
        };
    }

    pub fn run(self: *@This()) !void {
        while (!rl.windowShouldClose()) {
            self.input();
            try self.update();
            try self.draw();
        }
    }

    pub fn input(self: *@This()) void {
        if (rl.isKeyPressed(rl.KeyboardKey.enter) and rl.isKeyDown(rl.KeyboardKey.left_alt)) {
            rl.toggleFullscreen();
        }

        // Handle mouse dragging for camera movement
        const mousePos = rl.getMousePosition();

        if (rl.isMouseButtonPressed(rl.MouseButton.left)) {
            self.isDragging = true;
            self.lastMousePos = mousePos;
        }

        if (rl.isMouseButtonReleased(rl.MouseButton.left)) {
            self.isDragging = false;
        }

        if (self.isDragging) {
            const mouseDelta = rl.Vector2.init(mousePos.x - self.lastMousePos.x, mousePos.y - self.lastMousePos.y);

            self.cameraOffset.x += mouseDelta.x;
            self.cameraOffset.y += mouseDelta.y;

            // Update grid offset
            self.grid.offset.x += mouseDelta.x;
            self.grid.offset.y += mouseDelta.y;

            self.lastMousePos = mousePos;
        }

        const wheelMove = rl.getMouseWheelMove();
        if (wheelMove != 0.0) {
            const zoomSpeed = 0.3;
            const zoomDelta = wheelMove * zoomSpeed;
            self.grid.zoom(zoomDelta);

            // Update bee scales
            for (self.bees.items) |*bee| {
                bee.updateScale(self.grid.scale);
            }
        }
    }

    pub fn update(self: *@This()) !void {
        const deltaTime = rl.getFrameTime();

        var deadBeesIndexes = std.ArrayList(usize).init(self.allocator);
        defer deadBeesIndexes.deinit();

        for (self.bees.items, 0..self.bees.items.len) |*bee, index| {
            const previousPollen = bee.pollenCollected;

            bee.update(deltaTime, self.flowers.items, self.grid.offset, self.grid.scale);

            if (bee.pollenCollected > previousPollen) {
                const newHoneyAmount = bee.pollenCollected - previousPollen;
                self.resources.addHoney(newHoneyAmount);
            }

            if (bee.carryingPollen) {
                const spawnChancePerSecond = 0.1;
                const spawnChanceThisFrame = spawnChancePerSecond * deltaTime;
                const randomValue = @as(f32, @floatFromInt(rl.getRandomValue(0, 1000))) / 1000.0;

                if (randomValue < spawnChanceThisFrame) {
                    const spawned = try self.trySpawnFlower(bee.position);
                    if (spawned) {
                        bee.carryingPollen = false;
                    }
                }
            }

            if (bee.dead) {
                try deadBeesIndexes.append(index);
            }
        }

        for (deadBeesIndexes.items) |deadBeeIndex| {
            _ = self.bees.swapRemove(deadBeeIndex);
        }

        var deadFlowersIndexes = std.ArrayList(usize).init(self.allocator);
        defer deadFlowersIndexes.deinit();

        for (self.flowers.items, 0..self.flowers.items.len) |*element, index| {
            element.update(deltaTime);

            if (element.dead) {
                try deadFlowersIndexes.append(index);
            }
        }

        // Remove dead flowers in reverse order to maintain correct indices
        var i: usize = deadFlowersIndexes.items.len;
        while (i > 0) {
            i -= 1;
            _ = self.flowers.swapRemove(deadFlowersIndexes.items[i]);
        }
    }

    pub fn draw(self: *@This()) !void {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(rl.Color.init(0x1e, 0x1e, 0x2e, 0xff));

        self.grid.draw();

        // Draw flowers using centralized rendering
        for (self.flowers.items) |*flower| {
            if (flower.dead) continue;

            const source = rl.Rectangle.init(flower.state * flower.width, 0, flower.width, flower.height);

            if (flower.state == 4 and flower.hasPolen) {
                // Draw glow effect
                self.drawSpriteAtGridPosition(flower.texture, flower.gridPosition.x, flower.gridPosition.y, source, flower.scale + 0.1, rl.Color.init(255, 255, 100, 128));
            }

            // Draw main flower
            self.drawSpriteAtGridPosition(flower.texture, flower.gridPosition.x, flower.gridPosition.y, source, flower.scale, rl.Color.white);
        }

        for (self.bees.items) |*bee| {
            bee.draw();
        }

        if (self.ui.draw(self.resources.honey, self.bees.items.len)) {
            if (self.resources.spendHoney(10.0)) {
                const randomPos = self.grid.getRandomPositionInBounds();
                var bee = Bee.init(randomPos.x, randomPos.y, self.textures.bee);
                bee.updateScale(self.grid.scale); // Set scale based on current grid scale
                try self.bees.append(bee);
            }
        }

        rl.drawFPS(@as(i32, @intFromFloat(self.width - 100)), 10);
    }
};
