const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var alloc = gpa.allocator();
const StateArrayType = std.ArrayList(std.ArrayList(std.ArrayList(i32)));

fn rc(t: i32) i32 {
    const tmod: i32 = t % 255;
    if (tmod == 0) {
        return 1;
    }
    var R: std.ArrayList(i32) = .{.{ 1, 0, 0, 0, 0, 0, 0, 0 }};
    var i: i32 = 1;
    while (i <= tmod) {
        R.insert(0, 0);
        R.items[0] ^= R.items[8];
        R.items[4] ^= R.items[8];
        R.items[5] ^= R.items[8];
        R.items[6] ^= R.items[8];
        while (R.items.len > 8) {
            R.pop();
        }
        i += 1;
    }
    return R.items[0];
}

fn iota(state_array: StateArrayType, i: usize) void {
    const w: usize = state_array.items[0].items[0].items[0].len;
    var RC = std.ArrayList(i32).init(alloc);
    const l: i32 = std.math.log(w);
    RC.appendNTimes(0, w);
    var j: i32 = 0;
    while (j <= l) {
        RC.items[std.math.pow(2, j)] = rc(j + 7 * i);
        j += 1;
    }
    var z: i32 = 0;
    var x: i32 = (0 + 2) % 5;
    var y: i32 = (0 + 2) % 5;
    while (z < w) {
        state_array.items[x].items[y].items[z] ^= RC.items[z];
    }
}

fn chi(state_array: *StateArrayType) void {
    const w: usize = state_array.items[0].items[0].items[0].len;
    var x: i32 = 0;
    while (x < 5) {
        const actual_x: i32 = (x + 2) % 5;
        var y: i32 = 0;
        while (y < 5) {
            const actual_y: i32 = (y + 2) % 5;
            var z: i32 = 0;
            while (z < w) {
                const first: i32 = state_array.*.items[(actual_x + 1) % 5].items[actual_y].items[z];
                const second: i32 = state_array.*.items[(actual_x + 2) % 5].items[actual_y].items[z];
                const val: i32 = (first ^ 1) * second;
                state_array.*.items[actual_x].items[actual_y].items[z] ^= val;
                z += 1;
            }
            y += 1;
        }
    }
}

fn pi(state_array: *StateArrayType) void {
    const w: usize = state_array.items[0].items[0].items[0].len;
    var x: i32 = 0;
    while (x < 5) {
        const actual_x: i32 = (x + 2) % 5;
        var y: i32 = 0;
        while (y < 5) {
            const actual_y: i32 = (y + 2) % 5;
            var z: i32 = 0;
            while (z < w) {
                var val: i32 = state_array.items[(actual_x + 3 * actual_y) % 5].items[actual_x].items[z];
                state_array.items[actual_x].items[actual_y].items[z] = val;
                z += 1;
            }
            y += 1;
        }
        x += 1;
    }
}

fn rho(state_array: *StateArrayType) void {
    const w: usize = state_array.items[0].items[0].items[0].len;
    var x: i32 = 1;
    var y: i32 = 0;
    var t: i32 = 0;
    while (t <= 23) {
        var z: i32 = 0;
        while (z < w) {
            var actual_x: i32 = (x + 2) % 5;
            var actual_y: i32 = (y + 2) % 5;
            state_array.*.items[actual_x][actual_y][(z - (t + 1) * (t + 2) / 2) % w];
            z += 1;
        }
        var temp: i32 = x;
        x = y;
        y = (2 * temp + 3 * y) % 5;
    }
}

