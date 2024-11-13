const std = @import("std");

const AnyReader = std.io.AnyReader;

pub const Parser = struct {
    is_end: bool,
    is_invalid: bool,

    reader: AnyReader,

    pub fn init(reader: AnyReader) Parser {
        return .{
            .is_end = false,
            .is_invalid = false,

            .reader = reader,
        };
    }

    pub fn read(self: *Parser) !i32 {
        if (self.is_invalid) {
            return error.InvalidInput;
        }

        if (self.is_end) {
            return error.EndOfStream;
        }

        if (self.reader.readByte()) |byte| {
            return switch (byte) {
                '(' => 1,
                ')' => -1,
                '\n' => self.onEndOfStream(),
                else => self.onInvalidInput(),
            };
        } else |err| {
            return self.onError(err);
        }
    }

    fn onError(self: *Parser, err: anyerror) anyerror!i32 {
        switch (err) {
            error.EndOfStream => return self.onEndOfStream(),
            error.InvalidInput => return self.onInvalidInput(),
            else => {
                self.is_end = true;
                self.is_invalid = true;

                return err;
            },
        }
    }

    fn onEndOfStream(self: *Parser) !i32 {
        self.is_end = true;

        return error.EndOfStream;
    }

    fn onInvalidInput(self: *Parser) !i32 {
        self.is_end = true;
        self.is_invalid = true;

        return error.InvalidInput;
    }
};

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
