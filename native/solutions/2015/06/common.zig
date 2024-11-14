const std = @import("std");
const tools = @import("tools");

const Allocator = std.mem.Allocator;
const AnyReader = std.io.AnyReader;
const LineParser = tools.LineParser;

pub const Action = enum { on, off, toggle };

pub const Command = struct {
    action: Action,

    from_x: usize,
    from_y: usize,

    to_x: usize,
    to_y: usize,
};

const Iterator = std.mem.SplitIterator(u8, .any);

fn parseAction(it: *Iterator) !Action {
    const prelude = it.first();

    if (std.mem.eql(u8, prelude, "toggle")) {
        return .toggle;
    }

    if (!std.mem.eql(u8, prelude, "turn")) {
        return error.InvalidInput;
    }

    const token = it.next() orelse "";

    if (std.mem.eql(u8, token, "on")) {
        return .on;
    }

    if (std.mem.eql(u8, token, "off")) {
        return .off;
    }

    return error.InvalidInput;
}

fn checkThrough(it: *Iterator) !void {
    const token = it.next() orelse "";

    if (!std.mem.eql(u8, token, "through")) {
        return error.InvalidInput;
    }
}

fn parseValue(it: *Iterator) !usize {
    const token = it.next() orelse "";

    if (token.len > 3) {
        return error.InvalidInput;
    }

    return std.fmt.parseInt(usize, token, 10) catch {
        return error.InvalidInput;
    };
}

fn parse(line: []const u8, _: Allocator) !Command {
    var it = std.mem.splitAny(u8, line, " ,");

    const action = try parseAction(&it);

    const from_x = try parseValue(&it);
    const from_y = try parseValue(&it);

    try checkThrough(&it);

    const to_x = try parseValue(&it);
    const to_y = try parseValue(&it);

    return .{
        .action = action,

        .from_x = from_x,
        .from_y = from_y,

        .to_x = to_x,
        .to_y = to_y,
    };
}

pub const Parser = LineParser(Command, parse);
