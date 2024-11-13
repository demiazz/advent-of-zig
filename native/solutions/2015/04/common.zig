const std = @import("std");

const Allocator = std.mem.Allocator;
const AnyReader = std.io.AnyReader;
const Md5 = std.crypto.hash.Md5;

inline fn lengthOf(value: u32) usize {
    if (value == 0) {
        return 1;
    }

    const f_value: f32 = @floatFromInt(value);
    const log: usize = @intFromFloat(@log10(f_value));

    return log + 1;
}

inline fn reallocate(allocator: Allocator, buffer: []u8, key: []u8, value: u32) ![]u8 {
    const required = key.len + lengthOf(value);

    if (buffer.len == required) {
        return buffer;
    }

    allocator.free(buffer);

    return allocator.alloc(u8, required);
}

pub fn crash(allocator: Allocator, reader: AnyReader, comptime target: []const u8) !u32 {
    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit();

    while (reader.readByte()) |byte| {
        if (byte == '\n') {
            break;
        }

        try buffer.append(byte);
    } else |err| {
        if (err != error.EndOfStream) {
            return err;
        }
    }

    const key = try buffer.toOwnedSlice();
    defer allocator.free(key);

    buffer.clearAndFree();

    var round: u32 = 1;
    var hash: [Md5.digest_length]u8 = undefined;
    var input: []u8 = try allocator.alloc(u8, lengthOf(round));
    defer allocator.free(input);

    while (true) {
        input = try reallocate(allocator, input, key, round);

        _ = try std.fmt.bufPrint(input, "{s}{d}", .{ key, round });

        Md5.hash(input, &hash, .{});

        const hex = std.fmt.bytesToHex(hash, .lower);

        if (std.mem.eql(u8, hex[0..target.len], target)) {
            break;
        }

        round += 1;
    }

    return round;
}
