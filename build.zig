const std = @import("std");

pub fn build(b: *std.Build) void {
    const panic_module = b.addModule("panic", .{
        .root_source_file = b.path("native/panic.zig"),
    });

    const tools_module = b.addModule("tools", .{
        .root_source_file = b.path("native/tools/tools.zig"),
    });

    const registry_module = b.addModule("registry", .{
        .root_source_file = b.path("native/solutions/registry.zig"),
    });

    registry_module.addImport("tools", tools_module);

    const wasm = b.addExecutable(.{
        .name = "advent-of-zig",
        .root_source_file = b.path("native/wasm/main.zig"),
        .optimize = .ReleaseSafe,
        .target = b.resolveTargetQuery(.{ .cpu_arch = .wasm32, .os_tag = .freestanding }),
    });
    wasm.entry = .disabled;
    wasm.rdynamic = true;

    wasm.root_module.addImport("panic", panic_module);
    wasm.root_module.addImport("registry", registry_module);

    b.installArtifact(wasm);

    const cli = b.addExecutable(.{
        .name = "advent-of-zig",
        .root_source_file = b.path("native/cli/main.zig"),
        .optimize = .ReleaseSafe,
        .target = b.host,
    });

    cli.root_module.addImport("panic", panic_module);
    cli.root_module.addImport("registry", registry_module);

    b.installArtifact(cli);

    const run_cmd = b.addRunArtifact(cli);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const unit_tests = b.addTest(.{
        .root_source_file = b.path("native/solutions/solutions.zig"),
    });

    unit_tests.root_module.addImport("tools", tools_module);

    const run_unit_tests = b.addRunArtifact(unit_tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_unit_tests.step);
}
