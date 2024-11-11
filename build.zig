const std = @import("std");

fn appendAnonymousImports(b: *std.Build, c: *std.Build.Step.Compile) void {
    c.root_module.addAnonymousImport("panic", .{
        .root_source_file = b.path("native/panic.zig"),
    });

    c.root_module.addAnonymousImport("registry", .{
        .root_source_file = b.path("native/solutions/registry.zig"),
    });
}

pub fn build(b: *std.Build) void {
    const wasm = b.addExecutable(.{
        .name = "advent-of-zig",
        .root_source_file = b.path("native/wasm/main.zig"),
        .optimize = .ReleaseSafe,
        .target = b.resolveTargetQuery(.{ .cpu_arch = .wasm32, .os_tag = .freestanding }),
    });
    wasm.entry = .disabled;
    wasm.rdynamic = true;

    appendAnonymousImports(b, wasm);

    b.installArtifact(wasm);

    const cli = b.addExecutable(.{
        .name = "advent-of-zig",
        .root_source_file = b.path("native/cli/main.zig"),
        .optimize = .ReleaseSafe,
        .target = b.host,
    });

    appendAnonymousImports(b, cli);

    b.installArtifact(cli);

    const run_cmd = b.addRunArtifact(cli);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
