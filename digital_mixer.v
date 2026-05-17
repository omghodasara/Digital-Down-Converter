//author: omghodasara
//module: digital_mixer.v
//project: Digital Down Converter (SDR)

`timescale 1ns / 1ps

module digital_mixer #(
    parameter DATA_W = 16 
)(
    input  wire clk,
    input  wire rst,
    input  wire signed [DATA_W-1:0] adc_in,
    input  wire signed [DATA_W-1:0] nco_in,
//    16b * 16b = 32b output to prevent overflow
    output reg  signed [(2*DATA_W)-1:0] mixed_out
);

//    pipelined so vivado puts this in a dsp slice. otherwise it builds a slow one out of luts
    reg signed [DATA_W-1:0] adc_reg;
    reg signed [DATA_W-1:0] nco_reg;

    always @(posedge clk) begin
        if (rst) begin
            adc_reg   <= 0;
            nco_reg   <= 0;
            mixed_out <= 0;
        end else begin
            
            adc_reg <= adc_in;
            nco_reg <= nco_in;
            mixed_out <= adc_reg * nco_reg;
        end
    end

endmodule