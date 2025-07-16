const rl = @import("raylib");
const std = @import("std");
const utils = @import("utils.zig");

pub const Flowers = enum { rose, tulip, dandelion };

pub const Flower = struct {
    state: f32,
    position: rl.Vector2,

    texture: rl.Texture,
    width: f32,
    height: f32,

    randomGrowScale: f32,
    growTreshHold: f32,

    polenCoolDown: f32,
    hasPolen: bool,

    scale: f32,
    effectiveScale: f32,

    debug: bool,

    timeAlive: f32,

    pub fn init(texture: rl.Texture) @This() {
        return .{
            .state = 0,
            .texture = texture,
            .width = 32,
            .height = 32,
            .scale = 2,
            .effectiveScale = 2,

            .position = rl.Vector2.init(0, 0),
            .timeAlive = 0,

            .randomGrowScale = @floatFromInt(rl.getRandomValue(1, 10)),
            .growTreshHold = 50,

            .hasPolen = false,
            .polenCoolDown = @floatFromInt(rl.getRandomValue(10, 50)),

            .debug = false,
        };
    }

    pub fn setPosition(self: *@This(), i: f32, j: f32, offset: rl.Vector2, gridScale: f32) void {
        const tilePosition = utils.isoToXY(i, j, self.width, self.height, offset.x, offset.y, gridScale);
        self.effectiveScale = self.scale * (gridScale / 3.0);

        const scaledTileWidth = self.width * gridScale;
        const scaledTileHeight = self.height * gridScale;

        const flowerWidth = self.width * self.effectiveScale;
        const flowerHeight = self.height * self.effectiveScale;

        self.position = rl.Vector2.init(tilePosition.x + (scaledTileWidth - flowerWidth) / 2.0, tilePosition.y - (scaledTileHeight - flowerHeight));
    }

    pub fn draw(self: *@This()) void {
        const source = rl.Rectangle.init(self.state * self.width, 0, self.width, self.height);
        const destination = rl.Rectangle.init(self.position.x, self.position.y, self.width * self.effectiveScale, self.height * self.effectiveScale);

        if (self.state == 4 and self.hasPolen) {
            const glowDest = rl.Rectangle.init(self.position.x - 2, self.position.y - 2, (self.width * self.effectiveScale) + 4, (self.height * self.effectiveScale) + 4);
            rl.drawTexturePro(self.texture, source, glowDest, rl.Vector2.init(0, 0), 0, rl.Color.init(255, 255, 100, 128));
            rl.drawTexturePro(self.texture, source, destination, rl.Vector2.init(0, 0), 0, rl.Color.white);
        } else {
            rl.drawTexturePro(self.texture, source, destination, rl.Vector2.init(0, 0), 0, rl.Color.white);
        }
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
