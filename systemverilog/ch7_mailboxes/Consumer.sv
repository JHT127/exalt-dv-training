//==================================================================
//Consumer Class----------------------------------------------------
//==================================================================


class Consumer;
  
  local my_mailbox #(int) my_mbox;
  
 
  //constructor---------------------------------------------------
  function new (my_mailbox#(int) my_mbox);
    this.my_mbox = my_mbox;
  endfunction
  
  
  //Consume(blocking get)-----------------------------------------
  task get(output int data);
    my_mbox.get(data);
  endtask : get
  
  
  //Try consuming(non-blocking get)-------------------------------
  function bit try_get(output int data);
    return my_mbox.try_get(data);
  endfunction : try_get
  
  
  //peek
  task peek(output int data);
    my_mbox.peek(data);
  endtask : peek
  
  
  //try peek
  function bit try_peek(output int data);
    return my_mbox.try_peek(data);
  endfunction : try_peek
 
  
endclass : Consumer
  
  
  