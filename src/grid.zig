const rl = @import("raylib");
const std = @import("std");

pub const Grid = struct {
    width: u32,
    height: u32,

    tileTexture: rl.Texture,
    tileWidth: u32,
    tileHieght: u32,

    offsetX: u32,
    offsetY: u32,

    scale: u32,

    pub fn init(width: u32, height: u32, offsetX: u32, offsetY: u32) @This() {
        return .{
            .width = width,
            .height = height,

            .offsetX = offsetX,
            .offsetY = offsetY,

            .tileTexture = rl.loadTexture("sprites/grass-cube.png"),
            .tileWidth = 32,
            .tileHieght = 32,
            .scale = 5,
        };
    }

    pub fn draw(self: @This()) void {
        for (0..self.width) |i| {
            for (0..self.height) |j| {
                const x: i32 = @intCast(i);
                const y: i32 = @intCast(j);

                const screenX: i32 = (x - y) * @as(i32, @intCast(self.tileWidth * self.scale / 2)) + @as(i32, @intCast(self.offsetX));
                const screenY: i32 = (x + y) * @as(i32, @intCast(self.tileHieght * self.scale / 4)) + @as(i32, @intCast(self.offsetY));

                const position = rl.Vector2.init(@floatFromInt(screenX), @floatFromInt(screenY));

                rl.drawTextureEx(self.tileTexture, position, 0, @floatFromInt(self.scale), rl.Color.white);
            }
        }
    }

    pub fn deinit(self: @This()) void {
        rl.unloadTexture(self.tileTexture);
    }
};
