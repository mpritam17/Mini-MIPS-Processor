// ripple_adder_32.v
`timescale 1ns/1ps

module ripple_adder_32(
    input  [31:0] a, b,
    input         cin,
    output [31:0] sum,
    output        cout,
    output        overflow
);
wire [32:0] carry;
assign carry[0] = cin;

genvar i;
generate
    for (i=0; i<32; i=i+1) begin : fa_loop
        full_adder fa(.a(a[i]), .b(b[i]), .cin(carry[i]), .sum(sum[i]), .cout(carry[i+1]));
    end
endgenerate

assign cout     = carry[32];
assign overflow = carry[32] ^ carry[31];
endmodule
