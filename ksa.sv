module ksa(
    input  logic        CLOCK_50,       // Clock pin
    input  logic [3:0]  KEY,            // Push button switches
    input  logic [9:0]  SW,             // Slider switches
    output logic [9:0]  LEDR,           // Red lights
    output logic [6:0]  HEX0,
    output logic [6:0]  HEX1,
    output logic [6:0]  HEX2,
    output logic [6:0]  HEX3,
    output logic [6:0]  HEX4,
    output logic [6:0]  HEX5
);

/////////////////////////////// ALL SIGNALS USED//////////////////////////////
logic       clk;
logic       reset;


//s_memory Signals
logic [7:0] s_address; 
logic [7:0] s_data;
logic       s_wren;
logic [7:0] s_q;

//Task_1 s_Smemory Signals
logic [7:0] task1_s_address;
logic [7:0] task1_s_data;
logic       task1_s_wren;
logic       start_task1;
logic       task1_done_flag;

//Task_2a s_memory Signals
logic [7:0] task2a_s_address;
logic [7:0] task2a_s_data;
logic       task2a_s_wren;
logic       start_task2a;
logic       task2a_done_flag;

//Task_2b s_memory Signal
logic [7:0] task2b_s_address;
logic [7:0] task2b_s_data;
logic       task2b_s_wren;
logic       start_task2b;
logic       task2b_done_flag;

//Decrypt Message Signals
logic [7:0] Decrypted_Message_address;
logic [7:0] Decrypted_Message_data;
logic       Decrypted_Message_wren;
logic [7:0] Decrypted_Message_q;

logic [7:0] task2b_Decrypted_Message_address;
logic [7:0] task2b_Decrypted_Message_data;
logic       task2b_Decrypted_Message_wren;


//Validification Signals
logic [7:0] valid_Decrypted_Message_address;
logic [7:0] valid_task2b_Decrypted_Message_data;
logic       valid_task2b_Decrypted_Message_wren;
logic       valid_flag;

logic [7:0] valid_Decrypted_Message_data;
logic       valid_Decrypted_Message_wren;

//Encrypted Message Signals
logic [7:0] secret_message_address;
logic [7:0] secret_message_q;

//Secret Key Signals
logic [23:0] secret_key;
logic [21:0] secret_key_decoder;

//SevenSegmentDisplayDecoder Signals

logic [3:0] hex_digit0;
logic [3:0] hex_digit1;
logic [3:0] hex_digit2;
logic [3:0] hex_digit3;
logic [3:0] hex_digit4;
logic [3:0] hex_digit5;

/////////////////////////////// Assign Logic /////////////////////////////////////// 

