const rl = @import("raylib");
const std = @import("std");

pub const Grid = struct {
    width: usize,
    height: usize,

    tileImage: rl.Image,
    tileTexture: rl.Texture,
    tileWidth: i32,
    tileHeight: i32,

    offsetX: i32,
    offsetY: i32,

    scale: i32,

    debug: bool,

    pub fn init(width: usize, height: usize, offsetX: i32, offsetY: i32) @This() {
        return .{
            .width = width,
            .height = height,

            .offsetX = offsetX,
            .offsetY = offsetY,

            .tileImage = rl.loadImage("sprites/grass-cube.png"),
            .tileTexture = rl.loadTexture("sprites/grass-cube.png"),
            .tileWidth = 32,
            .tileHeight = 32,
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

    pub fn isoToXY(self: @This(), i: f32, j: f32) rl.Vector2 {
        const scale: f32 = @floatFromInt(self.scale);
        const tileWidth: f32 = @floatFromInt(self.tileWidth);
        const tileHeight: f32 = @floatFromInt(self.tileHeight);
        const offsetX: f32 = @floatFromInt(self.offsetX);
        const offsetY: f32 = @floatFromInt(self.offsetY);

        const scaledWidth: f32 = tileWidth * scale;
        const scaledHeight: f32 = tileHeight * scale;

        const halfScaledWidth: f32 = scaledWidth / 2.0;
        const quarterScaledHeight: f32 = scaledHeight / 4.0;

        const screenX: f32 = (i - j) * halfScaledWidth - halfScaledWidth + offsetX;
        const screenY: f32 = (i + j) * quarterScaledHeight + offsetY;

        return rl.Vector2.init(screenX, screenY);
    }

    fn xytoIso(self: @This(), x: f32, y: f32) rl.Vector2 {
        const a: f32 = @as(f32, @floatFromInt(self.tileWidth * self.scale)) / 2;
        const b: f32 = -@as(f32, @floatFromInt(self.tileWidth * self.scale)) / 2;
        const c: f32 = @as(f32, @floatFromInt(self.tileHeight * self.scale)) / 4;
        const d: f32 = @as(f32, @floatFromInt(self.tileHeight * self.scale)) / 4;

        const det: f32 = 1 / (a * d - b * c);

        const inv_a = det * d;
        const inv_b = det * -b;
        const inv_c = det * -c;
        const inv_d = det * a;

        const deoffx = x - @as(f32, @floatFromInt(self.offsetX));
        const deoofy = y - @as(f32, @floatFromInt(self.offsetY));

        const i = deoffx * inv_a + deoofy * inv_b;
        const j = deoffx * inv_c + deoofy * inv_d;

        return rl.Vector2.init(i, j);
    }

    pub fn draw(self: @This()) void {
        for (0..self.width) |i| {
            for (0..self.height) |j| {
                const x: f32 = @floatFromInt(i);
                const y: f32 = @floatFromInt(j);
                const position = self.isoToXY(x, y);

                if (self.debug) {
                    if (self.isMouseHovering(x, y)) {
                        rl.drawTextureEx(self.tileTexture, position, 0, @floatFromInt(self.scale), rl.Color.red);
                    } else {
                        rl.drawTextureEx(self.tileTexture, position, 0, @floatFromInt(self.scale), rl.Color.white);
                    }

                    const scale: f32 = @floatFromInt(self.scale);
                    const tileWidth: f32 = @floatFromInt(self.tileWidth);
                    const tileHeight: f32 = @floatFromInt(self.tileHeight);

                    const scaledWidth: f32 = tileWidth * scale;
                    const scaledHeight: f32 = tileHeight * scale;

                    const halfScaledWidth: f32 = scaledWidth / 2.0;
                    const quarterScaledHeight: f32 = scaledHeight / 4.0;

                    const textX: i32 = @as(i32, @intFromFloat(position.x)) + @as(i32, @intFromFloat(halfScaledWidth)) - 30;
                    const textY: i32 = @as(i32, @intFromFloat(position.y)) + @as(i32, @intFromFloat(quarterScaledHeight)) - 10;

                    rl.drawText(rl.textFormat("(%0.f, %0.f)", .{ x, y }), textX, textY, 25, rl.Color.black);
                } else {
                    rl.drawTextureEx(self.tileTexture, position, 0, @floatFromInt(self.scale), rl.Color.white);
                }
            }
        }
    }

    pub fn isMouseHovering(self: @This(), x: f32, y: f32) bool {
        const mousePosition = rl.getMousePosition();
        const gridMousePosition = self.xytoIso(mousePosition.x, mousePosition.y);

        if (self.debug) {
            rl.drawText(rl.textFormat("mouse: (%f, %f)", .{ mousePosition.x, mousePosition.y }), 10, 30, 25, rl.Color.white);
            rl.drawText(rl.textFormat("grid: (%d, %d)", .{ @as(i32, @intFromFloat(gridMousePosition.x)), @as(i32, @intFromFloat(gridMousePosition.y)) }), 10, 60, 25, rl.Color.white);
        }

        if (gridMousePosition.x < 0 or gridMousePosition.y < 0) {
            return false;
        }

        const normalizedGridMouseX = @trunc(gridMousePosition.x);
        const normalizedGridMouseY = @trunc(gridMousePosition.y);

        return x == normalizedGridMouseX and y == normalizedGridMouseY;
    }
};
