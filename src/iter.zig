pub const Iter = struct {
    array: [][]u8,
    index: u32,

    pub fn init(arr: [][]u8) @This() {
        return @This(){ .array = arr, .index = 0 };
    }

    pub fn next(self: *@This()) ?[]u8 {
        if (self.index + 1 < self.array.len) {
            self.index = self.index + 1;
            return self.array[self.index];
        }
        return null;
    }

    pub fn len(self: @This()) u32 {
        return self.array.len;
    }
};
