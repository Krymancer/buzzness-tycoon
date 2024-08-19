const rl = @import("raylib");
const std = @import("std");

pub const Flowers = enum { rose, tulip, dandelion };

pub const Flower = struct {
    state: f32,
    position: rl.Vector2,

    texture: rl.Texture,
    width: f32,
    height: f32,

    scale: f32,

    debug: bool,

    pub fn init(flower: Flowers) @This() {
        const texture = switch (flower) {
            .rose => rl.loadTexture("sprites/rose.png"),
            .tulip => rl.loadTexture("sprites/tulip.png"),
            .dandelion => rl.loadTexture("sprites/dandelion.png"),
        };

        return .{
            .state = 0,
            .texture = texture,
            .width = 32,
            .height = 32,
            .scale = 2,

            .position = rl.Vector2.init(540, 540),

            .debug = false,
        };
    }

    pub fn deinit(self: @This()) void {
        rl.unloadTexture(self.texture);
    }

    pub fn draw(self: @This()) void {
        //     void DrawTexturePro(Texture2D texture, Rectangle source, Rectangle dest, Vector2 origin, float rotation, Color tint);
        const source = rl.Rectangle.init(self.state * self.width, 0, self.width, self.height);
        const destination = rl.Rectangle.init(self.position.x, self.position.y, self.width * self.scale, self.height * self.scale);
        const origin = rl.Vector2.init(source.width / 2, source.height / 2);
        rl.drawTexturePro(self.texture, source, destination, origin, 0, rl.Color.white);
    }
};
