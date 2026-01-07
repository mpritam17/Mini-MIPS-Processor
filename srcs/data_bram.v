`timescale 1ns / 1ps
module data_bram(
    input wire clka,
    input wire ena,
    input wire wea,
    input wire [9:0] addra,
    input wire [31:0] dina,
    output wire [31:0] douta
);

    
    blk_mem_gen_0 bram_ip (
        .clka(clka),
        .ena(ena),
        .wea(wea),
        .addra(addra),
        .dina(dina),
        .douta(douta)
    );

endmodule