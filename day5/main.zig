const std = @import("std");

const allocator = std.heap.page_allocator;

const map_entry = struct { dest_start: u64, src_start: u64, range: u64 };

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

fn map_entry_cmp(context: void, a: map_entry, b: map_entry) bool {
    _ = context;
    if (a.src_start < b.src_start) {
        return true;
    }

    return false;
}

fn create_map(lines_input: [][]const u8, line_num: *usize) !std.ArrayList(map_entry) {
    var map = std.ArrayList(map_entry).init(allocator);

    while (line_num.* < lines_input.len and lines_input[line_num.*].len != 0) : (line_num.* += 1) {
        var map_entry_split = std.mem.split(u8, lines_input[line_num.*], " ");
        var dest_start = try std.fmt.parseInt(u64, map_entry_split.next().?, 10);
        var src_start = try std.fmt.parseInt(u64, map_entry_split.next().?, 10);
        var range = try std.fmt.parseInt(u64, map_entry_split.next().?, 10);
        try map.append(.{ .dest_start = dest_start, .src_start = src_start, .range = range });
    }

    std.mem.sort(map_entry, map.items, {}, map_entry_cmp);

    return map;
}

pub fn main() !void {
    const lines = (try read_input_file()).items;

    // First half of the puzzle

    var line_num: usize = 0;

    var seeds_split = std.mem.split(u8, lines[line_num][7..], " ");
    var seeds = std.ArrayList(u64).init(allocator);
    while (seeds_split.next()) |value_str| {
        const value = try std.fmt.parseInt(u64, value_str, 10);
        try seeds.append(value);
    }

    // std.debug.print("{any}\n", .{seeds});

    line_num = 3;

    var map_list = std.ArrayList(std.ArrayList(map_entry)).init(allocator);
    var seed_to_soil_map = try create_map(lines, &line_num);
    try map_list.append(seed_to_soil_map);
    line_num += 2;
    var soil_to_fertilizer_map = try create_map(lines, &line_num);
    try map_list.append(soil_to_fertilizer_map);
    line_num += 2;
    var fertilizer_to_water_map = try create_map(lines, &line_num);
    try map_list.append(fertilizer_to_water_map);
    line_num += 2;
    var water_to_light_map = try create_map(lines, &line_num);
    try map_list.append(water_to_light_map);
    line_num += 2;
    var light_to_temperature_map = try create_map(lines, &line_num);
    try map_list.append(light_to_temperature_map);
    line_num += 2;
    var temperature_to_humidity_map = try create_map(lines, &line_num);
    try map_list.append(temperature_to_humidity_map);
    line_num += 2;
    var humidity_to_location_map = try create_map(lines, &line_num);
    try map_list.append(humidity_to_location_map);

    // std.debug.print("{any}\n", .{humidity_to_location_map});

    var lowest_location: u64 = std.math.maxInt(u64);

    for (seeds.items) |seed| {
        var current_key = seed;
        for (map_list.items) |map| {
            for (map.items) |entry| {
                if (current_key < entry.src_start) {
                    break;
                } else if (current_key >= entry.src_start and current_key < entry.src_start + entry.range) {
                    current_key = entry.dest_start + (current_key - entry.src_start);
                    break;
                }
            }
        }

        if (current_key < lowest_location) {
            lowest_location = current_key;
        }
    }

    std.debug.print("first half lowest location: {}\n", .{lowest_location});

    // Second half of the puzzle

    std.debug.print("second half lowest location: {}\n", .{lowest_location});
}
