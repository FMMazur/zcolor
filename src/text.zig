const std = @import("std");
const config = @import("config.zig");
const Style = config.Style;
const Color = config.Color;

const Text = @This();

text: []const u8,
style: []const Style = &.{},
_fg_color: ?Color = null,
_bg_color: ?Color = null,
dont_clear: bool = false,

pub inline fn as_str(self: Text) []const u8 {
    comptime {
        const initial = "\x1B[";
        var has_wrote = self.style.len > 0;

        var styles: []const u8 = "";
        for (self.style, 0..) |style, idx| {
            styles = styles ++ style.get_style();

            if (idx < self.style.len - 1) {
                styles = styles ++ ";";
            }
        }

        const background = if (self._bg_color) |color| blk: {
            const color_str = color.get_bg_color();

            if (has_wrote) break :blk ";" ++ color_str;

            has_wrote = true;
            break :blk color_str;
        } else "";

        const foreground = if (self._fg_color) |color| blk: {
            const color_str = color.get_color();

            if (has_wrote) break :blk ";" ++ color_str;

            has_wrote = true;
            break :blk color_str;
        } else "";

        const final = if (self.dont_clear) "" else "\x1B[m";

        const output = initial ++ styles ++ background ++ foreground ++ "m" ++ self.text ++ final;

        return output;
    }
}

pub fn clear(comptime self: Text, clear_at_end: bool) Text {
    return .{
        .text = self.text,
        ._fg_color = self._fg_color,
        ._bg_color = self._bg_color,
        .style = self.style,
        .dont_clear = !clear_at_end,
    };
}

pub fn fg_color(comptime self: Text, color: anytype) Text {
    return .{
        .text = self.text,
        ._fg_color = format_color(color),
        ._bg_color = self._bg_color,
        .style = self.style,
        .dont_clear = self.dont_clear,
    };
}

pub fn bg_color(comptime self: Text, color: anytype) Text {
    return .{
        .text = self.text,
        ._fg_color = self._fg_color,
        ._bg_color = format_color(color),
        .style = self.style,
        .dont_clear = self.dont_clear,
    };
}

pub fn add_style(comptime self: Text, style: Style) Text {
    var styles: []const Style = self.style[0..];
    styles = styles ++ .{style};

    return .{
        .text = self.text,
        ._fg_color = self._fg_color,
        ._bg_color = self._bg_color,
        .style = styles,
        .dont_clear = self.dont_clear,
    };
}

pub fn remove_style(comptime self: Text, style: Style) Text {
    var styles: []const Style = {};

    for (self.style) |sstyle| {
        if (sstyle != style) {
            styles = styles ++ sstyle;
        }
    }

    return .{
        .text = self.text,
        ._fg_color = self._fg_color,
        ._bg_color = self._bg_color,
        .style = styles,
        .dont_clear = self.dont_clear,
    };
}

fn format_color(color: anytype) Color {
    const T = @TypeOf(color);

    return switch (@typeInfo(T)) {
        .EnumLiteral => .{ .ansi = color },
        .Union => blk: {
            if (!std.meta.eql(Color, color)) unreachable;
            break :blk color;
        },
        .Struct => {
            return .{ .true = color };
        },
        else => unreachable,
    };
}
