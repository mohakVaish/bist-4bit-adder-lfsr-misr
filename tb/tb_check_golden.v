`timescale 1ns/1ps
// tb_check_golden.v
// Re-runs the chain for N cycles and checks signature == GOLDEN_SIG.

module tb_check_golden;
    parameter integer TEST_CYCLES = 64;     // set to 255 if that’s what you extracted
    parameter [7:0]   SEED        = 8'h01;
    parameter [4:0]   GOLDEN_SIG  = 5'h16;  // <--- Replace with your printed golden

    reg clk = 1'b0;
    reg rst = 1'b1;
    always #5 clk = ~clk;

    initial begin
        rst = 1'b1; #20; rst = 1'b0;
    end

    reg  [15:0] cycle_cnt = 16'd0;
    wire        enable    = (!rst) && (cycle_cnt < TEST_CYCLES);
    always @(posedge clk) begin
        if (rst)         cycle_cnt <= 16'd0;
        else if (enable) cycle_cnt <= cycle_cnt + 16'd1;
    end

    wire [7:0] lfsr_q;
    wire [3:0] a = lfsr_q[3:0];
    wire [3:0] b = lfsr_q[7:4];
    wire [4:0] sum5;
    wire [4:0] signature;

    lfsr_8bit #(.SEED(SEED)) u_lfsr (.clk(clk), .rst(rst), .enable(enable), .lfsr(lfsr_q));
    adder4     #(.INJECT_FAULT(1'b0)) u_adder  (.a(a), .b(b), .sum5(sum5));
    misr_5bit  #(.INIT(5'b00000))      u_misr   (.clk(clk), .rst(rst), .enable(enable),
                                                 .data_in(sum5), .signature(signature));

    // handy probe for EPWave
    wire match = (signature === GOLDEN_SIG);

    initial begin
        $dumpfile("check_golden.vcd");
        $dumpvars(0, tb_check_golden);
    end

    initial begin
        @(negedge rst);
        wait (cycle_cnt == TEST_CYCLES);
        #1;

        $display("\n=== CHECK RESULT ===");
        $display("Config: TEST_CYCLES=%0d, SEED=0x%0h", TEST_CYCLES, SEED);
        $display("Observed signature = 0x%0h", signature);
        $display("Expected (GOLDEN) = 0x%0h", GOLDEN_SIG);
        if (signature === GOLDEN_SIG) $display("PASS: MISR matches golden.");
        else                          $display("FAIL: MISR does NOT match golden.");

        #20 $finish;
    end
endmodule
