const rg = @import("raygui");

// Catppuccin Mocha Color Palette
// https://github.com/catppuccin/catppuccin
pub const CatppuccinMocha = struct {
    // Surface colors
    pub const rosewater: u32 = 0xf5e0dcff;
    pub const flamingo: u32 = 0xf2cdcdff;
    pub const pink: u32 = 0xf5c2e7ff;
    pub const mauve: u32 = 0xcba6f7ff;
    pub const red: u32 = 0xf38ba8ff;
    pub const maroon: u32 = 0xeba0acff;
    pub const peach: u32 = 0xfab387ff;
    pub const yellow: u32 = 0xf9e2afff;
    pub const green: u32 = 0xa6e3a1ff;
    pub const teal: u32 = 0x94e2d5ff;
    pub const sky: u32 = 0x89dcebff;
    pub const sapphire: u32 = 0x74c7ecff;
    pub const blue: u32 = 0x89b4faff;
    pub const lavender: u32 = 0xb4befeff;
    
    // Text colors
    pub const text: u32 = 0xcdd6f4ff;
    pub const subtext1: u32 = 0xbac2deff;
    pub const subtext0: u32 = 0xa6adc8ff;
    
    // Overlay colors
    pub const overlay2: u32 = 0x9399b2ff;
    pub const overlay1: u32 = 0x7f849cff;
    pub const overlay0: u32 = 0x6c7086ff;
    
    // Surface colors
    pub const surface2: u32 = 0x585b70ff;
    pub const surface1: u32 = 0x45475aff;
    pub const surface0: u32 = 0x313244ff;
    
    // Base colors
    pub const base: u32 = 0x1e1e2eff;
    pub const mantle: u32 = 0x181825ff;
    pub const crust: u32 = 0x11111bff;
};

pub fn applyCatppuccinMochaTheme() void {
    // Load the default raygui style first
    rg.loadStyleDefault();
    
    // Set global background
    rg.setStyle(rg.Control.default, .{ .default = rg.DefaultProperty.background_color }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.base))));
    rg.setStyle(rg.Control.default, .{ .default = rg.DefaultProperty.text_size }, 16);
    rg.setStyle(rg.Control.default, .{ .default = rg.DefaultProperty.text_spacing }, 1);
    
    // Button styling with Yellow theme
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.base_color_normal }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.yellow))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.base_color_focused }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.peach))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.base_color_pressed }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.peach))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.base_color_disabled }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.surface0))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.text_color_normal }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.base))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.text_color_focused }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.base))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.text_color_pressed }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.base))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.text_color_disabled }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.subtext0))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.border_color_normal }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.surface1))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.border_color_focused }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.surface2))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.border_color_pressed }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.surface2))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.border_color_disabled }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.surface0))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.border_width }, 1);
    
    // Label styling
    rg.setStyle(rg.Control.label, .{ .control = rg.ControlProperty.text_color_normal }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.text))));
    rg.setStyle(rg.Control.label, .{ .control = rg.ControlProperty.text_color_focused }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.text))));
    rg.setStyle(rg.Control.label, .{ .control = rg.ControlProperty.text_color_pressed }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.text))));
    
    // Panel styling
    rg.setStyle(rg.Control.default, .{ .control = rg.ControlProperty.base_color_normal }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.surface0))));
    rg.setStyle(rg.Control.default, .{ .control = rg.ControlProperty.border_color_normal }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.surface1))));
    rg.setStyle(rg.Control.default, .{ .control = rg.ControlProperty.text_color_normal }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.text))));
}

// Alternative color schemes for different UI elements
pub fn applyGreenButtonTheme() void {
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.base_color_normal }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.green))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.base_color_focused }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.teal))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.base_color_pressed }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.teal))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.text_color_normal }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.base))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.text_color_focused }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.base))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.text_color_pressed }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.base))));
}

pub fn applyBlueButtonTheme() void {
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.base_color_normal }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.blue))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.base_color_focused }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.sapphire))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.base_color_pressed }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.sapphire))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.text_color_normal }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.base))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.text_color_focused }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.base))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.text_color_pressed }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.base))));
}

pub fn applyRedButtonTheme() void {
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.base_color_normal }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.red))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.base_color_focused }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.maroon))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.base_color_pressed }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.maroon))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.text_color_normal }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.base))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.text_color_focused }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.base))));
    rg.setStyle(rg.Control.button, .{ .control = rg.ControlProperty.text_color_pressed }, @bitCast(@as(i32, @bitCast(CatppuccinMocha.base))));
}
