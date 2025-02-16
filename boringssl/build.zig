const std = @import("std");
const crypto = @import("crypto.zig");
const ssl = @import("ssl.zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const source = b.dependency("boringssl_source", .{});

    const crypto_library = try crypto.build(b, target, optimize, source);
    b.installArtifact(crypto_library);

    const ssl_library = try ssl.build(b, target, optimize, source);
    ssl_library.linkLibrary(crypto_library);
    b.installArtifact(ssl_library);

    const bssl = b.addExecutable(.{
        .name = "bssl",
        .target = target,
        .optimize = optimize,
    });
    bssl.linkLibC();
    bssl.linkLibCpp();
    bssl.linkLibrary(ssl_library);
    bssl.linkLibrary(crypto_library);
    bssl.addIncludePath(source.path("include"));
    bssl.addCSourceFiles(.{
        .root = source.path(""),
        .files = bssl_sources,
        .flags = &.{
            "-Wall",
            "-Wextra",
            "-Wpedantic",
            "-Wconversion",
            "-Wsign-conversion",
        },
    });

    b.installArtifact(bssl);
}

const bssl_sources = &.{
    "tool/args.cc",
    "tool/ciphers.cc",
    "tool/client.cc",
    "tool/const.cc",
    "tool/digest.cc",
    "tool/fd.cc",
    "tool/file.cc",
    "tool/generate_ech.cc",
    "tool/generate_ed25519.cc",
    "tool/genrsa.cc",
    "tool/pkcs12.cc",
    "tool/rand.cc",
    "tool/server.cc",
    "tool/sign.cc",
    "tool/speed.cc",
    "tool/tool.cc",
    "tool/transport_common.cc",
};
