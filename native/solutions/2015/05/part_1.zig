const std = @import("std");
const tools = @import("tools");

const Allocator = std.mem.Allocator;
const AnyReader = std.io.AnyReader;
const LineParser = tools.LineParser;

fn parse(line: []const u8, _: Allocator) !bool {
    var vowels: usize = 0;
    var pairs: usize = 0;

    var optional_previous: ?u8 = null;

    for (line) |current| {
        if (optional_previous) |previous| {
            switch (current) {
                'b', 'd', 'q', 'y' => {
                    if (current - 1 == previous) {
                        return false;
                    }
                },
                else => {},
            }

            if (current == previous) {
                pairs += 1;
            }
        }

        switch (current) {
            'a', 'e', 'i', 'o', 'u' => {
                vowels += 1;
            },
            else => {},
        }

        optional_previous = current;
    }

    return vowels >= 3 and pairs > 0;
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

test "solution 2015/05/01" {
    const input_file = @embedFile("./input.fixture");
    var input = std.io.fixedBufferStream(input_file);

    const answer = try solve(std.testing.allocator, input.reader().any());
    defer std.testing.allocator.free(answer);

    try std.testing.expectEqualStrings(answer, "238");
}
