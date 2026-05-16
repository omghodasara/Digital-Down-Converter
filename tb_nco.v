//author: omghodasara
//module: tb_nco.v
//project: Digital Down Converter (SDR)

`timescale 1ns / 1ps

module tb_nco();

    reg clk;
    reg rst;
    reg [31:0] phase_inc;
    wire signed [15:0] sine_out;

    nco #(
        .PHASE_W(32),
        .LUT_AW(10),
        .DATA_W(16)
    ) uut (
        .clk(clk),
        .rst(rst),
        .phase_inc(phase_inc),
        .sine_out(sine_out)
    );

//    5ns high, 5ns low = 10ns period -> 100MHz
    initial begin
        clk = 0;
        forever #5 clk = ~clk; 
    end

    initial begin
        rst = 1;
//        Target = 10 MHz
//        Clock = 100 MHz
//        Formula: (Target / Clock) * 2^32 
//        (10 / 100) * 4294967296 = 429496729.6 -> round to 429496730 
        phase_inc = 32'd429496730; 

        #20;
        rst = 0;

        #1000;
        $finish;
    end

endmodule