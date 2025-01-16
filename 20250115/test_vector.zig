const std = @import("std");
const Vector = @import("vector.zig").Vector; // Import the custom Vector struct

// Test case to validate the functionality of various vector operations
test "vector operations" {
    var allocator = std.testing.allocator; // Use the standard testing allocator

    var vec = try Vector.init(&allocator); // Initialize a new vector with the testing allocator
    defer vec.deinit(); // Ensure the vector is deallocated after the test is done

    // Test push: Add two elements (10 and 20) to the vector
    try vec.push(10);
    try vec.push(20);

    // Test size and capacity: The vector should have 2 elements and an initial capacity of 16
    std.debug.assert(vec.size() == 2);
    std.debug.assert(vec.capacity() == 16);

    // Test at: Check that the first element is 10
    std.debug.assert(vec.at(0) == 10);

    // Test pop: Remove and return the last element from the vector (20)
    const popped_value = try vec.pop();
    std.debug.assert(popped_value == 20); // Verify that the popped value is 20

    // Test is_empty: Ensure the vector is not empty after the pop
    std.debug.assert(!vec.is_empty());

    // Test insert: Insert the value 5 at index 0 (at the beginning of the vector)
    try vec.insert(0, 5);
    std.debug.assert(vec.at(0) == 5); // Verify that the element at index 0 is now 5

    // Test delete: Remove the element at index 0 (which is 5)
    try vec.delete(0);
    std.debug.assert(vec.at(0) == 10); // Ensure that the element at index 0 is now 10

    // Test find: Find the index of element 10, which should be at index 0
    std.debug.assert(vec.find(10) == 0);

    // Test remove: Remove all occurrences of element 10
    try vec.remove(10);
    std.debug.assert(vec.is_empty()); // Ensure the vector is empty after the removal
}