module task2a
(
input logic clk,
input logic [23:0] secret_key,
input logic [7:0]  s_q,
input logic start_task2a,
input logic reset,
output logic s_wren,
output logic [7:0] s_address,
output logic [7:0] s_data,
output logic       task2a_done_flag

);

logic [7:0] j_counter = 8'b0;
logic [7:0] i_counter = 8'b0;
logic i_done_flag =1'b0;
logic [7:0] temp_i;
logic [7:0] temp_j;
logic [7:0] key_index;
logic [7:0] key_data;


logic task2a_done_flag_intialization;

assign task2a_done_flag = task2a_done_flag_intialization;

typedef enum logic [7:0] {
    check          = 8'd0,
    set_i_address  = 8'd1,
    key_index_math = 8'd2,
    save_i         = 8'd3,
    j_counter_math = 8'd4,
    set_j_address  = 8'd5,
    j_wait         = 8'd6,
    save_j         = 8'd7,
    swap_j         = 8'd8,
    save_temp_i    = 8'd9,
    swap_i         = 8'd10,
    wait1          = 8'd29,
    wait2          = 8'd30,
    wait3          = 8'd31,
    wait4          = 8'd32,
    wait5          = 8'd33,
    wait6          = 8'd34
} states;

states state = set_i_address;

always_ff @(posedge clk)
if (reset)
begin
    i_done_flag <= 1'b0;
    i_counter   <= 8'd0;
    j_counter   <= 8'd0;
    key_index   <= 2'b0;
    key_data    <= 8'd0;
    s_wren      <= 1'b0;
    temp_i      <= 8'd0;
    temp_j      <= 8'd0;
    state       <= set_i_address;
    task2a_done_flag_intialization <= 1'b0;
end else
    if (~i_done_flag && start_task2a)  
    begin
        case(state) 

        set_i_address: 
        begin 
            s_wren    <= 1'b0;
            s_address <= i_counter;                     // Select i_counter address
            key_index <= i_counter % 8'd3;                 // key_index math
            state     <= key_index_math;                        //
        end

        key_index_math:
        begin
            case (key_index)
                8'd0: key_data <= secret_key[23:16];
                8'd1: key_data <= secret_key[15:8];//secret_key[15:8];
                8'd2: key_data <= secret_key[7:0];
            endcase
            state     <= wait1;
        end

        wait1: state <= wait2;
        wait2: state <= wait3;
        wait3: state <= save_temp_i;

        save_temp_i:
        begin
            temp_i    <= s_q;
            state     <= save_i;
        end

        save_i:
        begin
                                        // temp_i = s[i]
            s_wren      <= 1'b0;
            state     <= j_counter_math;
        end

        j_counter_math:
        begin
            s_wren      <= 1'b0;                             // Go into write 
            j_counter <= (j_counter + temp_i + key_data) ;    //j_counter math
            state     <= set_j_address;
        end

        set_j_address:
        begin
            s_address   <= j_counter;                     // Go into j_counter address
            state       <= wait4;
        end

        wait4: state <= wait5;
        wait5: state <= wait6;
        wait6: state <= save_j;

        save_j:
        begin
            temp_j      <= s_q;                         //temp_j = s[j]
            state       <= swap_j;
        end

        swap_j:
        begin
            s_wren       <= 1'b1;
            s_address    <= j_counter;                  // j_address = s[i]
            s_data       <= temp_i;
            state        <= swap_i;
        end

        swap_i:
        begin
            s_wren       <= 1'b1;
            s_address    <= i_counter;                 // i_address = s[j]
            s_data       <= temp_j;
            state <= check;
        end

        check:
        begin
            s_wren       <= 1'b0;
            if (i_counter == 8'd255)       //checks if the counter has reach 255
            begin
                i_done_flag <= 1'b1;           // if it is flag is turn on
                s_wren      <= 1'b0;           // and write is turned off 
                task2a_done_flag_intialization <= 1'b1;
                state       <= check;
            end 
            else 
            begin
                s_wren    <= 1'b0;                             // Go into write
                i_counter <= i_counter + 8'd1;
                state <= set_i_address; 
            end
        end

        default:
        begin
            s_wren <= 0;
            state <= set_i_address;
        end
        endcase
    end

endmodule