const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("WraperSDL", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const sdl_window = b.dependency("binary_sdl_window", .{});
    if (builtin.target.os.tag == .windows) {
        if (builtin.target.cpu.arch == .x86_64) {
            mod.addLibraryPath(sdl_window.path("lib/x64"));
        } else if (builtin.target.cpu.arch == .x86) {
            mod.addLibraryPath(sdl_window.path("lib/x86"));
        } else if (builtin.target.cpu.arch == .aarch64) {
            mod.addLibraryPath(sdl_window.path("lib/arm64"));
        } else @panic("[WrapperSDL] Not support target arch");
    } else @panic("[WrapperSDL] Not support target os");

    mod.addIncludePath(sdl_window.path("include"));
}
