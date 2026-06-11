// sobel_accel.v - Synthesizable Sobel edge detector
// Pure Verilog (IEEE1364-2001 compliant)

module sobel_accel #(
    parameter IMG_WIDTH = 640
)(
    input  wire        clk,
    input  wire        rst_n,
    input  wire [7:0]  pixel_in,
    input  wire        pixel_valid,
    output reg  [7:0]  pixel_out,
    output reg         out_valid
);

    // Line buffers (two delay lines)
    reg [7:0] line_buf0 [0:IMG_WIDTH-1];
    reg [7:0] line_buf1 [0:IMG_WIDTH-1];

    // Counters
    reg [15:0] col_cnt;
    reg [15:0] row_cnt;

    // Three rows of shift registers (3 stages each)
    reg [7:0] cur_row [0:2];   // newest line
    reg [7:0] mid_row [0:2];   // previous line
    reg [7:0] top_row [0:2];   // line before previous

    // Wires for reading line buffer outputs (combinational)
    wire [7:0] prev_row_pixel;
    wire [7:0] prev2_row_pixel;

    assign prev_row_pixel = line_buf0[col_cnt];
    assign prev2_row_pixel = line_buf1[col_cnt];

    // Convolution intermediate values
    reg signed [11:0] Gx, Gy;
    reg [11:0] mag;

    // 3x3 window aliases (combinational)
    wire [7:0] p11 = top_row[2];
    wire [7:0] p12 = top_row[1];
    wire [7:0] p13 = top_row[0];
    wire [7:0] p21 = mid_row[2];
    wire [7:0] p22 = mid_row[1];
    wire [7:0] p23 = mid_row[0];
    wire [7:0] p31 = cur_row[2];
    wire [7:0] p32 = cur_row[1];
    wire [7:0] p33 = cur_row[0];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            col_cnt <= 0;
            row_cnt <= 0;
            out_valid <= 0;
            pixel_out <= 0;
            // Clear shift registers (optional)
            cur_row[0] <= 0; cur_row[1] <= 0; cur_row[2] <= 0;
            mid_row[0] <= 0; mid_row[1] <= 0; mid_row[2] <= 0;
            top_row[0] <= 0; top_row[1] <= 0; top_row[2] <= 0;
        end else if (pixel_valid) begin
            // ---- Update counters ----
            if (col_cnt == IMG_WIDTH - 1) begin
                col_cnt <= 0;
                row_cnt <= row_cnt + 1;
            end else begin
                col_cnt <= col_cnt + 1;
            end

            // ---- Write new data into line buffers ----
            line_buf0[col_cnt] <= pixel_in;
            line_buf1[col_cnt] <= prev_row_pixel;

            // ---- Update shift registers for each row ----
            cur_row[2] <= cur_row[1];
            cur_row[1] <= cur_row[0];
            cur_row[0] <= pixel_in;

            mid_row[2] <= mid_row[1];
            mid_row[1] <= mid_row[0];
            mid_row[0] <= prev_row_pixel;


            top_row[2] <= top_row[1];
            top_row[1] <= top_row[0];
            top_row[0] <= prev2_row_pixel;

            out_valid <= (row_cnt >= 2) && (col_cnt >= 2);
        end else begin
            out_valid <= 0;
        end
    end

    // Sobel computation (clocked to meet timing)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pixel_out <= 0;
        end else if (out_valid) begin

            Gx = (p13 + (p23 << 1) + p33) - (p11 + (p21 << 1) + p31);
            Gy = (p31 + (p32 << 1) + p33) - (p11 + (p12 << 1) + p13);
            mag = (Gx[11] ? -Gx : Gx) + (Gy[11] ? -Gy : Gy);

            // Clamp to 8 bits
            pixel_out <= (mag > 255) ? 8'hFF : mag[7:0];
        end
    end

endmodule