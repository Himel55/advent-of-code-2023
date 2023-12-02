const std = @import("std");

const allocator = std.heap.page_allocator;

const number_string = [_][]const u8{ "one", "two", "three", "four", "five", "six", "seven", "eight", "nine" };

fn read_input_file() !std.ArrayList([]const u8) {
    const file = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    defer file.close();

    var lines = std.ArrayList([]const u8).init(allocator);

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    while (try in_stream.readUntilDelimiterOrEofAlloc(allocator, '\n', 100)) |line| {
        try lines.append(line);
    }

    return lines;
}

pub fn main() !void {
    const lines = try read_input_file();

    // First half of the puzzle

    var sum: u32 = 0;

    for (lines.items) |line| {
        var first_digit: ?u8 = null;
        var second_digit: ?u8 = null;

        for (line) |char| {
            if (first_digit == null) {
                if (std.ascii.isDigit(char)) {
                    first_digit = char - '0';
                }
            } else {
                if (std.ascii.isDigit(char)) {
                    second_digit = char - '0';
                }
            }
        }

        sum += first_digit.? * 10 + (second_digit orelse first_digit.?);
    }

    std.debug.print("first half total: {}\n", .{sum});

    // Second half of the puzzle

    sum = 0;

    for (lines.items) |line| {
        var first_digit: ?u8 = null;
        var second_digit: ?u8 = null;

        // std.debug.print("line input: {s}\n", .{line});
        for (line, 0..) |char, index| {
            if (first_digit == null) {
                if (std.ascii.isDigit(char)) {
                    first_digit = char - '0';
                    // std.debug.print("first: {}\n", .{first_digit.?});
                } else {
                    for (number_string, 0..) |cmp_str, num| {
                        if (std.mem.eql(u8, cmp_str, line[index .. index + @min(cmp_str.len, line.len - index)])) {
                            first_digit = @truncate(num + 1);
                            // std.debug.print("first letter: {s} value: {}\n", .{ cmp_str, first_digit.? });
                            break;
                        }
                    }
                }
            } else {
                if (std.ascii.isDigit(char)) {
                    second_digit = char - '0';
                    // std.debug.print("second: {}\n", .{second_digit.?});
                } else {
                    for (number_string, 0..) |cmp_str, num| {
                        if (std.mem.eql(u8, cmp_str, line[index .. index + @min(cmp_str.len, line.len - index)])) {
                            second_digit = @truncate(num + 1);
                            // std.debug.print("second letter: {s} value: {}\n", .{ cmp_str, second_digit.? });
                            break;
                        }
                    }
                }
            }
        }

        // std.debug.print("\n\n", .{});
        sum += first_digit.? * 10 + (second_digit orelse first_digit.?);
    }

    std.debug.print("second half total: {}\n", .{sum});
}
