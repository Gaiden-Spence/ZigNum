const std = @import("std");
const zn = @import("lib.zig");
const print = std.debug.print;
const Allocator = std.mem.Allocator;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    print("\n=== METHOD 5: Set rows with mixed types ===\n", .{});
    var matrix5 = try zn.Array(f64).init(allocator, &[_]usize{ 3, 3 });
    defer matrix5.deinit();

    matrix5.set_row(0, .{ 1, 2.2, 4 }); // int + float
    matrix5.set_row(1, .{ 3.3, 4, 7 }); // float + int
    matrix5.set_row(2, .{ 5, 6.6, 9 }); // int + float

    matrix5.scalar(2.5);
    matrix5.print_matrix();
}
