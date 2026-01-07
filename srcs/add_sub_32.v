// add_sub_32.v
// sub=0 => ADD, sub=1 => SUB
`timescale 1ns/1ps

module add_sub_32(
    input  [31:0] a, b,
    input         sub,   // 0=add, 1=sub
    output [31:0] res,
    output        cout,
    output        overflow
);
wire [31:0] b_mod = b ^ {32{sub}};
wire cin = sub;
ripple_adder_32 adder(.a(a), .b(b_mod), .cin(cin), .sum(res), .cout(cout), .overflow(overflow));
endmodule

