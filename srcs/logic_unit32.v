// logic_unit32.v
// func: 3'b000 AND, 001 OR, 010 XOR, 011 NOR, 100 NOT
`timescale 1ns/1ps
// func[2:0]: 000=AND, 001=OR, 010=XOR, 011=NOR, 100=NOT
module logic_unit32(
    input  [31:0] a, b,
    input  [2:0]  func,
    output reg [31:0] out
);
always @(*) begin
    case(func)
        3'b000: out = a & b;
        3'b001: out = a | b;
        3'b010: out = a ^ b;
        3'b011: out = ~(a | b);
        3'b100: out = ~a;
        default: out = 0;
    endcase
end
endmodule
