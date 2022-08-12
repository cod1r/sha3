//! Keep track of where you place 'defer <array list>.deinit()' because that might mess up
//! the result that you get.
const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
var alloc = gpa.allocator();
const StateArrayType = std.ArrayList(std.ArrayList(std.ArrayList(u8)));

pub fn rc(t: usize) !u8 {
    const tmod: usize = t % 255;
    if (tmod == 0) {
        return 1;
    }
    var R: std.ArrayList(u8) = std.ArrayList(u8).init(alloc);
    try R.append(1);
    try R.appendNTimes(0, 7);
    defer R.deinit();
    var i: usize = 1;
    while (i <= tmod) {
        try R.insert(0, 0);
        R.items[0] ^= R.items[8];
        R.items[4] ^= R.items[8];
        R.items[5] ^= R.items[8];
        R.items[6] ^= R.items[8];
        if (R.items.len > 8) {
            _ = R.pop();
        }
        i += 1;
    }
    return R.items[0];
}

pub fn iota(state_array: *StateArrayType, i: usize) !void {
    const w: usize = state_array.*.items[0].items[0].items.len;
    var RC = std.ArrayList(u8).init(alloc);
    defer RC.deinit();
    const l: usize = std.math.log2(w);
    try RC.appendNTimes(0, w);
    var j: usize = 0;
    while (j <= l) {
        RC.items[std.math.pow(usize, 2, j) - 1] = try rc(j + 7 * i);
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

pub fn chi(state_array: *StateArrayType) void {
    const w: usize = state_array.*.items[0].items[0].items.len;
    var x: usize = 0;
    while (x < 5) {
        const actual_x: usize = (x + 2) % 5;
        var y: usize = 0;
        while (y < 5) {
            const actual_y: usize = (y + 2) % 5;
            var z: usize = 0;
            while (z < w) {
                const first: u8 = state_array.*.items[(actual_x + 1) % 5].items[actual_y].items[z];
                const second: u8 = state_array.*.items[(actual_x + 2) % 5].items[actual_y].items[z];
                const val: u8 = (first ^ 1) * second;
                state_array.*.items[actual_x].items[actual_y].items[z] ^= val;
                z += 1;
            }
            y += 1;
        }
        x += 1;
    }
}

pub fn pi(state_array: *StateArrayType) void {
    const w: usize = state_array.*.items[0].items[0].items.len;
    var x: usize = 0;
    while (x < 5) {
        const actual_x: usize = (x + 2) % 5;
        var y: usize = 0;
        while (y < 5) {
            const actual_y: usize = (y + 2) % 5;
            var z: usize = 0;
            while (z < w) {
                var val: u8 = state_array.*.items[(actual_x + 3 * actual_y) % 5].items[actual_x].items[z];
                state_array.*.items[actual_x].items[actual_y].items[z] = val;
                z += 1;
            }
            y += 1;
        }
        x += 1;
    }
}

pub fn rho(state_array: *StateArrayType) void {
    const w: usize = state_array.*.items[0].items[0].items.len;
    var x: usize = 1;
    var y: usize = 0;
    var t: usize = 0;
    while (t <= 23) {
        var z: usize = 0;
        while (z < w) {
            var actual_x: usize = (x + 2) % 5;
            var actual_y: usize = (y + 2) % 5;
            var t_sqrd: i32 = @divFloor((@intCast(i32, t) + 1) * (@intCast(i32, t) + 2), 2);
            var modified_z: usize = @intCast(usize, @mod(@intCast(i32, z) - t_sqrd, @intCast(i32, w)));
            state_array.*.items[actual_x].items[actual_y].items[z] = state_array.*.items[actual_x].items[actual_y].items[modified_z];
            z += 1;
        }
        var temp: usize = x;
        x = y;
        y = (2 * temp + 3 * y) % 5;
        t += 1;
    }
}

pub fn theta(state_array: *StateArrayType) !void {
    const w: usize = state_array.*.items[0].items[0].items.len;
    var C = std.ArrayList(std.ArrayList(u8)).init(alloc);
    var C_inner = std.ArrayList(u8).init(alloc);
    try C_inner.appendNTimes(0, w);
    var tc1: usize = 0;
    while (tc1 < 5) {
        try C.append(try clone(C_inner));
        tc1 += 1;
    }
    var D = std.ArrayList(std.ArrayList(u8)).init(alloc);
    var D_inner = std.ArrayList(u8).init(alloc);
    try D_inner.appendNTimes(0, w);
    var tc2: usize = 0;
    while (tc2 < 5) {
        try D.append(try clone(D_inner));
        tc2 += 1;
    }
    var x: usize = 0;
    while (x < 5) {
        const actual_x: usize = (x + 2) % 5;
        var z: usize = 0;
        while (z < w) {
            var xor: u8 = 0;
            var y: usize = 0;
            while (y < 5) {
                const actual_y: usize = (y + 2) % 5;
                xor ^= state_array.*.items[actual_x].items[actual_y].items[z];
                y += 1;
            }
            C.items[actual_x].items[z] = xor;
            z += 1;
        }
        x += 1;
    }

    var x_D: usize = 0;
    while (x_D < 5) {
        const actual_x_D: usize = (x_D + 2) % 5;
        var z_D: usize = 0;
        while (z_D < w) {
            var first: u8 = C.items[@intCast(usize, @mod(@intCast(i32, actual_x_D) - 1, 5))].items[z_D];
            var second: u8 = C.items[(actual_x_D + 1) % 5].items[@intCast(usize, @mod(@intCast(i32, z_D) - 1, 5))];
            D.items[actual_x_D].items[z_D] = first ^ second;
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
                state_array.*.items[actual_x_final].items[actual_y_final].items[z_final] ^= D.items[actual_x_final].items[z_final];
                z_final += 1;
            }
            y_final += 1;
        }
        x_final += 1;
    }
}

pub fn RND(state_array: *StateArrayType, i: usize) !void {
    try theta(state_array);
    rho(state_array);
    pi(state_array);
    chi(state_array);
    try iota(state_array, i);
}

pub fn keccak(b: usize, n: usize, s: []u8) !std.ArrayList(u8) {
    const w: usize = b / 25;
    const l: usize = std.math.log2(w);
    var state_array: StateArrayType = StateArrayType.init(alloc);
    defer state_array.deinit();
    var row_state_array = std.ArrayList(std.ArrayList(u8)).init(alloc);
    defer row_state_array.deinit();
    var col_state_array = std.ArrayList(u8).init(alloc);
    defer col_state_array.deinit();
    try col_state_array.appendNTimes(0, w);
    while (row_state_array.items.len < 5) {
        try row_state_array.append(try clone(col_state_array));
    }
    while (state_array.items.len < 5) {
        var clone_row_state_arr = std.ArrayList(std.ArrayList(u8)).init(alloc);
        for (row_state_array.items) |val| {
            try clone_row_state_arr.append(try clone(val));
        }
        try state_array.append(clone_row_state_arr);
    }

    var x: usize = 0;
    while (x < 5) {
        const actual_x: usize = (x + 2) % 5;
        var y: usize = 0;
        while (y < 5) {
            const actual_y: usize = (y + 2) % 5;
            var z: usize = 0;
            while (z < w) {
                state_array.items[actual_x].items[actual_y].items[z] = s[w * (5 * y + x) + z];
                z += 1;
            }
            y += 1;
        }
        x += 1;
    }

    var ir: usize = (12 + 2 * l) - n;
    var stop: usize = (12 + 2 * l) - 1;
    while (ir <= stop) {
        try RND(&state_array, ir);
        ir += 1;
    }

    var S = std.ArrayList(u8).init(alloc);

    var y_s: usize = 0;
    while (y_s < 5) {
        var actual_y_s: usize = (y_s + 2) % 5;
        var x_s: usize = 0;
        while (x_s < 5) {
            var actual_x_s: usize = (x_s + 2) % 5;
            var z_s: usize = 0;
            while (z_s < w) {
                try S.append(state_array.items[actual_x_s].items[actual_y_s].items[z_s]);
                z_s += 1;
            }
            x_s += 1;
        }
        y_s += 1;
    }

    for (state_array.items) |row_state_arr| {
        for (row_state_arr.items) |col_state_arr| {
            col_state_arr.deinit();
        }
        row_state_arr.deinit();
    }
    return S;
}

pub fn sponge(
    f: fn (b: usize, n: usize, s: []u8) anyerror!std.ArrayList(u8),
    pad: fn (x: i32, m: i32) anyerror!std.ArrayList(u8),
    r: usize,
    n: []u8,
    d: usize,
    b: usize,
    num_rounds: usize,
) !std.ArrayList(u8) {
    var P = std.ArrayList(u8).init(alloc);
    defer P.deinit();
    try P.appendSlice(n);
    try P.appendSlice((try pad(@intCast(i32, r), @intCast(i32, n.len))).items);
    var lenpr: i32 = @divFloor(@intCast(i32, P.items.len), @intCast(i32, r));
    var c: usize = b - r;
    var S = std.ArrayList(u8).init(alloc);
    defer S.deinit();
    while (S.items.len < b) {
        try S.append(0);
    }
    var splitr = std.ArrayList(std.ArrayList(u8)).init(alloc);
    defer splitr.deinit();
    var section: usize = 0;
    while (section < lenpr) {
        var subP = std.ArrayList(u8).init(alloc);
        defer subP.deinit();
        var pidx: usize = 0;
        while (pidx < r) {
            try subP.append(P.items[pidx + (section * r)]);
            pidx += 1;
        }
        try subP.appendNTimes(0, c);
        try splitr.append(try clone(subP));
        section += 1;
    }
    var i: usize = 0;
    while (i < lenpr) {
        string_xor(&S, &splitr.items[i]);
        var new_S = try f(b, num_rounds, S.items);
        for (new_S.items) |val, index| {
            S.items[index] = val;
        }
        i += 1;
    }
    var Z = std.ArrayList(u8).init(alloc);
    defer Z.deinit();
    while (true) {
        var ri: usize = 0;
        while (ri < r) {
            try Z.append(S.items[ri]);
            ri += 1;
        }
        if (d <= Z.items.len) {
            var truncd = std.ArrayList(u8).init(alloc);
            var tdi: usize = 0;
            while (tdi < d) {
                try truncd.append(Z.items[tdi]);
                tdi += 1;
            }
            return truncd;
        }
        var new_S = try f(b, num_rounds, S.items);
        for (new_S.items) |val, index| {
            S.items[index] = val;
        }
    }
}

/// this function xor's string_one and string_two and keeps result in string_one
pub fn string_xor(string_one: *std.ArrayList(u8), string_two: *std.ArrayList(u8)) void {
    var index: usize = 0;
    while (index < string_one.items.len) {
        string_one.items[index] ^= string_two.items[index];
        index += 1;
    }
}

pub fn pad101(x: i32, m: i32) !std.ArrayList(u8) {
    var j: i32 = @mod(-m - 2, x);
    var P = std.ArrayList(u8).init(alloc);
    try P.append(1);
    while (P.items.len - 1 < j) {
        try P.append(0);
    }
    try P.append(1);
    return P;
}

pub fn clone(arr: std.ArrayList(u8)) !std.ArrayList(u8) {
    var new_arr = try std.ArrayList(u8).initCapacity(alloc, arr.capacity);
    new_arr.items.len = arr.items.len;
    std.mem.copy(u8, new_arr.items, arr.items);
    return new_arr;
}

pub fn convertToBitStr(arr: std.ArrayList(u8)) !std.ArrayList(u8) {
    var new_arr_rev = std.ArrayList(u8).init(alloc);
    defer new_arr_rev.deinit();
    if (arr.items.len > 0) {
        var idx_back: usize = 0;
        while (idx_back < arr.items.len) {
            var ascii_val = arr.items[arr.items.len - 1 - idx_back];
            var cnt: usize = 0;
            while (cnt < 8) {
                try new_arr_rev.append(ascii_val & 1);
                ascii_val >>= 1;
                cnt += 1;
            }
            idx_back += 1;
        }
    }
    var new_arr = std.ArrayList(u8).init(alloc);
    var idx: usize = 0;
    while (idx < new_arr_rev.items.len) {
        try new_arr.append(new_arr_rev.items[new_arr_rev.items.len - 1 - idx]);
        idx += 1;
    }
    return new_arr;
}

pub fn convertToHex(arr: std.ArrayList(u8)) !std.ArrayList(u8) {
    var str = std.ArrayList(u8).init(alloc);
    const len_per_char: usize = 4;
    var value: u8 = 0;
    var place: u8 = len_per_char - 1;
    for (arr.items) |val, index| {
        if (index % len_per_char == 0 and index > 0) {
            if (value >= 10) {
                std.debug.assert(value >= 10 and value < 16);
                try str.append(97 + (16 - value));
            } else {
                std.debug.assert(value >= 0 and value < 10);
                try str.append(48 + value);
            }
            value = 0;
            place = len_per_char - 1;
        }
        value += std.math.pow(u8, 2, place) * val;
        if ((index + 1) % len_per_char != 0) {
            place -= 1;
        }
    }
    if (value >= 10) {
        std.debug.assert(value >= 10 and value < 16);
        try str.append(97 + (16 - value));
    } else {
        std.debug.assert(value >= 0 and value < 10);
        try str.append(48 + value);
    }
    return str;
}

// KECCAK-f[b] = KECCAK-p[b,12+2l]
// KECCAK[c] = The KECCAK instance with KECCAK-f[1600] as the underlying permutation and capacity c.
// SHA3-224(M) = KECCAK[448](M||01, 224);
// SHA3-256(M)= KECCAK[512](M||01, 256);
// SHA3-384(M)= KECCAK[768](M||01, 384);
// SHA3-512(M)= KECCAK[1024](M||01, 512).
test "testing string_xor" {
    var string_one = std.ArrayList(u8).init(alloc);
    try string_one.appendNTimes(0, 4);
    var string_two = std.ArrayList(u8).init(alloc);
    try string_two.appendNTimes(0, 4);
    string_one.items[0] = 1;
    string_two.items[0] = 1;
    string_two.items[1] = 1;
    string_two.items[2] = 1;
    string_two.items[3] = 1;
    string_xor(&string_one, &string_two);
    try std.testing.expect(string_one.items[0] == 0);
    var index: usize = 1;
    while (index < 4) {
        try std.testing.expect(string_one.items[index] == 1);
        index += 1;
    }
}

test "testing pad101" {
    var pad101f = try pad101(2, 2);
    try std.testing.expect(pad101f.items.len == 2);
    var pad101s = try pad101(2, 3);
    try std.testing.expect(pad101s.items.len == 3);
}

test "testing rc" {
    var rconst: u8 = try rc(256);
    try std.testing.expect(rconst == 0);
}

test "testing convertToBitStr; input = 'hello'" {
    // 0110100001100101011011000110110001101111 - correct result
    const correct = [_]u8{ 0, 1, 1, 0, 1, 0, 0, 0, 0, 1, 1, 0, 0, 1, 0, 1, 0, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 0, 0, 0, 1, 1, 0, 1, 1, 1, 1 };
    const str = [_]u8{ 'h', 'e', 'l', 'l', 'o' };
    var arrl = std.ArrayList(u8).init(alloc);
    try arrl.appendSlice(str[0..]);
    var bitstr = try convertToBitStr(arrl);
    std.debug.print("\n", .{});
    for (bitstr.items) |val| {
        std.debug.print("{}", .{val});
    }
    std.debug.print("\n", .{});
    for (bitstr.items) |val, index| {
        try std.testing.expect(val == correct[index]);
    }
    try std.testing.expect(bitstr.items.len == 40);
}

test "testing convertToBitStr; input = 'jason'" {
    // 0110101001100001011100110110111101101110 - correct result
    const correct = [_]u8{ 0, 1, 1, 0, 1, 0, 1, 0, 0, 1, 1, 0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1, 1, 0 };
    const str = [_]u8{ 'j', 'a', 's', 'o', 'n' };
    var arrl = std.ArrayList(u8).init(alloc);
    try arrl.appendSlice(str[0..]);
    var bitstr = try convertToBitStr(arrl);
    std.debug.print("\n", .{});
    for (bitstr.items) |val| {
        std.debug.print("{}", .{val});
    }
    std.debug.print("\n", .{});
    for (bitstr.items) |val, index| {
        try std.testing.expect(val == correct[index]);
    }
    try std.testing.expect(bitstr.items.len == 40);
}
