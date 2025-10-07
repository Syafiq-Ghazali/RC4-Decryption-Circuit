module valid_key_checker(
    input logic clk,
    input logic start,
    input logic reset,

    output logic valid_flag,
    output logic key_checker_done,

    output logic [4:0] valid_Decrypted_Message_address,
    output logic       valid_task2b_Decrypted_Message_wren,
    input logic  [7:0] Decrypted_Message_q
);

////////////////////////////// Signal Declaration///////////////////////////////
logic valid = 1'b0;
logic done_flag = 1'b0;

logic [7:0] counter = 8'd0;
logic [7:0] valid_counter = 8'd0;

logic [7:0] data_q;

//////////////////////////////Assign Declaration/////////////////////////////////

assign valid_flag = valid;
assign key_checker_done = done_flag;

assign valid_task2b_Decrypted_Message_wren = 1'b0;  //always low never write


typedef enum logic [7:0] {

    check           = 8'd0,
    load_address    = 8'd1,
    wait_address1   = 8'd2,
    wait_address2   = 8'd3,
    store_data      = 8'd4,
    check_valid     = 8'd5,
    valid_addr      = 8'd6,
    counter_state   = 8'd7
} states;

states state = check; 

always_ff @(posedge clk)
    begin
        if (reset)
        begin
            counter <= 8'd0;
            done_flag <= 1'b0;
            valid     <= 1'b0;
            valid_counter <= 8'b0;
            state <= check;
        end 
        else if (start && !done_flag)
            begin
                case(state)

                    check:
                    begin
                        if (counter == 8'd32 )
                        begin
                            if (valid_counter == 8'd32)
                            begin
                                valid <= 1'b1;
                            end
                            done_flag <= 1;
                            state <= check;
                        end
                        else
                        begin
                        valid <= 1'b0;
                        state <= load_address;
                        end
                    end

                    load_address:
                    begin
                        valid_Decrypted_Message_address <= counter;
                        state <= wait_address1;
                    end

                    wait_address1: state <= wait_address2;
                    wait_address2: state <= store_data;

                    store_data:
                    begin
                        data_q <= Decrypted_Message_q;
                        state  <= check_valid;
                    end

                    check_valid:
                    begin
                            if ( ((data_q <= 8'd122) && (data_q >= 8'd97) ) || (data_q == 8'd32))
                            state <= valid_addr;
                                else state <= counter_state;
                    end

                    valid_addr:
                    begin
                        valid_counter <= valid_counter + 8'd1;
                        state <= counter_state;
                    end
                    
                    counter_state:
                    begin
                        counter <= counter + 8'd1;
                        state <= check;
                    end
                    

                endcase
            end
    end
endmodule