const std = @import("std");
const print = std.debug.print;
const expect = std.testing.expect;
const heap = std.heap;
const mem = std.mem;

pub fn main() !void {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    var arena = heap.ArenaAllocator.init(&gpa.allocator);
    defer arena.deinit();

    var s = [_]u8{ 5, 3, 6, 2, 10 };

    print("{d}\n", .{try quicksort(&arena.allocator, &s)});
}

fn quicksort(allocator: *mem.Allocator, s: []const u8) anyerror![]const u8 {
    if (s.len < 2) {
        return s;
    }

    var lower = std.ArrayList(u8).init(allocator);
    var higher = std.ArrayList(u8).init(allocator);

    const pivot = s[0];
    for (s[1..]) |item| {
        if (item <= pivot) {
            try lower.append(item);
        } else {
            try higher.append(item);
        }
    }

    var low = try quicksort(allocator, lower.items);
    var high = try quicksort(allocator, higher.items);

    var res = std.ArrayList(u8).init(allocator);
    try res.appendSlice(low);
    try res.append(pivot);
    try res.appendSlice(high);

    return res.items;
}

test "quicksort" {
    var gpa = heap.GeneralPurposeAllocator(.{}){};
    var arena = heap.ArenaAllocator.init(&gpa.allocator);
    defer arena.deinit();

    const tests = [_]struct {
        s: []const u8,
        exp: []const u8,
    }{
        .{
            .s = &[_]u8{},
            .exp = &[_]u8{},
        },
        .{
            .s = &[_]u8{42},
            .exp = &[_]u8{42},
        },
        .{
            .s = &[_]u8{ 3, 2, 1 },
            .exp = &[_]u8{ 1, 2, 3 },
        },
    };

    for (tests) |t| {
        var res = try quicksort(&arena.allocator, t.s);
        expect(res.len == t.exp.len);
        for (res) |e, i|
            expect(e == t.exp[i]);
    }
}
