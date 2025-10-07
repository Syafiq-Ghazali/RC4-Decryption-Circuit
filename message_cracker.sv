module message_cracker(
    input logic clk,
    input logic task2b_done_flag,
    output logic reset,
    output logic valid_flag,
    output logic [21:0] secret_key,

    output logic [4:0] valid_Decrypted_Message_address,
    output logic       valid_Decrypted_Message_wren,
    input  logic [7:0] Decrypted_Message_q,

    input  logic [4:0]  task2b_Decrypted_Message_address,
    input  logic [7:0]  task2b_Decrypted_Message_data,
    input  logic        task2b_Decrypted_Message_wren,

    output logic [4:0]  Decrypted_Message_address,
    output logic [7:0]  Decrypted_Message_data,
    output logic        Decrypted_Message_wren,

    output logic [9:0] LED_on,
    output logic       start_task1,
    output logic       start_task2a,
    output logic       start_task2b,

    input              task1_done,
    input              task2a_done,

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
    output logic        s_wren

);




logic assign_flag = 0;
logic key_checker_done;

logic [21:0] secret_key_reg = 22'b000000_00000000_00000000;   // intial start
//logic [21:0] secret_key_reg = 22'b000000_00000011_11111111; // for msg2
//logic [21:0] secret_key_reg = 22'b000000_00000010_10101010; // for msg3 
//logic [21:0] secret_key_reg = 22'b001000_01111011_00101101; // for msg4
//logic [21:0] secret_key_reg = 22'b111111_11111111_11111111; // for msg8

assign secret_key = secret_key_reg;

typedef enum logic [7:0] {
    reset_state   = 8'd0,
    start_state  = 8'd1,
    start_task2b_state = 8'd2,
    check_key = 8'd3,
    valid_key_check = 8'd4,
    done_state = 8'd5,
    fail = 8'd6,
    wait_reset_1 = 8'd7,
    assign_state = 8'd8,
    start_task1_state = 8'd9,
    wait_reset_2 = 8'd13,
    incrementer = 8'd14,
    start_task2a_state = 8'd15
} states;

states state = reset_state; 

always_ff @(posedge clk)
begin
    case(state)

        reset_state: // do the proccess and if task2b_done flag is turned on go to check
        begin
            reset           <= 1;
            start_task1     <= 1'b0;
            start_task2a    <= 1'b0;
             start_task2b   <= 1'b0;
            assign_flag     <= 0;
            LED_on          <= 10'b0;
            state           <= wait_reset_1;
        end

        wait_reset_1: state <= wait_reset_2;
        wait_reset_2: state <= start_state;

        start_state: // check if the key is correct if not go back to restart if it is go to done
        begin
            reset <= 1'b0;
            start_task1 <= 1'b1;
            state <= start_task1_state;
        end

        start_task1_state:
        begin
            if (task1_done)
            begin
            start_task2a <= 1'b1;
            state <= start_task2a_state;
            end else
            begin
                s_address <= task1_s_address;
                s_data    <= task1_s_data;
                s_wren    <= task1_s_wren;
                state     <= start_task1_state;
            end
        end

        start_task2a_state:
        begin
            if (task2a_done)
            begin
             start_task2b <= 1'b1;
             state <= start_task2b_state;               
            end else
            begin
                s_address <= task2a_s_address;
                s_data    <= task2a_s_data;
                s_wren    <= task2a_s_wren;
                state     <= start_task2a_state;
            end

        end

        start_task2b_state:
        begin
            if (task2b_done_flag)
                begin
                    state <= assign_state;
                end
                    else 
                    begin
                        s_address <= task2b_s_address;
                        s_data    <= task2b_s_data;
                        s_wren    <= task2b_s_wren;
                        state     <= start_task2b_state;
                    end

        end

        assign_state:
        begin
            assign_flag <= 1'b1;
            state <= check_key;
        end

        check_key:
        begin
            if (key_checker_done)
                    begin
                        state <= valid_key_check;
                    end
                        else state <= check_key;
        end

        valid_key_check:
        begin
            if (valid_flag ) 
            begin
                state <= done_state;
            end 
                else
                if ( secret_key_reg == 22'b1111111111111111111111)
                    begin
                        state <= fail;
                    end 
                    else 
                        begin
                            state <= incrementer;
                        end 
        end

        incrementer:
        begin
            secret_key_reg <= secret_key_reg + 22'd1;
            state <= reset_state;
        end

        done_state:
        begin
            LED_on <= 10'b1111111111;
        end

        fail:
        begin
            LED_on <= 10'b0000000001;
        end

    endcase
end

always_ff @(posedge clk)
begin
     Decrypted_Message_address <= (!assign_flag) ? task2b_Decrypted_Message_address : valid_Decrypted_Message_address;
     Decrypted_Message_data    <= (!assign_flag) ? task2b_Decrypted_Message_data    : 8'b0;
     Decrypted_Message_wren    <= (!assign_flag) ? task2b_Decrypted_Message_wren    : valid_Decrypted_Message_wren;
end

valid_key_checker validkey(
    .clk(clk),
    .start(assign_flag),
    .reset(reset),
    .valid_flag(valid_flag),
    .key_checker_done(key_checker_done),
    .valid_Decrypted_Message_address(valid_Decrypted_Message_address),
    .valid_task2b_Decrypted_Message_wren(valid_Decrypted_Message_wren),
    .Decrypted_Message_q(Decrypted_Message_q)
);

endmodule