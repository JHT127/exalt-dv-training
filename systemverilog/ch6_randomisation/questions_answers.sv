//--------------------------------------------------------------------------
//Chapter 6 Task - Randomisation
//--------------------------------------------------------------------------


//Answers to the questions--------------------------------------------------
module questions_answers;
  
    function display();
      $display("Q1-What is the basic difference between rand and randc?");
      $display("Ans1 - randc does not choose the random number twice until all possible values are chosen.");
      $display("\nQ2-What is the difference between random property (class property) and non-random property in the classes?");
      $display("Ans2 - random property is randomised using .randosmise() while the non-random property is fixed until manually changed.");
      $display("\nQ3-What is the constraint?");
      $display("Ans3 - A constraint is like a limit to how random a generation could be, it allows us to get legal outputs from randomisation.");
      $display("\nQ4-Can 2 constraints make a contradiction without yielding to random failure?");
      $display("Ans4 - No, because the solver would not be able to choose a value that satisfies both HARD constraints.But if one of them is declared as SOFT, the solver can drop it to avoid failure.");
      $display("Note: Soft constraints act like defaults or preferences.They guide randomization but can be ignored if they conflict with stronger constraints.");
      $display("We use soft constraints to set default values or ranges,while still allowing overrides in tests or inline constraints.They are helpful when we want flexibility without randomization failure.");
      $display("\nQ5-What is the difference between if statement inside constraint and if inside sequential code?");
      $display("Ans5 - If statement inside a constraint is used to conditionally control how random values are generated during randomisation \nwhile if statements in sequential code are procedural and controls the program flow during execution.\nWe also use begin end in sequential while curly brackets in constraints."); 
    endfunction 
    
    initial begin
      $display("=========Answers to questions 1 to 5=======");
      display();
      $display("================Done=======================");
    end
  
endmodule 
