const std = @import("std");
const rl = @import("raylib");
const Game = @import("game.zig").Game;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var game = try Game.init(allocator);
    defer game.deinit();

    try game.run();
}
