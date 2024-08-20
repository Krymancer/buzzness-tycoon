const rl = @import("raylib");
const std = @import("std");

pub const Bee = struct {
    position: rl.Vector2,

    texture: rl.Texture,
    width: f32,
    height: f32,

    scale: f32,

    debug: bool,

    pub fn init(x: f32, y: f32, texture: rl.Texture) @This() {
        return .{
            .texture = texture,
            .width = 32,
            .height = 32,
            .scale = 1,

            .position = rl.Vector2.init(x, y),

            .debug = false,
        };
    }

    pub fn enableDebug(self: *@This()) void {
        self.debug = true;
    }

    pub fn update(self: *@This(), deltaTime: f32) void {
        // TODO: remove pure random walk and impelement a go to flower function
        const scaleFactor: f32 = 10.0;

        const offsetX: f32 = @as(f32, @floatFromInt(rl.getRandomValue(-100, 100))) * deltaTime * scaleFactor;
        const offsetY: f32 = @as(f32, @floatFromInt(rl.getRandomValue(-100, 100))) * deltaTime * scaleFactor;

        self.position.x += offsetX;
        self.position.y += offsetY;
    }

    pub fn draw(self: @This()) void {
        rl.drawTextureEx(self.texture, self.position, 0, self.scale, rl.Color.white);
    }

    pub fn goToFlower() void {
        //TODO: A bee must travel to the nearest flower
        // Maybe bees can have a scale factor in recognizing flowers that are able
        // to produce polen, but this may be a upgrade
        // upgraded bees will skip flowers that don't have any polem avaliable
    }
};
