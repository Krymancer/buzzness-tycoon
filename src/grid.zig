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

    pub fn draw(self: @This()) void {
        for (0..self.width) |i| {
            for (0..self.height) |j| {
                const x: i32 = @intCast(i);
                const y: i32 = @intCast(j);

                const screenX: i32 = (x - y) * @as(i32, @intCast(self.tileWidth * self.scale / 2)) + @as(i32, @intCast(self.offsetX));
                const screenY: i32 = (x + y) * @as(i32, @intCast(self.tileHieght * self.scale / 4)) + @as(i32, @intCast(self.offsetY));

                const position = rl.Vector2.init(@floatFromInt(screenX), @floatFromInt(screenY));

                if (isMouseHovering(self, x, y)) {
                    rl.drawTextureEx(self.tileTexture, position, 0, @floatFromInt(self.scale), rl.Color.red);
                } else {
                    rl.drawTextureEx(self.tileTexture, position, 0, @floatFromInt(self.scale), rl.Color.white);
                }

                if (self.debug) {
                    rl.drawText(rl.textFormat("(%d, %d)", .{ x, y }), screenX + @as(i32, @intCast(self.tileWidth * self.scale / 2)) - 30, screenY + @as(i32, @intCast(self.tileHieght * self.scale / 4)) - 10, 25, rl.Color.black);
                }
            }
        }
    }

    pub fn isMouseHovering(self: @This(), x: i32, y: i32) bool {
        const mousePos = rl.getMousePosition();

        const screenX: i32 = (x - y) * @as(i32, @intCast(self.tileWidth * self.scale / 2)) + @as(i32, @intCast(self.offsetX));
        const screenY: i32 = (x + y) * @as(i32, @intCast(self.tileHieght * self.scale / 4)) + @as(i32, @intCast(self.offsetY));

        const mouseX: i32 = @intFromFloat(mousePos.x);
        const mouseY: i32 = @intFromFloat(mousePos.y);

        if (mouseX >= screenX and mouseX <= screenX + @as(i32, @intCast(self.tileWidth * self.scale)) and
            mouseY >= screenY and mouseY <= screenY + @as(i32, @intCast(self.tileHieght * self.scale / 2)))
        {
            const relativeX = @divFloor((mouseX - screenX), @as(i32, @intCast(self.scale)));
            const relativeY = @divFloor((mouseY - screenY), @as(i32, @intCast(self.scale)));

            if (relativeX >= 32 or relativeY >= 32) {
                return false;
            }

            const pixelColor = rl.getImageColor(self.tileImage, relativeX, relativeY);

            if (pixelColor.a > 0) {
                return true;
            }
        }

        return false;
    }
};
