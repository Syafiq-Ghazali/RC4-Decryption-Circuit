module valid_key_checker_tb();

     logic clk;
     logic start;
     logic reset;


     logic valid_flag;
     logic key_checker_done;

     logic [4:0] valid_Decrypted_Message_address;
     logic [7:0] valid_task2b_Decrypted_Message_data;
     logic       valid_task2b_Decrypted_Message_wren;
     logic  [7:0] Decrypted_Message_wren_q;



valid_key_checker DUT(
      .clk(clk),
      .start(start),
      .reset(reset),

      .valid_flag(valid_flag),     
      .key_checker_done(key_checker_done),

       .valid_Decrypted_Message_address(valid_Decrypted_Message_address),
       .valid_task2b_Decrypted_Message_wren(valid_task2b_Decrypted_Message_wren),
       .Decrypted_Message_q(Decrypted_Message_wren_q)
);


initial clk = 0;
always #2 clk = ~clk;

initial begin
start = 0;
reset = 0;
Decrypted_Message_wren_q = 97;

#15

start = 1;


#50

Decrypted_Message_wren_q = 122;


#50

Decrypted_Message_wren_q = 32;

#50

reset = 1;

#10

reset = 0;

#10

Decrypted_Message_wren_q = 100;


#50

Decrypted_Message_wren_q = 240;


#50

Decrypted_Message_wren_q = 32;

#20

$stop;


end


endmodule