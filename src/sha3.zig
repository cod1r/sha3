const std = @import("std");
const keccak = @import("keccak.zig");
var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
var alloc = gpa.allocator();

pub fn sha3_256(message: std.ArrayList(u8)) !std.ArrayList(u8) {
    var digest = try keccak.sponge(
        keccak.keccak,
        keccak.pad101,
        1600 - (2 * 256),
        message.items,
        256,
        1600,
        24,
    );
    return digest;
}

test "input = ''" {
    var inAL = std.ArrayList(u8).init(alloc);
    defer inAL.deinit();
    var out = try sha3_256(inAL);
    var hexout = try keccak.convertToHexFromBin(out);
    std.debug.print("\n{s}\n", .{hexout.items});
}
