const rl = @import("raylib");
const rg = @import("raygui");
const std = @import("std");
const theme = @import("theme.zig");

// TODO
// This file should be USE like an API only
// Try to do everthing else like manage state in other files

// This shoud be simple UI for the game
// the idea is having some images and text maily

// maybe a popup to buying upgrades? idk

pub const UI = struct {
    pub fn init() @This() {
        // Apply the Catppuccin Mocha theme
        theme.applyCatppuccinMochaTheme();
        
        return .{};
    }

    pub fn deinit(self: @This()) void {
        _ = self;
    }

    pub fn draw(self: @This(), honey: f32, bees: usize) bool {
        _ = self;
        rl.drawText(rl.textFormat("Honey: %.0f", .{honey}), 10, 10, 30, rl.Color.white);
        rl.drawText(rl.textFormat("Bees: %d", .{bees}), 10, 40, 30, rl.Color.white);

        const buttonText = "Buy Bee (10 Honey)";
        const buttonWidth: f32 = 220;
        const buttonHeight: f32 = 40;
        const buttonRect = rl.Rectangle.init(10, 80, buttonWidth, buttonHeight);

        const canAfford = honey >= 10.0;

        // Disable the button if player can't afford it
        if (!canAfford) {
            rg.setState(@intFromEnum(rg.State.disabled));
        }

        // Use raygui button instead of manual rectangle drawing
        const buttonPressed = rg.button(buttonRect, buttonText);

        // Re-enable GUI if it was disabled
        if (!canAfford) {
            rg.setState(@intFromEnum(rg.State.normal));
        }

        return buttonPressed and canAfford;
    }
};
