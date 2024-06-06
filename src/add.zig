const std = @import("std");
const Iter = @import("./iter.zig").Iter;
const Task = @import("./store.zig").Task;
const TodoError = @import("./error.zig").TodoError;
const store = @import("./store.zig");

pub const addUsage =
    \\todo add <description> [options]
    \\options:
    \\  -t <deadline> Not yet implemented!
    \\
;

pub fn execAdd(argsIter: *Iter) TodoError!void {
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

    if (next_op) |next| {
        tasks.append(Task{ .desc = next, .index = @intCast(tasks.items.len), .deadline = 0 }) catch {
            return TodoError.Unexpected;
        };

        std.debug.print("Task added: '{s}'\n", .{next});
        std.debug.print("Total tasks: {}\n", .{tasks.items.len});

        store.writeTasks(tasks.items) catch |e| {
            std.debug.print("Error: Could not save tasks\n", .{});
            std.debug.print("{}\n", .{e});
        };

        return;
    }

    return TodoError.AddMode;
}
