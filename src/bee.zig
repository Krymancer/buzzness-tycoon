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
    targetLock: bool,
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
            .targetLock = false,
            .timeAlive = 0,
            .timeSpan = @floatFromInt(rl.getRandomValue(30, 70)),
            .dead = false,

            .debug = true,
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
        // to increase speed, polen collected coodowns and such
        // A bee should have a life span either frames, polen collected or timmer?

        // The game will end if the player don't have any bee alive

        self.timeAlive += deltaTime;

        if (self.timeAlive > self.timeSpan) {
            self.dead = true;
        }

        // If we don't have any flower locked try to find nearest flower
        if (!self.targetLock) {
            self.target = self.findNearestFlower(flowers);
            self.targetLock = true;
        } else {
            const leapFactor: f32 = 0.9;
            self.position.x += (self.target.x - self.position.x) * leapFactor * deltaTime;
            self.position.y += (self.target.y - self.position.y) * leapFactor * deltaTime;
        }
    }

    pub fn draw(self: @This()) void {
        if (self.dead) return;
        rl.drawTextureEx(self.texture, self.position, 0, self.scale, rl.Color.white);
    }

    pub fn findNearestFlower(self: @This(), flowers: []Flower) rl.Vector2 {
        //TODO: A bee must travel to the nearest flower
        // Maybe bees can have a scale factor in recognizing flowers that are able
        // to produce polen, but this may be a upgrade
        // upgraded bees will skip flowers that don't have any polem avaliable

        var minimumDistanceSoFar = std.math.floatMax(f32);
        var nearestFlower = rl.Vector2.init(0, 0);

        for (flowers) |*element| {
            const distance = rl.math.vector2DistanceSqr(element.position, self.position);

            if (distance < minimumDistanceSoFar) {
                minimumDistanceSoFar = distance;
                nearestFlower = element.position;
            }
        }

        return nearestFlower;
    }
};
