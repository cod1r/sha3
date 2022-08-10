const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var alloc = gpa.allocator();
const StateArrayType = std.ArrayList(std.ArrayList(std.ArrayList(i32)));

fn rc(t) i32 {
    const tmod: i32 = t % 255;
    if (tmod == 0) {
        return 1;
    }
    var R: std.ArrayList(i32) = .{.{1, 0, 0, 0, 0, 0, 0, 0}};
    var i: i32 = 1;
    while (i <= tmod) {
        R.insert(0, 0);
        R.items[0] ^= R.items[8];

        i += 1;
    }
}

fn iota() void {
}

fn chi(state_array: *StateArrayType) void {
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
    var C = [5][5]i32 {
        [5]i32 {0, 0, 0, 0, 0},
        [5]i32 {0, 0, 0, 0, 0},
        [5]i32 {0, 0, 0, 0, 0},
        [5]i32 {0, 0, 0, 0, 0},
        [5]i32 {0, 0, 0, 0, 0},
    };
    var D = [5][5]i32 {
        [5]i32 {0, 0, 0, 0, 0},
        [5]i32 {0, 0, 0, 0, 0},
        [5]i32 {0, 0, 0, 0, 0},
        [5]i32 {0, 0, 0, 0, 0},
        [5]i32 {0, 0, 0, 0, 0},
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

//fn RND(state_array: *StateArrayType, i: usize) void {
//}
//
//fn keccak(b: usize, n: usize, s: []u8) void {
//}

// KECCAK-f[b] = KECCAK-p[b,12+2l]
// KECCAK[c] = The KECCAK instance with KECCAK-f[1600] as the underlying permutation and capacity c. 
// SHA3-224(M) = KECCAK[448](M||01, 224);
// SHA3-256(M)= KECCAK[512](M||01, 256);
// SHA3-384(M)= KECCAK[768](M||01, 384);
// SHA3-512(M)= KECCAK[1024](M||01, 512).
pub fn main() !void {
    var state_array: StateArrayType = StateArrayType.init(alloc);
    var row_state_array = std.ArrayList(std.ArrayList(i32)).init(alloc);
    var col_state_array = try std.ArrayList(i32).initCapacity(alloc, 64);
    try row_state_array.appendNTimes(col_state_array, 5);
    try state_array.appendNTimes(row_state_array, 5);
}
