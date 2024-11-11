const std = @import("std");

const external = @import("./external.zig");

const String = external.String;

const allocator = std.heap.wasm_allocator;

extern fn onLog(level: usize, ptr: *String) void;

pub fn logFn(
    comptime message_level: std.log.Level,
    comptime scope: @Type(.enum_literal),
    comptime format: []const u8,
    args: anytype,
) void {
    const level = @intFromEnum(message_level);
    const prefix = if (scope == .default) "" else "(" ++ @tagName(scope) ++ "): ";
    const fmt = prefix ++ format;

    const message = std.fmt.allocPrint(allocator, fmt, args) catch return;
    defer allocator.free(message);

    const string = String.init(allocator, message) catch return;
    defer string.deinit();

    onLog(level, string);
}
