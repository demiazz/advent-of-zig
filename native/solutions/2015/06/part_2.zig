const std = @import("std");

const common = @import("./common.zig");

const Action = common.Action;
const Allocator = std.mem.Allocator;
const AnyReader = std.io.AnyReader;
const Command = common.Command;
const Parser = common.Parser;

const width = 1000;
const height = 1000;

fn allocLights(allocator: Allocator) ![]u16 {
    const lights = try allocator.alloc(u16, width * height);

    for (lights) |*light| {
        light.* = 0;
    }

    return lights;
}

inline fn turnOn(lights: []u16, from_x: usize, from_y: usize, to_x: usize, to_y: usize) void {
    for (from_x..to_x + 1) |x| {
        const from = x * 999 + from_y;
        const to = from + (to_y - from_y) + 1;

        for (from..to) |idx| {
            lights[idx] += 1;
        }
    }
}

inline fn turnOff(lights: []u16, from_x: usize, from_y: usize, to_x: usize, to_y: usize) void {
    for (from_x..to_x + 1) |x| {
        const from = x * 999 + from_y;
        const to = from + (to_y - from_y) + 1;

        for (from..to) |idx| {
            if (lights[idx] > 0) {
                lights[idx] -= 1;
            }
        }
    }
}

inline fn toggle(lights: []u16, from_x: usize, from_y: usize, to_x: usize, to_y: usize) void {
    for (from_x..to_x + 1) |x| {
        const from = x * 999 + from_y;
        const to = from + (to_y - from_y) + 1;

        for (from..to) |idx| {
            lights[idx] += 2;
        }
    }
}

pub fn solve(allocator: Allocator, reader: AnyReader) ![]const u8 {
    var parser = Parser.init(allocator, reader);

    const lights = try allocLights(allocator);
    defer allocator.free(lights);

    while (parser.read()) |command| {
        switch (command.action) {
            .on => {
                turnOn(
                    lights,
                    command.from_x,
                    command.from_y,
                    command.to_x,
                    command.to_y,
                );
            },
            .off => {
                turnOff(
                    lights,
                    command.from_x,
                    command.from_y,
                    command.to_x,
                    command.to_y,
                );
            },
            .toggle => {
                toggle(
                    lights,
                    command.from_x,
                    command.from_y,
                    command.to_x,
                    command.to_y,
                );
            },
        }
    } else |err| {
        if (err != error.EndOfStream) {
            return err;
        }
    }

    var count: u32 = 0;

    for (lights) |light| {
        count += light;
    }

    return try std.fmt.allocPrint(allocator, "{d}", .{count});
}

test "solution 2015/06/02" {
    const input_file = @embedFile("./input.fixture");
    var input = std.io.fixedBufferStream(input_file);

    const answer = try solve(std.testing.allocator, input.reader().any());
    defer std.testing.allocator.free(answer);

    try std.testing.expectEqualStrings(answer, "14687245");
}
