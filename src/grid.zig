const rl = @import("raylib");
const std = @import("std");

pub const Grid = struct {
    width: usize,
    height: usize,

    tileTexture: rl.Texture,
    tileWidth: f32,
    tileHeight: f32,

    offset: rl.Vector2,

    scale: f32,

    debug: bool,

    pub fn init(width: usize, height: usize, offset: rl.Vector2) @This() {
        return .{
            .width = width,
            .height = height,

            .offset = offset,

            .tileTexture = rl.loadTexture("sprites/grass-cube.png"),
            .tileWidth = 32,
            .tileHeight = 32,
            .scale = 3,

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
        const halfScaledWidth: f32 = self.tileWidth * self.scale / 2.0;
        const quarterScaledHeight: f32 = self.tileHeight * self.scale / 4.0;

        const screenX: f32 = (i - j) * halfScaledWidth - halfScaledWidth + self.offset.x;
        const screenY: f32 = (i + j) * quarterScaledHeight + self.offset.y;

        return rl.Vector2.init(screenX, screenY);
    }

    fn xytoIso(self: @This(), x: f32, y: f32) rl.Vector2 {
        const a: f32 = self.tileWidth * self.scale / 2;
        const b: f32 = -self.tileWidth * self.scale / 2;
        const c: f32 = self.tileHeight * self.scale / 4;
        const d: f32 = self.tileHeight * self.scale / 4;

        const determinant: f32 = 1 / (a * d - b * c);

        const inverse_a = determinant * d;
        const inverse_b = determinant * -b;
        const inverse_c = determinant * -c;
        const inverse_d = determinant * a;

        const ajustedX = x - self.offset.x;
        const ajustedY = y - self.offset.y;

        const i = ajustedX * inverse_a + ajustedY * inverse_b;
        const j = ajustedX * inverse_c + ajustedY * inverse_d;

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
                        rl.drawTextureEx(self.tileTexture, position, 0, self.scale, rl.Color.red);
                    } else {
                        rl.drawTextureEx(self.tileTexture, position, 0, self.scale, rl.Color.white);
                    }

                    const halfScaledWidth: f32 = self.tileWidth * self.scale / 2.0;
                    const quarterScaledHeight: f32 = self.tileHeight * self.scale / 4.0;

                    const textX: i32 = @as(i32, @intFromFloat(position.x)) + @as(i32, @intFromFloat(halfScaledWidth)) - 30;
                    const textY: i32 = @as(i32, @intFromFloat(position.y)) + @as(i32, @intFromFloat(quarterScaledHeight)) - 10;

                    rl.drawText(rl.textFormat("(%0.f, %0.f)", .{ x, y }), textX, textY, 25, rl.Color.black);
                } else {
                    rl.drawTextureEx(self.tileTexture, position, 0, self.scale, rl.Color.white);
                }
            }
        }
    }

    pub fn isMouseHovering(self: @This(), x: f32, y: f32) bool {
        const mousePosition = rl.getMousePosition();
        const gridMousePosition = self.xytoIso(mousePosition.x, mousePosition.y);

        if (gridMousePosition.x < 0 or gridMousePosition.y < 0) {
            return false;
        }

        const normalizedGridMouseX = @trunc(gridMousePosition.x);
        const normalizedGridMouseY = @trunc(gridMousePosition.y);

        return x == normalizedGridMouseX and y == normalizedGridMouseY;
    }
};
