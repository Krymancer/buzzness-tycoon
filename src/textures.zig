const rl = @import("raylib");
const std = @import("std");

const Flowers = @import("flower.zig").Flowers;

// Don't really know if this is a good idea
// Try to only load textures once and reuse
// A lot of flowers and bees can reuse the same texture

pub const Textures = struct {
    bee: rl.Texture,
    rose: rl.Texture,
    dandelion: rl.Texture,
    tulip: rl.Texture,

    pub fn init() @This() {
        return .{
            .rose = rl.loadTexture("sprites/rose.png"),
            .tulip = rl.loadTexture("sprites/tulip.png"),
            .dandelion = rl.loadTexture("sprites/dandelion.png"),
            .bee = rl.loadTexture("sprites/bee.png"),
        };
    }

    pub fn deinit(self: @This()) void {
        rl.unloadTexture(self.rose);
        rl.unloadTexture(self.dandelion);
        rl.unloadTexture(self.tulip);
        rl.unloadTexture(self.bee);
    }

    pub fn getFlowerTexture(self: @This(), flower: Flowers) rl.Texture {
        return switch (flower) {
            .rose => self.rose,
            .tulip => self.tulip,
            .dandelion => self.dandelion,
        };
    }
};
