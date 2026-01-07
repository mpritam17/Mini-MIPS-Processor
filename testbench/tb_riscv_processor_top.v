`timescale 1ns / 1ps
module tb_riscv_processor;

    reg clk;
    reg rst;
    reg led_sel;
    wire [15:0] leds;

    // Instantiate processor
    riscv_processor_top UUT (
        .clk(clk),
        .rst(rst),
        .led_sel(led_sel),
        .leds(leds)
    );

    // Clock generation
    initial clk = 0;
    always #5 clk = ~clk; // 100MHz -> 10ns period

    // Test sequence
    initial begin
        // Reset
        rst = 1;
        led_sel = 0;
        #20;
        rst = 0;

        // Run simulation for 200ns (~20 cycles)
        #2000;
        //$monitor("Simulation complete.");
        $stop;
    end

    // Optional: monitor PC and R2 register
    initial begin
        $display("Time\tPC\tR2\tLEDs");
        $monitor("t=%0t\tPC=%0d\tR2=%h\tLEDs=%h",
                 $time,
                 UUT.PC,
                 UUT.RB.regs[2],
                 leds);
    end
endmodule
