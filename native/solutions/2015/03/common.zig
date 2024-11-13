const std = @import("std");
const tools = @import("tools");

const AnyReader = std.io.AnyReader;
const ByteParser = tools.ByteParser;
const ByteParserError = tools.ByteParserError;
const Direction = enum { north, south, east, west };

fn process(byte: u8) ByteParserError!Direction {
    return switch (byte) {
        '^' => .north,
        'v' => .south,
        '>' => .east,
        '<' => .west,
        else => error.InvalidInput,
    };
}

pub const Parser = ByteParser(Direction, process);

pub const Point = struct {
    x: i32,
    y: i32,

    pub fn init() Point {
        return .{
            .x = 0,
            .y = 0,
        };
    }

    pub fn move(self: *Point, dir: Direction) void {
        switch (dir) {
            .north => self.y += 1,
            .south => self.y -= 1,
            .east => self.x += 1,
            .west => self.x -= 1,
        }
    }
};

fn checkInput(comptime input: []const u8, comptime output: []const Direction, is_valid: bool) !void {
    var stream = std.io.fixedBufferStream(input);

    var parser = Parser.init(stream.reader().any());

    for (output) |expected| {
        try std.testing.expectEqual(expected, parser.read());
    }

    const expected_error = if (is_valid) error.EndOfStream else error.InvalidInput;

    try std.testing.expectError(expected_error, parser.read());
}

fn checkValidInput(comptime input: []const u8, comptime output: []const Direction) !void {
    try checkInput(input, output, true);
}

fn checkInvalidInput(comptime input: []const u8, comptime output: []const Direction) !void {
    try checkInput(input, output, false);
}

test "parser" {
    try checkValidInput(
        "",
        &.{},
    );

    try checkValidInput(
        "\n",
        &.{},
    );

    try checkValidInput(
        "^v><",
        &.{
            .north,
            .south,
            .east,
            .west,
        },
    );

    try checkValidInput(
        "^v><\n",
        &.{
            .north,
            .south,
            .east,
            .west,
        },
    );

    try checkValidInput(
        "^v><\n^v><",
        &.{
            .north,
            .south,
            .east,
            .west,
        },
    );

    try checkInvalidInput(
        "^vV\n",
        &.{
            .north,
            .south,
        },
    );
}

test "point" {
    var point = Point.init();

    try std.testing.expectEqual(Point{ .x = 0, .y = 0 }, point);

    point.move(.north);

    try std.testing.expectEqual(Point{ .x = 0, .y = 1 }, point);

    point.move(.east);

    try std.testing.expectEqual(Point{ .x = 1, .y = 1 }, point);

    point.move(.south);

    try std.testing.expectEqual(Point{ .x = 1, .y = 0 }, point);

    point.move(.west);

    try std.testing.expectEqual(Point{ .x = 0, .y = 0 }, point);
}
