const std = @import("std");

pub const AnsiColor = enum {
    black,
    red,
    green,
    yellow,
    blue,
    magenta,
    purple,
    cyan,
    white,

    fn get_color(color: AnsiColor) []const u8 {
        return switch (color) {
            .black => "30",
            .red => "31",
            .green => "32",
            .yellow => "33",
            .blue => "34",
            .magenta, .purple => "35",
            .cyan => "36",
            .white => "37",
        };
    }

    fn get_bg_color(color: AnsiColor) []const u8 {
        return switch (color) {
            .black => "40",
            .red => "41",
            .green => "42",
            .yellow => "44",
            .blue => "44",
            .magenta, .purple => "45",
            .cyan => "46",
            .white => "47",
        };
    }
};

pub const TrueColor = struct {
    r: u8,
    g: u8,
    b: u8,

    pub fn init(r: u8, g: u8, b: u8) TrueColor {
        return .{ .r = r, .g = g, .b = b };
    }

    fn get_color(self: TrueColor) []const u8 {
        return std.fmt.comptimePrint("38;2;{};{};{}", .{ self.r, self.g, self.b });
    }

    fn get_bg_color(self: TrueColor) []const u8 {
        return std.fmt.comptimePrint("48;2;{};{};{}", .{ self.r, self.g, self.b });
    }
};

pub const Color = union(enum) {
    ansi: AnsiColor,
    true: TrueColor,

    pub fn get_color(self: Color) []const u8 {
        return switch (self) {
            .ansi => |ansi| ansi.get_color(),
            .true => |true_color| true_color.get_color(),
        };
    }

    pub fn get_bg_color(self: Color) []const u8 {
        return switch (self) {
            .ansi => |ansi| ansi.get_bg_color(),
            .true => |true_color| true_color.get_bg_color(),
        };
    }
};

pub const Style = enum(u8) {
    clear,
    normal,
    bold,
    dimmed,
    italic,
    underline,
    blink,
    fast_blink,
    reversed,
    hidden,
    strikethrough,
    double_underline,
    overlined,

    pub fn get_style(self: Style) []const u8 {
        return switch (self) {
            .clear => "0",
            .normal => "0",
            .bold => "1",
            .dimmed => "2",
            .italic => "3",
            .underline => "4",
            .blink => "5",
            .fast_blink => "6",
            .reversed => "7",
            .hidden => "8",
            .strikethrough => "9",
            .double_underline => "21",
            .overlined => "53",
        };
    }
};
