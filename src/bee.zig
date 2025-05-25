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

    carryingPollen: bool,
    pollenCollected: f32,

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

            .carryingPollen = false,
            .pollenCollected = 0,

            .debug = true,
        };
    }

    pub fn enableDebug(self: *@This()) void {
        self.debug = true;
    }

    pub fn update(self: *@This(), deltaTime: f32, flowers: []Flower) void {
        if (self.dead) return;

        self.timeAlive += deltaTime;

        if (self.timeAlive > self.timeSpan) {
            self.dead = true;
        }

        // If we don't have any flower locked try to find nearest flower
        if (!self.targetLock) {
            self.target = self.findNearestFlower(flowers);
            self.targetLock = true;
        } else {
            // Check if we've reached the target flower
            const distance = rl.math.vector2Distance(self.position, self.target);
            const arrivalThreshold: f32 = 5.0; // How close is close enough

            if (distance < arrivalThreshold) {
                // We've reached the flower, check if it has pollen
                for (flowers) |*flower| {
                    const flowerDistance = rl.math.vector2Distance(flower.position, self.target);
                    if (flowerDistance < 1.0) { // If this is the target flower
                        if (flower.state == 4 and flower.hasPolen) {
                            // Collect pollen
                            flower.collectPolen();
                            self.carryingPollen = true;
                            self.pollenCollected += 1;
                        }

                        // After collecting (or failing to collect) pollen, look for a new target
                        self.targetLock = false;
                        break;
                    }
                }
            } else {
                // Move to nearest flower bit by bit
                const leapFactor: f32 = 0.9;
                self.position.x += (self.target.x - self.position.x) * leapFactor * deltaTime;
                self.position.y += (self.target.y - self.position.y) * leapFactor * deltaTime;
            }
        }
    }

    pub fn draw(self: @This()) void {
        if (self.dead) return;

        // Draw bee with yellow tint if carrying pollen
        if (self.carryingPollen) {
            rl.drawTextureEx(self.texture, self.position, 0, self.scale, rl.Color.yellow);
        } else {
            rl.drawTextureEx(self.texture, self.position, 0, self.scale, rl.Color.white);
        }
    }

    pub fn findNearestFlower(self: @This(), flowers: []Flower) rl.Vector2 {
        // First try to find mature flowers with pollen
        var minimumDistanceSoFar = std.math.floatMax(f32);
        var nearestFlower = rl.Vector2.init(0, 0);
        var foundFlowerWithPollen = false;

        // Collect viable flowers within a reasonable distance
        var viableFlowers = std.ArrayList(rl.Vector2).init(std.heap.page_allocator);
        defer viableFlowers.deinit();

        // First pass: look for mature flowers with pollen and find the minimum distance
        for (flowers) |*element| {
            // Only consider mature flowers with pollen
            if (element.state == 4 and element.hasPolen) {
                const distance = rl.math.vector2DistanceSqr(element.position, self.position);

                if (distance < minimumDistanceSoFar) {
                    minimumDistanceSoFar = distance;
                    nearestFlower = element.position;
                    foundFlowerWithPollen = true;
                }
            }
        }

        // Second pass: collect all flowers with pollen that are within 25% of the minimum distance
        // This creates a "close enough" group of flowers to randomize between
        if (foundFlowerWithPollen) {
            const distanceThreshold = minimumDistanceSoFar * 1.25; // 25% margin

            for (flowers) |*element| {
                if (element.state == 4 and element.hasPolen) {
                    const distance = rl.math.vector2DistanceSqr(element.position, self.position);
                    if (distance <= distanceThreshold) {
                        viableFlowers.append(element.position) catch {};
                    }
                }
            }

            // If we have multiple viable flowers, pick one randomly
            if (viableFlowers.items.len > 1) {
                const randomIndex = rl.getRandomValue(0, @intCast(viableFlowers.items.len - 1));
                return viableFlowers.items[@intCast(randomIndex)];
            } else if (foundFlowerWithPollen) {
                return nearestFlower;
            }
        }

        // If no flower with pollen found, find any flower (even without pollen)
        minimumDistanceSoFar = std.math.floatMax(f32);

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
