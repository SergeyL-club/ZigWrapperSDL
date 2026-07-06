const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const sdl_windows_binary = b.dependency("sdl_windows_binary", .{});
    const sdl_h_c = b.addTranslateC(.{
        .root_source_file = sdl_windows_binary.path("include/SDL.h"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    const sdl_vulkan = b.addTranslateC(.{
        .root_source_file = sdl_windows_binary.path("include/SDL_vulkan.h"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });

    const mod = b.addModule("WrapperSDL", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "SDL_H", .module = sdl_h_c.createModule() },
            .{ .name = "SDL_Vulkan", .module = sdl_vulkan.createModule() },
        },
        .link_libc = true,
    });

    const sdl_path_artifacts = switch (builtin.target.os.tag) {
        .windows => switch (builtin.target.cpu.arch) {
            .x86 => sdl_windows_binary.path("lib/x86"),
            .x86_64 => sdl_windows_binary.path("lib/x64"),
            .aarch64 => sdl_windows_binary.path("lib/arm64"),
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

    const install_file = b.addInstallFileWithDir(sdl_path_artifacts, .bin, install_filename);
    b.getInstallStep().dependOn(&install_file.step);

    mod.addLibraryPath(sdl_path_artifacts);
    mod.linkSystemLibrary("SDL3", .{});
}
