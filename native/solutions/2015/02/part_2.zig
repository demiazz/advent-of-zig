const panic = @import("panic");
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
        var ribbon: u32 = box[0] + box[1] + box[2];

        const maxDs = blk: {
            var max = box[0];

            if (box[1] > max) {
                max = box[1];
            }

            if (box[2] > max) {
                max = box[2];
            }

            break :blk max;
        };

        ribbon -= maxDs;
        ribbon *= 2;
        ribbon += box[0] * box[1] * box[2];

        total += ribbon;
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

    try std.testing.expectEqualStrings(answer, "3812909");
}
