const std = @import("std");

const allocator = std.heap.page_allocator;

const race_stats = struct { time_ms: u32, distance: u32 };

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

fn concatentate(x: u64, y: u64) u64 {
    var pow: u64 = 10;
    while (y >= pow) {
        pow *= 10;
    }

    return x * pow + y;
}

pub fn main() !void {
    const lines = try read_input_file();

    // First half of the puzzle

    var sum: u32 = 1;

    var all_races = std.ArrayList(race_stats).init(allocator);
    var time_split = std.mem.split(u8, lines.items[0], " ");
    _ = time_split.next();

    while (time_split.next()) |str| {
        if (str.len == 0) continue;

        var value = try std.fmt.parseInt(u32, str, 10);
        try all_races.append(.{ .time_ms = value, .distance = 0 });
    }

    var distance_split = std.mem.split(u8, lines.items[1], " ");
    _ = distance_split.next();

    var i: u32 = 0;
    while (distance_split.next()) |str| {
        if (str.len == 0) continue;

        var value = try std.fmt.parseInt(u32, str, 10);
        all_races.items[i].distance = value;
        i += 1;
    }

    for (all_races.items) |race| {
        var hold_time: u32 = 1;
        var beat_count: u32 = 0;
        while (hold_time < race.time_ms) : (hold_time += 1) {
            var distance: u32 = hold_time * (race.time_ms - hold_time);
            if (distance > race.distance) beat_count += 1;
        }

        sum *= beat_count;
    }

    // std.debug.print("all races: {}\n", .{all_races});

    std.debug.print("first half total: {}\n", .{sum});

    // Second half of the puzzle

    var time: u64 = 0;
    var distance: u64 = 0;
    for (all_races.items) |race| {
        time = concatentate(time, race.time_ms);
        distance = concatentate(distance, race.distance);
    }

    // std.debug.print("time: {}, distance {}\n", .{ time, distance });

    const half_point: u64 = @divFloor(time, 2);
    var search_value: u64 = half_point;

    while (search_value * (time - search_value) > distance) {
        search_value -= 1;
    }

    var count: u64 = 0;
    if (time % 2 == 0) {
        count = (half_point - search_value) * 2 - 1;
    } else {
        count = (half_point - search_value) * 2;
    }

    std.debug.print("second half total: {}\n", .{count});
}
