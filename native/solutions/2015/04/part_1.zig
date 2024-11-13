const panic = @import("panic");
const std = @import("std");

const common = @import("./common.zig");

const Allocator = std.mem.Allocator;
const AnyReader = std.io.AnyReader;

pub fn solve(allocator: Allocator, reader: AnyReader) ![]const u8 {
    const round = try common.crash(allocator, reader, "00000");

    return try std.fmt.allocPrint(allocator, "{d}", .{round});
}

test "solution 2015/04/01" {
    var input = std.io.fixedBufferStream("bgvyzdsv");

    const answer = try solve(std.testing.allocator, input.reader().any());
    defer std.testing.allocator.free(answer);

    try std.testing.expectEqualStrings(answer, "254575");
}
