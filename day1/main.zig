const std = @import("std");

const allocator = std.heap.page_allocator;

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

    var sum: u32 = 0;

    for (lines.items) |line| {
        var first_char: ?u8 = null;
        var second_char: ?u8 = null;

        for (line) |char| {
            if (char >= '0' and char <= '9' and first_char == null) {
                first_char = char;
            } else if (char >= '0' and char <= '9') {
                second_char = char;
            }
        }

        const first_value: u16 = first_char.? - '0';
        const second_value: u16 = (second_char orelse first_char.?) - '0';
        sum += first_value * 10 + second_value;
    }

    std.debug.print("first half total: {any}\n", .{sum});
}
