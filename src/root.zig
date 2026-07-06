pub const SDL_H = @import("SDL_H");
pub const SDL_Vulkan = @import("SDL_Vulkan");

pub fn Vulkan_CreateSurface(window: ?*SDL_H.SDL_Window, instance: SDL_Vulkan.VkInstance, allocator: ?*const SDL_Vulkan.VkAllocationCallbacks, surface: *SDL_Vulkan.VkSurfaceKHR) bool {
    return SDL_Vulkan.SDL_Vulkan_CreateSurface(window, instance, allocator, @ptrCast(surface));
}
