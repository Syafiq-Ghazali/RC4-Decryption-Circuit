// TESTBENCH
module task2a_tb();

    logic clk;
    logic [23:0] secret_key;
    logic [7:0]  s_q;
    logic start_task2a;
    logic reset;
    logic s_wren;
    logic [7:0] s_address;
    logic [7:0] s_data;
    logic task2a_done_flag;

    task2a DUT(
        .clk(clk),
        .secret_key(secret_key),
        .s_q(s_q),
        .start_task2a(start_task2a),
        .reset(reset),
        .s_wren(s_wren),
        .s_address(s_address),
        .s_data(s_data),
        .task2a_done_flag(task2a_done_flag)
    );

    logic [7:0] s_memory [0:255];

    initial clk = 0;
    always #2 clk = ~clk;

    // Read from memory (combinational)
    always_comb begin
        s_q = s_memory[s_address];
    end

    // Write + initialize on reset
    always_ff @(posedge clk) begin
        if (reset) begin
            for (int i = 0; i < 256; i++) begin
                s_memory[i] <= i[7:0];
            end
        end else if (s_wren) begin
            s_memory[s_address] <= s_data;
        end
    end

    // Simulation sequence
    initial begin
        reset = 1;
        start_task2a = 0;
        secret_key = 24'h000249;

        #10;
        reset = 0;
        #10;
        start_task2a = 1;

        wait (task2a_done_flag);

        $display("TASK 2A DONE: FINAL S MEMORY:");
        for (int i = 0; i < 256; i++) begin
            $display("S[%0d] = %02h", i, s_memory[i]);
        end

        $stop;
    end

endmodule
