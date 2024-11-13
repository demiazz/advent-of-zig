const std = @import("std");

const Allocator = std.mem.Allocator;
const AnyReader = std.io.AnyReader;
const BytesArrayList = std.ArrayList(u8);

pub fn LineParser(
    comptime Item: type,
    comptime parse: *const fn ([]const u8, allocator: Allocator) anyerror!Item,
) type {
    return struct {
        is_end: bool,

        allocator: Allocator,
        buffer: BytesArrayList,
        reader: AnyReader,

        const Self = @This();

        pub fn init(allocator: Allocator, reader: AnyReader) Self {
            return .{
                .is_end = false,

                .allocator = allocator,
                .buffer = BytesArrayList.init(allocator),
                .reader = reader,
            };
        }

        pub fn read(self: *Self) !Item {
            if (self.is_end) {
                return error.EndOfStream;
            }

            while (self.reader.readByte()) |byte| {
                if (byte == '\n') {
                    break;
                }

                try self.buffer.append(byte);
            } else |err| {
                self.is_end = true;

                switch (err) {
                    error.EndOfStream => {
                        if (self.buffer.items.len == 0) {
                            return error.EndOfStream;
                        }
                    },
                    else => return err,
                }
            }

            const line = try self.buffer.toOwnedSlice();
            defer self.allocator.free(line);

            const result = try parse(line, self.allocator);

            return result;
        }
    };
}
