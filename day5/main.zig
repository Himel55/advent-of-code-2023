const std = @import("std");

const allocator = std.heap.page_allocator;

const map_entry = struct { dest_start: u64, src_start: u64, range: u64 };
const value_range = struct { start: u64, range: u64 };

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

fn value_range_cmp(context: void, a: value_range, b: value_range) bool {
    _ = context;
    if (a.start < b.start) {
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

    // ATTENTION: SORRY this solution is not very easy to follow and probably isn't good,
    // However, it isn't the bruteforce approach

    line_num = 0;

    seeds_split = std.mem.split(u8, lines[line_num][7..], " ");
    var entries = std.ArrayList(value_range).init(allocator);
    while (seeds_split.next()) |value_str| {
        const start = try std.fmt.parseInt(u64, value_str, 10);
        const range = try std.fmt.parseInt(u64, seeds_split.next().?, 10);
        try entries.append(.{ .start = start, .range = range - 1 });
    }

    // std.debug.print("{}\n", .{entries});

    line_num = 3;

    map_list = std.ArrayList(std.ArrayList(map_entry)).init(allocator);
    seed_to_soil_map = try create_map(lines, &line_num);
    try map_list.append(seed_to_soil_map);
    line_num += 2;
    soil_to_fertilizer_map = try create_map(lines, &line_num);
    try map_list.append(soil_to_fertilizer_map);
    line_num += 2;
    fertilizer_to_water_map = try create_map(lines, &line_num);
    try map_list.append(fertilizer_to_water_map);
    line_num += 2;
    water_to_light_map = try create_map(lines, &line_num);
    try map_list.append(water_to_light_map);
    line_num += 2;
    light_to_temperature_map = try create_map(lines, &line_num);
    try map_list.append(light_to_temperature_map);
    line_num += 2;
    temperature_to_humidity_map = try create_map(lines, &line_num);
    try map_list.append(temperature_to_humidity_map);
    line_num += 2;
    humidity_to_location_map = try create_map(lines, &line_num);
    try map_list.append(humidity_to_location_map);

    // std.debug.print("{any}\n", .{humidity_to_location_map});

    lowest_location = std.math.maxInt(u64);

    var current_entries = entries;
    for (map_list.items) |map| {
        // std.debug.print("new map!\n", .{});
        var new_entries = std.ArrayList(value_range).init(allocator);
        for (current_entries.items, 0..) |const_entry, entry_idx| {
            _ = entry_idx;
            var entry = const_entry;
            for (map.items) |map_value| {
                // std.debug.print("entry[{}]: {} map: {}\n", .{ entry_idx, entry, map_value });
                if (entry.start + entry.range < map_value.src_start) {
                    try new_entries.append(.{ .start = entry.start, .range = entry.range });
                    entry.range = 0;
                    break;
                } else if (entry.start >= map_value.src_start + map_value.range) {
                    continue;
                } else {
                    if (entry.start < map_value.src_start) {
                        // 5 6 7 8 | 9 10
                        // 5, 5 -> 5, 3  -> 9 - 5 + 1 = 3
                        // std.debug.print("entry start {} map value start {}\n", .{ entry.start, map_value.src_start });
                        var offset: u64 = map_value.src_start - entry.start - 1;
                        try new_entries.append(.{ .start = entry.start, .range = offset });
                        // std.debug.print("new entry (outside start) start = {}: range = {}\n", .{ entry.start, offset });
                        entry.start = map_value.src_start;
                        entry.range = entry.range - offset;
                    }

                    var start: u64 = map_value.dest_start + (entry.start - map_value.src_start);
                    var range: u64 =
                        if (entry.start + entry.range >= map_value.src_start + map_value.range)
                        //    6  7  8  9  10 11
                        // 20 21 22 23 24 25
                        // 20,5,6 -> 5 + 6 - 1 - 5 = 5 -> 5 + 6 - 1 - 6 = 4
                        map_value.src_start + (map_value.range - 1) - entry.start
                    else
                        // 5  6  7  8  9
                        // 20 21 22 23 24 25
                        // 20,5,6 ->
                        entry.range;

                    try new_entries.append(.{ .start = start, .range = range });
                    // std.debug.print("new entry (inside) start = {}: range = {}\n", .{ start, range });

                    if (entry.start + entry.range >= map_value.src_start + map_value.range) {
                        entry.start = map_value.src_start + map_value.range;
                        entry.range = entry.range - range - 1;
                    } else {
                        entry.range = 0;
                        break;
                    }
                }
            }

            if (entry.range != 0) {
                try new_entries.append(.{ .start = entry.start, .range = entry.range });
                // std.debug.print("new entry (outside above) start = {}: range = {}\n", .{ entry.start, entry.range });
            }
        }

        current_entries = new_entries;

        // std.debug.print("new entries {}\n", .{current_entries});
    }

    // std.debug.print("{}\n", .{current_entries});
    std.mem.sort(value_range, current_entries.items, {}, value_range_cmp);
    lowest_location = current_entries.items[0].start;

    std.debug.print("second half lowest location: {}\n", .{lowest_location});
}
