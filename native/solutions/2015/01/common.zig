const std = @import("std");
const tools = @import("tools");

const ByteParser = tools.ByteParser;
const ByteParserError = tools.ByteParserError;

fn parse(byte: u8) ByteParserError!i32 {
    return switch (byte) {
        '(' => 1,
        ')' => -1,
        else => error.InvalidInput,
    };
}

pub const Parser = ByteParser(i32, parse);

fn checkInput(comptime input: []const u8, comptime output: []const i32, is_valid: bool) !void {
    var stream = std.io.fixedBufferStream(input);

    var parser = Parser.init(stream.reader().any());

    for (output) |expected| {
        try std.testing.expectEqual(expected, parser.read());
    }

    const expected_error = if (is_valid) error.EndOfStream else error.InvalidInput;

    try std.testing.expectError(expected_error, parser.read());
}

fn checkValidInput(comptime input: []const u8, comptime output: []const i32) !void {
    try checkInput(input, output, true);
}

fn checkInvalidInput(comptime input: []const u8, comptime output: []const i32) !void {
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
        "()",
        &.{
            1, -1,
        },
    );

    try checkValidInput(
        "()\n",
        &.{
            1, -1,
        },
    );

    try checkValidInput(
        "()\n()",
        &.{
            1, -1,
        },
    );

    try checkInvalidInput(
        "()[\n",
        &.{
            1, -1,
        },
    );
}
