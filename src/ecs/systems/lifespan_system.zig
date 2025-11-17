const World = @import("../world.zig").World;

pub fn update(world: *World, deltaTime: f32) !void {
    var iter = try world.queryEntitiesWithLifespan();
    while (iter.next()) |entity| {
        if (world.getLifespan(entity)) |lifespan| {
            lifespan.timeAlive += deltaTime;
            lifespan.totalTimeAlive += deltaTime;

            if (lifespan.isDead()) {
                // Check if this is a bee carrying pollen - if so, extend life instead of dying
                if (world.getBeeAI(entity)) |beeAI| {
                    if (beeAI.carryingPollen) {
                        // Extend lifespan by 50%
                        const extension = lifespan.timeSpan * 0.5;
                        lifespan.timeSpan += extension;
                        lifespan.timeAlive = 0; // Reset time alive
                        beeAI.carryingPollen = false; // Consume the pollen
                        
                        // Also reset the pollen collected
                        if (world.getPollenCollector(entity)) |collector| {
                            collector.pollenCollected = 0;
                        }
                        continue; // Don't destroy this entity
                    }
                }
                
                try world.destroyEntity(entity);
            }
        }
    }
}
