const std = @import("std");

const common = @import("./common.zig");

const Allocator = std.mem.Allocator;
const AnyReader = std.io.AnyReader;
const Direction = common.Direction;
const Parser = common.Parser;
const Point = common.Point;

const Visited = std.hash_map.AutoHashMap(Point, void);

pub fn solve(allocator: Allocator, reader: AnyReader) ![]const u8 {
    var parser = Parser.init(reader);

    var visited = Visited.init(allocator);
    defer visited.deinit();

    var santa = Point.init();

    while (parser.read()) |dir| {
        santa.move(dir);

        try visited.put(santa, undefined);
    } else |err| {
        if (err != error.EndOfStream) {
            return err;
        }
    }

    return try std.fmt.allocPrint(allocator, "{d}", .{visited.count()});
}

test "solution 2015/03/01" {
    const input_file = @embedFile("./input.fixture");
    var input = std.io.fixedBufferStream(input_file);

    const answer = try solve(std.testing.allocator, input.reader().any());
    defer std.testing.allocator.free(answer);

    try std.testing.expectEqualStrings(answer, "2565");
}
