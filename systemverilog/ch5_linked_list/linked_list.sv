//=======================================================================================================================================================
//Linked List Package containing the node class and linked list class------------------------------------------------------------------------------------
//=======================================================================================================================================================

package linkedlist_package;



//=======================================================================================================================================================
//Node class---------------------------------------------------------------------------------------------------------------------------------------------
//=======================================================================================================================================================




class Node;
  
  
  //doubly linked list (defining the value and next/prev handles)
  int value;
  Node next; 
  Node prev;
  
  
  //custom constructor
  function new(int value=0); //value by default is 0
    this.value = value;
    next = null;
    prev = null;
  endfunction;
  
  
endclass : Node





//=======================================================================================================================================================
//Linked List class with all the functions---------------------------------------------------------------------------------------------------------------
//=======================================================================================================================================================




class LinkedList;
  
  
  //head and tail handles and size
  Node head; 
  Node tail;
  int size;
  
  
  //constructor
  function new();
    ////the handle is pointing to null (nothing) for both head and tail
    this.head = null; 
    this.tail = null;
    size = 0;
  endfunction
  
  
  
  //Functions============================================================================================================================================
  
  
  	  
      //Display the list from head to tail - Time Complexity: O(n)
      function void display_head_to_tail();

        Node current = head;

        if(current == null) begin
          $display("List is empty");
          return; //exiting the function
        end


        $write("List (head -> tail) : ");

        while(current != null) begin
          $write("%0d ", current.value);
          current = current.next;
        end

        $display("");

      endfunction : display_head_to_tail
  
  
  
   
      //Display the list from tail to head - Time Complexity: O(n)
      function void display_tail_to_head();

        Node current = tail;

        if(current == null) begin
          $display("List is empty");
          return; 
        end


        $write("List (tail -> head) : ");  

        while(current != null) begin
          $write("%0d ", current.value);
          current = current.prev;
        end

        $display("");

      endfunction : display_tail_to_head
  		
  
  
  
      //Add to head - Time Complexity: O(1)
      function void add_to_head(int data);
        
        Node new_node;
        
        size++;
        new_node = new(data); //object in the list

        if(head == null) begin //empty list, the new node is both the head and the tail 
          head = new_node;
          tail = new_node;
        end

        else begin
          new_node.next = head;
          head.prev = new_node;   
          head = new_node;
        end

      endfunction : add_to_head
  
  
  
  
      //Add to tail - Time Complexity: O(1)
      function void add_to_tail(int data);
        
        Node new_node;
        
        size++;
        new_node = new(data); 

        if(head == null) begin
          head = new_node;
          tail = new_node;
        end

        else begin
          tail.next = new_node;
          new_node.prev = tail;    
          tail = new_node;
        end

      endfunction : add_to_tail
  
  
  
  
      //Delete head - Time Complexity: O(1)
      function void delete_head();
        
        if(head == null) begin
          return;
        end
        
        size--;

        if(head == tail) begin //one value
          head = null;
          tail = null;
        end

        else begin
          head = head.next;
          head.prev = null;
        end

      endfunction : delete_head
  
  
  
  
      //Delete last - Time Complexity: O(1)
      function void delete_last();
        
        if(head == null) begin
          return;
        end
        
        size--;

        if(head == tail) begin
          head = null;
          tail = null;
        end

        else begin
          tail = tail.prev;
          tail.next = null;
        end

      endfunction : delete_last
  
  
  
  
      //Add at specific index - Time Complexity: O(n)
      function void add_at_specific_index(int data, int index);
        
        Node new_node;
        Node current;
        
        new_node = new(data);


        //case 1: out of bounds index
        if(index < 0 || index > size) begin
          return;
        end



        //case 2: list is empty
        if(head == null) begin

          //index can only be zero because the list is already empty, otherwise the index is invalid
          if(index == 0) begin
            head = new_node;
            tail = new_node;
            size++;
          end

          return; //no need to continue the other blocks

        end



        //case 3: index = 0 -> insert at head
        if(index == 0) begin
          new_node.next = head;
          head.prev = new_node;
          head = new_node;
          size++;
          return;
        end



        //case 4: traverse to the index 
        current = head;
        for(int i=0; i<index; i++) begin    //traverse index times (so that we reach the index)
          if (current == null) break; //leave the loop
          current = current.next;
        end


          //after traversing, if we are in null then we are at the end, insert at tail, else insert before the index
          if(current == null) begin
            new_node.prev = tail;
            tail.next = new_node;
            tail = new_node;
            size++;
          end
          else begin
            new_node.next = current;
            new_node.prev = current.prev;    
            current.prev.next = new_node;
            current.prev = new_node;
            size++;
          end



      endfunction : add_at_specific_index
  
  
  
  
      //Delete at specific index - Time Complexity: O(n)
      function void delete_at_specific_index(int index);


        Node current;


        //case 1: out of bounds index
        if(index < 0 || index > size) begin
           return;
        end



        //case 2: list is empty
        if (head == null) begin
            return;
        end



        //case 3: index = 0 -> delete head
        if (index == 0) begin

            //if only one node
            if (head == tail) begin
                head = null;
                tail = null;
                size--;
            end
            else begin
                head = head.next;
                head.prev = null;
                size--;
            end

            return;
        end



        //case 4: traverse to the index (then delete middle or tail node)
        current = head;
        for (int i = 0; i < index; i++) begin
            if (current == null) break;
            current = current.next;
        end


          //after traversing to the index
          if (current == tail) begin

              //delete at tail
              tail = tail.prev;
              tail.next = null;
              size--;

          end

          else begin

              //delete in the middle
              current.prev.next = current.next;
              current.next.prev = current.prev;
              size--;

          end


      endfunction : delete_at_specific_index
  
  
  
  
      //Return the size of the list - Time Complexity: O(1)
      function int get_size();

        return size;

      endfunction : get_size




      //Return if the list is empty - Time Complexity: O(1)
      function bit is_empty();

        return size == 0;

      endfunction : is_empty
  
  
  
  
       //Delete by specific data value - Time Complexity: O(n)
       function void delete_by_data(int data);
         
         
          Node current;

         
          //case 1: list is empty
          if (head == null) begin
              return;
          end

         
          //case 2: data is at head
          if (head.value == data) begin
            
              //if only one node
              if (head == tail) begin
                  head = null;
                  tail = null;
                  size--;
              end
            
              else begin
                  head = head.next;
                  head.prev = null;
                  size--;
              end
            
              return;
            
          end

         
         
          //case 3: traverse to find the data
          current = head.next;
          while (current != null) begin
              if (current.value == data) begin
                
                  //found the data
                  if (current == tail) begin
                    
                      //delete at tail
                      tail = tail.prev;
                      tail.next = null;
                      size--;
                  end
                
                  else begin
                      //delete in the middle
                      current.prev.next = current.next;
                      current.next.prev = current.prev;
                      size--;
                  end
                
                  return;
                
              end
            
              current = current.next;
          end

         
      	endfunction : delete_by_data
       
 
  
  
        //Search by data value - Time Complexity: O(n)
        function int search_by_data(int data);
          
            Node current;
            int index = 0;

            //case 1: list is empty
            if (head == null) begin
                return -1;
            end

          
            //traverse the list to find the data
            current = head;
            while (current != null) begin
                if (current.value == data) begin
                    return index;
                end
              
                current = current.next;
                index++;
              
            end

          
            //data not found
            return -1;

        endfunction : search_by_data




        //Sort in ascending order (Bubble Sort) - Time Complexity: O(n²)
        function void sort_ascending();
          
            Node current, next_node;
            int temp;
            int swapped;

            //case 1: empty or single node list
            if (head == null || head == tail) begin
                return;
            end

          
            //bubble sort algorithm
            do begin
                swapped = 0;
                current = head;

                while (current.next != null) begin
                    next_node = current.next;

                    //if current value is greater than next, swap them
                    if (current.value > next_node.value) begin
                        temp = current.value;
                        current.value = next_node.value;
                        next_node.value = temp;
                        swapped = 1;
                    end

                    current = current.next;
                end

            end while (swapped == 1);


        endfunction : sort_ascending




        //Sort in descending order (Bubble Sort) - Time Complexity: O(n²)
        function void sort_descending();
          
            Node current, next_node;
            int temp;
            int swapped;

            //case 1: empty or single node list
            if (head == null || head == tail) begin
                return;
            end

            //bubble sort algorithm
            do begin
                swapped = 0;
                current = head;

                while (current.next != null) begin
                    next_node = current.next;

                    //if current value is less than next, swap them
                    if (current.value < next_node.value) begin
                        temp = current.value;
                        current.value = next_node.value;
                        next_node.value = temp;
                        swapped = 1;
                    end

                    current = current.next;
                end

            end while (swapped == 1);


        endfunction : sort_descending

    
 
  
        //Get value at specific index - Time Complexity: O(n)
        function int get_value_at_index(int index);
          
            Node current;

            //check bounds
            if (index < 0 || index >= size) begin
                return -1;
            end

            //traverse to index
            current = head;
            for (int i = 0; i < index; i++) begin
                current = current.next;
            end

            return current.value;

        endfunction : get_value_at_index




        //Reverse the list - Time Complexity: O(n)
        function void reverse_list();
          
            Node current, temp;

            //empty or single node
            if (head == null || head == tail) begin
                return;
            end

            current = head;
            tail = head;  //old head becomes new tail

            //swap next and prev pointers for each node
            while (current != null) begin
                temp = current.prev;
                current.prev = current.next;
                current.next = temp;

                //move to next node (which is actually prev before swap)
                if (current.prev == null) begin
                    head = current;  //found new head
                end
                current = current.prev;
            end


        endfunction : reverse_list




        //Find minimum value in the list - Time Complexity: O(n)
        function int find_min();
          
            Node current;
            int min_value;

            if (head == null) begin
                return -1;
            end

            current = head;
            min_value = current.value;

            while (current != null) begin
                if (current.value < min_value) begin
                    min_value = current.value;
                end
                current = current.next;
            end

            return min_value;

        endfunction : find_min




        //Find maximum value in the list - Time Complexity: O(n)
        function int find_max();
          
            Node current;
            int max_value;

            if (head == null) begin
                return -1;
            end

            current = head;
            max_value = current.value;

            while (current != null) begin
                if (current.value > max_value) begin
                    max_value = current.value;
                end
                current = current.next;
            end

            return max_value;

        endfunction : find_max




        //Clear or delete all nodes in the list - Time Complexity: O(1)
        function void clear_list();

            if (head == null) begin
                return;
            end

            head = null;
            tail = null;
            size = 0;

        endfunction : clear_list
  
  
  
  
endclass : LinkedList



endpackage : linkedlist_package