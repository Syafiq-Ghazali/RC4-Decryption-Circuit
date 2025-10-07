module task2b_tb();

    logic clk;
    logic reset;
    logic start_task_2b;
    logic [7:0] s_q;
    logic [7:0] secret_message_q;
    logic [4:0] secret_message_address;

    logic s_wren;
    logic [7:0] s_address;
    logic [7:0] s_data;

    logic [4:0] Decrypted_Message_address;
    logic [7:0] Decrypted_Message_data;
    logic Decrypted_Message_wren;
    logic task2b_done_flag;

    // Instantiate DUT
    task2b DUT (
        .clk(clk),
        .reset(reset),
        .start_task_2b(start_task_2b),
        .s_q(s_q),
        .secret_message_q(secret_message_q),
        .secret_message_address(secret_message_address),
        .s_wren(s_wren),
        .s_address(s_address),
        .s_data(s_data),
        .Decrypted_Message_address(Decrypted_Message_address),
        .Decrypted_Message_data(Decrypted_Message_data),
        .Decrypted_Message_wren(Decrypted_Message_wren),
        .task2b_done_flag(task2b_done_flag)
    );

    // Simulated S-memory and secret message memory
    logic [7:0] s_memory [0:255];
    logic [7:0] secret_message_mem [0:31];

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk;

    // Combinational read logic
    always_comb begin
        s_q = s_memory[s_address];
        secret_message_q = secret_message_mem[secret_message_address];
    end

    // Memory init + write logic (single always_ff block)
    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < 256; i++) begin
                s_memory[i] <= i[7:0]; // Equivalent to Task 1 init
            end
        end else if (s_wren) begin
            s_memory[s_address] <= s_data;
        end
    end

    // Simulation sequence
    initial begin
        // Initialize secret message memory (example: xor'd with 0xAA)
        for (int i = 0; i < 32; i++) begin
            secret_message_mem[i] = i[7:0] ^ 8'hAA;
        end

        reset = 1;
        start_task_2b = 0;
        #20;

        reset = 0;
        #10;
        start_task_2b = 1;

        wait(task2b_done_flag);

        $display("Decrypted Output:");
        for (int i = 0; i < 32; i++) begin
            $display("Decrypted[%0d] = %h", i, DUT.Decrypted_Message_data);
        end

        $stop;
    end

endmodule
