const panic = @import("panic");
const registry = @import("registry");
const std = @import("std");

const args = @import("./args.zig");

const AnyReader = std.io.AnyReader;
const File = std.fs.File;

var gpa = std.heap.GeneralPurposeAllocator(.{}){
    .backing_allocator = std.heap.page_allocator,
};
const allocator = gpa.allocator();

pub fn main() !void {
    const target = args.parseArgs(allocator);

    if (registry.lookup(target.year, target.day, target.part)) |solver| {
        var file: File = undefined;

        if (target.input) |file_path| {
            file = std.fs.cwd().openFile(file_path, .{ .mode = .read_only }) catch {
                @panic("couldn't open input file");
            };
        } else {
            file = std.io.getStdIn();
        }

        defer file.close();

        var buffered = std.io.bufferedReader(file.reader());

        var arena = std.heap.ArenaAllocator.init(allocator);
        defer arena.deinit();

        const answer = solver(arena.allocator(), buffered.reader().any()) catch |err| panic.@"error"(err);

        std.debug.print("{s}", .{answer});
    } else {
        panic.message("no solver for given parameters", .{});
    }
}
