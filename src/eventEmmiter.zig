const std = @import("std");

const EventListener = struct {
    name: []const u8,
    once: bool,
    cb: *const fn (message: []const u8) void,
};

const EventEmitter = struct {
    allocator: std.mem.Allocator,
    listeners: std.ArrayList(EventListener),

    pub fn init(allocator: std.mem.Allocator) @This() {
        return .{ .allocator = allocator, .listeners = .empty };
    }

    pub fn emit(self: *@This(), event: []const u8, msg: []const u8) void {
        var idx: usize = 0;
        for (self.listeners.items) |listener| {
            // The idea here is for each listener that we have
            // When we emit a event we compare with the listener
            // name is the same as the event we are emiting
            // if so we can call the callback passing data
            if (std.mem.eql(u8, listener.name, event)) {
                listener.cb(msg);
                if (listener.once) {
                    _ = self.listeners.swapRemove(idx);
                }
            }
            idx = idx + 1;
        }
    }

    pub fn on(self: *@This(), event: []const u8, cb: *const fn (message: []const u8) void) !void {
        try self.listeners.append(self.allocator, .{ .name = event, .cb = cb, .once = false });
    }

    pub fn once(self: *@This(), event: []const u8, cb: *const fn (message: []const u8) void) !void {
        try self.listeners.append(self.allocator, .{ .name = event, .cb = cb, .once = true });
    }

    pub fn deinit(self: *@This()) void {
        self.listeners.deinit();
    }
};
