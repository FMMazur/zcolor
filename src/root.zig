const std = @import("std");
const testing = std.testing;

pub const Text = @import("text.zig");
pub const TrueColor = @import("config.zig").TrueColor;
pub const Color = @import("config.zig").Color;
pub const Style = @import("config.zig").Style;

pub fn text(str: []const u8) Text {
    return .{
        .text = str,
    };
}

test "basic simple bg" {
    try expectFmt(
        text("simple bg").bg_color(.magenta).as_str(),
        &(.{ 27, '[', '4', '5', 'm' } ++ "simple bg".* ++ .{ 27, '[', 'm' }),
    );
}

test "advanced bg" {
    const advanced = comptime text("advanced").bg_color(.magenta).clear(false).as_str();
    const bg = comptime text(" bg ").bg_color(.red).clear(false).as_str();
    const config = comptime text("multi").fg_color(.white).bg_color(.magenta).as_str();

    const formatted_text = advanced ++ bg ++ config;

    try expectFmt(
        formatted_text,
        &(.{ 27, '[', '4', '5', 'm' } ++ "advanced".* ++ .{ 27, '[', '4', '1', 'm' } ++ " bg ".* ++ .{ 27, '[', '4', '5', ';', '3', '7', 'm' } ++ "multi".* ++ .{ 27, '[', 'm' }),
    );
}

test "true color hello" {
    try expectFmt(
        text("Hello").fg_color(TrueColor.init(255, 82, 197)).bg_color(TrueColor.init(155, 106, 0)).as_str(),
        &(.{ 27, '[', '4', '8', ';', '2', ';', '1', '5', '5', ';', '1', '0', '6', ';', '0', ';', '3', '8', ';', '2', ';', '2', '5', '5', ';', '8', '2', ';', '1', '9', '7', 'm' } ++ "Hello".* ++ .{ 27, '[', 'm' }),
    );
}

test "styles" {
    try expectFmt(
        text("Hello").add_style(.dimmed).add_style(.double_underline).as_str(),
        &(.{ 27, '[', '2', ';', '2', '1', 'm' } ++ "Hello".* ++ .{ 27, '[', 'm' }),
    );
    try expectFmt(
        text("Hello").fg_color(.red).add_style(.bold).as_str(),
        &(.{ 27, '[', '1', ';', '3', '1', 'm' } ++ "Hello".* ++ .{ 27, '[', 'm' }),
    );
    try expectFmt(
        text("Hello").fg_color(.red).add_style(.italic).as_str(),
        &(.{ 27, '[', '3', ';', '3', '1', 'm' } ++ "Hello".* ++ .{ 27, '[', 'm' }),
    );
    try expectFmt(
        text("Hello").fg_color(.red).add_style(.bold).add_style(.italic).as_str(),
        &(.{ 27, '[', '1', ';', '3', ';', '3', '1', 'm' } ++ "Hello".* ++ .{ 27, '[', 'm' }),
    );
}

fn expectFmt(comptime actual: []const u8, expected: []const u8) !void {
    return testing.expectEqualSlices(u8, expected, actual);
}
