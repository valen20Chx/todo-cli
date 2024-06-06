const std = @import("std");
const Iter = @import("./iter.zig").Iter;
const Task = @import("./store.zig").Task;
const TodoError = @import("./error.zig").TodoError;

pub const addUsage =
    \\todo add <description> [options]
    \\options:
    \\  -t <deadline> Not yet implemented!
    \\
;

pub fn execAdd(argsIter: *Iter, tasks: *std.ArrayList(Task)) TodoError!void {
    const next_op = argsIter.next();

    if (next_op) |next| {
        tasks.append(Task{ .desc = next, .index = @intCast(tasks.items.len), .deadline = 0 }) catch {
            return TodoError.Unexpected;
        };

        std.debug.print("Task added: '{s}'\n", .{next});
        std.debug.print("Total tasks: {}\n", .{tasks.items.len});
        return;
    }

    return TodoError.AddMode;
}
