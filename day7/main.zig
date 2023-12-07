const std = @import("std");

const allocator = std.heap.page_allocator;

const hand_bid = struct { hand: []const u8, bid: u16 };

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

fn get_value(str: u8) u8 {
    if (str == 'T') {
        return 10;
    } else if (str == 'J') {
        return 11;
    } else if (str == 'Q') {
        return 12;
    } else if (str == 'K') {
        return 13;
    } else if (str == 'A') {
        return 14;
    }

    return str - '0';
}

fn hand_cmp(context: void, a: hand_bid, b: hand_bid) bool {
    _ = context;
    var i: u8 = 0;
    while (i < 5) : (i += 1) {
        var a_value = get_value(a.hand[i]);
        var b_value = get_value(b.hand[i]);

        if (a_value == b_value) {
            continue;
        } else if (a_value < b_value) {
            return true;
        } else {
            return false;
        }
    }

    std.debug.panic("hand compare failed!", .{});
    return false;
}

fn get_value_part_two(str: u8) u8 {
    if (str == 'T') {
        return 10;
    } else if (str == 'J') {
        return 1;
    } else if (str == 'Q') {
        return 12;
    } else if (str == 'K') {
        return 13;
    } else if (str == 'A') {
        return 14;
    }

    return str - '0';
}

fn hand_cmp_part_two(context: void, a: hand_bid, b: hand_bid) bool {
    _ = context;
    var i: u8 = 0;
    while (i < 5) : (i += 1) {
        var a_value = get_value_part_two(a.hand[i]);
        var b_value = get_value_part_two(b.hand[i]);

        if (a_value == b_value) {
            continue;
        } else if (a_value < b_value) {
            return true;
        } else {
            return false;
        }
    }

    std.debug.panic("hand compare failed!", .{});
    return false;
}