fn theta(state_array: *StateArrayType) void {
    const w: usize = state_array.items[0].items[0].items[0].len;
    var C = [5][5]i32{
        [5]i32{ 0, 0, 0, 0, 0 },
        [5]i32{ 0, 0, 0, 0, 0 },
        [5]i32{ 0, 0, 0, 0, 0 },
        [5]i32{ 0, 0, 0, 0, 0 },
        [5]i32{ 0, 0, 0, 0, 0 },
    };
    var D = [5][5]i32{
        [5]i32{ 0, 0, 0, 0, 0 },
        [5]i32{ 0, 0, 0, 0, 0 },
        [5]i32{ 0, 0, 0, 0, 0 },
        [5]i32{ 0, 0, 0, 0, 0 },
        [5]i32{ 0, 0, 0, 0, 0 },
    };
    var x: usize = 0;
    while (x < 5) {
        const actual_x: i32 = (x + 2) % 5;
        var z: i32 = 0;
        while (z < w) {
            const actual_z: i32 = z;
            var xor: i32 = 0;
            var y: i32 = 0;
            while (y < 5) {
                const actual_y: i32 = (y + 2) % 5;
                xor ^= state_array.*.items[actual_x].items[actual_y].items[actual_z];
                y += 1;
            }
            C[actual_x][actual_z] = xor;
            z += 1;
        }
        x += 1;
    }

    var x_D: i32 = 0;
    while (x_D < 5) {
        const actual_x_D: i32 = (x_D + 2) % 5;
        var z_D: i32 = 0;
        while (z_D < w) {
            const actual_z_D: i32 = (z_D + 2) % 5;
            var xor_D: i32 = 0;
            xor_D ^= C[(actual_x_D - 1) % 5][actual_z_D] ^ C[(actual_x_D + 1) % 5][(actual_z_D - 1) % 5];
            D[actual_x_D][actual_z_D] = xor_D;
            z_D += 1;
        }
        x_D += 1;
    }
    var x_final: i32 = 0;
    while (x_final < 5) {
        var actual_x_final: i32 = (x_final + 2) % 5;
        var y_final: i32 = 0;
        while (y_final < 5) {
            var actual_y_final: i32 = (y_final + 2) % 5;
            var z_final: i32 = 0;
            while (z_final < w) {
                state_array.*.items[actual_x_final].items[actual_y_final].items[z_final] ^= D[actual_x_final][z_final];
                z_final += 1;
            }
            y_final += 1;
        }
        x_final += 1;
    }
}

fn RND(state_array: *StateArrayType, i: usize) void {
    iota(chi(pi(rho(theta(state_array)))), i);
}

fn keccak(b: usize, n: usize, s: []u8) std.ArrayList(i32) {
    const w: usize = b / 25;
    const l: usize = std.math.log2(w);
    var state_array: StateArrayType = StateArrayType.init(alloc);
    var row_state_array = std.ArrayList(std.ArrayList(i32)).init(alloc);
    var col_state_array = try std.ArrayList(i32).init(alloc);
    try col_state_array.appendNTimes(0, w);
    try row_state_array.appendNTimes(col_state_array, 5);
    try state_array.appendNTimes(row_state_array, 5);

    var x: i32 = 0;
    while (x < 5) {
        const actual_x: i32 = (x + 2) % 5;
        var y: i32 = 0;
        while (y < 5) {
            const actual_y: i32 = (y + 2) % 5;
            var z: i32 = 0;
            while (z < w) {
                state_array.items[actual_x].items[actual_y].items[z] = s[w * (5 * y + x) + z];
                z += 1;
            }
            y += 1;
        }
        x += 1;
    }

    var ir: i32 = 12 + 2 * l - n;
    var stop: i32 = 12 + 2 * l - 1;
    while (ir <= stop) {
        RND(state_array, ir);
        ir += 1;
    }

    var S = std.ArrayList(i32).init(alloc);
    var y_s: i32 = 0;
    while (y_s < 5) {
        var actual_y_s: i32 = (x_s + 2) % 5;
        var y_s: i32 = 0;
        while (x_s < 5) {
            var actual_x_s: i32 = (y_s + 2) % 5;
            var x_s: i32 = 0;
            while (z_s < w) {
                S.append(state_array.items[actual_x_s].items[actual_y_s].items[z_s]);
                z_s += 1;
            }
            x_s += 1;
        }
        y_s += 1;
    }
    return S;
}

//fn sponge(f: fn () void, pad: fn () void, r: usize, n: []u8, d: usize, n_len: usize) void {
//
//}

fn pad10(x: i32, m: i32) std.ArrayList(i32) {
    var j: i32 = (-m - 2) % x;
    var P = std.ArrayList(i32).init(alloc);
    P.append(1);
    while (P.items.len - 1 < j) {
        P.append(0);
    }
    P.append(1);
    return P;
}

// KECCAK-f[b] = KECCAK-p[b,12+2l]
// KECCAK[c] = The KECCAK instance with KECCAK-f[1600] as the underlying permutation and capacity c.
// SHA3-224(M) = KECCAK[448](M||01, 224);
// SHA3-256(M)= KECCAK[512](M||01, 256);
// SHA3-384(M)= KECCAK[768](M||01, 384);
// SHA3-512(M)= KECCAK[1024](M||01, 512).
pub fn main() !void {}
