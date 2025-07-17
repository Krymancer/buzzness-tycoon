const rl = @import("raylib");
const std = @import("std");

// TODO
// The point of this file is to manage the games resources
// Currently we are using honey that can be spent
// To create new bees
// This file should be the only API to interact with the resources

pub const Resources = struct {
    honey: f32,
    bees: f32,

    pub fn init() @This() {
        return .{
            .honey = 2500.0,
            .bees = 0.0,
        };
    }

    pub fn deinit(self: @This()) void {
        _ = self;
    }

    pub fn addHoney(self: *@This(), amount: f32) void {
        self.honey += amount;
    }

    pub fn spendHoney(self: *@This(), amount: f32) bool {
        if (self.honey >= amount) {
            self.honey -= amount;
            return true;
        }
        return false;
    }

    pub fn canAfford(self: @This(), amount: f32) bool {
        return self.honey >= amount;
    }
};
