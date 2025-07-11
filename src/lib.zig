const std = @import("std");
const Allocator = std.mem.Allocator;

pub const version = "0.1.0";

pub fn Array(comptime T: type) type {
    return struct {
        const Self = @This();

        data: []T,
        shape: []usize,
        allocator: Allocator,

        pub fn init(allocator: Allocator, shape: []const usize) !Self {
            var total_size: usize = 1;
            for (shape) |dim| {
                total_size *= dim;
            }

            const data = try allocator.alloc(T, total_size);
            for (data) |*item| {
                item.* = 0;
            }

            const shape_copy = try allocator.alloc(usize, shape.len);
            @memcpy(shape_copy, shape);

            return Self{
                .data = data,
                .shape = shape_copy,
                .allocator = allocator,
            };
        }

        pub fn set_row(self: *Self, row: usize, values: anytype) void {
            const cols = self.shape[1];
            if (values.len != cols) {
                std.debug.panic("Row values length {} doesn't match columns {}\n", .{ values.len, cols });
            }

            const start_idx = row * cols;
            inline for (values, 0..) |value, i| {
                self.data[start_idx + i] = switch (@TypeOf(value)) {
                    comptime_int => @as(T, @floatFromInt(value)),
                    comptime_float => @as(T, value),
                    else => @as(T, value),
                };
            }
        }

        pub fn deinit(self: *Self) void {
            self.allocator.free(self.data);
            self.allocator.free(self.shape);
        }

        // Get element at multi-dimensional index
        pub fn get(self: Self, indices: []const usize) T {
            if (self.shape.len != 2) {
                std.debug.panic("Only 2D arrays supported for now\n", .{});
            }
            const row = indices[0];
            const col = indices[1];
            const flat_index = row * self.shape[1] + col;
            return self.data[flat_index];
        }

        pub fn print_matrix(self: Self) void {
            if (self.shape.len != 2) {
                std.debug.print("Can only print 2D matrices\n", .{});
                return;
            }

            const rows = self.shape[0];
            const cols = self.shape[1];

            for (0..rows) |row| {
                std.debug.print("[\n", .{});
                for (0..cols) |col| {
                    if (col > 0) std.debug.print(", \n", .{});
                    const indices = [_]usize{ row, col };
                    std.debug.print("{:6.1}", .{self.get(&indices)});
                }
                std.debug.print("]\n", .{});
            }
        }

        // Set element at multi-dimensional index
        pub fn set(self: *Self, indices: []const usize, value: T) void {
            var flat_index: usize = 0;
            for (indices, 0..) |idx, dim| {
                flat_index += idx * self.strides[dim];
            }
            self.data[flat_index] = value;
        }
    };
}
