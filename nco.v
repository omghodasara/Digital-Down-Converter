//author: omghodasara
//module: nco.v
//project: Digital Down Converter (SDR)

`timescale 1ns / 1ps

module nco #( 
    parameter PHASE_W = 32,
    parameter LUT_AW = 10,
    parameter DATA_W = 16 
)( 
    input wire clk,
    input wire rst,
    input wire [PHASE_W-1:0] phase_inc,
    output reg signed [DATA_W-1:0] sine_out
);

    reg [PHASE_W-1:0] phase_acc;
    
    // phase accumulator
    always @(posedge clk) begin
        if (rst) 
            phase_acc <= 0;
        else 
            phase_acc <= phase_acc + phase_inc;
    end
    
//    taking top 10 bits for ROM address. 
//    dropping the bottom 22 bits so it fits in the 10-bit rom
    wire [LUT_AW-1:0] lut_addr = phase_acc[PHASE_W-1:PHASE_W-LUT_AW];
    
    reg signed [DATA_W-1:0] sine_rom [0:(1<<LUT_AW)-1];
    
    initial begin
        $readmemh("E:/_grind/DDC/sine_lut.hex", sine_rom);
    end 
        
    always @(posedge clk) begin
        sine_out <= sine_rom[lut_addr];
    end 
        
endmodule