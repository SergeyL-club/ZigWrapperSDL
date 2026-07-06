const std = @import("std");
const builtin = @import("builtin");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const vk_sdk_path = b.graph.environ_map.get("VULKAN_SDK") orelse @panic("VULKAN_SDK missing!");
    const vk_path = b.fmt("{s}/Include", .{vk_sdk_path});
    std.debug.print("Vulkan SDK path: {s}", .{vk_path});

    const sdl_windows_binary = b.dependency("sdl_windows_binary", .{});

    const sdl_path_artifacts = switch (target.result.os.tag) {
        .windows => switch (target.result.cpu.arch) {
            .x86 => sdl_windows_binary.path("lib/x86"),
            .x86_64 => sdl_windows_binary.path("lib/x64"),
            .aarch64 => sdl_windows_binary.path("lib/arm64"),
            else => @panic("[WrapperSDL] Not support target arch"),
        },
        else => @panic("[WrapperSDL] Not support target os"),
    };

    const sdl_h_c = b.addTranslateC(.{
        .root_source_file = sdl_windows_binary.path("include/SDL3/SDL.h"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    sdl_h_c.addIncludePath(sdl_windows_binary.path("include/SDL3"));

    const sdl_vulkan = b.addTranslateC(.{
        .root_source_file = sdl_windows_binary.path("include/SDL3/SDL_vulkan.h"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    sdl_vulkan.addIncludePath(sdl_windows_binary.path("include/SDL3"));
    sdl_vulkan.addIncludePath(.{ .cwd_relative = vk_path });

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

    mod.addLibraryPath(sdl_path_artifacts);
    mod.linkSystemLibrary("SDL3", .{});

    const affix = switch (builtin.target.os.tag) {
        .windows => "dll",
        else => @panic("[WrapperSDL] Not support target os"),
    };

    const install_filename = b.fmt("SDL3.{s}", .{affix});

    const install_file = b.addInstallFileWithDir(sdl_path_artifacts.path(b, install_filename), .bin, install_filename);
    b.getInstallStep().dependOn(&install_file.step);
}
