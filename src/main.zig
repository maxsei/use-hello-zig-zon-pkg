const std = @import("std");
const hello = @import("hello");

pub fn main() !void {
    const hi = hello.greet();
    std.debug.print("{s}\n", .{hi});
}
