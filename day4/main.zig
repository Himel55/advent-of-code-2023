const std = @import("std");

const allocator = std.heap.page_allocator;

const WINNING_NUM_LEN: u8 = 10;
const NUM_LEN: u8 = 25;

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

pub fn main() !void {
    const lines = try read_input_file();

    // First half of the puzzle

    var sum: u32 = 0;

    for (lines.items) |line| {
        var header_body_split = std.mem.split(u8, line, ":");
        _ = header_body_split.next().?;

        var entry_split = std.mem.split(u8, header_body_split.next().?, "|");

        var winnings_split = std.mem.split(u8, entry_split.next().?, " ");
        var winnings: [WINNING_NUM_LEN]u8 = undefined;
        var count: usize = 0;

        while (winnings_split.next()) |value| {
            if (value.len == 0) continue;
            winnings[count] = try std.fmt.parseInt(u8, value, 10);
            count += 1;
        }

        // std.debug.print("winnings: {any}\n", .{winnings});

        var numbers_split = std.mem.split(u8, entry_split.next().?, " ");
        var numbers: [NUM_LEN]u8 = undefined;
        count = 0;

        while (numbers_split.next()) |value| {
            if (value.len == 0) continue;
            numbers[count] = try std.fmt.parseInt(u8, value, 10);
            count += 1;
        }

        // std.debug.print("numbers: {any}\n", .{numbers});

        var match_count: u32 = 0;

        for (winnings) |win_num| {
            for (numbers) |num| {
                if (win_num == num) match_count += 1;
            }
        }

        if (match_count != 0) {
            sum += std.math.pow(u32, 2, (match_count - 1));
        }
    }

    std.debug.print("first half total: {}\n", .{sum});
}
