const rl = @import("raylib");
const std = @import("std");

const Flower = @import("flower.zig").Flower;

pub const Bee = struct {
    position: rl.Vector2,

    texture: rl.Texture,
    width: f32,
    height: f32,

    scale: f32,

    target: rl.Vector2,
    timeAlive: f32,
    timeSpan: f32,
    dead: bool,

    debug: bool,

    pub fn init(x: f32, y: f32, texture: rl.Texture) @This() {
        return .{
            .texture = texture,
            .width = 32,
            .height = 32,
            .scale = 1,

            .position = rl.Vector2.init(x, y),

            .target = rl.Vector2.init(x, y),
            .timeAlive = 0,
            .timeSpan = @floatFromInt(rl.getRandomValue(30, 70)),
            .dead = false,

            .debug = false,
        };
    }

    pub fn enableDebug(self: *@This()) void {
        self.debug = true;
    }

    pub fn update(self: *@This(), deltaTime: f32, flowers: []Flower) void {
        if (self.dead) return;
        // TODO: remove pure random walk and impelement a go to flower function

        // Bees sould search a flower to collect nectar and generate honey
        // With honey the player can create new bees and upgrade them
        // to increase speed, plen collected coodowns and such
        // A bee should have a life span either frames, polen collected or timmer?

        // The game will end if the player don't have any bee alive

        self.timeAlive += deltaTime;

        if (self.timeAlive > self.timeSpan) {
            self.dead = true;
        }

        const target = self.findNearestFlower(flowers);

        self.target = target;

        const scaleFactor: f32 = 10.0;

        const offsetX: f32 = @as(f32, @floatFromInt(rl.getRandomValue(-100, 100))) * deltaTime * scaleFactor;
        const offsetY: f32 = @as(f32, @floatFromInt(rl.getRandomValue(-100, 100))) * deltaTime * scaleFactor;

        self.position.x += offsetX;
        self.position.y += offsetY;
    }

    pub fn draw(self: @This()) void {
        rl.drawTextureEx(self.texture, self.position, 0, self.scale, rl.Color.white);
    }

    pub fn findNearestFlower(self: @This(), flowers: []Flower) rl.Vector2 {
        _ = self;
        _ = flowers;
        //TODO: A bee must travel to the nearest flower
        // Maybe bees can have a scale factor in recognizing flowers that are able
        // to produce polen, but this may be a upgrade
        // upgraded bees will skip flowers that don't have any polem avaliable

        return rl.Vector2.init(0, 0);
    }
};
