const std = @import("std");
const rl = @import("raylib");
const World = @import("../world.zig").World;
const Entity = @import("../entity.zig").Entity;
const components = @import("../components.zig");
const Textures = @import("../../textures.zig").Textures;
const Flowers = @import("../../textures.zig").Flowers;

pub fn update(world: *World, deltaTime: f32, gridOffset: rl.Vector2, gridScale: f32, gridWidth: usize, gridHeight: usize, textures: Textures) !void {
    var iter = try world.queryEntitiesWithBeeAI();
    while (iter.next()) |entity| {
        if (world.getBeeAI(entity)) |beeAI| {
            if (world.getPosition(entity)) |position| {
                if (world.getLifespan(entity)) |lifespan| {
                    if (lifespan.isDead()) {
                        continue;
                    }
                }

                // Pollination mechanic: bee carrying pollen over empty grid cell can spawn flower
                if (beeAI.carryingPollen) {
                    try handlePollination(world, entity, beeAI, position, gridOffset, gridScale, gridWidth, gridHeight, textures);
                }

                // Handle scatter timer - force bees to wander after collecting pollen
                if (beeAI.scatterTimer > 0) {
                    beeAI.scatterTimer -= deltaTime;
                    performRandomWalk(beeAI, position, deltaTime);
                    continue; // Skip targeting while scattering
                }

                // Handle pollen deposit timer
                if (beeAI.carryingPollen) {
                    beeAI.depositTimer += deltaTime;

                    // After 3 seconds, deposit the pollen as honey
                    if (beeAI.depositTimer >= 3.0) {
                        if (world.getPollenCollector(entity)) |collector| {
                            if (collector.pollenCollected > 0) {
                                // This will be picked up by the honey conversion in game.zig
                                beeAI.carryingPollen = false;
                                beeAI.depositTimer = 0;
                            }
                        }
                    }
                }

                if (!beeAI.targetLocked) {
                    beeAI.targetEntity = try findNearestFlower(world, entity, position.toVector2(), gridOffset, gridScale);
                    // Only lock if we actually found a target
                    if (beeAI.targetEntity != null) {
                        beeAI.targetLocked = true;
                    }
                } else {
                    if (beeAI.targetEntity) |targetEntity| {
                        if (world.getGridPosition(targetEntity)) |targetGridPos| {
                            if (world.getFlowerGrowth(targetEntity)) |targetFlower| {
                                const targetPos = getFlowerWorldPosition(targetGridPos.toVector2(), gridOffset, gridScale);

                                const distance = rl.math.vector2Distance(position.toVector2(), targetPos);
                                const arrivalThreshold: f32 = 5.0;

                                if (distance < arrivalThreshold) {
                                    if (targetFlower.state == 4 and targetFlower.hasPollen) {
                                        targetFlower.hasPollen = false;
                                        beeAI.carryingPollen = true;

                                        if (world.getPollenCollector(entity)) |collector| {
                                            collector.collect(1.0);
                                        }

                                        // Make bee scatter away from flower for 2-4 seconds
                                        beeAI.scatterTimer = @as(f32, @floatFromInt(rl.getRandomValue(20, 40))) / 10.0;
                                    }

                                    beeAI.targetLocked = false;
                                    beeAI.targetEntity = null;
                                } else {
                                    const leapFactor: f32 = 0.9;
                                    position.x += (targetPos.x - position.x) * leapFactor * deltaTime;
                                    position.y += (targetPos.y - position.y) * leapFactor * deltaTime;
                                }
                            } else {
                                beeAI.targetLocked = false;
                                beeAI.targetEntity = null;
                            }
                        } else {
                            beeAI.targetLocked = false;
                            beeAI.targetEntity = null;
                        }
                    } else {
                        performRandomWalk(beeAI, position, deltaTime);
                    }
                }
            }
        }
    }
}

