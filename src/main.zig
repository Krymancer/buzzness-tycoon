const std = @import("std");
const Game = @import("game.zig").Game;

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var game = try Game.init(1080, 1080, allocator);
    defer game.deinit();

    try game.run();
}
