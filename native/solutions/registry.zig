const std = @import("std");

const index = @import("./solutions.zig");

const Allocator = std.mem.Allocator;
const AnyReader = std.io.AnyReader;

pub const Year = enum(u16) {
    year_2015 = 2015,
    year_2016,
    year_2017,
    year_2018,
    year_2019,
    year_2020,
    year_2021,
    year_2022,
    year_2023,
    year_2024,
};

pub const Day = enum(u16) {
    day_01 = 1,
    day_02,
    day_03,
    day_04,
    day_05,
    day_06,
    day_07,
    day_09,
    day_10,
    day_11,
    day_12,
    day_13,
    day_14,
    day_15,
    day_16,
    day_17,
    day_18,
    day_19,
    day_20,
    day_21,
    day_22,
    day_23,
    day_24,
    day_25,
};

pub const Part = enum(u16) {
    part_one = 1,
    part_two = 2,
};

pub const Solver = *const fn (Allocator, AnyReader) anyerror![]const u8;

const Entry = struct {
    year: Year,
    day: Day,
    part: Part,

    solver: Solver,
};

fn entry(year: Year, day: Day, part: Part, solver: Solver) Entry {
    return Entry{
        .year = year,
        .day = day,
        .part = part,
        .solver = solver,
    };
}

pub const items = [_]Entry{
    entry(.year_2015, .day_01, .part_one, index.solver_2015_01_01),
    entry(.year_2015, .day_01, .part_two, index.solver_2015_01_02),
    entry(.year_2015, .day_02, .part_one, index.solver_2015_02_01),
    entry(.year_2015, .day_02, .part_two, index.solver_2015_02_02),
};

pub fn lookup(year: Year, day: Day, part: Part) ?Solver {
    for (items) |item| {
        if (item.year != year) {
            continue;
        }

        if (item.day != day) {
            continue;
        }

        if (item.part != part) {
            continue;
        }

        return item.solver;
    }

    return null;
}

comptime {
    for (items, 0..) |self, idx| {
        if (idx == items.len - 1) {
            break;
        }

        for (items[idx + 1 ..]) |other| {
            if (self.year == other.year and self.day == other.day and self.part == other.part) {
                @compileError(
                    std.fmt.comptimePrint("duplicated keys founded in registry for {d}/{d:0>2}/{d:0>2}", .{
                        @intFromEnum(self.year),
                        @intFromEnum(self.day),
                        @intFromEnum(self.part),
                    }),
                );
            }

            if (self.solver == other.solver) {
                @compileError(std.fmt.comptimePrint(
                    "duplicated solvers founded in registry for {d}/{d:0>2}/{d:0>2} and {d}/{d:0>2}/{d:0>2}",
                    .{
                        @intFromEnum(self.year),
                        @intFromEnum(self.day),
                        @intFromEnum(self.part),
                        @intFromEnum(other.year),
                        @intFromEnum(other.day),
                        @intFromEnum(other.part),
                    },
                ));
            }
        }
    }
}
