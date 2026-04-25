//==================================================================
//Producer Class----------------------------------------------------
//==================================================================


class Producer;
  
  local my_mailbox #(int) my_mbox;
  
 
  //constructor---------------------------------------------------
  function new (my_mailbox#(int) my_mbox);
    this.my_mbox = my_mbox;
  endfunction
  
  
  //Produce(blocking put)-----------------------------------------
  task put(int data);
    my_mbox.put(data);
  endtask : put
  
  
  //Try producing(non-blocking put)-------------------------------
  function bit try_put(int data);
    return my_mbox.try_put(data);
  endfunction : try_put
 
  
endclass : Producer
  
  
  