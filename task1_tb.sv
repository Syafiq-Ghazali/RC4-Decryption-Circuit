module task1_tb();


 logic clk;
 logic reset;
 logic s_wren;
 logic start_task1;
 logic [7:0] s_address;
 logic [7:0] s_data;
 logic task1_done;


task1 DUT
(
  .clk(clk),
  .reset(reset),
  .s_wren(s_wren),
  .start_task1(start_task1),
  .s_address(s_address),
  .s_data(s_Data),
  .task1_done(task1_done)
);


s_memory memory( 
	.clock(clk),           
	.address(s_address),	
	.data(s_data),		
	.wren(s_wren),		
	.q()
);


initial clk = 0;
always #2 clk = ~clk;

initial begin
#100;

reset = 1;
start_task1 = 1;

#10

reset = 0;

#250

reset = 1;
#15
reset = 0;



end



endmodule