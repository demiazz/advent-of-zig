pub const solver_2015_01_01 = @import("./2015/01/part_1.zig").solve;
pub const solver_2015_01_02 = @import("./2015/01/part_2.zig").solve;
pub const solver_2015_02_01 = @import("./2015/02/part_1.zig").solve;
pub const solver_2015_02_02 = @import("./2015/02/part_2.zig").solve;
pub const solver_2015_03_01 = @import("./2015/03/part_1.zig").solve;
pub const solver_2015_03_02 = @import("./2015/03/part_2.zig").solve;
pub const solver_2015_04_01 = @import("./2015/04/part_1.zig").solve;
pub const solver_2015_04_02 = @import("./2015/04/part_2.zig").solve;

test {
    @import("std").testing.refAllDecls(@This());
}
