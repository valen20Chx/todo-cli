const std = @import("std");
const TodoError = @import("./error.zig").TodoError;

pub const Task = struct { desc: []u8, index: u32, deadline: ?u32, done: bool };

const Store = struct {
    version: u8,
    tasks: []Task,
};

// TODO : Make it work on Windows and MacOS
// const TASKS_DIR_PATH = "~/.local/share/todo-cli/";
const TASKS_DIR_PATH = "./store/";
const TASKS_STORE_PATH = TASKS_DIR_PATH ++ "store";
const TASKS_VERSION_PATH = TASKS_DIR_PATH ++ "version";

const STORE_VERSION = 0;

fn openOrCreateFile(path: []const u8) !std.fs.File {
    const file = std.fs.cwd().openFile(path, .{ .mode = .write_only }) catch |e| {
        switch (e) {
            std.fs.File.OpenError.FileNotFound => {
                return std.fs.cwd().createFile(path, .{ .read = false });
            },
            else => return e,
        }
    };

    return file;
}

fn canReadStore() bool {
    const versionFile = std.fs.cwd().openFile(TASKS_VERSION_PATH, .{ .mode = .read_only }) catch return false;
    defer versionFile.close();

    const storeFile = std.fs.cwd().openFile(TASKS_STORE_PATH, .{ .mode = .read_only }) catch return false;
    defer storeFile.close();

    return true;
}

fn readVersion(allocator: std.mem.Allocator) !u8 {
    const file = try std.fs.cwd().openFile(TASKS_VERSION_PATH, .{
        .mode = .read_only,
    });
    defer file.close();

    const versionStr = try file.readToEndAlloc(allocator, 512);

    return try std.fmt.parseInt(u8, versionStr, 10);
}

pub fn readTasks(allocator: std.mem.Allocator) !std.ArrayList(Task) {
    if (!canReadStore()) {
        return std.ArrayList(Task).init(allocator);
    }

    const version = try readVersion(allocator);

    if (version != STORE_VERSION) {
        // TODO : Open version file, if older, migrate.
        return TodoError.Unexpected;
    }

    // TODO : If no file, init an empty list
    const file = try std.fs.cwd().openFile(TASKS_STORE_PATH, .{
        .mode = .read_only,
    });
    defer file.close();

    const content = try file.readToEndAlloc(allocator, 512);

    var linesSplitSequence = std.mem.splitSequence(u8, content, "\n");

    var tasks = std.ArrayList(Task).init(allocator);

    while (linesSplitSequence.next()) |line| {
        var fieldsSplitSequence = std.mem.splitSequence(u8, line, ";");

        const indexStr = fieldsSplitSequence.next() orelse return TodoError.Unexpected;
        const index = try std.fmt.parseInt(u32, indexStr, 10);
        const desc = fieldsSplitSequence.next() orelse return TodoError.Unexpected;
        const deadlineStr = fieldsSplitSequence.next();
        const deadline = if (deadlineStr.?.len > 0)
            try std.fmt.parseInt(u32, deadlineStr orelse unreachable, 10)
        else
            null;
        const doneStr = fieldsSplitSequence.next();
        const done = if (doneStr.?.len > 0) switch (try std.fmt.parseInt(u8, doneStr orelse unreachable, 10)) {
            0 => false,
            1 => true,
            else => return TodoError.Unexpected,
        } else {
            return TodoError.Unexpected;
        };

        const mutableDesc = try allocator.dupe(u8, desc);

        try tasks.append(Task{ .index = index, .desc = mutableDesc, .deadline = deadline, .done = done });
    }

    return tasks;
}

pub fn writeTasks(tasks: []Task) !void {
    // TODO : If the dir does not exit, create it.
    const storeFile = try openOrCreateFile(TASKS_STORE_PATH);
    defer storeFile.close();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    for (tasks, 0..) |task, index| {
        const deadlineStr: []u8 = if (task.deadline != null)
            try std.fmt.allocPrint(allocator, "{}", .{task.deadline orelse unreachable})
        else
            "";

        const doneStr = if (task.done) "1" else "0";

        const content = try std.fmt.allocPrint(allocator, "{};{s};{s};{s}", .{ task.index, task.desc, deadlineStr, doneStr });
        _ = try storeFile.write(content);

        if (index < tasks.len - 1) {
            _ = try storeFile.write("\n");
        }
    }

    const versionFile = try openOrCreateFile(TASKS_VERSION_PATH);
    defer versionFile.close();

    const versionStr = try std.fmt.allocPrint(allocator, "{}", .{STORE_VERSION});

    _ = try versionFile.write(versionStr);
}

pub fn reset() !void {
    std.fs.cwd().deleteTree(TASKS_DIR_PATH) catch |e| {
        std.log.debug("{} : {s}", .{ e, TASKS_DIR_PATH });
        return TodoError.Unexpected;
    };

    try std.fs.cwd().makeDir(TASKS_DIR_PATH);
}
