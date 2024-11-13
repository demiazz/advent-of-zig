const std = @import("std");
const tools = @import("tools");

const Allocator = std.mem.Allocator;
const AnyReader = std.io.AnyReader;
const LineParser = tools.LineParser;

const Pairs = std.hash_map.AutoHashMap([2]u8, usize);
const Overlap = struct {
    byte: u8,
    index: usize,

    fn isOverlapped(self: Overlap, byte: u8, idx: usize) bool {
        return byte == self.byte and idx - 1 == self.index;
    }
};

fn parse(line: []const u8, allocator: Allocator) !bool {
    if (line.len < 3) {
        return false;
    }

    var has_repeat = false;

    var pairs = Pairs.init(allocator);
    defer pairs.deinit();

    var optional_overlap: ?Overlap = null;

    for (1..line.len) |idx| {
        if (idx >= 2) {
            has_repeat = has_repeat or line[idx] == line[idx - 2];
        }

        if (optional_overlap) |overlap| {
            if (overlap.isOverlapped(line[idx], idx)) {
                continue;
            }
        }

        const pair: [2]u8 = .{ line[idx], line[idx - 1] };

        if (pairs.get(pair)) |count| {
            try pairs.put(pair, count + 1);
        } else {
            try pairs.put(pair, 1);
        }

        if (pair[0] == pair[1]) {
            optional_overlap = .{
                .byte = pair[0],
                .index = idx,
            };
        }
    }

    var has_pairs = false;

    var iterator = pairs.valueIterator();

    while (iterator.next()) |count| {
        if (count.* >= 2) {
            has_pairs = true;

            break;
        }
    }

    return has_repeat and has_pairs;
}

pub const Parser = LineParser(bool, parse);

pub fn solve(allocator: Allocator, reader: AnyReader) ![]const u8 {
    var parser = Parser.init(allocator, reader);

    var count: usize = 0;

    while (parser.read()) |is_nice| {
        if (is_nice) {
            count += 1;
        }
    } else |err| {
        if (err != error.EndOfStream) {
            return err;
        }
    }

    return try std.fmt.allocPrint(allocator, "{d}", .{count});
}

test "solution 2015/05/02" {
    const input_file = @embedFile("./input.fixture");
    var input = std.io.fixedBufferStream(input_file);

    const answer = try solve(std.testing.allocator, input.reader().any());
    defer std.testing.allocator.free(answer);

    try std.testing.expectEqualStrings(answer, "69");
}
