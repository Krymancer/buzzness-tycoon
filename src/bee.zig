const rl = @import("raylib");
const std = @import("std");

pub const Bee = struct {
    position: rl.Vector2,

    texture: rl.Texture,
    width: f32,
    height: f32,

    scale: f32,

    debug: bool,

    pub fn init() @This() {
        return .{
            .texture = rl.loadTexture("sprites/bee.png"),
            .width = 32,
            .height = 32,
            .scale = 1,

            .position = rl.Vector2.init(540, 540),

            .debug = false,
        };
    }

    pub fn enableDebug(self: *@This()) void {
        self.debug = true;
    }

    pub fn deinit(self: @This()) void {
        rl.unloadTexture(self.texture);
    }

    pub fn update(self: *@This()) !void {
        const rand = std.crypto.random;

        const newX = if (rand.boolean()) rand.float(f32) else -rand.float(f32);
        const newY = if (rand.boolean()) rand.float(f32) else -rand.float(f32);

        self.position.x += newX;
        self.position.y += newY;
    }

    pub fn draw(self: @This()) void {
        rl.drawTextureEx(self.texture, self.position, 0, self.scale, rl.Color.white);
    }
};
