const rl = @import("raylib");
const std = @import("std");

// TODO
// This file should be USE like an API only
// Try to do everthing else like manage state in other files

// This shoud be simple UI for the game
// the idea is having some images and text maily

// maybe a popup to buying upgrades? idk

pub const UI = struct {
    pub fn init() @This() {
        return .{};
    }

    pub fn deinit(self: @This()) void {
        _ = self;
    }

    pub fn draw(self: @This(), honey: f32, bees: usize) bool {
        _ = self;
        rl.drawText(rl.textFormat("Honey: %.0f", .{honey}), 10, 10, 30, rl.Color.white);
        rl.drawText(rl.textFormat("Bees: %d", .{bees}), 10, 40, 30, rl.Color.white);

        // Button to create a new bee (costs 10 honey)
        const buttonText = "Buy Bee (10 Honey)";
        const buttonWidth: f32 = 220;
        const buttonHeight: f32 = 40;
        const buttonRect = rl.Rectangle.init(10, 80, buttonWidth, buttonHeight);

        // Check if we can afford it
        const canAfford = honey >= 10.0;
        const buttonColor = if (canAfford) rl.Color.yellow else rl.Color.gray;

        // Draw button
        rl.drawRectangleRec(buttonRect, buttonColor);
        rl.drawRectangleLinesEx(buttonRect, 2, rl.Color.white);
        rl.drawText(buttonText, @intFromFloat(buttonRect.x + 10), @intFromFloat(buttonRect.y + 10), 20, rl.Color.black);

        // Check for click
        const mousePos = rl.getMousePosition();
        const mouseOnButton = rl.checkCollisionPointRec(mousePos, buttonRect);

        if (mouseOnButton and rl.isMouseButtonReleased(rl.MouseButton.left) and canAfford) {
            return true; // Player wants to buy a bee
        }

        return false;
    }
};