assign clk          = CLOCK_50;
assign secret_key   = {2'b0, secret_key_decoder};

//Hex Data encodings
assign hex_digit0   = secret_key[3:0];
assign hex_digit1   = secret_key[7:4];
assign hex_digit2   = secret_key[11:8];
assign hex_digit3   = secret_key[15:12];
assign hex_digit4   = secret_key[19:16];
assign hex_digit5   = secret_key[23:20];


////////////////////////////// Module Intializataion //////////////////////////////

//Seven Segment Decoder
//For every 4 bits corresponds to a Hex display
//
SevenSegmentDisplayDecoder Hex0_display(.nIn(hex_digit0), .ssOut(HEX0));
SevenSegmentDisplayDecoder Hex1_display(.nIn(hex_digit1), .ssOut(HEX1));
SevenSegmentDisplayDecoder Hex2_display(.nIn(hex_digit2), .ssOut(HEX2));
SevenSegmentDisplayDecoder Hex3_display(.nIn(hex_digit3), .ssOut(HEX3));
SevenSegmentDisplayDecoder Hex4_display(.nIn(hex_digit4), .ssOut(HEX4));
SevenSegmentDisplayDecoder Hex5_display(.nIn(hex_digit5), .ssOut(HEX5));

//Intialization of s_memory
//RAM memory
//256x8
s_memory memory( 
	.clock(clk),           
	.address(s_address),	
	.data(s_data),		
	.wren(s_wren),		
	.q(s_q)
);

// ROM memory
// Contains the encrypted message
//32x8
memory secret_message(
    .clock(clk),
    .address(secret_message_address),
    .q(secret_message_q)
);

//STORE DECRYPTED MESSAGE
//RAM MEMORY
//Will contain the decrypted output
//32x8
Decrypted_Message Decrypted_Message_store(
    .clock(clk),
    .address(Decrypted_Message_address),
    .data(Decrypted_Message_data),
    .wren(Decrypted_Message_wren),
    .q(Decrypted_Message_q)
);


//s_memory_logic
// for i = 0 to 255 
//   {   s[i]
//             }
//
task1 memory_logic(
    .reset(reset),
    .start_task1(start_task1),
    .clk(clk),
    .s_wren(task1_s_wren),
    .s_address(task1_s_address),
    .s_data(task1_s_data),
    .task1_done(task1_done_flag)
);

//j = 0
//for i = 0 to 255 {
//j = (j + s[i] + secret_key[i mod keylength] )
//swap values of s[i] and s[j]
//}
//Keylength is 3

//MEMORY SCARMBLE LOGIC
task2a memory_scramble(
     .clk(clk),
     .reset(reset),
     .secret_key(secret_key),
     .s_q(s_q),
     .s_wren(task2a_s_wren),
     .s_address(task2a_s_address),
     .s_data(task2a_s_data),
     .start_task2a(start_task2a),
     .task2a_done_flag(task2a_done_flag)
);

//i = 0, j=0
//for k = 0 to message_length-1 { // message_length is 32 in our implementation
//i = i+1
//j = j+s[i]
//swap values of s[i] and s[j]
//f = s[ (s[i]+s[j]) ]
//decrypted_output[k] = f xor encrypted_input[k] // 8 bit wide XOR function
//}

task2b decrypt_core (
    .clk(clk),
    .reset(reset),
    .start_task_2b(start_task2b),

    .secret_message_q(secret_message_q),
    .secret_message_address(secret_message_address),

    .s_wren(task2b_s_wren),                 
    .s_address(task2b_s_address),
    .s_data(task2b_s_data),
    .s_q(s_q),

    .Decrypted_Message_address(task2b_Decrypted_Message_address),
    .Decrypted_Message_data(task2b_Decrypted_Message_data),
    .Decrypted_Message_wren(task2b_Decrypted_Message_wren),
    .task2b_done_flag(task2b_done_flag)
);

//Contains main FSM
//Contains valid checker FSM
message_cracker message_solver(
    .clk(clk),
    .reset(reset),
    .start_task1(start_task1),
    .task2b_done_flag(task2b_done_flag),

    .valid_flag(valid_flag),
    .secret_key(secret_key_decoder),
    .valid_Decrypted_Message_address(valid_Decrypted_Message_address),
    .valid_Decrypted_Message_wren(valid_Decrypted_Message_wren),
    .Decrypted_Message_q(Decrypted_Message_q),
    .LED_on(LEDR[9:0]),

    .start_task2a(start_task2a),
    .start_task2b(start_task2b),

    .task1_done(task1_done_flag),
    .task2a_done(task2a_done_flag),

    .task1_s_address(task1_s_address),
    .task2a_s_address(task2a_s_address),
    .task2b_s_address(task2b_s_address),

    .task1_s_data(task1_s_data),
    .task2a_s_data(task2a_s_data),
    .task2b_s_data(task2b_s_data),

    .task1_s_wren(task1_s_wren),
    .task2a_s_wren(task2a_s_wren),
    .task2b_s_wren(task2b_s_wren),

    .s_address(s_address),
    .s_data(s_data),
    .s_wren(s_wren),

    .task2b_Decrypted_Message_address(task2b_Decrypted_Message_address),
    .task2b_Decrypted_Message_data(task2b_Decrypted_Message_data),
    .task2b_Decrypted_Message_wren(task2b_Decrypted_Message_wren),

    .Decrypted_Message_address(Decrypted_Message_address),
    .Decrypted_Message_data(Decrypted_Message_data),
    .Decrypted_Message_wren(Decrypted_Message_wren)
);

endmodule
