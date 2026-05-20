//author: omghodasara
//module: ddc_top.v
//project: Digital Down Converter (SDR)

`timescale 1ns / 1ps

module ddc_top (
    input  wire                 clk,
    input  wire                 rst,
    input  wire signed [15:0]   adc_in,       
    input  wire [31:0]          phase_inc,    
    
    output wire signed [35:0]   baseband_out, 
    output wire                 valid_out     
);

    wire signed [15:0] nco_wave;
    wire signed [31:0] mixed_wave;

    nco #(
        .PHASE_W(32),
        .LUT_AW(10),
        .DATA_W(16)
    ) u_nco (
        .clk(clk),
        .rst(rst),
        .phase_inc(phase_inc),
        .sine_out(nco_wave)
    );

    digital_mixer #(
        .DATA_W(16)
    ) u_mixer (
        .clk(clk),
        .rst(rst),
        .adc_in(adc_in),
        .nco_in(nco_wave),
        .mixed_out(mixed_wave)
    );

    cic_filter #(
        .DATA_IN_W(32),
        .DEC_FACTOR(10),
        .DATA_OUT_W(36)
    ) u_cic (
        .clk(clk),
        .rst(rst),
        .data_in(mixed_wave),
        .data_out(baseband_out),
        .valid_out(valid_out)
    );

endmodule