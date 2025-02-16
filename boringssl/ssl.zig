const std = @import("std");

pub fn build(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    boringssl_dep: *std.Build.Dependency,
) !*std.Build.Step.Compile {
    const lib = b.addSharedLibrary(.{
        .name = "ssl",
        .optimize = optimize,
        .target = target,
    });

    lib.linkLibC();
    lib.linkLibCpp();

    if (optimize == .ReleaseSmall) {
        lib.root_module.addCMacro("OPENSSL_SMALL", "");
    }

    lib.root_module.addCMacro("ARCH", "generic");
    lib.root_module.addCMacro("OPENSSL_NO_ASM", "");

    if (target.result.os.tag == .wasi) {
        lib.root_module.addCMacro("OPENSSL_NO_THREADS_CORRUPT_MEMORY_AND_LEAK_SECRETS_IF_THREADED", "");
        lib.root_module.addCMacro("SO_KEEPALIVE", "0");
        lib.root_module.addCMacro("SO_ERROR", "0");
        lib.root_module.addCMacro("FREEBSD_GETRANDOM", "");
        lib.root_module.addCMacro("getrandom(a,b,c)", "getentropy(a,b)|b");
        lib.root_module.addCMacro("socket(a,b,c)", "-1");
        lib.root_module.addCMacro("setsockopt(a,b,c,d,e)", "-1");
        lib.root_module.addCMacro("connect(a,b,c)", "-1");
        lib.root_module.addCMacro("GRND_NONBLOCK", "0");
    }

    const cflags: []const []const u8 = &[_][]const u8{
        "-Wall",
        "-Wextra",
        "-Wpedantic",
        "-Wconversion",
        "-Wsign-conversion",
    };

    lib.addIncludePath(boringssl_dep.path("include"));

    for (sources) |source| {
        lib.addCSourceFile(.{
            .file = boringssl_dep.path(source),
            .flags = cflags,
        });
    }

    b.installDirectory(.{
        .source_dir = boringssl_dep.path("include"),
        .install_dir = .header,
        .install_subdir = "",
    });

    return lib;
}

const sources = &[_][]const u8{
    "ssl/tls13_server.cc",
    "ssl/tls13_both.cc",
    "ssl/tls_record.cc",
    "ssl/tls13_enc.cc",
    "ssl/tls13_client.cc",
    "ssl/t1_enc.cc",
    "ssl/ssl_versions.cc",
    "ssl/tls_method.cc",
    "ssl/ssl_stat.cc",
    "ssl/ssl_session.cc",
    "ssl/extensions.cc",
    "ssl/dtls_method.cc",
    "ssl/handshake_client.cc",
    "ssl/ssl_asn1.cc",
    "ssl/ssl_aead_ctx.cc",
    "ssl/handshake_server.cc",
    "ssl/d1_both.cc",
    "ssl/ssl_transcript.cc",
    "ssl/ssl_x509.cc",
    "ssl/s3_lib.cc",
    "ssl/handshake.cc",
    "ssl/ssl_privkey.cc",
    "ssl/dtls_record.cc",
    "ssl/ssl_buffer.cc",
    "ssl/encrypted_client_hello.cc",
    "ssl/d1_pkt.cc",
    "ssl/bio_ssl.cc",
    "ssl/s3_pkt.cc",
    "ssl/ssl_cert.cc",
    "ssl/ssl_cipher.cc",
    "ssl/ssl_key_share.cc",
    "ssl/ssl_credential.cc",
    "ssl/ssl_file.cc",
    "ssl/ssl_lib.cc",
    "ssl/s3_both.cc",
    "ssl/d1_srtp.cc",
    "ssl/d1_lib.cc",
    "ssl/handoff.cc",
};
