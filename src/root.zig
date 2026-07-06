pub const sdl_h = @cImport({
    @cInclude("SDL3/SDL.h");
});
pub const sdl_vulkan = @cImport({
    @cInclude("SDL3/SDL_vulkan.h");
});

pub fn Vulkan_CreateSurface(window: ?*sdl_h.SDL_Window, instance: sdl_vulkan.VkInstance, allocator: ?*const sdl_vulkan.VkAllocationCallbacks, surface: *sdl_vulkan.VkSurfaceKHR) bool {
    return sdl_vulkan.SDL_Vulkan_CreateSurface(window, instance, allocator, @ptrCast(surface));
}
