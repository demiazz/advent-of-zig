const builtin = @import("builtin");
const std = @import("std");

pub fn message(comptime fmt: []const u8, args: anytype) noreturn {
    std.log.err(fmt, args);

    if (builtin.os.tag == .freestanding) {
        @trap();
    } else {
        std.process.exit(1);
    }
}

pub fn @"error"(err: anyerror) noreturn {
    switch (err) {
        error.OutOfMemory => {
            message("out of memory", .{});
        },
        else => {
            message("unknown error: {s}", .{@errorName(err)});
        },
    }
}
