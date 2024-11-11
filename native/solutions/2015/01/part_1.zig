const std = @import("std");

const Allocator = std.mem.Allocator;
const AnyReader = std.io.AnyReader;

pub fn solve(allocator: Allocator, reader: AnyReader) ![]const u8 {
    var floor: i32 = 0;

    while (reader.readByte()) |byte| {
        floor += switch (byte) {
            '(' => 1,
            ')' => -1,
            else => return error.InvalidInput,
        };
    } else |err| {
        if (err == error.EndOfStream) {
            return try std.fmt.allocPrint(allocator, "{d}", .{floor});
        } else {
            return err;
        }
    }
}

test "solution 2015/01/01" {
    const input_file = @embedFile("./input.fixture");
    var input = std.io.fixedBufferStream(input_file);

    const answer = try solve(std.testing.allocator, input.reader().any());
    defer std.testing.allocator.free(answer);

    try std.testing.expectEqualStrings(answer, "232");
}
