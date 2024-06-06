const std = @import("std");
const Iter = @import("./iter.zig").Iter;
const Task = @import("./store.zig").Task;
const TodoError = @import("./error.zig").TodoError;
const store = @import("./store.zig");

pub const checkUsage =
    \\todo check <index>
    \\
;

pub fn execCheck(argsIter: *Iter) TodoError!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var tasks = std.ArrayList(Task).init(allocator);
    defer tasks.deinit();

    const storage_tasks = store.readTasks(allocator) catch |e| {
        std.debug.print("Error: Could not read saved tasks\n", .{});
        std.debug.print("{}\n", .{e});
        return;
    };

    tasks.appendSlice(storage_tasks.items) catch {
        return TodoError.Unexpected;
    };

    const next_op = argsIter.next();

    if (next_op) |indexStr| {
        const index = std.fmt.parseInt(u8, indexStr, 10) catch {
            return TodoError.Unexpected;
        };
        const tasksLen: u8 = @intCast(tasks.items.len);

        if (index >= tasksLen) {
            return TodoError.CheckOutOfBounds;
        }

        var task = &tasks.items[index];
        task.done = if (task.done) false else true;

        store.writeTasks(tasks.items) catch {
            return TodoError.Unexpected;
        };

        return;
    }

    return TodoError.AddMode;
}
