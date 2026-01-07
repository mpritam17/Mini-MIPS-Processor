`timescale 1ns/1ps

// HAM: Popcount (count of 1 bits in rs1)
module ham_unit32(
    input  [31:0] a,
    output reg [31:0] out
);
integer i, cnt;
always @(*) begin
    cnt = 0;
    for (i=0; i<32; i=i+1)
        cnt = cnt + a[i];
    out = cnt;
end
endmodule
