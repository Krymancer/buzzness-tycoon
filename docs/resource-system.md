# Resource System

## Overview

The Resource system (`resources.zig`) manages the game's economy through honey production, storage, and spending. It provides a simple but effective foundation for the game's economic mechanics and future expansion into more complex resource management.

## Resource Structure

### Core Properties

```zig
pub const Resources = struct {
    honey: f32,    // Primary resource - accumulated from bee pollen collection
    bees: f32,     // Currently unused - placeholder for future bee counting
}
```

### Resource Types

**Honey (Primary Resource):**
- Produced by bees collecting pollen
- Used to purchase new bees
- Acts as the game's primary currency
- Displayed prominently in UI

**Bees (Placeholder):**
- Currently unused in gameplay
- Reserved for future bee-related mechanics
- Could track bee population statistics

## Economic System

### Honey Production

**Production Chain:**
1. Bees collect pollen from mature flowers
2. Each pollen unit converts to 1 honey unit
3. Honey accumulates in the resource pool
4. No upper limit on honey storage

**Production Tracking:**
- Main game loop monitors bee pollen collection
- Honey increases when bees successfully collect pollen
- Immediate conversion from pollen to honey

### Honey Consumption

**Current Uses:**
- Purchase new bees (10 honey per bee)
- Only spending mechanism in current game

**Spending Validation:**
- `canAfford()` checks resource availability
- `spendHoney()` validates and deducts resources
- Transaction-safe resource management

### Resource Initialization

**Starting Resources:**
- Players begin with 2,500 honey
- Provides buffer for initial bee purchases
- Allows for strategic early game decisions

## API Design

### Resource Management Functions

```zig
pub fn init() Resources
pub fn deinit(self: Resources) void
pub fn addHoney(self: *Resources, amount: f32) void
pub fn spendHoney(self: *Resources, amount: f32) bool
pub fn canAfford(self: Resources, amount: f32) bool
```

### Transaction Safety

**Atomic Operations:**
- `spendHoney()` checks availability before spending
- Returns boolean success/failure status
- Prevents negative resource values

**Validation:**
```zig
pub fn spendHoney(self: *Resources, amount: f32) bool {
    if (self.honey >= amount) {
        self.honey -= amount;
        return true;
    }
    return false;
}
```

## Integration with Game Systems

### Bee System Integration

**Honey Production:**
- Game engine tracks bee pollen collection
- Calls `addHoney()` when bees collect pollen
- Seamless integration with bee AI behavior

**Bee Purchasing:**
- UI system calls `spendHoney()` for bee purchases
- Validates resource availability before purchase
- Creates new bees on successful transaction

### UI System Integration

**Resource Display:**
- UI displays current honey amount
- Real-time updates as resources change
- Visual feedback for resource availability

**Purchase Interface:**
- UI checks `canAfford()` for button states
- Disabled appearance when resources insufficient
- Immediate feedback for successful purchases

## Economic Balance

### Current Balance

**Starting Resources:**
- 2,500 honey provides good starting buffer
- Allows for 250 bee purchases initially
- Balances early game progression

**Production Rates:**
- 1 honey per pollen collected
- Sustainable production with active bees
- Scales with bee population size

**Spending Costs:**
- 10 honey per bee purchase
- Reasonable cost for expansion
- Encourages strategic bee management

### Economic Pressure

**Resource Scarcity:**
- Bees die over time (30-70 seconds)
- Must maintain pollen collection to sustain economy
- Creates natural challenge progression

**Growth Dynamics:**
- More bees = more honey production
- More honey = ability to buy more bees
- Positive feedback loop with death pressure

## Future Economic Features

### Planned Resource Types

1. **Pollen** - Direct bee collection resource
2. **Nectar** - Secondary bee product
3. **Wax** - Construction material
4. **Royal Jelly** - Bee upgrade resource
5. **Seeds** - Flower planting resource

### Advanced Economic Mechanics

1. **Market Prices** - Fluctuating resource values
2. **Trade System** - Exchange between resource types
3. **Production Chains** - Multi-step resource processing
4. **Storage Limits** - Maximum resource capacities
5. **Decay/Spoilage** - Time-based resource loss

### Upgrade Economy

1. **Bee Upgrades** - Enhanced collection rates
2. **Flower Upgrades** - Better pollen production
3. **Efficiency Improvements** - Reduced costs
4. **Speed Boosts** - Faster bee movement
5. **Capacity Increases** - Larger resource storage

## Performance Considerations

### Optimization Features

**Minimal State:**
- Only tracks essential resource values
- No complex calculations during updates
- Efficient memory usage

**Simple Operations:**
- Basic arithmetic for resource changes
- No dynamic allocations
- Fast transaction processing

### Scalability

**Future Expansion:**
- Easy to add new resource types
- Extensible transaction system
- Modular design for complex economies

## Configuration Values

```zig
const STARTING_HONEY = 2500.0;    // Initial honey amount
const BEE_COST = 10.0;            // Honey cost per bee
const POLLEN_TO_HONEY_RATIO = 1.0; // Conversion rate
```

## Error Handling

### Transaction Safety

**Validation Checks:**
- Always validate resource availability
- Prevent negative resource values
- Return clear success/failure status

**Error Prevention:**
- Type safety through Zig's type system
- Compile-time error detection
- Runtime bounds checking

## Future Improvements

### Planned Features

1. **Resource Persistence** - Save/load resource state
2. **Resource History** - Track production/consumption over time
3. **Economic Events** - Random economic boosts/penalties
4. **Achievement System** - Milestones for resource accumulation
5. **Advanced Transactions** - Multi-resource exchanges

### Technical Improvements

1. **Resource Notifications** - Event system for resource changes
2. **Batch Transactions** - Multiple resource operations
3. **Transaction Logging** - Debug and analytics support
4. **Resource Validation** - Advanced bounds checking
5. **Performance Metrics** - Resource system performance tracking

## API Reference

### Core Functions

```zig
pub fn init() Resources
pub fn deinit(self: Resources) void
pub fn addHoney(self: *Resources, amount: f32) void
pub fn spendHoney(self: *Resources, amount: f32) bool
pub fn canAfford(self: Resources, amount: f32) bool
```

### Usage Examples

```zig
// Initialize resources
var resources = Resources.init();

// Add honey from bee collection
resources.addHoney(5.0);

// Check affordability
if (resources.canAfford(10.0)) {
    // Attempt purchase
    if (resources.spendHoney(10.0)) {
        // Purchase successful
        // Create new bee
    }
}

// Cleanup
resources.deinit();
```

## Debugging Features

### Debug Information

Potential debug features:
- Resource change logging
- Transaction history
- Production rate tracking
- Economic balance analysis

### Development Tools

Future debug tools could include:
- Resource state inspector
- Economic simulation tools
- Balance testing utilities
- Performance profiling

## Integration Examples

### Game Engine Integration

```zig
// In game update loop
if (bee.pollenCollected > previousPollen) {
    const newHoney = bee.pollenCollected - previousPollen;
    self.resources.addHoney(newHoney);
}
```

### UI Integration

```zig
// In UI draw function
const canAfford = self.resources.canAfford(BEE_COST);
const buttonColor = if (canAfford) rl.Color.yellow else rl.Color.gray;

if (mouseClicked and canAfford) {
    if (self.resources.spendHoney(BEE_COST)) {
        // Purchase successful
    }
}
```

This resource system provides a solid foundation for the game's economy while remaining simple enough for future expansion and modification.
