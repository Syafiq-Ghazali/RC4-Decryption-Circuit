module message_cracker_tb();

    logic clk;
    logic reset, task2b_done_flag;
    logic valid_flag;
    logic [21:0] secret_key;
    logic [4:0] valid_Decrypted_Message_address;
    logic valid_Decrypted_Message_wren;
    logic [7:0] Decrypted_Message_q;
    logic [4:0] task2b_Decrypted_Message_address;
    logic [7:0] task2b_Decrypted_Message_data;
    logic task2b_Decrypted_Message_wren;
    logic [4:0] Decrypted_Message_address;
    logic [7:0] Decrypted_Message_data;
    logic Decrypted_Message_wren;
    logic [9:0] LED_on;
    logic start_task1, start_task2a, start_task2b;
    logic task1_done, task2a_done;

    logic [7:0] task1_s_address, task2a_s_address, task2b_s_address;
    logic [7:0] task1_s_data, task2a_s_data, task2b_s_data;
    logic task1_s_wren, task2a_s_wren, task2b_s_wren;
    logic [7:0] s_address, s_data;
    logic s_wren;

    // DUT instantiation
    message_cracker dut (
        .clk(clk),
        .task2b_done_flag(task2b_done_flag),
        .reset(reset),
        .valid_flag(valid_flag),
        .secret_key(secret_key),
        .valid_Decrypted_Message_address(valid_Decrypted_Message_address),
        .valid_Decrypted_Message_wren(valid_Decrypted_Message_wren),
        .Decrypted_Message_q(Decrypted_Message_q),
        .task2b_Decrypted_Message_address(task2b_Decrypted_Message_address),
        .task2b_Decrypted_Message_data(task2b_Decrypted_Message_data),
        .task2b_Decrypted_Message_wren(task2b_Decrypted_Message_wren),
        .Decrypted_Message_address(Decrypted_Message_address),
        .Decrypted_Message_data(Decrypted_Message_data),
        .Decrypted_Message_wren(Decrypted_Message_wren),
        .LED_on(LED_on),
        .start_task1(start_task1),
        .start_task2a(start_task2a),
        .start_task2b(start_task2b),
        .task1_done(task1_done),
        .task2a_done(task2a_done),
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
        .s_wren(s_wren)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Dummy S-RAM for simulating s_q reads
    logic [7:0] memory [0:255];

    // Stimulus logic
    initial begin
        // Initialize signals
        reset = 0;
        task1_done = 0;
        task2a_done = 0;
        task2b_done_flag = 0;
        Decrypted_Message_q = 8'h00;
        task2b_Decrypted_Message_address = 5'd0;
        task2b_Decrypted_Message_data = 8'h00;
        task2b_Decrypted_Message_wren = 0;
        valid_flag = 0;

        // Trigger reset
        #10 reset = 1;
        #10 reset = 0;

        // Simulate Task 1 complete
        #100 task1_done = 1;

        // Simulate Task 2A complete
        #100 task2a_done = 1;

        // Simulate Task 2B completion and memory writes
        repeat (32) begin
            @(posedge clk);
            task2b_Decrypted_Message_address <= task2b_Decrypted_Message_address + 1;
            task2b_Decrypted_Message_data    <= $random;
            task2b_Decrypted_Message_wren    <= 1;
        end
        task2b_done_flag = 1;

        // Simulate valid_key_checker response
        #100 valid_flag = 1;

        // Observe LED output
        #50;

        $display("Final secret key: %b", secret_key);
        $display("LED status: %b", LED_on);

        $finish;
    end

endmodule
