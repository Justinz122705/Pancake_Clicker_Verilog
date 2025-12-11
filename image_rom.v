module image_rom #(
    parameter IMAGE_WIDTH = 100,
    parameter IMAGE_HEIGHT = 100,
    parameter MIF_FILE = "file.hex"
)(
    input wire clk,
    input wire [9:0] x,
    input wire [9:0] y,
    input wire [9:0] base_x,      // Position to display image
    input wire [9:0] base_y,
    output reg [11:0] pixel_data, // 12-bit RGB (4 bits each)
    output reg valid              // High when within image bounds
);

    // Calculate address from x,y coordinates
    wire [9:0] rel_x = x - base_x;
    wire [9:0] rel_y = y - base_y;
    wire [16:0] addr = rel_y * IMAGE_WIDTH + rel_x;
    
    // Check if current pixel is within image bounds
    wire in_image = (x >= base_x) && (x < base_x + IMAGE_WIDTH) &&
                    (y >= base_y) && (y < base_y + IMAGE_HEIGHT);
    
    // ROM memory
    reg [11:0] image_mem [0:IMAGE_WIDTH*IMAGE_HEIGHT-1];
    
    // Initialize ROM from MIF file
    initial begin
        $readmemh(MIF_FILE, image_mem);
    end
    
    // Read from ROM
    always @(posedge clk) begin
        if (in_image) begin
            pixel_data <= image_mem[addr];
            valid <= 1'b1;
        end else begin
            pixel_data <= 12'h000;
            valid <= 1'b0;
        end
    end

endmodule