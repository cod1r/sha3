//! Keep track of where you place 'defer <array list>.deinit()' 
//! because that might mess up the result that you get.
const std = @import("std");
var gpa = std.heap.GeneralPurposeAllocator(.{ .safety = true }){};
var alloc = gpa.allocator();
const StateArrayType = std.ArrayList(std.ArrayList(std.ArrayList(u8)));

fn index(i: usize) usize {
    return (i + 2) % 5;
}

fn theta(state_array: StateArrayType) !void {
    const w: usize = state_array.items[0].items[0].items.len;
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

    {
        var x: usize = 0;
        while (x < 5) {
            var z: usize = 0;
            while (z < w) {
                var first = state_array.items[index(x)].items[0].items[z];
                var second = state_array.items[index(x)].items[1].items[z];
                var third = state_array.items[index(x)].items[2].items[z];
                var fourth = state_array.items[index(x)].items[3].items[z];
                var fifth = state_array.items[index(x)].items[4].items[z];
                C.items[index(x)].items[z] = first ^ second ^ third ^ fourth ^ fifth;
                z += 1;
            }
            x += 1;
        }
    }

    {
        var x: usize = 0;
        while (x < 5) {
            var z: usize = 0;
            while (z < w) {
                var mod_x = @mod(@intCast(i32, index(x)) - 1, 5);
                var mod_x_casted = @intCast(usize, mod_x);
                var first: u8 = C.items[mod_x_casted].items[z];
                var mod_z = @mod(@intCast(i32, z) - 1, 5);
                var mod_z_casted = @intCast(usize, mod_z);
                var second: u8 = C.items[(index(x) + 1) % 5].items[mod_z_casted];
                D.items[index(x)].items[z] = first ^ second;
                z += 1;
            }
            x += 1;
        }
    }

    {
        var x: usize = 0;
        while (x < 5) {
            var y: usize = 0;
            while (y < 5) {
                var z: usize = 0;
                while (z < w) {
                    state_array.items[index(x)].items[index(y)].items[z] ^= D.items[index(x)].items[z];
                    z += 1;
                }
                y += 1;
            }
            x += 1;
        }
    }
}

fn rho(state_array: StateArrayType) void {
    const w: usize = state_array.items[0].items[0].items.len;
    var x: usize = 1;
    var y: usize = 0;
    var t: usize = 0;
    while (t <= 23) {
        var z: usize = 0;
        while (z < w) {
            var t_sqrd: i32 = @divFloor(
                (@intCast(i32, t) + 1) * (@intCast(i32, t) + 2),
                2,
            );
            var modified_z: usize = @intCast(
                usize,
                @mod(
                    @intCast(i32, z) - t_sqrd,
                    @intCast(i32, w),
                ),
            );
            state_array.items[index(x)].items[index(y)].items[z] =
                state_array.items[index(x)].items[index(y)].items[modified_z];
            z += 1;
        }
        var temp: usize = x;
        x = y;
        y = (2 * temp + 3 * y) % 5;
        t += 1;
    }
}

fn pi(state_array: StateArrayType) void {
    const w: usize = state_array.items[0].items[0].items.len;
    var x: usize = 0;
    while (x < 5) {
        var y: usize = 0;
        while (y < 5) {
            var z: usize = 0;
            while (z < w) {
                state_array.items[index(x)].items[index(y)].items[z] =
                    state_array.items[(index(x) + (3 * index(y))) % 5].items[index(x)].items[z];
                z += 1;
            }
            y += 1;
        }
        x += 1;
    }
}

fn chi(state_array: StateArrayType) void {
    const w: usize = state_array.items[0].items[0].items.len;
    var x: usize = 0;
    while (x < 5) {
        var y: usize = 0;
        while (y < 5) {
            var z: usize = 0;
            while (z < w) {
                const first: u8 = state_array.items[(index(x) + 1) % 5].items[index(y)].items[z] ^ 1;
                const second: u8 = state_array.items[(index(x) + 2) % 5].items[index(y)].items[z];
                state_array.items[index(x)].items[index(y)].items[z] ^= (first & second);
                z += 1;
            }
            y += 1;
        }
        x += 1;
    }
}

