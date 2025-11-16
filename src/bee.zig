const rl = @import("raylib");
const std = @import("std");

const Flower = @import("flower.zig").Flower;

pub const Bee = struct {
    position: rl.Vector2,

    texture: rl.Texture,
    width: f32,
    height: f32,

    scale: f32,
    effectiveScale: f32,

    targetFlowerIndex: ?usize,
    targetLock: bool,
    timeAlive: f32,
    timeSpan: f32,
    dead: bool,

    carryingPollen: bool,
    pollenCollected: f32,

    allocator: std.mem.Allocator,

    debug: bool,

    pub fn init(x: f32, y: f32, texture: rl.Texture, allocator: std.mem.Allocator) @This() {
        return .{
            .texture = texture,
            .width = 32,
            .height = 32,
            .scale = 1,
            .effectiveScale = 1,

            .position = rl.Vector2.init(x, y),

            .targetFlowerIndex = null,
            .targetLock = false,
            .timeAlive = 0,
            .timeSpan = @floatFromInt(rl.getRandomValue(30, 70)),
            .dead = false,

            .carryingPollen = false,
            .pollenCollected = 0,

            .allocator = allocator,

            .debug = true,
        };
    }

    pub fn enableDebug(self: *@This()) void {
        self.debug = true;
    }

    pub fn updateScale(self: *@This(), gridScale: f32) void {
        self.effectiveScale = self.scale * (gridScale / 3.0);
    }

    pub fn update(self: *@This(), deltaTime: f32, flowers: []Flower, gridOffset: rl.Vector2, gridScale: f32) void {
        if (self.dead) return;

        self.timeAlive += deltaTime;

        if (self.timeAlive > self.timeSpan) {
            self.dead = true;
        }

        if (!self.targetLock) {
            self.targetFlowerIndex = self.findNearestFlower(flowers, gridOffset, gridScale);
            self.targetLock = true;
        } else {
            if (self.targetFlowerIndex) |flowerIndex| {
                if (flowerIndex < flowers.len) {
                    const targetFlower = &flowers[flowerIndex];
                    const targetPos = targetFlower.getWorldPosition(gridOffset, gridScale);

                    const distance = rl.math.vector2Distance(self.position, targetPos);
                    const arrivalThreshold: f32 = 5.0;

                    if (distance < arrivalThreshold) {
                        if (targetFlower.state == 4 and targetFlower.hasPolen) {
                            targetFlower.collectPolen();
                            self.carryingPollen = true;
                            self.pollenCollected += 1;
                        }

                        self.targetLock = false;
                        self.targetFlowerIndex = null;
                    } else {
                        const leapFactor: f32 = 0.9;
                        self.position.x += (targetPos.x - self.position.x) * leapFactor * deltaTime;
                        self.position.y += (targetPos.y - self.position.y) * leapFactor * deltaTime;
                    }
                } else {
                    self.targetLock = false;
                    self.targetFlowerIndex = null;
                }
            } else {
                self.targetLock = false;
            }
        }
    }

    pub fn draw(self: @This()) void {
        if (self.dead) return;

        if (self.carryingPollen) {
            rl.drawTextureEx(self.texture, self.position, 0, self.effectiveScale, rl.Color.yellow);
        } else {
            rl.drawTextureEx(self.texture, self.position, 0, self.effectiveScale, rl.Color.white);
        }
    }
    pub fn findNearestFlower(self: @This(), flowers: []Flower, gridOffset: rl.Vector2, gridScale: f32) ?usize {
        var minimumDistanceSoFar = std.math.floatMax(f32);
        var nearestFlowerIndex: ?usize = null;
        var foundFlowerWithPollen = false;

        var viableFlowers: std.ArrayList(usize) = .empty;
        defer viableFlowers.deinit(self.allocator);

        // First pass: look for mature flowers with pollen and find the minimum distance
        for (flowers, 0..) |*element, index| {
            // Only consider mature flowers with pollen that are not dead
            if (!element.dead and element.state == 4 and element.hasPolen) {
                const flowerWorldPos = element.getWorldPosition(gridOffset, gridScale);
                const distance = rl.math.vector2DistanceSqr(flowerWorldPos, self.position);

                if (distance < minimumDistanceSoFar) {
                    minimumDistanceSoFar = distance;
                    nearestFlowerIndex = index;
                    foundFlowerWithPollen = true;
                }
            }
        }

        // Second pass: collect all flowers with pollen that are within 25% of the minimum distance
        // This creates a "close enough" group of flowers to randomize between
        if (foundFlowerWithPollen) {
            const distanceThreshold = minimumDistanceSoFar * 1.25;

            for (flowers, 0..) |*element, index| {
                if (!element.dead and element.state == 4 and element.hasPolen) {
                    const flowerWorldPos = element.getWorldPosition(gridOffset, gridScale);
                    const distance = rl.math.vector2DistanceSqr(flowerWorldPos, self.position);
                    if (distance <= distanceThreshold) {
                        viableFlowers.append(self.allocator, index) catch {};
                    }
                }
            }

            // If we have multiple viable flowers, pick one randomly
            if (viableFlowers.items.len > 1) {
                const randomIndex = rl.getRandomValue(0, @intCast(viableFlowers.items.len - 1));
                return viableFlowers.items[@intCast(randomIndex)];
            } else if (foundFlowerWithPollen) {
                return nearestFlowerIndex;
            }
        }

        // If no flower with pollen found, find any flower (even without pollen)
        minimumDistanceSoFar = std.math.floatMax(f32);

        for (flowers, 0..) |*element, index| {
            if (!element.dead) {
                const flowerWorldPos = element.getWorldPosition(gridOffset, gridScale);
                const distance = rl.math.vector2DistanceSqr(flowerWorldPos, self.position);

                if (distance < minimumDistanceSoFar) {
                    minimumDistanceSoFar = distance;
                    nearestFlowerIndex = index;
                }
            }
        }

        return nearestFlowerIndex;
    }
};
