const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("WraperSDL", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
    });

    const sdl_window = b.dependency("binary_sdl_window", .{});
    const sdl_path_bin = switch (builtin.target.os.tag) {
        .windows => switch (builtin.target.cpu.arch) {
            .x86 => sdl_window.path("lib/x86"),
            .x86_64 => sdl_window.path("lib/x64"),
            .aarch64 => sdl_window.path("lib/arm64"),
            else => @panic("[WrapperSDL] Not support target arch"),
        },
        else => @panic("[WrapperSDL] Not support target os"),
    };

    const affix = switch (builtin.target.os.tag) {
        .windows => ".dll",
        else => @panic("[WrapperSDL] Not support target os"),
    };

    const install_filename = try std.fmt.allocPrint(b.allocator, "SDL3.{s}", .{affix});
    errdefer @panic("Error alloc string");
    defer b.allocator.free(install_filename);

    const install_file = b.addInstallFileWithDir(sdl_path_bin, .bin, install_filename);
    b.getInstallStep().dependOn(&install_file.step);

    mod.addIncludePath(sdl_window.path("include"));
}
