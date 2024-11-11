const std = @import("std");

pub const Reader = struct {
    reader: std.io.AnyReader,

    pub fn readNext(self: Reader) !i32 {
        const byte = try self.reader.readByte();

        return switch (byte) {
            '(' => 1,
            ')' => -1,
            '\n' => error.EndOfStream,
            else => error.InvalidInput,
        };
    }
};
