`timescale 1ns/1ps

// func[2:0]:
// 000 = ADD
// 001 = SUB
// 010 = INC
// 011 = DEC
// 100 = SLT
// 101 = SGT

module arith_unit32(
    input  [31:0] a, b,
    input  [2:0]  func,
    output [31:0] out,
    output        ovf
);

wire [31:0] one = 32'd1;

// ===== B input MUX =====
// b_sel depends on func
wire [31:0] b_add   = b;       // ADD
wire [31:0] b_sub   = ~b;      // SUB
wire [31:0] b_inc   = one;     // INC
wire [31:0] b_dec   = ~one;     // DEC (a + ~1 + 1)
wire [31:0] b_slt   = ~b;      // SLT (a-b)
wire [31:0] b_sgt   = ~a;      // SGT (b-a)

wire [31:0] a_sgt = b; // for SGT

wire [31:0] b_sel =
    (func == 3'b000) ? b_add :
    (func == 3'b001) ? b_sub :
    (func == 3'b010) ? b_inc :
    (func == 3'b011) ? b_dec :
    (func == 3'b100) ? b_slt :
    (func == 3'b101) ? b_sgt : 32'b0;

wire [31:0] a_sel =
    (func == 3'b101) ? a_sgt : a; // for SGT

// ===== Cin MUX =====
wire cin_add = 1'b0;
wire cin_sub = 1'b1;
wire cin_inc = 1'b0;
wire cin_dec = 1'b1;
wire cin_slt = 1'b1;
wire cin_sgt = 1'b1;

wire cin_sel =
    (func == 3'b000) ? cin_add :
    (func == 3'b001) ? cin_sub :
    (func == 3'b010) ? cin_inc :
    (func == 3'b011) ? cin_dec :
    (func == 3'b100) ? cin_slt :
    (func == 3'b101) ? cin_sgt : 1'b0;

// ===== Adder =====
wire [31:0] adder_result;
wire cout, of;

ripple_adder_32 adder(
    .a(a_sel),
    .b(b_sel),
    .cin(cin_sel),   // effectively acts like carry-in
    .sum(adder_result),
    .cout(cout),
    .overflow(of)
);

// ===== SLT/SGT detection =====
wire signed_less    = adder_result[31] ^ of; // from (a-b)
wire signed_greater = adder_result[31] ^ of; // from (b-a)

// ===== Output MUX =====
assign out =
    (func == 3'b000) ? adder_result :   // ADD
    (func == 3'b001) ? adder_result :   // SUB
    (func == 3'b010) ? adder_result :   // INC
    (func == 3'b011) ? adder_result :   // DEC
    (func == 3'b100) ? {31'b0, signed_less} :    // SLT
    (func == 3'b101) ? {31'b0, signed_greater} : // SGT
    32'b0;

// ===== Overflow =====
assign ovf = (func==3'b100 || func==3'b101) ? 1'b0 : of;

endmodule
