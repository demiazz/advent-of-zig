const std = @import("std");

const common = @import("./common.zig");

const Allocator = std.mem.Allocator;
const AnyReader = std.io.AnyReader;

pub fn solve(allocator: Allocator, input: AnyReader) ![]const u8 {
    var floor: i32 = 0;

    const reader = common.Reader{
        .reader = input,
    };

    while (reader.readNext()) |dir| {
        floor += dir;
    } else |err| {
        if (err != error.EndOfStream) {
            return err;
        }
    }

    return try std.fmt.allocPrint(allocator, "{d}", .{floor});
}

test "solution 2015/01/01" {
    const input_file = @embedFile("./input.fixture");
    var input = std.io.fixedBufferStream(input_file);

    const answer = try solve(std.testing.allocator, input.reader().any());
    defer std.testing.allocator.free(answer);

    try std.testing.expectEqualStrings(answer, "232");
}
