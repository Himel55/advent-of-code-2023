const std = @import("std");

const allocator = std.heap.page_allocator;

const node = []const u8;
const node_entry = struct { left: node, right: node };

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

    var instructions = lines.items[0];
    var network_map = std.StringHashMap(node_entry).init(allocator);

    for (lines.items[2..]) |line| {
        const k_node: node = line[0..3];
        const vl_node: node = line[7..10];
        const vr_node: node = line[12..15];

        try network_map.put(k_node, .{ .left = vl_node, .right = vr_node });
    }

    // std.debug.print("instructions: {s}\n network map: {}\n", .{ instructions, network_map });

    var current_node: node = "AAA";
    var current_instruction: u64 = 0;
    var step_count: u64 = 0;

    while (!std.mem.eql(u8, current_node, "ZZZ")) : (current_instruction = (current_instruction + 1) % instructions.len) {
        // std.debug.print("start node: {s} ", .{current_node});
        const value_node_entry = network_map.get(current_node).?;
        current_node = if (instructions[current_instruction] == 'L') value_node_entry.left else value_node_entry.right;
        step_count += 1;

        // std.debug.print("instruction: {c} new node: {s}\n", .{ instructions[current_instruction], current_node });
    }

    std.debug.print("first half total: {}\n", .{step_count});

    // Second half of the puzzle

    for (lines.items) |line| {
        _ = line;
    }

    const sum: u8 = 0;

    std.debug.print("second half total: {}\n", .{sum});
}
