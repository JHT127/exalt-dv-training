//==================================================================
//My mailbox class--------------------------------------------------
//==================================================================



class my_mailbox #(type T = int); 
  
  local T queue[$];
  local semaphore sem_space; //tracks how many empty slots are left
  local semaphore sem_item; //tracks how many msgs are inside
  local bit is_bounded;
  
  

  //constructor------------------------------------
  function new (int size = 0);
    
    this.is_bounded = (size > 0);
    this.sem_item = new(0);
    
    if(is_bounded) this.sem_space = new (size);
    
  endfunction
  
  
  
  //num function----------------------------------
  function int num();
    return queue.size();
  endfunction
  
  
  
  //Blocking methods------------------------------
  
      //put
      task put(T value);
        if(is_bounded) sem_space.get(1); //wait for space 
        queue.push_back(value);
        sem_item.put(1); //signals that an item is available
      endtask : put



      //get
      task get(output T value);
        sem_item.get(1); //wait for item
        value = queue.pop_front();
        if (is_bounded) sem_space.put(1); //signal space is free now
      endtask : get



      //peek
      task peek(output T value);
        sem_item.get(1); 
        value = queue[0];
        sem_item.put(1); //return it immediately 
      endtask : peek
  
  
  
  //Non-blocking methods--------------------------------------
  
      //try put
      function bit try_put(T value);
        if(is_bounded) begin
          if(!sem_space.try_get(1)) return 0;
        end
        queue.push_back(value);
        sem_item.put(1);
        return 1;
      endfunction : try_put



      //try get
      function bit try_get(output T value);
        if(!sem_item.try_get(1)) return 0;
        value = queue.pop_front();
        if(is_bounded) sem_space.put(1);
        return 1;
      endfunction : try_get



      //try peek
      function bit try_peek(output T value);
        if(!sem_item.try_get(1)) return 0;
        value = queue[0];
        sem_item.put(1);
        return 1;
      endfunction : try_peek

  
endclass : my_mailbox
  
   