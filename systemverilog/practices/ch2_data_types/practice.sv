//Chapter 2 practice


//logic vs byte------------------------------------
module logic_vs_byte_demo;
  
  logic [7:0] a, c, e;
  byte        b, d, f;
  
  initial begin
    
    // Difference 1: Can store X and Z?
    $display("\n=== Can store X and Z? ===");
    a = 8'bxxxx_zzzz;
    b = 8'bxxxx_zzzz;
    $display("logic = %b  (keeps X and Z)", a);
    $display("byte  = %b  (converts to 0)", b);
    
    
    // Difference 2: Signed or unsigned?
    $display("\n=== Signed or unsigned? ===");
    c = 8'b1111_1111;
    d = 8'b1111_1111;
    $display("logic = %d  (unsigned, so 255)", c);
    $display("byte  = %d  (signed, so -1)", d);
    
    
    // Difference 3: Overflow behavior
    $display("\n=== What happens at max value + 1? ===");
    e = 255;
    f = 127;
    e = e + 1;
    f = f + 1;
    $display("logic: 255 + 1 = %d", e); //gives 0
    $display("byte:  127 + 1 = %d", f); //gives 128
    
  end
  
endmodule



//union vs struct------------------------------

module struct_vs_union_demo;

  // STRUCT
  typedef struct {
    byte   age;      // 8 bits
    int    salary;   // 32 bits
    bit    active;   // 1 bit
  } employee_t;
  
  // UNION
  typedef union {
    int    full;     // 32 bits
    byte   bytes[4]; // 4 x 8 bits
    bit[31:0] bits;  // 32 bits
  } data_t;
  
  employee_t emp;
  data_t     dat;
 
  
  
  initial begin
    
    // Difference 1: Memory allocation
    $display("\n=== Memory Size ===");
    $display("struct size = %0d bits (8+32+1 = 41 bits total)", $bits(emp));
    $display("union size  = %0d bits (largest member = 32 bits)", $bits(dat));
    
    
    // Difference 2: Independent vs shared storage
    $display("\n=== Storage Behavior ===");
    
    // Struct: each member is independent
    emp.age = 25;
    emp.salary = 50000;
    emp.active = 1;
    $display("\nStruct (independent storage):");
    $display("  age = %0d, salary = %0d, active = %0d", 
             emp.age, emp.salary, emp.active);
    
    // Union: all members share the same memory
    dat.full = 32'hDEADBEEF;
    $display("\nUnion (shared storage):");
    $display("  Write full = 0x%h", dat.full);
    $display("  Read bytes[0] = 0x%h (same memory)", dat.bytes[0]);
    $display("  Read bytes[1] = 0x%h", dat.bytes[1]);
    
    
    // Difference 3: When to use each
    $display("\n=== Use Cases ===");
    $display("\nStruct: Store MULTIPLE values at the same time, also Each member gets its own memory (like unpacked arrays (default is unpacked, but can be packed)");
    $display("Union:  View the SAME data in different ways, also Can be packed or unpacked");
    
  end
  
endmodule




//associative arrays (like hash maps)--------------------

module associative_array_demo;
  
  // DECLARE: key-value pairs
  int scores[string];  // name -> score
  
  
  initial begin
    
    // === ADD elements ===
    $display("\n=== Adding ===");
    scores["Joud"] = 95;
    scores["Duaa"]   = 87;
    scores["Tala"] = 92;
    $display("Added 3 students, size = %0d", scores.num());
    
    
    // === READ elements ===
    $display("\n=== Reading ===");
    $display("Joud = %0d", scores["Joud"]);
    $display("Duaa   = %0d", scores["Duaa"]);
    
    
    // === CHECK if exists ===
    $display("\n=== Check Exists ===");
    if (scores.exists("Duaa"))
      $display("Duaa exists");
    if (!scores.exists("Yasmeen"))
      $display("Yasmeen does NOT exist");
    
    
    // === LOOP through all ===
    $display("\n=== Loop All ===");
    foreach (scores[name]) begin
      $display("%s = %0d", name, scores[name]);
    end
    
    
    // === DELETE one ===
    $display("\n=== Delete One ===");
    scores.delete("Duaa");
    $display("Deleted Duaa, size = %0d", scores.num());
    
    
    // === DELETE all ===
    $display("\n=== Delete All ===");
    scores.delete();
    $display("Cleared all, size = %0d", scores.num());
    
    
    // === How it's like a hash map ===
    $display("\n=== Like a Hash Map Because: ===");
    $display("1. Key-value pairs:  scores[\"Joud\"] = 95");
    $display("2. Fast lookup:      O(1) time");
    $display("3. Dynamic size:     grows/shrinks automatically");
    $display("4. Any key type:     string, int, etc.");
    
  end
  
endmodule



//dynamic arrays----------------------------------

module dynamic_array_demo;
  
  // DECLARE: starts with size 0
  int numbers[];
  
  
  initial begin
    
    // === CREATE array with size 10 ===
    $display("\n=== Create Size 10 ===");
    numbers = new[10];
    
    // Fill with values
    for (int i = 0; i < 10; i++) begin
      numbers[i] = i * 10;  // 0, 10, 20, 30...
    end
    
    $display("Size = %0d", numbers.size());
    $display("Values = %p", numbers);
    
    
    // === RESIZE to 20 (keeps old 10 values) ===
    $display("\n=== Resize to 20 (keep old data) ===");
    numbers = new[20](numbers);  // the answer haha
    
    // Fill new slots (10-19)
    for (int i = 10; i < 20; i++) begin
      numbers[i] = i * 10;  // 100, 110, 120...
    end
    
    $display("Size = %0d", numbers.size());
    $display("Values = %p", numbers);
    
    
    // === RESIZE to 5 (keeps only first 5) ===
    $display("\n=== Resize to 5 ===");
    numbers = new[5](numbers);
    $display("Size = %0d", numbers.size());
    $display("Values = %p", numbers);
    
    
    // === DELETE (free memory) ===
    $display("\n=== Delete ===");
    numbers.delete();
    $display("Size = %0d", numbers.size());
    
    
    // === Key Syntax ===
    $display("\n=== Key Syntax ===");
    $display("Create:     arr = new[10];");
    $display("Resize:     arr = new[20](arr);  <- keeps old data");
    $display("Check size: arr.size()");
    $display("Delete:     arr.delete()");
    
  end
  
endmodule