const rl = @import("raylib");
const std = @import("std");

pub fn main() anyerror!void {
    const screenWidth = 1024;
    const screenHeight = 1024;

    rl.initWindow(screenWidth, screenHeight, "Buzzness Tycoon");
    defer rl.closeWindow();

    const beeIcon = rl.loadImage("sprites/bee.png");
    defer rl.unloadImage(beeIcon);
    rl.setWindowIcon(beeIcon);

    rl.setTargetFPS(60);

    const texture = rl.loadTexture("sprites/bee.png");
    defer rl.unloadTexture(texture);

    const grassTexture = rl.loadTexture("sprites/grass.png");
    defer rl.unloadTexture(grassTexture);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        //rl.drawTexture(texture, 12, 12, rl.Color.white);

        const gap: i32 = 5;

        const grassWidth: i32 = @intCast(grassTexture.width);
        const grassHeight: i32 = @intCast(grassTexture.height);

        const border = 10;

        const sizeX: i32 = @intCast(@divFloor(screenWidth, grassWidth + gap) - border);
        const sizeY: i32 = @intCast(@divFloor(screenHeight, grassHeight + gap) - border);

        const diffX = screenWidth - (sizeX * grassWidth);
        const diffY = screenHeight - (sizeY * grassHeight);

        const baseX = @divFloor(diffX, 2) - grassWidth;
        const baseY = @divFloor(diffY, 2) - grassHeight;

        for (0..@intCast(sizeX)) |i| {
            for (0..@intCast(sizeY)) |j| {
                const x: i32 = @intCast(i);
                const y: i32 = @intCast(j);
                const offsetX = if (@mod(y, 2) == 0)
                    x * (grassWidth + gap)
                else
                    x * (grassWidth + gap) + @divFloor(grassWidth, 2);

                rl.drawTexture(grassTexture, baseX + offsetX, baseY + (grassTexture.height * y), rl.Color.white);
            }
        }

        rl.clearBackground(rl.Color.init(0x1e, 0x1e, 0x2e, 0xff));
    }
}
