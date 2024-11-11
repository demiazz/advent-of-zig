const panic = @import("panic");
const registry = @import("registry");
const std = @import("std");

const Allocator = std.mem.Allocator;

const Target = struct {
    year: registry.Year,
    day: registry.Day,
    part: registry.Part,

    input: ?[]const u8,
};

pub fn parseArgs(allocator: Allocator) *Target {
    var opt_year: ?registry.Year = null;
    var opt_day: ?registry.Day = null;
    var opt_part: ?registry.Part = null;
    var opt_input: ?[]const u8 = null;

    var arena = std.heap.ArenaAllocator.init(allocator);
    defer arena.deinit();

    const args = std.process.argsAlloc(arena.allocator()) catch |err| panic.@"error"(err);

    var idx: usize = 1;

    while (idx < args.len) : (idx += 1) {
        const arg = args[idx];

        if (std.mem.eql(u8, arg, "-y") or std.mem.eql(u8, arg, "--year")) {
            idx += 1;

            if (idx > args.len) {
                panic.message("expected arg after '{s}'", .{arg});
            }

            if (opt_year != null) {
                panic.message("duplicated {s} argument", .{arg});
            }

            const raw_year = std.fmt.parseUnsigned(u16, args[idx], 10) catch {
                panic.message("expected number after '{s}'", .{arg});
            };

            opt_year = std.meta.intToEnum(registry.Year, raw_year) catch {
                panic.message("invalid year value", .{});
            };
        } else if (std.mem.eql(u8, arg, "-d") or std.mem.eql(u8, arg, "--day")) {
            idx += 1;

            if (idx > args.len) {
                panic.message("expected arg after '{s}'", .{arg});
            }

            if (opt_day != null) {
                panic.message("duplicated {s} argument", .{arg});
            }

            const raw_day = std.fmt.parseUnsigned(u16, args[idx], 10) catch {
                panic.message("expected number after '{s}'", .{arg});
            };

            opt_day = std.meta.intToEnum(registry.Day, raw_day) catch {
                panic.message("invalid day value", .{});
            };
        } else if (std.mem.eql(u8, arg, "-p") or std.mem.eql(u8, arg, "--part")) {
            idx += 1;

            if (idx > args.len) {
                panic.message("expected arg after '{s}'", .{arg});
            }

            if (opt_part != null) {
                panic.message("duplicated {s} argument", .{arg});
            }

            const raw_part = std.fmt.parseUnsigned(u16, args[idx], 10) catch {
                panic.message("expected number after '{s}'", .{arg});
            };

            opt_part = std.meta.intToEnum(registry.Part, raw_part) catch {
                panic.message("invalid part value", .{});
            };
        } else {
            if (opt_input != null) {
                panic.message("duplicated input argument", .{});
            }

            opt_input = allocator.dupe(u8, arg) catch |err| panic.@"error"(err);
        }
    }

    const target = allocator.create(Target) catch |err| panic.@"error"(err);

    errdefer allocator.free(target);

    if (opt_year) |year| {
        target.*.year = year;
    } else {
        panic.message("the '-y' option is required", .{});
    }

    if (opt_day) |day| {
        target.*.day = day;
    } else {
        panic.message("the '-d' option is required", .{});
    }

    if (opt_part) |part| {
        target.*.part = part;
    } else {
        panic.message("the '-p' option is required", .{});
    }

    target.*.input = opt_input;

    return target;
}