fn rc(t: usize) !u8 {
    const tmod: usize = t % 255;
    if (tmod == 0) {
        return 1;
    }
    var R = std.ArrayList(u8).init(alloc);
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

fn iota(state_array: StateArrayType, i: usize) !void {
    const w: usize = state_array.items[0].items[0].items.len;
    var RC = std.ArrayList(u8).init(alloc);
    defer RC.deinit();
    try RC.appendNTimes(0, w);
    const l: usize = std.math.log2(w);
    var j: usize = 0;
    while (j <= l) {
        RC.items[std.math.pow(usize, 2, j) - 1] = try rc(j + 7 * i);
        j += 1;
    }
    var z: usize = 0;
    while (z < w) {
        state_array.items[index(0)].items[index(0)].items[z] ^= RC.items[z];
        z += 1;
    }
}

fn RND(state_array: StateArrayType, i: usize) !void {
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

    {
        // converting input to state array
        var x: usize = 0;
        while (x < 5) {
            var y: usize = 0;
            while (y < 5) {
                var z: usize = 0;
                while (z < w) {
                    state_array.items[index(x)].items[index(y)].items[z] = s[w * (5 * (index(y)) + (index(x))) + z];
                    z += 1;
                }
                y += 1;
            }
            x += 1;
        }
    }

    var ir: usize = (12 + 2 * l) - n;
    var stop: usize = (12 + 2 * l) - 1;
    while (ir <= stop) {
        try RND(state_array, ir);
        ir += 1;
    }

    var S = std.ArrayList(u8).init(alloc);
    {
        // converting state array to string output
        var y: usize = 0;
        while (y < 5) {
            var x: usize = 0;
            while (x < 5) {
                var z: usize = 0;
                while (z < w) {
                    std.debug.assert(state_array.items[index(x)].items[index(y)].items[z] <= 1);
                    try S.append(state_array.items[index(x)].items[index(y)].items[z]);
                    z += 1;
                }
                x += 1;
            }
            y += 1;
        }
    }

    for (state_array.items) |row_state_arr| {
        for (row_state_arr.items) |col_state_arr| {
            col_state_arr.deinit();
        }
        row_state_arr.deinit();
    }
    std.debug.assert(S.items.len == b);
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
    try S.appendNTimes(0, b);

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
        try splitr.append(try clone(subP));
        section += 1;
    }

    var i: usize = 0;
    while (i < lenpr) {
        var concat_zero = try clone(splitr.items[i]);
        defer concat_zero.deinit();
        try concat_zero.appendNTimes(0, c);
        std.debug.assert(concat_zero.items.len == 1600);
        string_xor(&S, &concat_zero);
        var new_S = try f(b, num_rounds, S.items);
        for (new_S.items) |val, idx| {
            S.items[idx] = val;
        }
        i += 1;
    }

    var Z = std.ArrayList(u8).init(alloc);
    defer Z.deinit();
    while (true) {
        try Z.appendSlice(S.items[0..r]);
        if (d <= Z.items.len) {
            var truncd = std.ArrayList(u8).init(alloc);
            try truncd.appendSlice(Z.items[0..d]);
            for (splitr.items) |subP| {
                subP.deinit();
            }
            return truncd;
        }
        var new_S = try f(b, num_rounds, S.items);
        defer new_S.deinit();
        for (new_S.items) |val, idx| {
            S.items[idx] = val;
        }
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

/// this function xor's string_one and string_two and keeps result in string_one
pub fn string_xor(string_one: *std.ArrayList(u8), string_two: *std.ArrayList(u8)) void {
    var idx: usize = 0;
    while (idx < string_one.items.len) {
        string_one.items[idx] ^= string_two.items[idx];
        idx += 1;
    }
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

pub fn convertToHexFromBin(arr: std.ArrayList(u8)) !std.ArrayList(u8) {
    var str = std.ArrayList(u8).init(alloc);
    const len_per_char: usize = 4;
    var value: u8 = 0;
    var place: u8 = len_per_char - 1;
    for (arr.items) |val, idx| {
        if (idx % len_per_char == 0 and idx > 0) {
            if (value >= 10) {
                std.debug.assert(value >= 10 and value < 16);
                try str.append(97 + (value - 10));
            } else {
                std.debug.assert(value >= 0 and value < 10);
                try str.append(48 + value);
            }
            value = 0;
            place = len_per_char - 1;
        }
        value += std.math.pow(u8, 2, place) * val;
        if ((idx + 1) % len_per_char != 0) {
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

fn print(arr: std.ArrayList(u8)) void {
    std.debug.print("\n", .{});
    for (arr.items) |val| {
        std.debug.print("{} ", .{val});
    }
    std.debug.print("\n", .{});
}

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
    var idx: usize = 1;
    while (idx < 4) {
        try std.testing.expect(string_one.items[idx] == 1);
        idx += 1;
    }
}

test "testing convertToHexFromBin; abcd" {
    var alpha = [_]u8{ 10, 11, 12, 13 };
    var alphaAL = std.ArrayList(u8).init(alloc);
    try alphaAL.appendSlice(alpha[0..]);
    var bs = try convertToBitStr(alphaAL);
    std.debug.print("\n", .{});
    for (bs.items) |val| {
        std.debug.print("{c}", .{val + 48});
    }
    var hs = try convertToHexFromBin(bs);
    std.debug.print("\n{s}\n", .{hs.items});
}
