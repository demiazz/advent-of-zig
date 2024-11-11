const registry = @import("registry");
const std = @import("std");

const Allocator = std.mem.Allocator;

pub const Item = struct {
    year: registry.Year,
    day: registry.Day,
    part: registry.Part,
};

fn ExternSlice(comptime T: type, comptime is_const: bool) type {
    const DataType = if (is_const) [*]const T else [*]T;
    const SliceType = if (is_const) []const T else []T;

    return struct {
        data: DataType,
        len: usize,

        allocator: Allocator,

        const Self = @This();

        pub fn init(allocator: Allocator, slice: SliceType) !*Self {
            const root = try allocator.create(Self);

            root.*.data = slice.ptr;
            root.*.len = slice.len;

            root.*.allocator = allocator;

            return root;
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.data[0..self.len]);
            self.allocator.destroy(self);
        }

        pub fn toSlice(self: *Self) SliceType {
            return self.data[0..self.len];
        }
    };
}

pub const Items = ExternSlice(Item, false);

pub const String = ExternSlice(u8, true);
