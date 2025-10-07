module task2b
(
    input logic        clk,
    input logic  [7:0] s_q,

    input logic        start_task_2b,

    input  logic [7:0]  secret_message_q,
    input  logic        reset,
    output logic [4:0]  secret_message_address,

    output logic       s_wren,
    output logic [7:0] s_address,
    output logic [7:0] s_data,

    output logic [4:0] Decrypted_Message_address,
    output logic [7:0] Decrypted_Message_data,
    output logic       Decrypted_Message_wren,

    output logic       task2b_done_flag
);

logic [7:0] i_counter = 8'd0;
logic [7:0] j_counter = 8'd0;

logic [7:0] temp_i;
logic [7:0] temp_j;

logic [4:0] k_counter = 5'd0;

logic [7:0] f_data;

logic [7:0] Decrypted_Message_data_store;
logic [7:0] secret_message_q_store;

logic k_done_flag =0;

assign task2b_done_flag = k_done_flag;
typedef enum logic [7:0] {
    check            = 8'd0,
    i_counter_state  = 8'd1,
    set_i_address    = 8'd2,
    save_i           = 8'd4,
    j_counter_state  = 8'd5,
    set_j_address    = 8'd6,
    wait_j           = 8'd7,
    swap_j           = 8'd9,
    swap_i           = 8'd10,
    new_s_address    = 8'd11,
    save_f_data      = 8'd13,
    k_logic          = 8'd15,
    save_sm_q        = 8'd19,
    xor_data         = 8'd20,
    begin_state      = 8'd27,
    load_k_counter   = 8'd30,
    wait1            = 8'd34,
    wait2            = 8'd35,
    wait3            = 8'd36,
    wait4            = 8'd37,
    wait5            = 8'd38,
    wait6            = 8'd39,
    wait7            = 8'd40,
    wait8            = 8'd41,
    wait9            = 8'd42,
    wait10           = 8'd43,
    wait11           = 8'd44,
    wait12           = 8'd45
} states;

states state = begin_state;

always_ff @(posedge clk)
    begin
    if (reset)
        begin
            k_done_flag <= 1'd0;
            i_counter   <= 8'd0;
            j_counter   <= 8'd0;
            k_counter   <= 5'd0;
            temp_i      <= 8'd0;
            temp_j      <= 8'd0;
            s_address   <= 8'd0;
            s_data      <= 8'd0;
            s_wren      <= 1'b0;
            state       <= begin_state;
            Decrypted_Message_wren <= 1'b0;
        end 
        else if (!k_done_flag && start_task_2b)
        begin
            case(state)

                begin_state:
                    begin
                    i_counter <= i_counter + 8'd1; 
                    state  <= i_counter_state;
                    end

                i_counter_state:
                    begin
                        s_wren <= 1'b0;                    //write off 
                        i_counter <= i_counter;
                        state     <= set_i_address;   
                    end

                set_i_address:
                    begin
                        s_address <= i_counter;         // set i address
                        state     <= wait1;
                    end

                wait1: state <= wait2;
                wait2: state <= wait3;
                wait3: state <= save_i;

                save_i:
                    begin
                        temp_i <= s_q;                 //take i
                        state  <= j_counter_state;
                    end

                j_counter_state:
                    begin
                        s_wren    <= 1'b0;
                        j_counter <= j_counter + temp_i;        // j = j+s[i]
                        state     <= set_j_address;
                    end

                set_j_address:
                    begin
                        s_address <= j_counter;                 //set j address
                        state <= wait4;
                    end

                wait4: state <= wait5;
                wait5: state <= wait6;
                wait6: state <= wait_j;

                wait_j:
                    begin
                        temp_j <= s_q;                      // temp_j = s[j]
                        state  <= swap_j;
                    end

            //////////////////////////////swap s[i] and s[j]////////////////////
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
                        state <= new_s_address;
                    end

            /////////////////////////////////////////////////////////////////////
                new_s_address:
                    begin
                        s_wren <= 1'b0;
                        s_address <= (temp_j + temp_i);               // find new s address
                        state <= wait7;
                    end

                wait7: state <= wait8;
                wait8: state <= wait9;
                wait9: state <= save_f_data;

                save_f_data:
                    begin
                        f_data <= s_q;                             // save new value to f_data
                        state <= load_k_counter;                     // 
                    end

                load_k_counter:
                    begin
                        secret_message_address <= k_counter;       //set address to k
                        state <= wait10;
                    end

                wait10: state  <= wait11;
                wait11: state  <= wait12;
                wait12: state <= save_sm_q;

                save_sm_q:
                    begin
                        secret_message_q_store       <=  secret_message_q;
                        state <= xor_data;
                    end

                xor_data:
                    begin
                        Decrypted_Message_data_store <=  secret_message_q_store ^ f_data;
                        state <= k_logic;
                    end

                k_logic:
                    begin
                        Decrypted_Message_wren <= 1'b1;                 // write into decrypted message
                        Decrypted_Message_address <= k_counter;         // decrypted_output[k] = f xor encrypted_input[k]
                        Decrypted_Message_data <= Decrypted_Message_data_store;
                        state <= check;
                    end

                check:
                    begin
                        if ( k_counter == 5'd31 )          //Checks if flag is done
                        begin
                            k_done_flag <= 1'b1;
                            state       <= check;
                            Decrypted_Message_wren <= 1'b0;
                        end else
                        begin
                        state <= begin_state;   
                        Decrypted_Message_wren <= 1'b0; 
                        k_counter <= k_counter + 5'd1;
                        s_wren <= 1'b0;                    //write off 
                        end 
                    end

                default:
                    begin
                        Decrypted_Message_wren <= 1'b0;
                        s_wren                 <= 1'b0;
                        state <= begin_state;
                    end

            endcase
        end
    end
endmodule
