const std = @import("std");
const keccak = @import("keccak.zig");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var alloc = gpa.allocator();

test "testing keccak sha3-256" {
    const str = [_]u8{ 'h', 'e', 'l', 'l', 'o' };
    var arrl = std.ArrayList(u8).init(alloc);
    for (str) |val| {
        try arrl.append(val);
    }
    var bitstr = try keccak.convertToBitStr(arrl);
    try bitstr.append(0);
    try bitstr.append(1);
    var digest = try keccak.sponge(keccak.keccak, keccak.pad10, 1600 - 2 * 256, bitstr.items, 256, 1600, 24);
    defer digest.deinit();
    try std.testing.expect(digest.items.len == 256);
}
