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

    debug: bool,

    timeAlive: f32,

    pub fn init(texture: rl.Texture) @This() {
        return .{
            .state = 0,
            .texture = texture,
            .width = 32,
            .height = 32,
            .scale = 2,

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
        // The folwer offset takes in consideration the sprite width and height to put them in the center of the square
        // The offset passed to this is the offset for the grid x,y corner position (the tiles)
        self.position = utils.isoToXY(i, j, self.width, self.height, offset.x + self.width, offset.y - self.height / 2, gridScale);
    }

    pub fn draw(self: *@This()) void {
        const source = rl.Rectangle.init(self.state * self.width, 0, self.width, self.height);
        const destination = rl.Rectangle.init(self.position.x, self.position.y, self.width * self.scale, self.height * self.scale);
        const origin = rl.Vector2.init(source.width / 2, source.height / 2);

        // Draw with a slight yellow glow if mature and has pollen
        if (self.state == 4 and self.hasPolen) {
            // Draw a slightly larger yellow version underneath for a "glow" effect
            const glowDest = rl.Rectangle.init(self.position.x - 2, self.position.y - 2, (self.width * self.scale) + 4, (self.height * self.scale) + 4);
            rl.drawTexturePro(self.texture, source, glowDest, origin, 0, rl.Color.init(255, 255, 100, 128));
            rl.drawTexturePro(self.texture, source, destination, origin, 0, rl.Color.white);
        } else {
            rl.drawTexturePro(self.texture, source, destination, origin, 0, rl.Color.white);
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
