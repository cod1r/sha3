const std = @import("std");
const keccak = @import("keccak.zig");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var alloc = gpa.allocator();

pub fn sha3_256(message: std.ArrayList(u8)) !std.ArrayList(u8) {
    var bit_str = try keccak.convertToBitStr(message);
    var digest = try keccak.sponge(keccak.keccak, keccak.pad101, 1600 - 2 * 256, bit_str.items, 256, 1600, 24);
    return digest;
}

test "testing keccak sha3-256" {
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
    var str_digest = try keccak.convertToStr(digest);
    defer str_digest.deinit();
    std.debug.print("\n", .{});
    for (str_digest.items) |val| {
        std.debug.print("{c} ", .{val + 48});
    }
    std.debug.print("\n", .{});
    try std.testing.expect(str_digest.items.len == 64);
    try std.testing.expect(digest.items.len == 256);
}
