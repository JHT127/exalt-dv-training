//--------------------------------------------------------------------------
//Chapter 6 Task - Randomisation
//--------------------------------------------------------------------------



//Question 6 Task F---------------------------------------------------------



//Randomisation check macro
`define SV_RAND_CHECK(r) \
	do begin \
      if(!(r)) begin \
        $display("Randomisation failed!"); \
        $finish; \
      end \
    end while(0)




//Class c
class c;
  
  rand bit grid[][];

  //constructor to allocate chosen rows and cols
  function new(int rows, int cols);
    grid = new[rows];
    foreach(grid[i]) begin
      grid[i] = new[cols];
    end
  endfunction
  
  
  //constraint that 1's should have NO neigboring 1's
  constraint no_neighbors {
    foreach (grid[i, j]) {  
      if (grid[i][j] == 1) {
        if (i > 0)           grid[i-1][j] == 0; // up
        if (i < grid.size()-1) grid[i+1][j] == 0; // down
        if (j > 0)           grid[i][j-1] == 0; // left
        if (j < grid[i].size()-1) grid[i][j+1] == 0; // right
      }
    }
  }

  
        
  //function to display values
  function void display();
    foreach(grid[i]) begin
      foreach(grid[i][j]) begin
        $write("%0b ", grid[i][j]);
      end
      $display("\n");
    end
      $display("\n-------------\n");
  endfunction : display
   
  
endclass : c


//tb for task f
module task_f;
  c object = new(3,4);
  initial begin
    repeat(12) begin
      `SV_RAND_CHECK(object.randomize());
       object.display();
    end
  end
endmodule 