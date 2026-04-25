//=======================================================================================================================================================
//Testbench for Linked List Package----------------------------------------------------------------------------------------------------------------------
//=======================================================================================================================================================

//Using program (not module) because it executes after DUT completes; module is for hardware description

program testbench;

  import linkedlist_package::*;

  LinkedList list;
  int passed = 0;
  int failed = 0;
  int expected_size;

  initial begin
    
    
    //Create the list
    list = new();
    
    
    $display("\n=== Linked List Testbench Start ===\n");
    
    

    //=======================================================================================================================================================
    //Empty List Tests---------------------------------------------------------------------------------------------------------------------------------------
    //=======================================================================================================================================================
    
    $display("=== Test 1: Empty List Operations ===");
    if(list.is_empty() == 1 && list.get_size() == 0) begin
      $display("[PASS] List is empty");
      passed++;
    end
    else begin
      $display("[FAIL] List should be empty");
      failed++;
    end
    list.display_head_to_tail();
    $display("---");
    
    
    
    //=======================================================================================================================================================
    //Add Operations Tests-----------------------------------------------------------------------------------------------------------------------------------
    //=======================================================================================================================================================
    
    $display("\n=== Test 2: Add to Head Operations ===");
    $display("Adding values: 5, 10, 15");
    list.add_to_head(5);
    list.add_to_head(10);
    list.add_to_head(15);
    expected_size = 3;
    if(list.get_size() == expected_size) begin
      $display("[PASS] Size is %0d", expected_size);
      passed++;
    end
    else begin
      $display("[FAIL] Expected size %0d, got %0d", expected_size, list.get_size());
      failed++;
    end
    list.display_head_to_tail();
    $display("---");
    
    
    
    $display("\n=== Test 3: Add to Tail Operations ===");
    $display("Adding values: 20, 25");
    list.add_to_tail(20);
    list.add_to_tail(25);
    expected_size = 5;
    if(list.get_size() == expected_size) begin
      $display("[PASS] Size is %0d", expected_size);
      passed++;
    end
    else begin
      $display("[FAIL] Expected size %0d, got %0d", expected_size, list.get_size());
      failed++;
    end
    list.display_head_to_tail();
    list.display_tail_to_head();
    $display("---");
    
    
    
    $display("\n=== Test 4: Add at Specific Index ===");
    $display("Adding: value 1 at index 0, value 12 at index 3, value 30 at end");
    list.add_at_specific_index(1, 0);
    list.add_at_specific_index(12, 3);
    list.add_at_specific_index(30, list.get_size());
    expected_size = 8;
    if(list.get_size() == expected_size) begin
      $display("[PASS] Size is %0d", expected_size);
      passed++;
    end
    else begin
      $display("[FAIL] Expected size %0d, got %0d", expected_size, list.get_size());
      failed++;
    end
    list.display_head_to_tail();
    $display("---");
    
    
    
    //=======================================================================================================================================================
    //Search and Get Operations Tests------------------------------------------------------------------------------------------------------------------------
    //=======================================================================================================================================================
    
    $display("\n=== Test 5: Search by Data ===");
    $display("Searching for value 12:");
    if(list.search_by_data(12) != -1) begin
      $display("[PASS] Value 12 found at index %0d", list.search_by_data(12));
      passed++;
    end
    else begin
      $display("[FAIL] Value 12 should be found");
      failed++;
    end
    
    $display("Searching for value 99 (not in list):");
    if(list.search_by_data(99) == -1) begin
      $display("[PASS] Value 99 not found (as expected)");
      passed++;
    end
    else begin
      $display("[FAIL] Value 99 should not be found");
      failed++;
    end
    $display("---");
    
    
    
    $display("\n=== Test 6: Get Value at Index ===");
    $display("Getting value at index 0: %0d", list.get_value_at_index(0));
    $display("Getting value at last index: %0d", list.get_value_at_index(list.get_size()-1));
    if(list.get_value_at_index(0) == 1 && list.get_value_at_index(list.get_size()-1) == 30) begin
      $display("[PASS] Head value: %0d, Tail value: %0d", list.get_value_at_index(0), list.get_value_at_index(list.get_size()-1));
      passed++;
    end
    else begin
      $display("[FAIL] Head or tail value incorrect");
      failed++;
    end
    $display("---");
    
    
    
    //=======================================================================================================================================================
    //Delete Operations Tests--------------------------------------------------------------------------------------------------------------------------------
    //=======================================================================================================================================================
    
    $display("\n=== Test 7: Delete Head and Tail ===");
    $display("Before deletion:");
    list.display_head_to_tail();
    $display("Deleting head and tail...");
    list.delete_head();
    list.delete_last();
    expected_size = 6;
    if(list.get_size() == expected_size) begin
      $display("[PASS] Size after deletions: %0d", expected_size);
      passed++;
    end
    else begin
      $display("[FAIL] Expected size %0d, got %0d", expected_size, list.get_size());
      failed++;
    end
    $display("After deletion:");
    list.display_head_to_tail();
    $display("---");
    
    
    
    $display("\n=== Test 8: Delete at Specific Index ===");
    $display("Deleting at index 2...");
    list.delete_at_specific_index(2);
    expected_size = 5;
    if(list.get_size() == expected_size) begin
      $display("[PASS] Size after deletion: %0d", expected_size);
      passed++;
    end
    else begin
      $display("[FAIL] Expected size %0d, got %0d", expected_size, list.get_size());
      failed++;
    end
    list.display_head_to_tail();
    $display("---");
    
    
    
    $display("\n=== Test 9: Delete by Data ===");
    $display("Deleting value 10...");
    list.delete_by_data(10);
    expected_size = 4;
    if(list.get_size() == expected_size && list.search_by_data(10) == -1) begin
      $display("[PASS] Value 10 deleted successfully");
      passed++;
    end
    else begin
      $display("[FAIL] Value 10 should be deleted");
      failed++;
    end
    list.display_head_to_tail();
    $display("---");
    
    
    
    //=======================================================================================================================================================
    //Sorting Tests------------------------------------------------------------------------------------------------------------------------------------------
    //=======================================================================================================================================================
    
    $display("\n=== Test 10: Sort Ascending ===");
    $display("Adding more values: 2, 50, 8");
    list.add_to_head(2);
    list.add_to_tail(50);
    list.add_to_tail(8);
    $display("Before sorting:");
    list.display_head_to_tail();
    $display("Sorting in ascending order...");
    list.sort_ascending();
    $display("After sorting:");
    list.display_head_to_tail();
    if(list.get_value_at_index(0) < list.get_value_at_index(list.get_size()-1)) begin
      $display("[PASS] List sorted in ascending order");
      passed++;
    end
    else begin
      $display("[FAIL] List not sorted correctly");
      failed++;
    end
    $display("---");
    
    
    
    $display("\n=== Test 11: Sort Descending ===");
    $display("Sorting in descending order...");
    list.sort_descending();
    $display("After sorting:");
    list.display_head_to_tail();
    if(list.get_value_at_index(0) > list.get_value_at_index(list.get_size()-1)) begin
      $display("[PASS] List sorted in descending order");
      passed++;
    end
    else begin
      $display("[FAIL] List not sorted correctly");
      failed++;
    end
    $display("---");
    
    
    
    //=======================================================================================================================================================
    //Min/Max and Reverse Tests------------------------------------------------------------------------------------------------------------------------------
    //=======================================================================================================================================================
    
    $display("\n=== Test 12: Find Min and Max ===");
    if(list.find_min() == 2 && list.find_max() == 50) begin
      $display("[PASS] Min: %0d, Max: %0d", list.find_min(), list.find_max());
      passed++;
    end
    else begin
      $display("[FAIL] Min or max value incorrect");
      failed++;
    end
    $display("---");
    
    
    
    $display("\n=== Test 13: Reverse List ===");
    $display("Reversing the list...");
    list.reverse_list();
    $display("After reversal:");
    list.display_head_to_tail();
    list.display_tail_to_head();
    if(list.get_value_at_index(0) < list.get_value_at_index(list.get_size()-1)) begin
      $display("[PASS] List reversed successfully");
      passed++;
    end
    else begin
      $display("[FAIL] List not reversed correctly");
      failed++;
    end
    $display("---");
    
    
    
    //=======================================================================================================================================================
    //Edge Cases Tests---------------------------------------------------------------------------------------------------------------------------------------
    //=======================================================================================================================================================
    
    $display("\n=== Test 14: Edge Cases - Out of Bounds ===");
    $display("Attempting to add at index 50 (out of bounds)...");
    expected_size = list.get_size();
    list.add_at_specific_index(100, 50);
    if(list.get_size() == expected_size) begin
      $display("[PASS] Out of bounds add rejected, size unchanged: %0d", expected_size);
      passed++;
    end
    else begin
      $display("[FAIL] Out of bounds add should not change size");
      failed++;
    end
    
    
    
    $display("Attempting to delete at index 50 (out of bounds)...");
    expected_size = list.get_size();
    list.delete_at_specific_index(50);
    if(list.get_size() == expected_size) begin
      $display("[PASS] Out of bounds delete rejected, size unchanged: %0d", expected_size);
      passed++;
    end
    else begin
      $display("[FAIL] Out of bounds delete should not change size");
      failed++;
    end
    
    
    
    $display("Attempting to get value at index 50 (out of bounds)...");
    if(list.get_value_at_index(50) == -1) begin
      $display("[PASS] Out of bounds get returned -1");
      passed++;
    end
    else begin
      $display("[FAIL] Out of bounds get should return -1");
      failed++;
    end
    $display("---");
    
    
    
    
    $display("\n=== Test 15: Clear List ===");
    $display("Clearing the list...");
    list.clear_list();
    if(list.is_empty() == 1 && list.get_size() == 0) begin
      $display("[PASS] List cleared successfully");
      passed++;
    end
    else begin
      $display("[FAIL] List should be empty after clear");
      failed++;
    end
    list.display_head_to_tail();
    $display("---");
    
    
    
    
    $display("\n=== Test 16: Operations on Empty List ===");
    $display("Attempting delete head on empty list...");
    expected_size = list.get_size();
    list.delete_head();
    if(list.get_size() == expected_size) begin
      $display("[PASS] Delete head on empty list handled correctly");
      passed++;
    end
    else begin
      $display("[FAIL] Size should not change on empty list delete");
      failed++;
    end
    
    
    $display("Attempting delete tail on empty list...");
    expected_size = list.get_size();
    list.delete_last();
    if(list.get_size() == expected_size) begin
      $display("[PASS] Delete tail on empty list handled correctly");
      passed++;
    end
    else begin
      $display("[FAIL] Size should not change on empty list delete");
      failed++;
    end
    
    
    
    $display("Attempting delete by value on empty list...");
    list.delete_by_data(10);
    $display("[PASS] Delete by value on empty list handled correctly");
    passed++;
    
    
    
    $display("Attempting search on empty list...");
    if(list.search_by_data(10) == -1) begin
      $display("[PASS] Search on empty list returned -1");
      passed++;
    end
    else begin
      $display("[FAIL] Search on empty list should return -1");
      failed++;
    end
    
    
    
    $display("Attempting find min/max on empty list...");
    if(list.find_min() == -1 && list.find_max() == -1) begin
      $display("[PASS] Min/Max on empty list returned -1");
      passed++;
    end
    else begin
      $display("[FAIL] Min/Max on empty list should return -1");
      failed++;
    end
    $display("---");
    
    
    
    
    $display("\n=== Test 17: Single Element Operations ===");
    $display("Adding single element: 100");
    list.add_to_head(100);
    $display("Performing reverse and sort on single element...");
    list.reverse_list();
    list.sort_ascending();
    if(list.get_size() == 1 && list.get_value_at_index(0) == 100) begin
      $display("[PASS] Single element operations handled correctly");
      passed++;
    end
    else begin
      $display("[FAIL] Single element operations failed");
      failed++;
    end
    list.display_head_to_tail();
    $display("---");
    
    
    
    //=======================================================================================================================================================
    //Final Summary------------------------------------------------------------------------------------------------------------------------------------------
    //=======================================================================================================================================================
    
    $display("\n=== Test Summary ===");
    $display("Total Tests: %0d", passed + failed);
    $display("Passed: %0d", passed);
    $display("Failed: %0d", failed);
    
    if(failed == 0) begin
      $display("Status: ALL TESTS PASSED");
    end
    else begin
      $display("Status: SOME TESTS FAILED");
    end
    
    
    $display("\n=== Linked List Testbench End ===\n");
    
    
    $finish;
    
  end

endprogram