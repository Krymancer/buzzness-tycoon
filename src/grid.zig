const rl = @import("raylib");
const std = @import("std");
const utils = @import("utils.zig");

pub const Grid = struct {
    width: usize,
    height: usize,

    tileTexture: rl.Texture,
    tileWidth: f32,
    tileHeight: f32,

    offset: rl.Vector2,

    scale: f32,

    debug: bool,
    pub fn init(width: usize, height: usize, offset: rl.Vector2) !@This() {
        return .{
            .width = width,
            .height = height,

            .offset = offset,

            .tileTexture = try rl.loadTexture("sprites/grass-cube.png"),
            .tileWidth = 32,
            .tileHeight = 32,
            .scale = 3,

            .debug = true,
        };
    }

    pub fn enableDebug(self: *@This()) void {
        self.debug = true;
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
            }
        }
    }

    pub fn isMouseHovering(self: @This(), x: f32, y: f32) bool {
        // Get mouse position in screen coordinates
        const mousePosition = rl.getMousePosition();

        // Use the improved isometric hit detection
        return utils.isPointInIsometricTile(mousePosition.x, mousePosition.y, x, y, self.tileWidth, self.tileHeight, self.offset.x, self.offset.y, self.scale);
    }
};
