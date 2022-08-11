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
    defer R.deinit();
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

fn iota(state_array: *StateArrayType, i: usize) void {
    const w: usize = state_array.*.items[0].items[0].items[0].len;
    var RC = std.ArrayList(i32).init(alloc);
    defer RC.deinit();
    const l: usize = std.math.log(w);
    RC.appendNTimes(0, w);
    var j: usize = 0;
    while (j <= l) {
        RC.items[std.math.pow(2, j)] = rc(j + 7 * i);
        j += 1;
    }
    var z: usize = 0;
    var x: usize = (0 + 2) % 5;
    var y: usize = (0 + 2) % 5;
    while (z < w) {
        state_array.*.items[x].items[y].items[z] ^= RC.items[z];
        z += 1;
    }
}

fn chi(state_array: *StateArrayType) void {
    const w: usize = state_array.*.items[0].items[0].items[0].len;
    var x: usize = 0;
    while (x < 5) {
        const actual_x: usize = (x + 2) % 5;
        var y: usize = 0;
        while (y < 5) {
            const actual_y: usize = (y + 2) % 5;
            var z: usize = 0;
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
    const w: usize = state_array.*.items[0].items[0].items[0].len;
    var x: i32 = 0;
    while (x < 5) {
        const actual_x: i32 = (x + 2) % 5;
        var y: i32 = 0;
        while (y < 5) {
            const actual_y: i32 = (y + 2) % 5;
            var z: i32 = 0;
            while (z < w) {
                var val: i32 = state_array.*.items[(actual_x + 3 * actual_y) % 5].items[actual_x].items[z];
                state_array.*.items[actual_x].items[actual_y].items[z] = val;
                z += 1;
            }
            y += 1;
        }
        x += 1;
    }
}

fn rho(state_array: *StateArrayType) void {
    const w: usize = state_array.*.items[0].items[0].items[0].len;
    var x: usize = 1;
    var y: usize = 0;
    var t: usize = 0;
    while (t <= 23) {
        var z: usize = 0;
        while (z < w) {
            var actual_x: usize = (x + 2) % 5;
            var actual_y: usize = (y + 2) % 5;
            state_array.*.items[actual_x].items[actual_y].items[z] = state_array.*.items[actual_x][actual_y][(z - (t + 1) * (t + 2) / 2) % w];
            z += 1;
        }
        var temp: usize = x;
        x = y;
        y = (2 * temp + 3 * y) % 5;
        t += 1;
    }
}

fn theta(state_array: *StateArrayType) void {
    const w: usize = state_array.*.items[0].items[0].items[0].len;
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
        const actual_x: usize = (x + 2) % 5;
        var z: usize = 0;
        while (z < w) {
            var xor: i32 = 0;
            var y: usize = 0;
            while (y < 5) {
                const actual_y: usize = (y + 2) % 5;
                xor ^= state_array.*.items[actual_x].items[actual_y].items[z];
                y += 1;
            }
            C[actual_x][z] = xor;
            z += 1;
        }
        x += 1;
    }

    var x_D: usize = 0;
    while (x_D < 5) {
        const actual_x_D: usize = (x_D + 2) % 5;
        var z_D: usize = 0;
        while (z_D < w) {
            var xor_D: i32 = 0;
            xor_D ^= C[(actual_x_D - 1) % 5][z_D] ^ C[(actual_x_D + 1) % 5][@intCast(usize, (@intCast(i32, z_D) - 1) % 5)];
            D[actual_x_D][z_D] = xor_D;
            z_D += 1;
        }
        x_D += 1;
    }
    var x_final: usize = 0;
    while (x_final < 5) {
        var actual_x_final: usize = (x_final + 2) % 5;
        var y_final: usize = 0;
        while (y_final < 5) {
            var actual_y_final: usize = (y_final + 2) % 5;
            var z_final: usize = 0;
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
    defer state_array.deinit();
    var row_state_array = std.ArrayList(std.ArrayList(i32)).init(alloc);
    var col_state_array = try std.ArrayList(i32).init(alloc);
    defer col_state_array.deinit();
    try col_state_array.appendNTimes(0, w);
    while (row_state_array.items.len < 5) {
        try row_state_array.append(col_state_array.clone());
    }
    while (state_array.items.len < 5) {
        try state_array.append(row_state_array.clone());
    }

    var x: usize = 0;
    while (x < 5) {
        const actual_x: usize = (x + 2) % 5;
        var y: usize = 0;
        while (y < 5) {
            const actual_y: usize = (y + 2) % 5;
            var z: usize = 0;
            while (z < w) {
                state_array.*.items[actual_x].items[actual_y].items[z] = s[w * (5 * y + x) + z];
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
    defer S.deinit();

    var y_s: usize = 0;
    while (y_s < 5) {
        var actual_y_s: usize = (y_s + 2) % 5;
        var x_s: usize = 0;
        while (x_s < 5) {
            var actual_x_s: usize = (y_s + 2) % 5;
            var z_s: usize = 0;
            while (z_s < w) {
                S.append(state_array.*.items[actual_x_s].items[actual_y_s].items[z_s]);
                z_s += 1;
            }
            x_s += 1;
        }
        y_s += 1;
    }

    for (state_array) |x_row| {
        for (x_row) |y_row| {
            for (y_row) |z_row| {
                z_row.deinit();
            }
            y_row.deinit();
        }
        x_row.deinit();
    }
    return S;
}

fn sponge(f: fn () void, pad: fn () void, r: usize, n: []u8, d: usize, n_len: usize, b: usize) void {
    var P = std.ArrayList(i32).init(alloc);
    defer P.deinit();
    for (n) |val| {
        P.append(val);
    }
    P.appendSlice(pad(r, n.len).items);
    var lenpr: i32 = P.items.len / r;
    var c: i32 = b - r;
    _ = c;
    var S = std.ArrayList(i32).init(alloc);
    defer S.deinit();
    while (S.items.len < b) {
        S.append(0);
    }
    var splitr = std.ArrayList(std.ArrayList(i32)).init(alloc);
    defer splitr.deinit();
    var section: usize = 0;
    while (section < lenpr) {
        var subP = std.ArrayList(i32).init(alloc);
        defer subP.deinit();
        var pidx: usize = 0;
        while (pidx < r) {
            subP.append(P.items[pidx + (section * r)]);
            pidx += 1;
        }
        splitr.append(subP.clone());
    }
}

fn pad10(x: i32, m: i32) std.ArrayList(i32) {
    var j: i32 = (-m - 2) % x;
    var P = std.ArrayList(i32).init(alloc);
    defer P.deinit();
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
