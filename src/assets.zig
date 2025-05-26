const std = @import("std");
const rl = @import("raylib");

// Embed file data
pub const bee_png = @embedFile("./sprites/bee.png");
pub const rose_png = @embedFile("./sprites/rose.png");
pub const dandelion_png = @embedFile("./sprites/dandelion.png");
pub const tulip_png = @embedFile("./sprites/tulip.png");
pub const grass_cube_png = @embedFile("./sprites/grass-cube.png");

// Custom Image loader that loads from embedded memory
pub fn loadImageFromMemory(fileData: []const u8) !rl.Image {
    return rl.loadImageFromMemory(".png", fileData);
}

// Custom Texture loader that loads from embedded memory
pub fn loadTextureFromMemory(fileData: []const u8) !rl.Texture {
    const image = try loadImageFromMemory(fileData);
    defer rl.unloadImage(image);
    return rl.loadTextureFromImage(image);
}
