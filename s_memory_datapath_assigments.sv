module s_memory_datapath_assigments (
    input  logic        clk,
    input  logic        task1_done_flag,
    input  logic        reset,
    input  logic        task2a_done_flag,
    input  logic        task2b_done_flag,
    input  logic        switch_flag,
    input  logic [7:0]  task1_s_address,
    input  logic [7:0]  task2a_s_address,
    input  logic [7:0]  task2b_s_address,
    input  logic [7:0]  task1_s_data,
    input  logic [7:0]  task2a_s_data,
    input  logic [7:0]  task2b_s_data,
    input  logic        task1_s_wren,
    input  logic        task2a_s_wren,
    input  logic        task2b_s_wren,
    output logic [7:0]  s_address,
    output logic [7:0]  s_data,
    output logic        s_wren,


    input  logic [4:0]  valid_Decrypted_Message_address,
    input  logic        valid_Decrypted_Message_wren,

    input  logic [4:0]  task2b_Decrypted_Message_address,
    input  logic [7:0]  task2b_Decrypted_Message_data,
    input  logic        task2b_Decrypted_Message_wren,

    output logic [4:0]  Decrypted_Message_address,
    output logic [7:0]  Decrypted_Message_data,
    output logic        Decrypted_Message_wren
);

/*
always_ff @(posedge clk) 
begin
        if (!task1_done_flag) 
        begin
            s_address <= task1_s_address;
            s_data    <= task1_s_data;
            s_wren    <= task1_s_wren;
        end else if (!task2a_done_flag) begin
            s_address <= task2a_s_address;
            s_data    <= task2a_s_data;
            s_wren    <= task2a_s_wren;
        end else begin
            s_address <= task2b_s_address;
            s_data    <= task2b_s_data;
            s_wren    <= task2b_s_wren;
        end
end
*/
/*
assign s_address = (!task1_done_flag)     ? task1_s_address  :
                   (!task2a_done_flag)    ? task2a_s_address :
                                            task2b_s_address;

assign s_data    = (!task1_done_flag)     ? task1_s_data  :
                   (!task2a_done_flag)    ? task2a_s_data :
                                            task2b_s_data;

assign s_wren    = (!task1_done_flag)     ? task1_s_wren  :
                   (!task2a_done_flag)    ? task2a_s_wren :
                                            task2b_s_wren;
*/

/*
always_ff @(posedge clk, posedge reset) begin
    if (reset) begin
        s_wren    <= 1'b0;
    end else if (!task1_done_flag) begin
        s_address <= task1_s_address;
        s_data    <= task1_s_data;
        s_wren    <= task1_s_wren;
    end else if (!task2a_done_flag) begin
        s_address <= task2a_s_address;
        s_data    <= task2a_s_data;
        s_wren    <= task2a_s_wren;
    end else begin
        s_address <= task2b_s_address;
        s_data    <= task2b_s_data;
        s_wren    <= task2b_s_wren;
    end
end

*/
/*
    assign Decrypted_Message_address = (!switch_flag) ? task2b_Decrypted_Message_address : valid_Decrypted_Message_address;
    assign Decrypted_Message_data    = (!switch_flag) ? task2b_Decrypted_Message_data    : 8'b0;
    assign Decrypted_Message_wren    = (!switch_flag) ? task2b_Decrypted_Message_wren    : valid_Decrypted_Message_wren;
*/
endmodule