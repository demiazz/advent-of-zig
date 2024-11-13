const std = @import("std");

const AnyReader = std.io.AnyReader;

pub const ByteParserError = error{ EndOfStream, InvalidInput };

pub fn ByteParser(
    comptime Item: type,
    comptime parse: *const fn (u8) ByteParserError!Item,
) type {
    return struct {
        is_end: bool,
        is_invalid: bool,

        reader: AnyReader,

        const Self = @This();

        pub fn init(reader: AnyReader) Self {
            return .{
                .is_end = false,
                .is_invalid = false,

                .reader = reader,
            };
        }

        pub fn read(self: *Self) !Item {
            if (self.is_invalid) {
                return error.InvalidInput;
            }

            if (self.is_end) {
                return error.EndOfStream;
            }

            const byte = self.reader.readByte() catch |err| {
                return self.onError(err);
            };

            if (byte == '\n') {
                return self.onEndOfStream();
            }

            return parse(byte);
        }

        fn onError(self: *Self, err: anyerror) anyerror!Item {
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

        fn onEndOfStream(self: *Self) !Item {
            self.is_end = true;

            return error.EndOfStream;
        }

        fn onInvalidInput(self: *Self) !Item {
            self.is_end = true;
            self.is_invalid = true;

            return error.InvalidInput;
        }
    };
}
