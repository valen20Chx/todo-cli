const reset = @import("./store.zig").reset;
const TodoError = @import("./error.zig").TodoError;

pub const resetUsage =
    \\todo reset
    \\
;

pub fn execReset() TodoError!void {
    reset() catch {
        return TodoError.Unexpected;
    };
}
