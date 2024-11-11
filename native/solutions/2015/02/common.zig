const std = @import("std");

const AnyReader = std.io.AnyReader;
const Allocator = std.mem.Allocator;

const BytesList = std.ArrayList(u8);

pub const Box = struct { u32, u32, u32 };

pub const Parser = struct {
    data: [3]u32,
    index: usize,

    is_end: bool,
    is_invalid: bool,

    allocator: Allocator,
    reader: AnyReader,

    buffer: BytesList,

    pub fn init(allocator: Allocator, reader: AnyReader) Parser {
        return .{
            .data = .{ 0, 0, 0 },
            .index = 0,

            .is_end = false,
            .is_invalid = false,

            .allocator = allocator,
            .reader = reader,

            .buffer = BytesList.init(allocator),
        };
    }

    pub fn read(self: *Parser, dest: *Box) !void {
        if (self.is_invalid) {
            return error.InvalidInput;
        }

        if (self.is_end) {
            return error.EndOfStream;
        }

        while (self.reader.readByte()) |byte| {
            switch (byte) {
                '0'...'9' => try self.buffer.append(byte),
                'x' => try self.onFlush(),
                '\n' => return self.onEnd(dest),
                else => return self.onError(error.InvalidInput),
            }
        } else |err| {
            return if (err != error.EndOfStream) self.onError(err) else self.onEnd(dest);
        }
    }

    fn onFlush(self: *Parser) !void {
        if (self.buffer.items.len == 0) {
            return self.onError(error.InvalidInput);
        }

        self.data[self.index] = try std.fmt.parseInt(u32, self.buffer.items, 10);

        self.buffer.clearAndFree();

        self.index = if (self.index == 2) 0 else self.index + 1;
    }

    fn onEnd(self: *Parser, dest: *Box) !void {
        if (self.buffer.items.len == 0) {
            return self.onEndOfStream();
        }

        if (self.index != 2) {
            return self.onInvalidInput();
        }

        try self.onFlush();

        dest.* = .{ self.data[0], self.data[1], self.data[2] };

        self.data = .{ 0, 0, 0 };
    }

    fn onError(self: *Parser, err: anyerror) anyerror {
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

    fn onEndOfStream(self: *Parser) error{EndOfStream} {
        self.is_end = true;

        return error.EndOfStream;
    }

    fn onInvalidInput(self: *Parser) error{InvalidInput} {
        self.is_end = true;
        self.is_invalid = true;

        return error.InvalidInput;
    }

    pub fn deinit(self: *Parser) void {
        self.buffer.deinit();
    }
};

fn checkInput(comptime input: []const u8, comptime output: []const Box, is_valid: bool) !void {
    const allocator = std.testing.allocator;

    var stream = std.io.fixedBufferStream(input);

    var parser = Parser.init(allocator, stream.reader().any());
    defer parser.deinit();

    const dest = try allocator.create(Box);
    defer allocator.destroy(dest);

    for (output) |expected| {
        try parser.read(dest);

        try std.testing.expectEqual(expected, dest.*);
    }

    const expected_error = if (is_valid) error.EndOfStream else error.InvalidInput;

    try std.testing.expectError(expected_error, parser.read(dest));
}

fn checkValidInput(comptime input: []const u8, comptime output: []const Box) !void {
    try checkInput(input, output, true);
}

fn checkInvalidInput(comptime input: []const u8, comptime output: []const Box) !void {
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
        "1x2x3",
        &.{
            .{ 1, 2, 3 },
        },
    );

    try checkValidInput(
        "1x2x3\n",
        &.{
            .{ 1, 2, 3 },
        },
    );

    try checkValidInput(
        "1x2x3\n10x20x30",
        &.{
            .{ 1, 2, 3 },
            .{ 10, 20, 30 },
        },
    );

    try checkValidInput(
        "1x2x3\n10x20x30\n",
        &.{
            .{ 1, 2, 3 },
            .{ 10, 20, 30 },
        },
    );

    try checkValidInput(
        "1x2x3\n10x20x30\n\n1x2x3",
        &.{
            .{ 1, 2, 3 },
            .{ 10, 20, 30 },
        },
    );

    try checkInvalidInput(
        "10x20\n",
        &.{},
    );

    try checkInvalidInput(
        "1x2x3\n10xx20x30",
        &.{
            .{ 1, 2, 3 },
        },
    );
}