pub fn main() !void {
    const lines = try read_input_file();

    // First half of the puzzle

    var five_of_a_kind_list = std.ArrayList(hand_bid).init(allocator);
    var four_of_a_kind_list = std.ArrayList(hand_bid).init(allocator);
    var full_house_list = std.ArrayList(hand_bid).init(allocator);
    var three_of_a_kind_list = std.ArrayList(hand_bid).init(allocator);
    var two_pair_list = std.ArrayList(hand_bid).init(allocator);
    var one_pair_list = std.ArrayList(hand_bid).init(allocator);
    var high_card_list = std.ArrayList(hand_bid).init(allocator);

    for (lines.items) |line| {
        var hand_bid_split = std.mem.split(u8, line, " ");
        var hand = hand_bid_split.next().?;
        var bid = try std.fmt.parseInt(u16, hand_bid_split.next().?, 10);
        var hb = hand_bid{ .hand = hand, .bid = bid };

        var cards = std.AutoHashMap(u8, u8).init(allocator);
        for (hand) |card| {
            var count: u8 = 1;
            if (cards.contains(card)) count += cards.get(card).?;
            try cards.put(card, count);
        }

        var has_three_of_a_kind = false;
        var pair_count: u8 = 0;
        var to_be_completed = true;
        var iter = cards.valueIterator();
        while (iter.next()) |count| {
            if (count.* == 5) {
                try five_of_a_kind_list.append(hb);
                to_be_completed = false;
                break;
            } else if (count.* == 4) {
                try four_of_a_kind_list.append(hb);
                to_be_completed = false;
                break;
            } else if (count.* == 3) {
                has_three_of_a_kind = true;
            } else if (count.* == 2) {
                pair_count += 1;
            }
        }

        if (to_be_completed) {
            if (has_three_of_a_kind) {
                if (pair_count == 1) {
                    try full_house_list.append(hb);
                } else {
                    try three_of_a_kind_list.append(hb);
                }
            } else if (pair_count == 2) {
                try two_pair_list.append(hb);
            } else if (pair_count == 1) {
                try one_pair_list.append(hb);
            } else {
                try high_card_list.append(hb);
            }
        }
    }

    std.mem.sort(hand_bid, five_of_a_kind_list.items, {}, hand_cmp);
    std.mem.sort(hand_bid, four_of_a_kind_list.items, {}, hand_cmp);
    std.mem.sort(hand_bid, full_house_list.items, {}, hand_cmp);
    std.mem.sort(hand_bid, three_of_a_kind_list.items, {}, hand_cmp);
    std.mem.sort(hand_bid, two_pair_list.items, {}, hand_cmp);
    std.mem.sort(hand_bid, one_pair_list.items, {}, hand_cmp);
    std.mem.sort(hand_bid, high_card_list.items, {}, hand_cmp);

    // std.debug.print("{any}\n", .{five_of_a_kind_list.items});
    // std.debug.print("{any}\n", .{four_of_a_kind_list.items});
    // std.debug.print("{any}\n", .{full_house_list.items});
    // std.debug.print("{any}\n", .{three_of_a_kind_list.items});
    // std.debug.print("{any}\n", .{two_pair_list.items});
    // std.debug.print("{any}\n", .{one_pair_list.items});
    // std.debug.print("{any}\n", .{high_card_list.items});

    var sum: u64 = 0;
    var rank: u16 = 1;

    for (high_card_list.items) |hb| {
        sum += @as(u64, rank) * hb.bid;
        rank += 1;
    }

    for (one_pair_list.items) |hb| {
        sum += @as(u64, rank) * hb.bid;
        rank += 1;
    }

    for (two_pair_list.items) |hb| {
        sum += @as(u64, rank) * hb.bid;
        rank += 1;
    }

    for (three_of_a_kind_list.items) |hb| {
        sum += @as(u64, rank) * hb.bid;
        rank += 1;
    }

    for (full_house_list.items) |hb| {
        sum += @as(u64, rank) * hb.bid;
        rank += 1;
    }

    for (four_of_a_kind_list.items) |hb| {
        sum += @as(u64, rank) * hb.bid;
        rank += 1;
    }

    for (five_of_a_kind_list.items) |hb| {
        sum += @as(u64, rank) * hb.bid;
        rank += 1;
    }

    std.debug.print("first half total: {}\n", .{sum});

    // Second half of the puzzle
    five_of_a_kind_list = std.ArrayList(hand_bid).init(allocator);
    four_of_a_kind_list = std.ArrayList(hand_bid).init(allocator);
    full_house_list = std.ArrayList(hand_bid).init(allocator);
    three_of_a_kind_list = std.ArrayList(hand_bid).init(allocator);
    two_pair_list = std.ArrayList(hand_bid).init(allocator);
    one_pair_list = std.ArrayList(hand_bid).init(allocator);
    high_card_list = std.ArrayList(hand_bid).init(allocator);

    for (lines.items) |line| {
        var hand_bid_split = std.mem.split(u8, line, " ");
        var hand = hand_bid_split.next().?;
        var bid = try std.fmt.parseInt(u16, hand_bid_split.next().?, 10);
        var hb = hand_bid{ .hand = hand, .bid = bid };

        var cards = std.AutoHashMap(u8, u8).init(allocator);
        for (hand) |card| {
            var count: u8 = 1;
            if (cards.contains(card)) count += cards.get(card).?;
            try cards.put(card, count);
        }

        if (cards.contains('J') and cards.get('J').? != 5) {
            var adjustment_amount = cards.fetchRemove('J').?.value;
            var iter = cards.iterator();
            var highest_kv = iter.next().?;
            while (iter.next()) |kv| {
                if (highest_kv.value_ptr.* < kv.value_ptr.*) {
                    highest_kv = kv;
                }
            }

            try cards.put(highest_kv.key_ptr.*, highest_kv.value_ptr.* + adjustment_amount);
        }

        var has_three_of_a_kind = false;
        var pair_count: u8 = 0;
        var to_be_completed = true;
        var iter = cards.valueIterator();
        while (iter.next()) |count| {
            if (count.* == 5) {
                try five_of_a_kind_list.append(hb);
                to_be_completed = false;
                break;
            } else if (count.* == 4) {
                try four_of_a_kind_list.append(hb);
                to_be_completed = false;
                break;
            } else if (count.* == 3) {
                has_three_of_a_kind = true;
            } else if (count.* == 2) {
                pair_count += 1;
            }
        }

        if (to_be_completed) {
            if (has_three_of_a_kind) {
                if (pair_count == 1) {
                    try full_house_list.append(hb);
                } else {
                    try three_of_a_kind_list.append(hb);
                }
            } else if (pair_count == 2) {
                try two_pair_list.append(hb);
            } else if (pair_count == 1) {
                try one_pair_list.append(hb);
            } else {
                try high_card_list.append(hb);
            }
        }
    }

    std.mem.sort(hand_bid, five_of_a_kind_list.items, {}, hand_cmp_part_two);
    std.mem.sort(hand_bid, four_of_a_kind_list.items, {}, hand_cmp_part_two);
    std.mem.sort(hand_bid, full_house_list.items, {}, hand_cmp_part_two);
    std.mem.sort(hand_bid, three_of_a_kind_list.items, {}, hand_cmp_part_two);
    std.mem.sort(hand_bid, two_pair_list.items, {}, hand_cmp_part_two);
    std.mem.sort(hand_bid, one_pair_list.items, {}, hand_cmp_part_two);
    std.mem.sort(hand_bid, high_card_list.items, {}, hand_cmp_part_two);

    // std.debug.print("{any}\n", .{five_of_a_kind_list.items});
    // std.debug.print("{any}\n", .{four_of_a_kind_list.items});
    // std.debug.print("{any}\n", .{full_house_list.items});
    // std.debug.print("{any}\n", .{three_of_a_kind_list.items});
    // std.debug.print("{any}\n", .{two_pair_list.items});
    // std.debug.print("{any}\n", .{one_pair_list.items});
    // std.debug.print("{any}\n", .{high_card_list.items});

    sum = 0;
    rank = 1;

    for (high_card_list.items) |hb| {
        sum += @as(u64, rank) * hb.bid;
        rank += 1;
    }

    for (one_pair_list.items) |hb| {
        sum += @as(u64, rank) * hb.bid;
        rank += 1;
    }

    for (two_pair_list.items) |hb| {
        sum += @as(u64, rank) * hb.bid;
        rank += 1;
    }

    for (three_of_a_kind_list.items) |hb| {
        sum += @as(u64, rank) * hb.bid;
        rank += 1;
    }

    for (full_house_list.items) |hb| {
        sum += @as(u64, rank) * hb.bid;
        rank += 1;
    }

    for (four_of_a_kind_list.items) |hb| {
        sum += @as(u64, rank) * hb.bid;
        rank += 1;
    }

    for (five_of_a_kind_list.items) |hb| {
        sum += @as(u64, rank) * hb.bid;
        rank += 1;
    }

    std.debug.print("second half total: {}\n", .{sum});
}
