const std = @import("std");

pub const Entity = u32;
pub const INVALID_ENTITY: Entity = std.math.maxInt(Entity);

pub const EntityManager = struct {
    nextId: Entity,
    freeList: std.ArrayList(Entity),
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) @This() {
        const freeList: std.ArrayList(Entity) = .empty;
        return .{
            .nextId = 0,
            .freeList = freeList,
            .allocator = allocator,
        };
    }

    pub fn deinit(self: *@This()) void {
        self.freeList.deinit(self.allocator);
    }

    pub fn create(self: *@This()) !Entity {
        if (self.freeList.items.len > 0) {
            const id = self.freeList.items[self.freeList.items.len - 1];
            _ = self.freeList.pop();
            return id;
        }

        const id = self.nextId;
        self.nextId += 1;
        return id;
    }

    pub fn destroy(self: *@This(), entity: Entity) !void {
        try self.freeList.append(self.allocator, entity);
    }

    pub fn isValid(self: @This(), entity: Entity) bool {
        _ = self;
        return entity != INVALID_ENTITY;
    }
};
