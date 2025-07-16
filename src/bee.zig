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

    targetFlowerPosition: ?*rl.Vector2, // Reference to the flower's position
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
            .effectiveScale = 1,

            .position = rl.Vector2.init(x, y),

            .targetFlowerPosition = null,
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

    pub fn updateScale(self: *@This(), gridScale: f32) void {
        // Update the effective scale based on grid scale
        self.effectiveScale = self.scale * (gridScale / 3.0); // 3.0 is the base grid scale
    }

    pub fn update(self: *@This(), deltaTime: f32, flowers: []Flower) void {
        if (self.dead) return;

        self.timeAlive += deltaTime;

        if (self.timeAlive > self.timeSpan) {
            self.dead = true;
        }

        // If we don't have any flower locked try to find nearest flower
        if (!self.targetLock) {
            self.targetFlowerPosition = self.findNearestFlower(flowers);
            self.targetLock = true;
        } else {
            // Check if we have a valid target flower position
            if (self.targetFlowerPosition) |targetPos| {
                // Check if we've reached the target flower
                const distance = rl.math.vector2Distance(self.position, targetPos.*);
                const arrivalThreshold: f32 = 5.0; // How close is close enough

                if (distance < arrivalThreshold) {
                    // We've reached the flower, check if it has pollen
                    for (flowers) |*flower| {
                        const flowerDistance = rl.math.vector2Distance(flower.position, targetPos.*);
                        if (flowerDistance < 1.0) { // If this is the target flower
                            if (flower.state == 4 and flower.hasPolen) {
                                // Collect pollen
                                flower.collectPolen();
                                self.carryingPollen = true;
                                self.pollenCollected += 1;
                            }

                            // After collecting (or failing to collect) pollen, look for a new target
                            self.targetLock = false;
                            self.targetFlowerPosition = null;
                            break;
                        }
                    }
                } else {
                    // Move to nearest flower bit by bit
                    const leapFactor: f32 = 0.9;
                    self.position.x += (targetPos.*.x - self.position.x) * leapFactor * deltaTime;
                    self.position.y += (targetPos.*.y - self.position.y) * leapFactor * deltaTime;
                }
            } else {
                // No valid target, unlock to find a new one
                self.targetLock = false;
            }
        }
    }

    pub fn draw(self: @This()) void {
        if (self.dead) return;

        // Draw bee with yellow tint if carrying pollen, using effective scale
        if (self.carryingPollen) {
            rl.drawTextureEx(self.texture, self.position, 0, self.effectiveScale, rl.Color.yellow);
        } else {
            rl.drawTextureEx(self.texture, self.position, 0, self.effectiveScale, rl.Color.white);
        }
    }

    pub fn findNearestFlower(self: @This(), flowers: []Flower) ?*rl.Vector2 {
        // First try to find mature flowers with pollen
        var minimumDistanceSoFar = std.math.floatMax(f32);
        var nearestFlowerPtr: ?*rl.Vector2 = null;
        var foundFlowerWithPollen = false;

        // Collect viable flowers within a reasonable distance
        var viableFlowers = std.ArrayList(*rl.Vector2).init(std.heap.page_allocator);
        defer viableFlowers.deinit();

        // First pass: look for mature flowers with pollen and find the minimum distance
        for (flowers) |*element| {
            // Only consider mature flowers with pollen
            if (element.state == 4 and element.hasPolen) {
                const distance = rl.math.vector2DistanceSqr(element.position, self.position);

                if (distance < minimumDistanceSoFar) {
                    minimumDistanceSoFar = distance;
                    nearestFlowerPtr = &element.position;
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
                        viableFlowers.append(&element.position) catch {};
                    }
                }
            }

            // If we have multiple viable flowers, pick one randomly
            if (viableFlowers.items.len > 1) {
                const randomIndex = rl.getRandomValue(0, @intCast(viableFlowers.items.len - 1));
                return viableFlowers.items[@intCast(randomIndex)];
            } else if (foundFlowerWithPollen) {
                return nearestFlowerPtr;
            }
        }

        // If no flower with pollen found, find any flower (even without pollen)
        minimumDistanceSoFar = std.math.floatMax(f32);

        for (flowers) |*element| {
            const distance = rl.math.vector2DistanceSqr(element.position, self.position);

            if (distance < minimumDistanceSoFar) {
                minimumDistanceSoFar = distance;
                nearestFlowerPtr = &element.position;
            }
        }

        return nearestFlowerPtr;
    }
};
