const rl = @import("raylib");
const std = @import("std");
const utils = @import("utils.zig");

pub const Flowers = enum { rose, tulip, dandelion };

pub const Flower = struct {
    state: f32,
    gridPosition: rl.Vector2, // Store grid position (i, j) instead of world position

    texture: rl.Texture,
    width: f32,
    height: f32,

    randomGrowScale: f32,
    growTreshHold: f32,

    polenCoolDown: f32,
    hasPolen: bool,

    scale: f32,

    debug: bool,

    timeAlive: f32,

    pub fn init(texture: rl.Texture, i: f32, j: f32) @This() {
        return .{
            .state = 0,
            .texture = texture,
            .width = 32,
            .height = 32,
            .scale = 2,

            .gridPosition = rl.Vector2.init(i, j),
            .timeAlive = 0,

            .randomGrowScale = @floatFromInt(rl.getRandomValue(1, 10)),
            .growTreshHold = 50,

            .hasPolen = false,
            .polenCoolDown = @floatFromInt(rl.getRandomValue(10, 50)),

            .debug = false,
        };
    }

    pub fn getWorldPosition(self: @This(), offset: rl.Vector2, gridScale: f32) rl.Vector2 {
        const tilePosition = utils.isoToXY(self.gridPosition.x, self.gridPosition.y, self.width, self.height, offset.x, offset.y, gridScale);
        const effectiveScale = self.scale * (gridScale / 3.0);

        // Calculate the center of the tile's top surface (same logic as drawSpriteAtGridPosition)
        const tileWidth = 32 * gridScale;
        const tileHeight = 32 * gridScale;
        
        // Center horizontally on the tile
        const centeredX = tilePosition.x + (tileWidth - self.width * effectiveScale) / 2.0;
        
        // Position on the top surface of the isometric cube (top 1/4 of the tile)
        const centeredY = tilePosition.y + (tileHeight * 0.25) - (self.height * effectiveScale);

        return rl.Vector2.init(centeredX, centeredY);
    }

    pub fn update(self: *@This(), deltaTime: f32) void {
        // TODO: flowers are only able to procude polem when mature (state = 5)
        // add a field to indicate that the flower can have polen
        // add a cooldown each time that a bee haverst the flower polen

        // Every flower will have a grow rate to prevent every flower to grow at the same
        // speed, this will make the game fell more organic

        //In the begginging all flowers will be hide and will not grow until
        // they are showing in the game
        // this will simulate flowers to born (?)

        // If flower is not fully grown cant produce honey
        // Once the flower is fully grown its periodicly will produce honey
        // TODO: "Kill" flower at some point, maybe increase the honey
        // production or decrease the polen cooldown?
        if (self.state == 4) {
            if (!self.hasPolen) {
                self.timeAlive += self.randomGrowScale * deltaTime;
                if (self.timeAlive > self.polenCoolDown) {
                    self.hasPolen = true;
                    self.timeAlive = 0;
                }
            }
            return;
        }

        if (self.state < 4) {
            self.timeAlive += self.randomGrowScale * deltaTime;
            if (self.timeAlive > self.growTreshHold) {
                self.timeAlive = 0;
                self.state += 1;
            }
        }
    }

    pub fn collectPolen(self: *@This()) void {
        self.hasPolen = false;
    }
};
