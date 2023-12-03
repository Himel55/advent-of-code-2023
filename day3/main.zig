const std = @import("std");

const allocator = std.heap.page_allocator;

const COL_ROW_END: u8 = 139;

fn read_input_file() !std.ArrayList([]const u8) {
    const file = try std.fs.cwd().openFile("input.txt", .{ .mode = .read_only });
    defer file.close();

    var lines = std.ArrayList([]const u8).init(allocator);

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    while (try in_stream.readUntilDelimiterOrEofAlloc(allocator, '\n', 1000)) |line| {
        try lines.append(line);
    }

    return lines;
}

fn check_surrounding_for_special_char(row: usize, col: usize, len: usize, map: std.ArrayList([]const u8)) bool {
    const left_side: usize = if (col == 0) 0 else col - 1;
    const right_side: usize = if (col + len >= COL_ROW_END) COL_ROW_END else col + len;

    const left_char = map.items[row][left_side];
    if (!std.ascii.isDigit(left_char) and left_char != '.') {
        return true;
    }

    const right_char = map.items[row][right_side];
    if (!std.ascii.isDigit(right_char) and right_char != '.') {
        return true;
    }

    if (row != 0) {
        const row_above = row - 1;
        for (map.items[row_above][left_side .. right_side + 1]) |char| {
            if (!std.ascii.isDigit(char) and char != '.') {
                return true;
            }
        }
    }

    if (row != COL_ROW_END) {
        const row_below = row + 1;
        for (map.items[row_below][left_side .. right_side + 1]) |char| {
            if (!std.ascii.isDigit(char) and char != '.') {
                return true;
            }
        }
    }

    return false;
}

pub fn main() !void {
    const lines = try read_input_file();

    // First half of the puzzle

    var sum: u32 = 0;

    for (lines.items, 0..) |line, row_index| {
        var num_start: ?usize = null;

        for (line, 0..) |char, col_index| {
            if (std.ascii.isDigit(char) and num_start == null) {
                num_start = col_index;
            } else if (!std.ascii.isDigit(char) and num_start != null) {
                const parsed_int = try std.fmt.parseInt(u16, line[num_start.?..col_index], 10);
                const valid = check_surrounding_for_special_char(row_index, num_start.?, col_index - num_start.?, lines);
                // std.debug.print("int: {} valid: {}\n", .{ parsed_int, valid });
                if (valid) sum += parsed_int;
                num_start = null;
            } else if (col_index == COL_ROW_END and num_start != null) {
                const parsed_int = try std.fmt.parseInt(u16, line[num_start.? .. col_index + 1], 10);
                const valid = check_surrounding_for_special_char(row_index, num_start.?, col_index + 1 - num_start.?, lines);
                // std.debug.print("int: {} valid: {}\n", .{ parsed_int, valid });
                if (valid) sum += parsed_int;
            }
        }
    }

    std.debug.print("first half total: {}\n", .{sum});
}
