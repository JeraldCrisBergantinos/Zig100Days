// Implement a vector (mutable array with automatic resizing):
// * New raw data array with allocated memory
//     can allocate int array under the hood, just not use its features
//     start with 16, or if the starting number is greater, use power of 2 - 16, 32, 64, 128
// * size() - number of items
// * capacity() - number of items it can hold
// * is_empty()
// * at(index) - returns the item at a given index, blows up if index out of bounds
// * push(item)
// * insert(index, item) - inserts item at index, shifts that index's value and trailing elements to the right
// * prepend(item) - can use insert above at index 0
// * pop() - remove from end, return value
// * delete(index) - delete item at index, shifting all trailing elements left
// * remove(item) - looks for value and removes index holding it (even if in multiple places)
// * find(item) - looks for value and returns first index with that value, -1 if not found
// * resize(new_capacity) // private function
//     when you reach capacity, resize to double the size
//     when popping an item, if the size is 1/4 of capacity, resize to half

const std = @import("std");

// A dynamic array-like structure (Vector) for integers, managing memory automatically.
pub const Vector = struct {
    _allocator: *std.mem.Allocator, // Allocator used for dynamic memory management
    _data: []i32,                   // Array holding the elements of the vector
    _size: usize,                   // Current number of elements in the vector
    _capacity: usize,               // Maximum number of elements the vector can hold without resizing

    // Initialize a new Vector with a given allocator.
    pub fn init(allocator: *std.mem.Allocator) !Vector {
        const initial_capacity = 16; // Start with capacity of 16 elements
        const data = try allocator.alloc(i32, initial_capacity); // Allocate memory for initial capacity
        return Vector{
            ._allocator = allocator,
            ._data = data,
            ._size = 0, // Vector starts empty
            ._capacity = initial_capacity, // Initial capacity set
        };
    }

    // Clean up the vector, freeing allocated memory.
    pub fn deinit(self: *Vector) void {
        self._allocator.free(self._data); // Free the allocated memory for the vector's data
    }

    // Return the current number of elements in the vector.
    pub fn size(self: *Vector) usize {
        return self._size;
    }

    // Return the maximum number of elements the vector can hold without resizing.
    pub fn capacity(self: *Vector) usize {
        return self._capacity;
    }

    // Check if the vector is empty.
    pub fn is_empty(self: *Vector) bool {
        return self._size == 0; // Vector is empty when size is 0
    }

    // Get the element at a specific index in the vector.
    pub fn at(self: *Vector, index: usize) i32 {
        if (index >= self._size) {
            std.debug.panic("Index out of bounds", .{}); // Panic if the index is out of bounds
        }
        return self._data[index];
    }

    // Add a new element to the end of the vector. Resizes if needed.
    pub fn push(self: *Vector, item: i32) !void {
        if (self._size == self._capacity) {
            try self._resize(self._capacity * 2); // Double capacity if vector is full
        }
        self._data[self._size] = item; // Add the new item at the next available position
        self._size += 1; // Increase the size after insertion
    }

    // Insert an element at a specific index. Resizes if needed.
    pub fn insert(self: *Vector, index: usize, item: i32) !void {
        if (index >= self._size) {
            std.debug.panic("Index out of bounds", .{}); // Panic if index is out of bounds
        }
        if (self._size == self._capacity) {
            try self._resize(self._capacity * 2); // Double capacity if vector is full
        }
        // Shift elements to the right to make room for the new item
        var i: usize = self._size;
        while (i > index) : (i -= 1) {
            self._data[i] = self._data[i - 1];
        }
        self._data[index] = item; // Insert the new item at the specified index
        self._size += 1; // Increase the size after insertion
    }

    // Add an element to the beginning of the vector.
    pub fn prepend(self: *Vector, item: i32) !void {
        try self.insert(0, item); // Insert the item at index 0
    }

    // Remove and return the last element in the vector.
    pub fn pop(self: *Vector) !i32 {
        if (self.is_empty()) {
            std.debug.panic("Cannot pop from an empty vector", .{}); // Panic if vector is empty
        }
        const value = self._data[self._size - 1]; // Get the last element
        self._size -= 1; // Reduce the size

        // Resize the vector to half the current capacity if it's too large
        if (self._size <= self._capacity / 4 and self._capacity > 16) {
            try self._resize(self._capacity / 2);
        }

        return value; // Return the popped element
    }

    // Delete an element at a specific index and shift elements left to fill the gap.
    pub fn delete(self: *Vector, index: usize) !void {
        if (index >= self._size) {
            std.debug.panic("Index out of bounds", .{}); // Panic if index is out of bounds
        }

        // Shift elements to the left to overwrite the deleted element
        for (index..self._size - 1) |i| {
            self._data[i] = self._data[i + 1];
        }

        // Decrease the size after deletion
        self._size -= 1;
    }

    // Remove all occurrences of an element from the vector.
    pub fn remove(self: *Vector, item: i32) !void {
        var i: usize = 0;

        // Loop through the vector and delete each occurrence of the item
        while (i < self._size) {
            if (self._data[i] == item) {
                try self.delete(i); // Delete the element and shift others left
            } else {
                i += 1; // Only increment if no deletion occurred
            }
        }
    }

    // Find the index of the first occurrence of an element in the vector.
    // Returns the index if found, -1 if not.
    pub fn find(self: *Vector, item: i32) isize {
        var i: usize = 0;
        // Iterate through the vector to find the item
        while (i < self._size) : (i += 1) {
            if (self._data[i] == item) {
                return @intCast(i); // Return the index if found
            }
        }

        return -1; // Return -1 if the item is not found
    }

    // Resize the vector to a new capacity and reallocate memory.
    fn _resize(self: *Vector, new_capacity: usize) !void {
        if (self._capacity == new_capacity) {
            return; // No resizing needed if capacity is the same
        }

        const new_data = try self._allocator.alloc(i32, new_capacity); // Allocate new memory for the new capacity

        // Copy the existing elements to the new data array
        var i: usize = 0;
        while (i < self._size) : (i += 1) {
            new_data[i] = self._data[i];
        }

        self._allocator.free(self._data); // Free the old data array
        self._data = new_data;            // Update the data pointer to the new array
        self._capacity = new_capacity;    // Update the capacity to the new value
    }
};