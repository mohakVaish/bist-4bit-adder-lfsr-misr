`timescale 1ns/1ps
// tb_extract_golden.v
// Runs LFSR -> 4-bit adder -> MISR for N cycles and prints the golden signature.

module tb_extract_golden;
    parameter integer TEST_CYCLES = 64;  // set 255 for longer run
    parameter [7:0]   SEED        = 8'h01;

    reg clk = 1'b0;
    reg rst = 1'b1;
    always #5 clk = ~clk;   // 100 MHz

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
    adder4     #(.INJECT_FAULT(1'b0)) u_adder  (.a(a), .b(b), .sum5(sum5)); // GOOD DUT
    misr_5bit  #(.INIT(5'b00000))      u_misr   (.clk(clk), .rst(rst), .enable(enable),
                                                 .data_in(sum5), .signature(signature));

    initial begin
        $dumpfile("golden_extract.vcd");
        $dumpvars(0, tb_extract_golden);
    end

    initial begin
        @(negedge rst);
        wait (cycle_cnt == TEST_CYCLES);
        #1;
        $display("\n=== GOLDEN SIGNATURE ===");
        $display("Config: TEST_CYCLES=%0d, SEED=0x%0h", TEST_CYCLES, SEED);
        $display("Golden = 0x%0h", signature);
        $display("========================\n");
        #20 $finish;
    end
endmodule
