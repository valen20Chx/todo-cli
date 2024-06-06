const std = @import("std");

const iter = @import("./iter.zig");
const Iter = iter.Iter;

const Add = @import("./add.zig");
const Reset = @import("./reset.zig");

const todoError = @import("./error.zig");
const TodoError = todoError.TodoError;

const store = @import("./store.zig");
const Task = store.Task;

const Mode = enum {
    reset,
    add,
};

fn parseMode(argsIter: *Iter) TodoError!Mode {
    const next_op = argsIter.next();

    if (next_op) |next| {
        if (std.mem.eql(u8, next, "reset")) {
            return Mode.reset;
        }

        if (std.mem.eql(u8, next, "add")) {
            return Mode.add;
        }
    }

    return TodoError.InvalidMode;
}

fn exec() TodoError!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer _ = gpa.deinit();

    const args = std.process.argsAlloc(allocator) catch {
        return TodoError.Unexpected;
    };
    defer std.process.argsFree(allocator, args);

    var argsIter = Iter.init(args);

    const mode = try parseMode(&argsIter);

    var tasks = std.ArrayList(Task).init(allocator);
    defer tasks.deinit();

    // const storage_tasks = store.readTasks(allocator) catch |e| {
    //     std.debug.print("Error: Could not read saved tasks\n", .{});
    //     std.debug.print("{}\n", .{e});
    //     return;
    // };
    // tasks.appendSlice(storage_tasks.items) catch {
    //     return TodoError.Unexpected;
    // };

    switch (mode) {
        Mode.reset => try Reset.execReset(),
        Mode.add => try Add.execAdd(&argsIter, &tasks),
    }

    store.writeTasks(tasks.items) catch |e| {
        std.debug.print("Error: Could not save tasks\n", .{});
        std.debug.print("{}\n", .{e});
    };
}

pub fn main() !void {
    exec() catch |err| {
        switch (err) {
            TodoError.InvalidMode => {
                std.debug.print("This mode is not implemented\n", .{});
                std.debug.print(Add.addUsage, .{});
            },
            TodoError.AddMode => {
                std.debug.print("Wrong arguments passed to the add mode\n", .{});
                std.debug.print(Add.addUsage, .{});
            },
            TodoError.Unexpected => {
                std.debug.print("Unexpected error\n", .{});
            },
        }
    };
}
