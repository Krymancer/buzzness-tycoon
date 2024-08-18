const rl = @import("raylib");
const std = @import("std");

pub const Grid = struct {
    width: u32,
    height: u32,

    tileImage: rl.Image,
    tileTexture: rl.Texture,
    tileWidth: u32,
    tileHieght: u32,

    offsetX: u32,
    offsetY: u32,

    scale: u32,

    debug: bool,

    pub fn init(width: u32, height: u32, offsetX: u32, offsetY: u32) @This() {
        return .{
            .width = width,
            .height = height,

            .offsetX = offsetX,
            .offsetY = offsetY,

            .tileImage = rl.loadImage("sprites/grass-cube.png"),
            .tileTexture = rl.loadTexture("sprites/grass-cube.png"),
            .tileWidth = 32,
            .tileHieght = 32,
            .scale = 5,

            .debug = false,
        };
    }

    pub fn enableDebug(self: *@This()) void {
        self.debug = true;
    }

    pub fn deinit(self: @This()) void {
        rl.unloadTexture(self.tileTexture);
    }

    pub fn isoToXY(self: @This(), i: i32, j: i32) rl.Vector2 {
        const screenX: i32 = (i - j) * @as(i32, @intCast(self.tileWidth * self.scale / 2)) - @as(i32, @intCast(self.tileWidth / 2 * self.scale)) + @as(i32, @intCast(self.offsetX));
        const screenY: i32 = (i + j) * @as(i32, @intCast(self.tileHieght * self.scale / 4)) + @as(i32, @intCast(self.offsetY));

        return rl.Vector2.init(@floatFromInt(screenX), @floatFromInt(screenY));
    }

    fn xytoIso(self: @This(), x: i32, y: i32) rl.Vector2 {
        const a: f32 = @as(f32, @floatFromInt(self.tileWidth * self.scale)) / 2;
        const b: f32 = -@as(f32, @floatFromInt(self.tileWidth * self.scale)) / 2;
        const c: f32 = @as(f32, @floatFromInt(self.tileHieght * self.scale)) / 4;
        const d: f32 = @as(f32, @floatFromInt(self.tileHieght * self.scale)) / 4;

        const det: f32 = 1 / (a * d - b * c);

        const inv_a = det * d;
        const inv_b = det * -b;
        const inv_c = det * -c;
        const inv_d = det * a;

        const deoffx = x - @as(i32, @intCast(self.offsetX));
        const deoofy = y - @as(i32, @intCast(self.offsetY));

        const i = @as(f32, @floatFromInt(deoffx)) * inv_a + @as(f32, @floatFromInt(deoofy)) * inv_b;
        const j = @as(f32, @floatFromInt(deoffx)) * inv_c + @as(f32, @floatFromInt(deoofy)) * inv_d;

        return rl.Vector2.init(i, j);
    }

    pub fn draw(self: @This()) void {
        for (0..self.width) |i| {
            for (0..self.height) |j| {
                const x: i32 = @intCast(i);
                const y: i32 = @intCast(j);
                const position = self.isoToXY(x, y);

                if (self.isMouseHovering(x, y)) {
                    rl.drawTextureEx(self.tileTexture, position, 0, @floatFromInt(self.scale), rl.Color.red);
                } else {
                    rl.drawTextureEx(self.tileTexture, position, 0, @floatFromInt(self.scale), rl.Color.white);
                }

                if (self.debug) {
                    rl.drawText(rl.textFormat("(%d, %d)", .{ x, y }), @as(i32, @intFromFloat(position.x)) + @as(i32, @intCast(self.tileWidth * self.scale / 2)) - 30, @as(i32, @intFromFloat(position.y)) + @as(i32, @intCast(self.tileHieght * self.scale / 4)) - 10, 25, rl.Color.black);
                }
            }
        }
    }

    pub fn isMouseHovering(self: @This(), x: i32, y: i32) bool {
        const mousePos = rl.getMousePosition();
        const a = self.xytoIso(@intFromFloat(mousePos.x), @intFromFloat(mousePos.y));

        if (self.debug) {
            rl.drawText(rl.textFormat("mouse: (%f, %f)", .{ mousePos.x, mousePos.y }), 10, 30, 25, rl.Color.white);
            rl.drawText(rl.textFormat("grid: (%f, %f)", .{ a.x, a.y }), 10, 60, 25, rl.Color.white);
        }

        return x == @as(i32, @intFromFloat(a.x)) and y == @as(i32, @intFromFloat(a.y));
    }
};
