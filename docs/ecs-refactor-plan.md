# ECS Refactor Plan

## Overview

Migrating from traditional object-oriented architecture to Entity Component System (ECS) to support future features like boost totems, new behaviors, and better code scalability.

## Current Architecture (Object-Oriented)

- `Bee` and `Flower` are structs with data + methods
- `Game` holds `ArrayList(Bee)` and `ArrayList(Flower)`
- Each entity updates itself (`bee.update()`, `flower.update()`)
- Manual iteration and index tracking for dead entities
- Tight coupling between entities and their behavior

## Target ECS Architecture

### Entities
Just unique IDs (`u32` or `u64`) that represent game objects.

### Components (Pure Data)

#### Core Components
```zig
Position { 
    x: f32, 
    y: f32 
}

GridPosition { 
    x: f32, 
    y: f32 
}

Sprite { 
    texture: rl.Texture, 
    width: f32, 
    height: f32, 
    scale: f32 
}

Velocity { 
    x: f32, 
    y: f32 
}
```

#### Behavior Components
```zig
BeeAI { 
    targetEntity: ?Entity,
    targetLocked: bool,
    carryingPollen: bool,
}

FlowerGrowth {
    state: f32,
    timeAlive: f32,
    growthRate: f32,
    growthThreshold: f32,
    hasPollen: bool,
    pollenCooldown: f32,
}

Lifespan {
    timeAlive: f32,
    totalTimeAlive: f32,
    timeSpan: f32,
}

PollenCollector { 
    pollenCollected: f32 
}

ScaleSync { 
    effectiveScale: f32 
}
```

### Systems (Pure Logic)

Systems operate on entities with specific component combinations:

1. **LifespanSystem** - Tracks entity age, marks entities as dead
2. **FlowerGrowthSystem** - Updates flower growth states, handles pollen regeneration
3. **BeeAISystem** - Finds target flowers, moves bees toward targets
4. **PollenCollectionSystem** - Handles bee-flower interactions and pollen collection
5. **FlowerSpawningSystem** - Spawns new flowers from bees carrying pollen
6. **ScaleSyncSystem** - Updates entity scales based on grid zoom level
7. **DeadEntityCleanupSystem** - Removes dead entities from the world
8. **RenderSystem** - Draws all entities with Position + Sprite components

### World Structure

```zig
World {
    // Entity management
    nextEntityId: u32,
    entities: std.ArrayList(Entity),
    
    // Component storage (Struct of Arrays for cache efficiency)
    positions: std.MultiArrayList(Position),
    gridPositions: std.MultiArrayList(GridPosition),
    sprites: std.MultiArrayList(Sprite),
    beeAIs: std.MultiArrayList(BeeAI),
    flowerGrowths: std.MultiArrayList(FlowerGrowth),
    lifespans: std.MultiArrayList(Lifespan),
    pollenCollectors: std.MultiArrayList(PollenCollector),
    scaleSync: std.MultiArrayList(ScaleSync),
    
    // Sparse mapping: entityId -> component array index
    entityToPosition: std.AutoHashMap(Entity, usize),
    entityToSprite: std.AutoHashMap(Entity, usize),
    entityToBeeAI: std.AutoHashMap(Entity, usize),
    // ... etc for all component types
}
```

## Implementation Phases

### Phase 1: Core ECS Infrastructure
**Goal**: Build the foundation without breaking existing code

- [ ] Create `src/ecs/` directory structure
- [ ] Implement `entity.zig` - Entity ID type and management
- [ ] Implement `components.zig` - All component struct definitions
- [ ] Implement `world.zig` - Component storage, add/remove/get methods
- [ ] Implement basic query system for component iteration

**Files to create**:
- `src/ecs/entity.zig`
- `src/ecs/components.zig`
- `src/ecs/world.zig`

### Phase 2: Component Migration
**Goal**: Define all components matching current entity data

- [ ] Extract Position data from Bee/Flower
- [ ] Extract Sprite/rendering data
- [ ] Extract GridPosition for grid-based entities
- [ ] Extract BeeAI behavior data
- [ ] Extract FlowerGrowth behavior data
- [ ] Extract Lifespan/death tracking data
- [ ] Extract PollenCollector stats

**Files to modify**:
- `src/ecs/components.zig` (add all component definitions)

### Phase 3: System Implementation
**Goal**: Implement systems that replace current update/draw logic

