const rl = @import("raylib");
const std = @import("std");

// TODO
// This file should be USE like an API only
// Try to do everthing else like manage state in other files

// This shoud be simple UI for the game
// the idea is having some images and text maily

// maybe a popup to buying upgrades? idk

pub const UI = struct {
    pub fn init() @This() {
        return .{};
    }

    pub fn deinit(self: @This()) void {
        _ = self;
    }

    pub fn draw(self: @This(), honey: f32, bees: usize) void {
        _ = self;
        rl.drawText(rl.textFormat("Honey: %.0f", .{honey}), 10, 10, 30, rl.Color.white);
        rl.drawText(rl.textFormat("Bees: %d", .{bees}), 10, 40, 30, rl.Color.white);
    }
};
