const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // const opts = .{ .target = target, .optimize = optimize };
    const hello = b.dependency("hello", .{});

    const exe = b.addExecutable(.{
        .name = "main",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    exe.addModule("hello", hello.module("hello"));
    b.installArtifact(exe);
}
