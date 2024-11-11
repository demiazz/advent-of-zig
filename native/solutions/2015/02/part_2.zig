const panic = @import("panic");
const std = @import("std");

const Allocator = std.mem.Allocator;
const AnyReader = std.io.AnyReader;

const BytesList = std.ArrayList(u8);

const Parser = struct {
    total: i32,

    data: [3]i32,
    index: usize,

    buffer: BytesList,

    fn init(allocator: Allocator) Parser {
        return .{
            .total = 0,

            .data = .{ 0, 0, 0 },
            .index = 0,

            .buffer = BytesList.init(allocator),
        };
    }

    fn write(self: *Parser, byte: u8) !void {
        return switch (byte) {
            '0'...'9' => try self.buffer.append(byte),
            'x' => try self.flushDimension(),
            '\n' => try self.flushTotal(),
            else => error.InvalidInput,
        };
    }

    fn flushDimension(self: *Parser) !void {
        if (self.buffer.items.len > 0) {
            self.data[self.index] = try std.fmt.parseInt(i32, self.buffer.items, 10);
        }

        self.index += 1;

        self.buffer.clearAndFree();
    }

    fn flushTotal(self: *Parser) !void {
        try self.flushDimension();

        var ribbon: i32 = self.data[0] + self.data[1] + self.data[2];

        const maxDs = blk: {
            var max = self.data[0];

            if (self.data[1] > max) {
                max = self.data[1];
            }

            if (self.data[2] > max) {
                max = self.data[2];
            }

            break :blk max;
        };

        ribbon -= maxDs;
        ribbon *= 2;

        ribbon += self.data[0] * self.data[1] * self.data[2];

        self.total += ribbon;

        self.data[0] = 0;
        self.data[1] = 0;
        self.data[2] = 0;

        self.index = 0;
    }

    fn deinit(self: *Parser) void {
        self.buffer.deinit();
    }
};

pub fn solve(allocator: Allocator, reader: AnyReader) ![]const u8 {
    var parser = Parser.init(allocator);
    defer parser.deinit();

    while (reader.readByte()) |byte| {
        try parser.write(byte);
    } else |err| {
        if (err != error.EndOfStream) {
            return err;
        }
    }

    try parser.flushTotal();

    return try std.fmt.allocPrint(allocator, "{d}", .{parser.total});
}

test "solution 2015/02/01" {
    const input_file = @embedFile("./input.fixture");
    var input = std.io.fixedBufferStream(input_file);

    const answer = try solve(std.testing.allocator, input.reader().any());
    defer std.testing.allocator.free(answer);

    try std.testing.expectEqualStrings(answer, "3812909");
}
