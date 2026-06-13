`timescale 1ns / 1ps

module tb_sobel_accel();

reg clk, rst_n;
reg [7:0] pixel_in;
reg pixel_valid;
wire [7:0] pixel_out;
wire out_valid;

localparam WIDTH = 640;
localparam HEIGHT = 427;
localparam NUM_PIXELS = WIDTH * HEIGHT;

sobel_accel #(.IMG_WIDTH(WIDTH)) dut (
    .clk(clk),
    .rst_n(rst_n),
    .pixel_in(pixel_in),
    .pixel_valid(pixel_valid),
    .pixel_out(pixel_out),
    .out_valid(out_valid)
);

always #5 clk = ~clk;

integer in_file, out_file, scan_ret, i;
reg [7:0] temp_pixel;
reg [31:0] pixel_count;
reg done;

integer out_count = 0;

initial begin
    clk = 0;
    rst_n = 0;
    pixel_valid = 0;
    pixel_in = 0;
    done = 0;
    pixel_count = 0;
    
    in_file = $fopen("img/output_image.txt", "r");
    if (in_file == 0) begin
        $display("ERROR: Could not open img/output_image.txt");
        $finish;
    end
    
    out_file = $fopen("img/output_data.txt", "w");
    
    #20 rst_n = 1;
    #10;
    
    while (!$feof(in_file)) begin
        scan_ret = $fscanf(in_file, "%d\n", temp_pixel);
        if (scan_ret == 1) begin
            pixel_in = temp_pixel;
            pixel_valid = 1;
            @(posedge clk);
            pixel_count = pixel_count + 1;
        end
    end
    
    pixel_valid = 0;
    $display("Sent %0d pixels", pixel_count);
    
    //flush
    repeat(200) @(posedge clk);
    
    $fclose(in_file);
    $fclose(out_file);
    $display("Simulation finished.");
    $finish;
end

initial begin
    $monitor("Time %t: pixel_in=%d, pixel_valid=%b, out_valid=%b, pixel_out=%d",
              $time, pixel_in, pixel_valid, out_valid, pixel_out);
end

always @(posedge clk) begin
    if (pixel_valid) begin
        if (out_valid) begin
            $fwrite(out_file, "%d\n", pixel_out);
            out_count = out_count + 1;
        end
end
end

endmodule