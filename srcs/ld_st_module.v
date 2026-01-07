

// `timescale 1ns / 1ps
// module ld_st_module(
//     input wire clk,
//     input wire reset,
//     input wire execute,
//     input wire [15:0] switches,
//     output wire [15:0] leds
// );

//     wire display_select = switches[15];
//     wire op_select = switches[14];
//     wire [3:0] dst_reg_addr = switches[13:10];
//     wire [3:0] base_reg_addr = switches[9:6];
//     wire [5:0] signed_offset = switches[5:0];

//     wire [31:0] mem_read_data;
//     wire [31:0] mem_write_data;
//     wire [31:0] mem_address;
//     wire mem_write_enable;

//     reg execute_delayed;
//     reg [3:0] dst_reg_addr_delayed;
//     reg op_select_delayed;

//     wire [31:0] sign_extended_offset = {{26{signed_offset[5]}}, signed_offset};

//     // --- Register Bank Connections ---
//     wire [31:0] rs1_data;
//     wire [31:0] rs2_data;
//     reg  [31:0] write_data;
//     reg  reg_we;

//     reg_bank REGFILE (
//         .clk(clk),
//         .rst(reset),
//         .we(reg_we),
//         .rd_addr(dst_reg_addr_delayed),
//         .rs1_addr(base_reg_addr),
//         .rs2_addr(dst_reg_addr),
//         .wd(write_data),
//         .rs1(rs1_data),
//         .rs2(rs2_data)
//     );

//     assign mem_address = rs1_data + sign_extended_offset;
//     assign mem_write_data = rs2_data;
//     assign mem_write_enable = op_select & execute;

//     // --- Memory Interface ---
//     data_bram data_mem (
//         .clka(clk),
//         .ena(1'b1),
//         .wea(mem_write_enable),
//         .addra(mem_address[9:0]),
//         .dina(mem_write_data),
//         .douta(mem_read_data)
//     );

//     // --- Execution Control ---
//     always @(posedge clk) begin
//         if (reset) begin
//             execute_delayed <= 0;
//             dst_reg_addr_delayed <= 0;
//             op_select_delayed <= 0;
//             reg_we <= 0;
//             write_data <= 0;
//         end else begin
//             execute_delayed <= execute;
//             dst_reg_addr_delayed <= dst_reg_addr;
//             op_select_delayed <= op_select;
//             reg_we <= 0;

//             // Load from memory into register
//             if (execute_delayed && !op_select_delayed) begin
//                 write_data <= mem_read_data;
//                 reg_we <= 1'b1;
//                 $display("REGISTER UPDATE: R%d = 0x%h (from memory)", dst_reg_addr_delayed, mem_read_data);
//             end
//         end
//     end

//     // --- LED Display ---
//     wire [31:0] display_value = rs2_data;
//     assign leds = display_select ? display_value[31:16] : display_value[15:0];

// endmodule

`timescale 1ns / 1ps
module ld_st_module(
    input  wire        clk,
    input  wire        reset,
    input  wire        ld_en,        // Load enable
    input  wire        st_en,        // Store enable
    input  wire [31:0] addr,         // Memory address
    input  wire [31:0] write_data,   // Data to store
    output reg  [31:0] read_data,    // Data read from memory
    output reg         ready         // Operation complete signal (optional)
);

    // --- Memory signals ---
    wire [31:0] mem_out;
    wire [9:0]  addr_10 = addr[9:0]; // Assuming 1KB memory depth
    wire        write_enable = st_en;

    // --- Data Memory ---
    data_bram data_mem (
        .clka(clk),
        .ena(1'b1),
        .wea(write_enable),
        .addra(addr_10),
        .dina(write_data),
        .douta(mem_out)
    );

    // --- Sequential control for load/store ---
    always @(posedge clk) begin
        if (reset) begin
            read_data <= 32'b0;
            ready     <= 1'b0;
        end else begin
            ready <= 1'b0;
            //$display("HELLO, st_en <= 0x%h, ld_en <= 0x%h", st_en, ld_en);
            if (st_en) begin
                // Write occurs automatically via BRAM
                ready <= 1'b1;
            end else if (ld_en) begin
                // Load from memory
                read_data <= mem_out;
                ready <= 1'b1;
            end
        end
    end

endmodule
