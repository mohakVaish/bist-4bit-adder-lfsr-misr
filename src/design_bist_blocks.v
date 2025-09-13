// design_bist_blocks.v
// Reusable building blocks: 4-bit adder, 8-bit LFSR, 5-bit MISR 

// 4-bit adder
module adder4
#(
    parameter INJECT_FAULT = 1'b0,
    parameter [4:0] FAULT_MASK = 5'b00001
)
(
    input  [3:0] a,
    input  [3:0] b,
    output [4:0] sum5   // {carry, sum[3:0]}
);
    wire [4:0] s;
    assign s    = a + b;
    assign sum5 = INJECT_FAULT ? (s ^ FAULT_MASK) : s;
endmodule

// 8-bit LFSR: x^8 + x^6 + x^5 + x^4 + 1 (taps 7,5,4,3)
// Shift into LSB (right-shift form with feedback to bit0)
module lfsr_8bit
#(
    parameter [7:0] SEED = 8'h01   // non-zero!
)
(
    input        clk,
    input        rst,     // sync reset
    input        enable,
    output [7:0] lfsr
);
    reg  [7:0] lfsr_r;
    wire       feedback;

    assign feedback = lfsr_r[7] ^ lfsr_r[5] ^ lfsr_r[4] ^ lfsr_r[3];
    assign lfsr     = lfsr_r;

    always @(posedge clk) begin
        if (rst)         lfsr_r <= SEED;
        else if (enable) lfsr_r <= {lfsr_r[6:0], feedback};
    end
endmodule

// 5-bit MISR: x^5 + x^2 + 1
module misr_5bit
#(
    parameter [4:0] INIT = 5'b00000
)
(
    input        clk,
    input        rst,         // sync reset
    input        enable,
    input  [4:0] data_in,     // {carry,sum[3:0]}
    output [4:0] signature
);
    reg  [4:0] sig_r;
    wire [4:0] next;

    assign next[0] = sig_r[4] ^ data_in[0];
    assign next[1] = sig_r[0] ^ sig_r[4] ^ data_in[1];
    assign next[2] = sig_r[1] ^ data_in[2];
    assign next[3] = sig_r[2] ^ data_in[3];
    assign next[4] = sig_r[3] ^ data_in[4];

    assign signature = sig_r;

    always @(posedge clk) begin
        if (rst)         sig_r <= INIT;
        else if (enable) sig_r <= next;
    end
endmodule
