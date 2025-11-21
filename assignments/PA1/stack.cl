(*
 *  CS164 Fall 94
 *
 *  Programming Assignment 1
 *    Implementation of a simple stack machine.
 *
 *  Skeleton file
 *)

class Stack inherits IO {
   stack : StackNode;

   isNil() : Bool {
      isvoid stack
   };

   display() : SELF_TYPE {
      {
         let ptr : StackNode <- stack in {
            while (not isvoid ptr) loop {
               out_string(ptr.string());
               ptr <- ptr.next();
            } pool;
            self;
         };
      }
   };

   eval() : SELF_TYPE {
      {
         if isNil() then {
            self;
         } else {
            stack <- stack.eval();
         } fi;
         self;
      }
   };

   run() : SELF_TYPE {
      let input : String <- in_string(), valid : Bool <- true, new_cmd : StackCommand in {
         while (valid) loop {
            if input = "d" then {
               display();
            } else if input = "+" then {
               new_cmd <- new StackAddition;
               stack <- (new StackNode).init(new_cmd, stack);
            } else if input = "s" then {
               new_cmd <- new StackSwap;
               stack <- (new StackNode).init(new_cmd, stack);
            } else if input = "x" then {
               -- Graceful exit
               valid <- false;
            } else if input = "e" then {
               eval();
            } else {
               -- Assume input is an Int
               new_cmd <- (new StackInteger).init((new A2I).a2i(input));
               stack <- (new StackNode).init(new_cmd, stack);

            } fi fi fi fi fi;

            if valid then input <- in_string() else self fi;
         } pool;
         self;
      }
   };
};

class StackNode {
   value : StackCommand;
   next : StackNode;

   init(cmd : StackCommand, next_node : StackNode) : SELF_TYPE {
      {
         value <- cmd;
         next <- next_node;
         self;
      }
   };

   eval() : StackNode {
      {
         value.eval(self);
      }
   };

   -- string() is intended for pretty formatted string and not for returning raw strings.
   string() : String {
      value.prettyprint()
   };

   value() : StackCommand {
      value
   };

   next() : StackNode {
      next
   };

   setNext(next_node : StackNode) : SELF_TYPE {
      {
         next <- next_node;
         self;
      }
   };
};

class StackSwap inherits StackCommand {
   eval(s : StackNode) : StackNode {
     let node1 : StackNode <- s.next(), node2 : StackNode <- node1.next(), new_node : StackNode in {
         node1.setNext(node2.next());
         node2.setNext(node1);

         node2;
     } 
   };

   string() : String {
      "s"
   };
};

class StackAddition inherits StackCommand {
   eval(s : StackNode) : StackNode {
      let node1 : StackNode <- s.next(), node2 : StackNode <- node1.next(), new_node : StackNode in 
      let cmd1 : StackCommand <- node1.value(), cmd2 : StackCommand <- node2.value(), new_cmd : StackCommand in {
         case cmd1 of 
            i1 : StackInteger => { 
               case cmd2 of
                  i2 : StackInteger => let sum : Int <- i1.int() + i2.int() in new_cmd <- (new StackInteger).init(sum);
               esac;
             };
         esac;

         new_node <- (new StackNode).init(new_cmd, node2.next());
      }
   };

   string() : String {
      "+"
   };
};

class StackInteger inherits StackCommand {
   data : Int;

   init(int : Int) : SELF_TYPE {
      {
         data <- int;
         self;
      }
   };

   string() : String {
      (new A2I).i2a(data)
   };

   int() : Int {
      data
   };
};

class StackCommand inherits IO {
   eval(s : StackNode) : StackNode {
      s
   };

   string() : String {
      "Noop / Unimplemented string()"
   };

   prettyprint() : String {
      string().concat("\n")
   };
};

class Main inherits IO {

   main() : Object {
      let stack : Stack <- new Stack in {
         stack.run();
      }
   };
};
