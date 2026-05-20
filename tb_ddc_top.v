//author: omghodasara
//module: tb_ddc_top.v
//project: Digital Down Converter (SDR)

`timescale 1ns / 1ps

module tb_ddc_top();

    reg clk;
    reg rst;
    reg [31:0] phase_inc;
    
    reg signed [15:0] adc_in;
    wire signed [35:0] baseband_out;
    wire valid_out;

    ddc_top uut (
        .clk(clk),
        .rst(rst),
        .adc_in(adc_in),
        .phase_inc(phase_inc),
        .baseband_out(baseband_out),
        .valid_out(valid_out)
    );

    // 100 MHz clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        $dumpfile("ddc_waveform.vcd"); 
        $dumpvars(0, tb_ddc_top);      
    end

    reg signed [15:0] adc_rom [0:4095]; 
    integer output_file;
    integer i;

    initial begin
//        reading fake antenna data
        $readmemh("E:/_grind/DDC/adc_data_in.hex", adc_rom);
        
//        saving filtered results
        output_file = $fopen("E:/_grind/DDC/filtered_output.hex", "w");
        
        rst = 1;
        adc_in = 0;
        phase_inc = 32'd429496730; // 10 MHz tuning word
        
        #20 rst = 0;

//        feeding data in exactly 4096 times 
        for (i = 0; i < 4096; i = i + 1) begin
            @(posedge clk);
            adc_in = adc_rom[i];
        end

        #100;
        $fclose(output_file);
        $display("done. check filtered_output.hex");
        $finish;
    end

//    writing to file only when decimator fires
    always @(posedge clk) begin
        if (valid_out && !rst) begin
            $fdisplay(output_file, "%d", baseband_out);
        end
    end

endmodule