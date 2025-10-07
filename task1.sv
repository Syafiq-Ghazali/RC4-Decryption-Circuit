module task1
(
input  logic clk,
input  logic reset,
input  logic start_task1,
output logic s_wren,
output logic [7:0] s_address,
output logic [7:0] s_data,
output logic task1_done
);

logic [7:0] s_memory_counter = 8'd0;


typedef enum logic [2:0] {
    increment = 3'b0_0_1,
    check     = 3'b0_1_0,
    done      = 3'b1_0_0
} states;

states state = increment;

assign s_wren                = state[0];
assign task1_done            = state[2];

always_ff @(posedge clk)
begin
    if (reset)
    begin
    s_memory_counter <= 8'd0;
    state            <= increment;
    end
        else if (!task1_done && start_task1)
        begin
            case(state)
                increment:
                begin
                    s_address           <= s_memory_counter;                      // store counter address to memory
                    s_data              <= s_memory_counter;                      // store counter to memory        
                    state               <= check;             
                end
                check:
                begin
                    if ( s_memory_counter == 8'd255)                              //If s_memory_counter = 255 go to done
                    begin                                                         //else counter++
                        state            <= done;                                 //then go to increment state
                    end
                    else
                    begin
                        s_memory_counter <= s_memory_counter + 8'd1; 
                        state            <= increment;
                    end  
                end

                done: state              <= done;                                 //forever loop & done flag on
            endcase
        end
end

endmodule