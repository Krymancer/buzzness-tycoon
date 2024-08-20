const rl = @import("raylib");
const std = @import("std");
const utils = @import("utils.zig");

pub const Flowers = enum { rose, tulip, dandelion };

pub const Flower = struct {
    state: f32,
    position: rl.Vector2,

    texture: rl.Texture,
    width: f32,
    height: f32,

    scale: f32,

    debug: bool,

    timeAlive: f32,

    pub fn init(texture: rl.Texture) @This() {
        return .{
            .state = 0,
            .texture = texture,
            .width = 32,
            .height = 32,
            .scale = 2,

            .position = rl.Vector2.init(0, 0),
            .timeAlive = 0,

            .debug = false,
        };
    }

    pub fn isoToXY(self: @This(), i: f32, j: f32, offsetX: f32, offsetY: f32, gridScale: f32) rl.Vector2 {
        const halfScaledWidth: f32 = self.width * gridScale / 2.0;
        const quarterScaledHeight: f32 = self.height * gridScale / 4.0;

        const screenX: f32 = (i - j) * halfScaledWidth - halfScaledWidth + offsetX + self.width;
        const screenY: f32 = (i + j) * quarterScaledHeight + offsetY - self.height / 2;

        return rl.Vector2.init(screenX, screenY);
    }

    pub fn setPosition(self: *@This(), i: f32, j: f32, offset: rl.Vector2, gridScale: f32) void {
        self.position = self.isoToXY(i, j, offset.x, offset.y, gridScale);
    }

    pub fn draw(self: *@This()) void {
        const source = rl.Rectangle.init(self.state * self.width, 0, self.width, self.height);
        const destination = rl.Rectangle.init(self.position.x, self.position.y, self.width * self.scale, self.height * self.scale);
        const origin = rl.Vector2.init(source.width / 2, source.height / 2);
        rl.drawTexturePro(self.texture, source, destination, origin, 0, rl.Color.white);
    }

    pub fn update(self: *@This(), deltaTime: f32) void {
        // TODO: flowers are only able to procude polem when mature (state = 5)
        // add a field to indicate that the flower can have polen
        // add a cooldown each time that a bee haverst the flower polen

        if (self.state < 4) {
            self.timeAlive += deltaTime;
            if (self.timeAlive > 1) {
                self.timeAlive = 0;
                self.state += 1;
            }
        }
    }
};