- [ ] Create `src/ecs/systems/` directory
- [ ] Implement `lifespan_system.zig`
- [ ] Implement `flower_growth_system.zig`
- [ ] Implement `bee_ai_system.zig`
- [ ] Implement `pollen_collection_system.zig`
- [ ] Implement `flower_spawning_system.zig`
- [ ] Implement `scale_sync_system.zig`
- [ ] Implement `cleanup_system.zig`
- [ ] Implement `render_system.zig`

**Files to create**:
- `src/ecs/systems/lifespan_system.zig`
- `src/ecs/systems/flower_growth_system.zig`
- `src/ecs/systems/bee_ai_system.zig`
- `src/ecs/systems/pollen_collection_system.zig`
- `src/ecs/systems/flower_spawning_system.zig`
- `src/ecs/systems/scale_sync_system.zig`
- `src/ecs/systems/cleanup_system.zig`
- `src/ecs/systems/render_system.zig`

### Phase 4: Game Integration
**Goal**: Replace old code with ECS, maintain feature parity

- [ ] Add World to `Game` struct
- [ ] Migrate entity spawning (bees, flowers) to use World
- [ ] Replace `update()` method with system execution
- [ ] Replace `draw()` method with render system
- [ ] Remove old `ArrayList(Bee)` and `ArrayList(Flower)`
- [ ] Remove or archive old `bee.zig` and `flower.zig`

**Files to modify**:
- `src/game.zig` (major refactor)

**Files to potentially archive**:
- `src/bee.zig` (keep for reference during migration)
- `src/flower.zig` (keep for reference during migration)

### Phase 5: Testing & Verification
**Goal**: Ensure everything works as before

- [ ] Verify bees spawn and move correctly
- [ ] Verify flowers grow and produce pollen
- [ ] Verify pollen collection works
- [ ] Verify flower spawning from bees works
- [ ] Verify entities die after timespan
- [ ] Verify dead entity cleanup works
- [ ] Verify rendering matches old behavior
- [ ] Verify camera/zoom interactions work
- [ ] Verify resource counting (honey) works
- [ ] Performance testing

## Benefits of ECS

✅ **Better cache coherence** - Components stored in contiguous arrays  
✅ **Easier extensibility** - Add boost totems by adding components  
✅ **Cleaner separation** - Data completely separate from logic  
✅ **Parallelization potential** - Systems can run independently  
✅ **Simplified entity management** - One cleanup system handles all dead entities  
✅ **Better for serialization** - Save/load is just dumping component arrays  
✅ **More testable** - Systems are pure functions operating on data

## Future Features Enabled by ECS

### Boost Totems
```zig
BoostEffect { 
    radius: f32, 
    multiplier: f32, 
    affectType: BoostType 
}
```
System queries all entities near totems and applies multipliers.

### New Entity Types
- **Predators**: Add `Predator` + `Velocity` components
- **Buildings**: Add `Structure` + `GridPosition` components
- **Workers**: Add `WorkerAI` + `Inventory` components

### Advanced Behaviors
- **Flocking**: Query nearby bees, apply separation/alignment/cohesion
- **Territories**: Mark grid cells with ownership
- **Status Effects**: Add `StatusEffect` component for buffs/debuffs

## Migration Strategy

1. **Incremental**: Build ECS alongside existing code
2. **Parallel Testing**: Run both systems simultaneously to verify parity
3. **Gradual Cutover**: Switch one entity type at a time
4. **Rollback Safety**: Keep old code until ECS is fully verified

## System Execution Order

### Update Phase
```
LifespanSystem
   ↓
FlowerGrowthSystem
   ↓
BeeAISystem
   ↓
PollenCollectionSystem
   ↓
FlowerSpawningSystem
   ↓
ScaleSyncSystem
   ↓
DeadEntityCleanupSystem
```

### Render Phase
```
RenderSystem (iterates all entities with Position + Sprite)
```

## Notes & Considerations

- Keep textures/resources separate from ECS (shared assets)
- Use sparse mapping for O(1) component lookup by entity ID
- Consider component pools for frequently added/removed components
- May need custom query syntax for complex component combinations
- Grid reference should be passed to systems, not stored per entity
- Camera offset should be global state, not per entity

## Timeline Estimate

- Phase 1: 1-2 days
- Phase 2: 1 day
- Phase 3: 2-3 days
- Phase 4: 1-2 days
- Phase 5: 1 day
- **Total**: ~1-2 weeks for full migration

## References

- Current `bee.zig` implementation (for behavior extraction)
- Current `flower.zig` implementation (for behavior extraction)
- Current `game.zig` update/draw loops (for system design)
