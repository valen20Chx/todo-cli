const std = @import("std");
const Iter = @import("./iter.zig").Iter;
const Task = @import("./store.zig").Task;
const TodoError = @import("./error.zig").TodoError;
const store = @import("./store.zig");

pub const listUsage =
    \\todo list
    \\
;

pub fn printTask(task: Task) void {
    std.debug.print("{} [{s}]: {s}\n", .{ task.index, if (task.done) "X" else " ", task.desc });
}

pub fn execList() TodoError!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var tasks = std.ArrayList(Task).init(allocator);
    defer tasks.deinit();

    const storage_tasks = store.readTasks(allocator) catch {
        return TodoError.Unexpected;
    };
    tasks.appendSlice(storage_tasks.items) catch {
        return TodoError.Unexpected;
    };

    for (storage_tasks.items) |task| {
        printTask(task);
    }
}
