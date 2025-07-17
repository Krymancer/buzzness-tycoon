const rl = @import("raylib");
const std = @import("std");
const utils = @import("utils.zig");
const assets = @import("assets.zig");

pub const Grid = struct {
    width: usize,
    height: usize,

    tileTexture: rl.Texture,
    tileWidth: f32,
    tileHeight: f32,

    offset: rl.Vector2,

    scale: f32,
    baseScale: f32,
    minScale: f32,
    maxScale: f32,

    viewportWidth: f32,
    viewportHeight: f32,

    debug: bool,
    pub fn init(width: usize, height: usize, viewportWidth: f32, viewportHeight: f32) !@This() {
        const tileWidth = 32;
        const tileHeight = 32;
        const baseScale = 3;

        const offset = utils.calculateCenteredGridOffset(width, height, tileWidth, tileHeight, baseScale, viewportWidth, viewportHeight);

        return .{
            .width = width,
            .height = height,

            .offset = offset,

            .tileTexture = try assets.loadTextureFromMemory(assets.grass_cube_png),
            .tileWidth = tileWidth,
            .tileHeight = tileHeight,
            .scale = baseScale,
            .baseScale = baseScale,
            .minScale = 1.0,
            .maxScale = 6.0,

            .viewportWidth = viewportWidth,
            .viewportHeight = viewportHeight,

            .debug = true,
        };
    }

    pub fn enableDebug(self: *@This()) void {
        self.debug = true;
    }

    pub fn zoom(self: *@This(), zoomDelta: f32) void {
        const newScale = self.scale + zoomDelta;
        self.scale = @max(self.minScale, @min(self.maxScale, newScale));
        self.updateOffset();
    }

    pub fn updateOffset(self: *@This()) void {
        self.offset = utils.calculateCenteredGridOffset(self.width, self.height, self.tileWidth, self.tileHeight, self.scale, self.viewportWidth, self.viewportHeight);
    }

    pub fn getRandomPositionInBounds(self: @This()) rl.Vector2 {
        // Get a random position within the grid's visual bounds
        const scaledTileWidth = self.tileWidth * self.scale;
        const scaledTileHeight = self.tileHeight * self.scale;

        // Calculate the approximate grid bounds
        const gridWidth = @as(f32, @floatFromInt(self.width)) * scaledTileWidth;
        const gridHeight = @as(f32, @floatFromInt(self.height)) * scaledTileHeight;

        // Generate random position within the grid bounds
        const x = self.offset.x + @as(f32, @floatFromInt(rl.getRandomValue(0, @as(i32, @intFromFloat(gridWidth)))));
        const y = self.offset.y + @as(f32, @floatFromInt(rl.getRandomValue(0, @as(i32, @intFromFloat(gridHeight)))));

        return rl.Vector2.init(x, y);
    }

    pub fn deinit(self: @This()) void {
        rl.unloadTexture(self.tileTexture);
    }

    pub fn draw(self: @This()) void {
        for (0..self.width) |i| {
            for (0..self.height) |j| {
                const x: f32 = @floatFromInt(i);
                const y: f32 = @floatFromInt(j);
                const position = utils.isoToXY(x, y, self.tileWidth, self.tileHeight, self.offset.x, self.offset.y, self.scale);

                if (self.debug) {
                    if (self.isMouseHovering(x, y)) {
                        rl.drawTextureEx(self.tileTexture, position, 0, self.scale, rl.Color.red);
                    } else {
                        rl.drawTextureEx(self.tileTexture, position, 0, self.scale, rl.Color.white);
                    }
                } else {
                    rl.drawTextureEx(self.tileTexture, position, 0, self.scale, rl.Color.white);
                }
                
                // Debug border for tiles
                const tileWidth = self.tileWidth * self.scale;
                const tileHeight = self.tileHeight * self.scale;
                rl.drawRectangleLines(@intFromFloat(position.x), @intFromFloat(position.y), @intFromFloat(tileWidth), @intFromFloat(tileHeight), rl.Color.blue);
            }
        }
    }

    pub fn isMouseHovering(self: @This(), x: f32, y: f32) bool {
        const mousePosition = rl.getMousePosition();
        return utils.isPointInIsometricTile(mousePosition.x, mousePosition.y, x, y, self.tileWidth, self.tileHeight, self.offset.x, self.offset.y, self.scale);
    }
};
