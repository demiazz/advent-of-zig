const std = @import("std");
const tools = @import("tools");

const Allocator = std.mem.Allocator;
const AnyReader = std.io.AnyReader;
const LineParser = tools.LineParser;

const Action = enum { on, off, toggle };
const Command = struct {
    action: Action,

    from_x: u16,
    from_y: u16,

    to_x: u16,
    to_y: u16,
};

const State = enum { action, from_x, delimiter, from_y, through, to_x, to_y };

const turn_on_pattern = "turn on ";
const turn_off_pattern = "turn off ";
const toggle_pattern = "toggle ";
const through_pattern = "through ";

// NOTE: Minimal length of line, which pattern is:
//
//         turn off x,y through x,y
//
//       where `x` and `y` is number in range 0..9.
const min_line_len =
    turn_off_pattern.len + 3 + through_pattern.len + 3;

fn isMatch(line: []const u8, comptime pattern: []const u8) bool {
    if (line.len < pattern.len) {
        return false;
    }

    return std.mem.eql(u8, line[0..pattern.len], pattern);
}

fn matchAction(line: []const u8) ?Action {
    if (isMatch(line, turn_on_pattern)) {
        return .on;
    }

    if (isMatch(line, turn_off_pattern)) {
        return .off;
    }

    if (isMatch(line, toggle_pattern)) {
        return .toggle;
    }

    return null;
}

fn parse(line: []const u8, allocator: Allocator) !Command {
    if (line.len < min_line_len) {
        return error.InvalidInput;
    }

    const action = matchAction(line) orelse return error.InvalidInput;

    var stream = std.io.fixedBufferStream(line);
    const reader = stream.reader();

    switch (action) {
        .on => {
            try reader.skipBytes(turn_on_pattern.len, .{});
        },
        .off => {
            try reader.skipBytes(turn_off_pattern.len, .{});
        },
        .toggle => {
            try reader.skipBytes(toggle_pattern.len, .{});
        },
    }

    const from_x_buffer = try reader.readUntilDelimiterAlloc(allocator, ',', 4);
    defer allocator.free(from_x_buffer);

    const from_x = try std.fmt.parseInt(u16, from_x_buffer, 10);

    const from_y_buffer = try reader.readUntilDelimiterAlloc(allocator, ' ', 4);
    defer allocator.free(from_y_buffer);

    const from_y = try std.fmt.parseInt(u16, from_y_buffer, 10);

    const through_buffer = try allocator.alloc(u8, through_pattern.len);
    defer allocator.free(through_buffer);

    _ = try reader.read(through_buffer);

    if (!isMatch(through_buffer, through_pattern)) {
        return error.InvalidInput;
    }

    const to_x_buffer = try reader.readUntilDelimiterAlloc(allocator, ',', 4);
    defer allocator.free(to_x_buffer);

    const to_x = try std.fmt.parseInt(u16, to_x_buffer, 10);

    const to_y_buffer = try reader.readAllAlloc(allocator, 3);
    defer allocator.free(to_y_buffer);

    const to_y = try std.fmt.parseInt(u16, to_y_buffer, 10);

    return .{
        .action = action,

        .from_x = from_x,
        .from_y = from_y,

        .to_x = to_x,
        .to_y = to_y,
    };
}

pub fn solve(allocator: Allocator, _: AnyReader) ![]const u8 {
    const action = try parse("turn on 599,989 through 806,993", allocator);

    std.log.info("{}", .{action});

    return try std.fmt.allocPrint(allocator, "{d}", .{1});
}

// test "solution 2015/05/01" {
//     const input_file = @embedFile("./input.fixture");
//     var input = std.io.fixedBufferStream(input_file);

//     const answer = try solve(std.testing.allocator, input.reader().any());
//     defer std.testing.allocator.free(answer);

//     try std.testing.expectEqualStrings(answer, "238");
// }
