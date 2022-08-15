const std = @import("std");
const A = [5][5]u64;
const w: usize = 64;
const b: usize = 1600;
const num_rounds: usize = 24;
const r: usize = 1088;

const RO = [5][5]usize{
    [5]usize{ 25, 39, 3, 10, 43 },
    [5]usize{ 55, 20, 36, 44, 6 },
    [5]usize{ 28, 27, 0, 1, 62 },
    [5]usize{ 56, 14, 18, 2, 61 },
    [5]usize{ 21, 8, 41, 45, 15 },
};

const RC = [_]u64{
    0x0000000000000001,
    0x0000000000008082,
    0x800000000000808A,
    0x8000000080008000,
    0x000000000000808B,
    0x0000000080000001,
    0x8000000080008081,
    0x8000000000008009,
    0x000000000000008A,
    0x0000000000000088,
    0x0000000080008009,
    0x000000008000000A,
    0x000000008000808B,
    0x800000000000008B,
    0x8000000000008089,
    0x8000000000008003,
    0x8000000000008002,
    0x8000000000000080,
    0x000000000000800A,
    0x800000008000000A,
    0x8000000080008081,
    0x8000000000008080,
    0x0000000080000001,
    0x8000000080008008,
};

fn ROT(n: u64, r: usize) u64 {
    var ret: u128 = @intCast(u128, n) << 64;
    ret |= n;
    ret >>= @intCast(u7, r % 64);
    return @intCast(u64, ret & ((1 << 64) - 1));
}

fn REV(n: u64) u64 {
    var ret: u64 = 0;
    var place: u64 = 1 << 63;
    var inc_amt: u8 = 0;
    while (place > (1 << 31)) {
        if (n & place) {
            ret |= (1 << inc_amt);
        }
        place >>= 1;
        inc_amt += 1;
    }
}

fn round(s: *A, rnd_c: usize) void {
    var C: [5]u64 = undefined;
    for (C) |_, idx| {
        C[idx] = s.*[idx][0] ^ s.*[idx][1] ^ s.*[idx][2] ^ s.*[idx][3] ^ s.*[idx][4];
    }

    var D: [5]u64 = undefined;
    for (D) |_, idx| {
        D[idx] = C[@mod(@intCast(i32, idx) - 1, 5)] ^ C[(idx + 1) % 5];
    }

    for (s.*) |_, row| {
        for (s.*[row]) |_, col| {
            s.*[row][col] ^= D[row];
        }
    }

    var B: A = undefined;
    for (B) |_, row| {
        for (B[row]) |_, col| {
            for (B[row][col]) |_, z| {
                B[row][col][z] = ROT(s.*[row][col], RO[row][col]);
            }
        }
    }

    for (s.*) |_, row| {
        for (s.*[row]) |_, col| {
            s.*[row][col] = B[row][col] ^ ((~B[(row + 1) % 5][col]) & B[(row + 2) % 5][col]);
        }
    }

    s.*[0][0] ^= rnd_c;
}

fn keccak_f(s: *A) void {
    var r: usize = 0;
    while (r < num_rounds) {
        round(s, RC[r]);
        r += 1;
    }
}

fn keccak(in: []u8) void {
    var s: A = undefined;
    for (s) |_, row| {
        for (s[row]) |_, col| {
            s[row][col] = 0;
        }
    }
}

test "ROT" {
    var r = ROT(2, 63);
    var r2 = ROT(1 << 63, 64);
    var r3 = ROT(1, 1);
    try std.testing.expect(r == 4);
    try std.testing.expect(r2 == 1 << 63);
    try std.testing.expect(r3 == 1 << 63);
}
