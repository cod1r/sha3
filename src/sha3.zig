const std = @import("std");
const keccak = @import("keccak.zig");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var alloc = gpa.allocator();

pub fn sha3_256(message: std.ArrayList(u8)) !std.ArrayList(u8) {
    var bit_str = try keccak.convertToBitStr(message);
    var digest = try keccak.sponge(keccak.keccak, keccak.pad101, 1600 - (2 * 256), bit_str.items, 256, 1600, 24);
    return digest;
}

test "testing keccak sha3-256; input = 'hello'" {
    const str = [_]u8{ 'h', 'e', 'l', 'l', 'o' };
    var arrl = std.ArrayList(u8).init(alloc);
    for (str) |val| {
        try arrl.append(val);
    }
    var bitstr = try keccak.convertToBitStr(arrl);
    try bitstr.append(0);
    try bitstr.append(1);
    var digest = try sha3_256(bitstr);
    defer digest.deinit();
    var str_digest = try keccak.convertToHex(digest);
    defer str_digest.deinit();
    std.debug.print("\n{s}\n", .{str_digest.items});
    try std.testing.expect(str_digest.items.len == 64);
    try std.testing.expect(digest.items.len == 256);
}

test "testing keccak sha3-256; input = ''" {
    const str = [_]u8{};
    var arrl = std.ArrayList(u8).init(alloc);
    try arrl.appendSlice(str[0..]);
    var bitstr = try keccak.convertToBitStr(arrl);
    try bitstr.append(0);
    try bitstr.append(1);
    var digest = try sha3_256(bitstr);
    defer digest.deinit();
    var str_digest = try keccak.convertToHex(digest);
    defer str_digest.deinit();
    std.debug.print("\n{s}\n", .{str_digest.items});
    try std.testing.expect(str_digest.items.len == 64);
    try std.testing.expect(digest.items.len == 256);
}

test "testing keccak sha3-256; input = 'hello' but not with bit string input" {
    const str = [_]u8{ 'h', 'e', 'l', 'l', 'o' };
    var arrl = std.ArrayList(u8).init(alloc);
    for (str) |val| {
        try arrl.append(val);
    }
    try arrl.append(0);
    try arrl.append(1);
    var digest = try sha3_256(arrl);
    defer digest.deinit();
    var str_digest = try keccak.convertToHex(digest);
    defer str_digest.deinit();
    std.debug.print("\n{s}\n", .{str_digest.items});
    try std.testing.expect(str_digest.items.len == 64);
    try std.testing.expect(digest.items.len == 256);
}

test "testing keccak sha3-256; input = 'jasonho' but not with bit string input" {
    const str = [_]u8{ 'j', 'a', 's', 'o', 'n', 'h', 'o' };
    var arrl = std.ArrayList(u8).init(alloc);
    for (str) |val| {
        try arrl.append(val);
    }
    try arrl.append(0);
    try arrl.append(1);
    var digest = try sha3_256(arrl);
    defer digest.deinit();
    var str_digest = try keccak.convertToHex(digest);
    defer str_digest.deinit();
    std.debug.print("\n{s}\n", .{str_digest.items});
    try std.testing.expect(str_digest.items.len == 64);
    try std.testing.expect(digest.items.len == 256);
}

test "testing keccak sha3-256; input = '' but not with bit string input" {
    const str = [_]u8{};
    var arrl = std.ArrayList(u8).init(alloc);
    for (str) |val| {
        try arrl.append(val);
    }
    try arrl.append(0);
    try arrl.append(1);
    var digest = try sha3_256(arrl);
    defer digest.deinit();
    var str_digest = try keccak.convertToHex(digest);
    defer str_digest.deinit();
    std.debug.print("\n{s}\n", .{str_digest.items});
    try std.testing.expect(str_digest.items.len == 64);
    try std.testing.expect(digest.items.len == 256);
}

test "testing keccak sha3-256; input = 'zzzzzz' but not with bit string input" {
    const str = [_]u8{ 'z', 'z', 'z', 'z', 'z', 'z' };
    var arrl = std.ArrayList(u8).init(alloc);
    try arrl.appendSlice(str[0..]);
    try arrl.append(0);
    try arrl.append(1);
    var digest = try sha3_256(arrl);
    defer digest.deinit();
    var str_digest = try keccak.convertToHex(digest);
    defer str_digest.deinit();
    std.debug.print("\n{s}\n", .{str_digest.items});
    try std.testing.expect(str_digest.items.len == 64);
    try std.testing.expect(digest.items.len == 256);
}
