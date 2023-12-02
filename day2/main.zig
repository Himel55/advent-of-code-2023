const std = @import("std");

const allocator = std.heap.page_allocator;

const RED_LIMIT: u8 = 12;
const GREEN_LIMIT: u8 = 13;
const BLUE_LIMIT: u8 = 14;

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

    var sum: u32 = 0;

    for (lines.items) |line| {
        var is_possible = true;
        var header_body_split = std.mem.split(u8, line, ":");
        const game_id = try std.fmt.parseInt(u8, header_body_split.next().?[5..], 10);
        // std.debug.print("Game ID: {}\n", .{game_id});

        var record_split = std.mem.split(u8, header_body_split.next().?, ";");

        while (record_split.next()) |record| {
            // std.debug.print("record: {s}\n", .{record});
            var cubes_split = std.mem.split(u8, record, ",");
            while (cubes_split.next()) |cube| {
                var num_colour_split = std.mem.split(u8, cube, " ");
                // remove first space which is empty
                _ = num_colour_split.next().?;
                const cube_value = try std.fmt.parseInt(u8, num_colour_split.next().?, 10);
                const cube_colour = num_colour_split.next().?;
                // std.debug.print("colour, value: {s} {}\n", .{ cube_colour, cube_value });

                if ((std.mem.eql(u8, "red", cube_colour) and cube_value > RED_LIMIT) or
                    (std.mem.eql(u8, "green", cube_colour) and cube_value > GREEN_LIMIT) or
                    (std.mem.eql(u8, "blue", cube_colour) and cube_value > BLUE_LIMIT))
                {
                    // std.debug.print("record not possible: {s}\n", .{record});
                    is_possible = false;
                    break;
                }
            }

            if (!is_possible) {
                break;
            }
        }

        // std.debug.print("\n\n", .{});

        if (is_possible) {
            sum += game_id;
        }
    }

    std.debug.print("first half total: {}\n", .{sum});
}
