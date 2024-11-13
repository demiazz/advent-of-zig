const std = @import("std");

const common = @import("./common.zig");

const Allocator = std.mem.Allocator;
const AnyReader = std.io.AnyReader;
const Box = common.Box;
const Parser = common.Parser;

pub fn solve(allocator: Allocator, reader: AnyReader) ![]const u8 {
    var parser = Parser.init(allocator, reader);
    defer parser.deinit();

    const box = try allocator.create(Box);
    defer allocator.destroy(box);

    var total: u32 = 0;

    while (parser.read(box)) {
        const sqs = [_]u32{
            box[0] * box[1],
            box[1] * box[2],
            box[2] * box[0],
        };

        const minSq = blk: {
            var min = sqs[0];

            if (sqs[1] < min) {
                min = sqs[1];
            }

            if (sqs[2] < min) {
                min = sqs[2];
            }

            break :blk min;
        };

        total += 2 * sqs[0] + 2 * sqs[1] + 2 * sqs[2] + minSq;
    } else |err| {
        if (err != error.EndOfStream) {
            return err;
        }
    }

    return try std.fmt.allocPrint(allocator, "{d}", .{total});
}

test "solution 2015/02/01" {
    const input_file = @embedFile("./input.fixture");
    var input = std.io.fixedBufferStream(input_file);

    const answer = try solve(std.testing.allocator, input.reader().any());
    defer std.testing.allocator.free(answer);

    try std.testing.expectEqualStrings(answer, "1598415");
}
