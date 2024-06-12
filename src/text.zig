const std = @import("std");
const config = @import("config.zig");
const Style = config.Style;
const Color = config.Color;
const TrueColor = config.TrueColor;

const Text = @This();

const TextData = struct {
    text: []const u8,
    style: []const Style = &.{},
    _fg_color: ?Color = null,
    _bg_color: ?Color = null,
    dont_clear: bool = false,
};

data: TextData,

pub fn init(str: []const u8) Text {
    return .{
        .data = .{
            .text = str,
        },
    };
}

pub inline fn as_str(self: Text) []const u8 {
    comptime {
        const data = self.data;
        const initial = "\x1B[";
        var has_wrote = data.style.len > 0;

        var styles: []const u8 = "";
        for (data.style, 0..) |style, idx| {
            styles = styles ++ style.get_style();

            if (idx < data.style.len - 1) {
                styles = styles ++ ";";
            }
        }

        const background = if (data._bg_color) |color| blk: {
            const color_str = color.get_bg_color();

            if (has_wrote) break :blk ";" ++ color_str;

            has_wrote = true;
            break :blk color_str;
        } else "";

        const foreground = if (data._fg_color) |color| blk: {
            const color_str = color.get_color();

            if (has_wrote) break :blk ";" ++ color_str;

            has_wrote = true;
            break :blk color_str;
        } else "";

        const final = if (data.dont_clear) "" else "\x1B[m";

        const output = initial ++ styles ++ background ++ foreground ++ "m" ++ data.text ++ final;

        return output;
    }
}

pub fn clear(comptime self: Text, clear_at_end: bool) Text {
    const data = self.data;
    return .{
        .data = .{
            .text = data.text,
            ._fg_color = data._fg_color,
            ._bg_color = data._bg_color,
            .style = data.style,
            .dont_clear = !clear_at_end,
        },
    };
}

pub fn fg_color(comptime self: Text, color: anytype) Text {
    const data = self.data;
    return .{
        .data = .{
            .text = data.text,
            ._fg_color = format_color(color),
            ._bg_color = data._bg_color,
            .style = data.style,
            .dont_clear = data.dont_clear,
        },
    };
}

pub fn bg_color(comptime self: Text, color: anytype) Text {
    const data = self.data;
    return .{
        .data = .{
            .text = data.text,
            ._fg_color = data._fg_color,
            ._bg_color = format_color(color),
            .style = data.style,
            .dont_clear = data.dont_clear,
        },
    };
}

pub fn add_style(comptime self: Text, style: Style) Text {
    const data = self.data;
    var styles: []const Style = data.style[0..];
    styles = styles ++ .{style};

    return .{
        .data = .{
            .text = data.text,
            ._fg_color = data._fg_color,
            ._bg_color = data._bg_color,
            .style = styles,
            .dont_clear = data.dont_clear,
        },
    };
}

pub fn remove_style(comptime self: Text, style: Style) Text {
    const data = self.data;
    var styles: []const Style = {};

    for (data.style) |sstyle| {
        if (sstyle != style) {
            styles = styles ++ sstyle;
        }
    }

    return .{
        .data = .{
            .text = data.text,
            ._fg_color = data._fg_color,
            ._bg_color = data._bg_color,
            .style = styles,
            .dont_clear = data.dont_clear,
        },
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
            if (!std.meta.eql(TrueColor, T)) unreachable;
            return .{ .true = color };
        },
        else => unreachable,
    };
}
