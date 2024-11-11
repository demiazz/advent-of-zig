const panic = @import("panic");
const registry = @import("registry");
const std = @import("std");

const external = @import("./external.zig");
const log = @import("./log.zig");

const Item = external.Item;
const Items = external.Items;
const String = external.String;

var allocator = std.heap.wasm_allocator;

pub const std_options = .{
    .logFn = log.logFn,
};

fn _getAvailable() !*Items {
    const items = try allocator.alloc(Item, registry.items.len);

    errdefer allocator.free(items);

    for (registry.items, 0..) |item, idx| {
        items[idx] = .{
            .year = item.year,
            .day = item.day,
            .part = item.part,
        };
    }

    return try Items.init(allocator, items);
}

export fn getAvailable() *Items {
    return _getAvailable() catch |err| panic.@"error"(err);
}

export fn freeAvailable(items: *Items) void {
    items.deinit();
}

fn _allocateString(len: u32) !*String {
    const data = try allocator.alloc(u8, len);

    return try String.init(allocator, data);
}

export fn allocateString(len: u32) *String {
    return _allocateString(len) catch |err| panic.@"error"(err);
}

export fn freeString(string: *String) void {
    string.deinit();
}

fn _solve(raw_year: u16, raw_day: u16, raw_part: u16, input_ptr: *String) !*String {
    const year = try std.meta.intToEnum(registry.Year, raw_year);
    const day = try std.meta.intToEnum(registry.Day, raw_day);
    const part = try std.meta.intToEnum(registry.Part, raw_part);

    if (registry.lookup(year, day, part)) |solver| {
        defer input_ptr.deinit();

        var input = std.io.fixedBufferStream(input_ptr.toSlice());
        const inputReader = input.reader();

        var arena = std.heap.ArenaAllocator.init(allocator);
        defer arena.deinit();

        const answer = try solver(arena.allocator(), inputReader.any());
        const to_export: []const u8 = try allocator.dupe(u8, answer);

        return try String.init(allocator, to_export);
    } else {
        panic.message("no solver for given parameters", .{});
    }
}

export fn solve(raw_year: u16, raw_day: u16, raw_part: u16, input_ptr: *String) *String {
    return _solve(raw_year, raw_day, raw_part, input_ptr) catch |err| panic.@"error"(err);
}
