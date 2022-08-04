const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var alloc = gpa.allocator();
var StateArrayType = std.ArrayList(std.ArrayList(std.ArrayList(i32)));

fn iota() void {
}

fn chi() void {
}

fn pi() void {
}

fn rho() void {
}

fn theta(state_array: *StateArrayType) void {
    var y: usize = 0;
    while (y < 5) {
        var actual_y = y + 2;
        y += 1;
    }
}

fn RND(state_array: *StateArrayType, i: usize) void {
}

fn keccak(b: usize, n: usize, s: []u8) void {
}

// KECCAK-f[b] = KECCAK-p[b,12+2l]
// KECCAK[c] = The KECCAK instance with KECCAK-f[1600] as the underlying permutation and capacity c. 
// SHA3-224(M) = KECCAK[448](M||01, 224);
// SHA3-256(M)= KECCAK[512](M||01, 256);
// SHA3-384(M)= KECCAK[768](M||01, 384);
// SHA3-512(M)= KECCAK[1024](M||01, 512).
pub fn main() !void {
    var state_array = 
        try std.ArrayList(std.ArrayList(std.ArrayList(i32)))
        .initCapacity(alloc, 5);
    try state_array.appendNTimes(
        try std.ArrayList(std.ArrayList(i32))
        .initCapacity(alloc, 5),
        5
    );
    var i: usize = 0;
    while (i < 5) {
        try state_array.items[i]
            .appendNTimes(try std.ArrayList(i32).initCapacity(alloc, 64), 5);
        i += 1;
    }
}