fn findNearestFlower(world: *World, currentBee: Entity, beePosition: rl.Vector2, gridOffset: rl.Vector2, gridScale: f32) !?Entity {
    var minimumDistanceSoFar = std.math.floatMax(f32);
    var nearestFlowerEntity: ?Entity = null;
    var foundFlowerWithPollen = false;

    var viableFlowers: std.ArrayList(Entity) = .empty;
    defer viableFlowers.deinit(world.allocator);

    var iter = try world.queryEntitiesWithFlowerGrowth();
    while (iter.next()) |entity| {
        if (world.getFlowerGrowth(entity)) |growth| {
            if (world.getGridPosition(entity)) |gridPos| {
                if (world.getLifespan(entity)) |lifespan| {
                    if (lifespan.isDead()) {
                        continue;
                    }
                }

                if (growth.state == 4 and growth.hasPollen) {
                    // Check bee density around this flower
                    const beesNearFlower = try countBeesNearFlower(world, currentBee, entity, gridOffset, gridScale);
                    if (beesNearFlower >= 2) {
                        continue; // Skip overcrowded flowers
                    }

                    const flowerWorldPos = getFlowerWorldPosition(gridPos.toVector2(), gridOffset, gridScale);
                    const distance = rl.math.vector2DistanceSqr(flowerWorldPos, beePosition);

                    if (distance < minimumDistanceSoFar) {
                        minimumDistanceSoFar = distance;
                        nearestFlowerEntity = entity;
                        foundFlowerWithPollen = true;
                    }
                }
            }
        }
    }

    if (foundFlowerWithPollen) {
        const distanceThreshold = minimumDistanceSoFar * 1.25;

        var iter2 = try world.queryEntitiesWithFlowerGrowth();
        while (iter2.next()) |entity| {
            if (world.getFlowerGrowth(entity)) |growth| {
                if (world.getGridPosition(entity)) |gridPos| {
                    if (world.getLifespan(entity)) |lifespan| {
                        if (lifespan.isDead()) {
                            continue;
                        }
                    }

                    if (growth.state == 4 and growth.hasPollen) {
                        // Check bee density for viable flowers too
                        const beesNearFlower = try countBeesNearFlower(world, currentBee, entity, gridOffset, gridScale);
                        if (beesNearFlower >= 2) {
                            continue;
                        }

                        const flowerWorldPos = getFlowerWorldPosition(gridPos.toVector2(), gridOffset, gridScale);
                        const distance = rl.math.vector2DistanceSqr(flowerWorldPos, beePosition);
                        if (distance <= distanceThreshold) {
                            try viableFlowers.append(world.allocator, entity);
                        }
                    }
                }
            }
        }

        if (viableFlowers.items.len > 1) {
            const randomIndex = rl.getRandomValue(0, @intCast(viableFlowers.items.len - 1));
            return viableFlowers.items[@intCast(randomIndex)];
        } else if (foundFlowerWithPollen) {
            return nearestFlowerEntity;
        }
    }

    minimumDistanceSoFar = std.math.floatMax(f32);
    var iter3 = try world.queryEntitiesWithFlowerGrowth();
    while (iter3.next()) |entity| {
        if (world.getGridPosition(entity)) |gridPos| {
            if (world.getLifespan(entity)) |lifespan| {
                if (lifespan.isDead()) {
                    continue;
                }
            }

            const flowerWorldPos = getFlowerWorldPosition(gridPos.toVector2(), gridOffset, gridScale);
            const distance = rl.math.vector2DistanceSqr(flowerWorldPos, beePosition);

            if (distance < minimumDistanceSoFar) {
                minimumDistanceSoFar = distance;
                nearestFlowerEntity = entity;
            }
        }
    }

    return nearestFlowerEntity;
}

fn getFlowerWorldPosition(gridPos: rl.Vector2, offset: rl.Vector2, gridScale: f32) rl.Vector2 {
    const utils = @import("../../utils.zig");
    const tileWidth: f32 = 32;
    const tileHeight: f32 = 32;
    const flowerWidth: f32 = 32;
    const flowerHeight: f32 = 32;
    const flowerScale: f32 = 2;

    const tilePosition = utils.isoToXY(gridPos.x, gridPos.y, tileWidth, tileHeight, offset.x, offset.y, gridScale);
    const effectiveScale = flowerScale * (gridScale / 3.0);

    const tileTotalWidth = 32 * gridScale;
    const tileTotalHeight = 32 * gridScale;

    const centeredX = tilePosition.x + (tileTotalWidth - flowerWidth * effectiveScale) / 2.0;
    const centeredY = tilePosition.y + (tileTotalHeight * 0.25) - (flowerHeight * effectiveScale);

    return rl.Vector2.init(centeredX, centeredY);
}

