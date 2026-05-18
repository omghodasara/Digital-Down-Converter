//author: omghodasara
//module: cic_filter.v
//project: Digital Down Converter (SDR)

`timescale 1ns / 1ps

module cic_filter #(
    parameter DATA_IN_W  = 32, // Input width from our mixer
    parameter DEC_FACTOR = 10, 
//    decimation by 10 (100MHz to 10MHz)
//    Bit growth formula: N * log2(R) -> 1 * log2(10) = approx. 4 extra bits
    parameter DATA_OUT_W = 36  // Output width (32 + 4 bits of growth)
)(
    input  wire                   clk,
    input  wire                   rst,
    input  wire signed [DATA_IN_W-1:0]  data_in,
    
    // Outputs
    output reg  signed [DATA_OUT_W-1:0] data_out,
    output reg                    valid_out // flag that tells when a new decimated point is ready
);

//    stage 1: integrator (running sum)
    reg signed [DATA_OUT_W-1:0] integrator;
    
    always @(posedge clk) begin
        if (rst) begin
            integrator <= 0;
        end else begin
            integrator <= integrator + data_in; 
        end
    end

//    stage 2: decimator (throw away 9 out of 10 samples)
    reg [7:0] dec_counter; 
    reg signed [DATA_OUT_W-1:0] dec_reg; // to hold the captured data
    reg dec_tick; // a pulse that fires every 10(decimation factor) cycles 
    
    always @(posedge clk) begin
        if (rst) begin
            dec_counter <= 0;
            dec_tick    <= 0;
            dec_reg     <= 0;
        end else begin
            if (dec_counter == DEC_FACTOR - 1) begin
                dec_counter <= 0;
                dec_tick    <= 1;            
                dec_reg     <= integrator;   
            end else begin
                dec_counter <= dec_counter + 1;
                dec_tick    <= 0;
            end
        end
    end

//    stage 3: comb (moving average subtractor)
    reg signed [DATA_OUT_W-1:0] comb_delay;
    
    always @(posedge clk) begin
        if (rst) begin
            comb_delay <= 0;
            data_out   <= 0;
            valid_out  <= 0;
        end else begin
//            only do the comb math when the decimator grabs a new point
            valid_out <= dec_tick;
            
            if (dec_tick) begin
//                save the current value for next time
                comb_delay <= dec_reg;            
//                output = current total - previous total
                data_out <= dec_reg - comb_delay; 
            end
        end
    end

endmodule