fn performRandomWalk(beeAI: anytype, position: anytype, deltaTime: f32) void {
    const wanderSpeed: f32 = 50.0;
    const wanderChangeInterval: f32 = 1.0;

    beeAI.wanderChangeTimer += deltaTime;

    if (beeAI.wanderChangeTimer >= wanderChangeInterval) {
        const angleChange = @as(f32, @floatFromInt(rl.getRandomValue(-30, 30))) * std.math.pi / 180.0;
        beeAI.wanderAngle += angleChange;
        beeAI.wanderChangeTimer = 0;
    }

    const moveX = @cos(beeAI.wanderAngle) * wanderSpeed * deltaTime;
    const moveY = @sin(beeAI.wanderAngle) * wanderSpeed * deltaTime;

    position.x += moveX;
    position.y += moveY;
}

fn handlePollination(world: *World, _: Entity, beeAI: anytype, position: anytype, gridOffset: rl.Vector2, gridScale: f32, gridWidth: usize, gridHeight: usize, textures: Textures) !void {
    const utils = @import("../../utils.zig");

    // Convert bee's world position to grid coordinates
    const gridPos = utils.worldToGrid(position.toVector2(), gridOffset, gridScale);
    const gridX: i32 = @intFromFloat(@floor(gridPos.x));
    const gridY: i32 = @intFromFloat(@floor(gridPos.y));

    // Check if we've moved to a new grid cell
    if (gridX == beeAI.lastGridX and gridY == beeAI.lastGridY) {
        return; // Still in same cell, don't check again
    }

    // Update last grid position
    beeAI.lastGridX = gridX;
    beeAI.lastGridY = gridY;

    // Check if position is within grid bounds
    if (gridX < 0 or gridY < 0 or gridX >= @as(i32, @intCast(gridWidth)) or gridY >= @as(i32, @intCast(gridHeight))) {
        return;
    }

    // Check if there's already a flower at this position
    const gridXf: f32 = @floatFromInt(gridX);
    const gridYf: f32 = @floatFromInt(gridY);

    var hasFlower = false;
    var flowerIter = try world.queryEntitiesWithFlowerGrowth();
    while (flowerIter.next()) |flowerEntity| {
        if (world.getGridPosition(flowerEntity)) |flowerGridPos| {
            if (@abs(flowerGridPos.x - gridXf) < 0.1 and @abs(flowerGridPos.y - gridYf) < 0.1) {
                hasFlower = true;
                break;
            }
        }
    }

    // If no flower exists, 10% chance to spawn one
    if (!hasFlower) {
        const spawnChance = rl.getRandomValue(1, 100);
        if (spawnChance <= 10) {
            // Spawn a random flower type
            const flowerTypeRoll = rl.getRandomValue(1, 3);
            const flowerType = switch (flowerTypeRoll) {
                1 => Flowers.rose,
                2 => Flowers.dandelion,
                3 => Flowers.tulip,
                else => Flowers.rose,
            };

            const flowerTexture = textures.getFlowerTexture(flowerType);

            const flowerEntity = try world.createEntity();
            try world.addGridPosition(flowerEntity, components.GridPosition.init(gridXf, gridYf));
            try world.addSprite(flowerEntity, components.Sprite.init(flowerTexture, 32, 32, 2));
            try world.addFlowerGrowth(flowerEntity, components.FlowerGrowth.init());
            try world.addLifespan(flowerEntity, components.Lifespan.init(@floatFromInt(rl.getRandomValue(60, 120))));
        }
    }
}

fn countBeesNearFlower(world: *World, currentBee: Entity, flowerEntity: Entity, gridOffset: rl.Vector2, gridScale: f32) !u32 {
    const flowerGridPos = world.getGridPosition(flowerEntity) orelse return 0;
    const flowerWorldPos = getFlowerWorldPosition(flowerGridPos.toVector2(), gridOffset, gridScale);
    const checkRadius: f32 = 100.0; // pixels

    var count: u32 = 0;
    var beeIter = try world.queryEntitiesWithBeeAI();
    while (beeIter.next()) |beeEntity| {
        if (beeEntity == currentBee) continue; // Don't count self

        if (world.getBeeAI(beeEntity)) |otherBeeAI| {
            // Count bees that are targeting this flower or are nearby
            if (otherBeeAI.targetEntity) |targetEntity| {
                if (targetEntity == flowerEntity) {
                    count += 1;
                    continue;
                }
            }

            // Also count bees physically near the flower
            if (world.getPosition(beeEntity)) |otherPos| {
                const distance = rl.math.vector2Distance(otherPos.toVector2(), flowerWorldPos);
                if (distance < checkRadius) {
                    count += 1;
                }
            }
        }
    }

    return count;
}
