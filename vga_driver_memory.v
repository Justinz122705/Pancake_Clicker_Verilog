module vga_driver_memory	(
	input 		          		CLOCK_50,
	output		     [6:0]		HEX0,
	output		     [6:0]		HEX1,
	output		     [6:0]		HEX2,
	output		     [6:0]		HEX3,
	output			  [6:0]     HEX4,
	output 			  [6:0]     HEX5,
	input 		     [3:0]		KEY,
	output		     [9:0]		LEDR,

	inout 		          		PS2_CLK,
	inout 		          		PS2_DAT,

	output		          		VGA_BLANK_N,
	output reg	     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output reg	     [7:0]		VGA_G,
	output		          		VGA_HS,
	output reg	     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS
);
assign HEX0 = seg7_dig0;
assign HEX1 = seg7_dig1;
assign HEX2 = seg7_dig2;
assign HEX3 = seg7_dig3;
assign HEX4 = seg7_dig4;
assign HEX5 = seg7_neg_sign;


wire active_pixels;
wire [9:0]x;
wire [9:0]y;
wire clk;
wire rst;
wire left;
wire right;
wire up;
wire uppie;
wire leftie;
wire downie;
wire rightie;
wire click;
wire [19:0]to_display;
wire tucker;
wire sec;
reg in_pan;
reg no_more_up;
reg in_upg;
assign LEDR[3:0] = {rst, tucker, tucker, win};
wire [23:0] seven_seg_color;
wire [23:0] timer_color;

assign clk = CLOCK_50;
assign rst = KEY[0];
assign LEDR[5] = active_pixels;

///////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////VGA LOGIC START/////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////

reg [9:0] cursor_x;
reg [9:0] cursor_y;
parameter CURSOR_WIDTH = 15;   // Width of cursor
parameter CURSOR_HEIGHT = 15;  // Height of cursor

reg [9:0] pancake_x;
reg [9:0] pancake_y;
parameter PANCAKE_WIDTH = 175;
parameter PANCAKE_HEIGHT = 175;

reg [9:0] upgrade_x;
reg [9:0] upgrade_y;
parameter UPGRADE_WIDTH = 200;
parameter UPGRADE_HEIGHT = 75;

reg [9:0] upgrade_list_x;
reg [9:0] upgrade_list_y;
parameter UPGRADE_LIST_WIDTH = 200;
parameter UPGRADE_LIST_HEIGHT = 200;

reg [9:0] progress_x;
reg [9:0] progress_y;
parameter PROGRESS_WIDTH = 298;
parameter PROGRESS_HEIGHT = 26;

reg [9:0] green_x;
reg [9:0] green_y;
wire [9:0] green_wide;
assign green_wide = count/34;
parameter GREEN_HEIGHT = 22;

reg [9:0] prison_x;
reg [9:0] prison_y;
parameter PRISON_WIDTH = 175;
parameter PRISON_HEIGHT = 175;

reg [9:0] title_x;
reg [9:0] title_y;
parameter TITLE_WIDTH = 160;
parameter TITLE_HEIGHT = 120;

reg [9:0] end_x;
reg [9:0] end_y;
parameter END_WIDTH = 160;
parameter END_HEIGHT = 120;

reg [9:0] instructions_x;
reg [9:0] instructions_y;
parameter INSTRUCTIONS_WIDTH = 160;
parameter INSTRUCTIONS_HEIGHT = 120;

reg [9:0] lose_x;
reg [9:0] lose_y;
parameter LOSE_WIDTH = 160;
parameter LOSE_HEIGHT = 120;

reg [9:0] lost_x;
reg [9:0] lost_y;
parameter LOST_WIDTH = 160;
parameter LOST_HEIGHT = 120;

// Checking if current pixel is within cursor bounds
wire in_cursor;
assign in_cursor = (x >= cursor_x) && (x < cursor_x + CURSOR_WIDTH) &&
                   (y >= cursor_y) && (y < cursor_y + CURSOR_HEIGHT);
// Checking if current pixel is within pancake bounds						 
wire in_pancake;
assign in_pancake = (x >= pancake_x) && (x < pancake_x + PANCAKE_WIDTH) &&
                   (y >= pancake_y) && (y < pancake_y + PANCAKE_HEIGHT);
// Checking if current pixel is within upgrade bounds
wire in_upgrade;
assign in_upgrade = (x >= upgrade_x) && (x < upgrade_x + UPGRADE_WIDTH) &&
                   (y >= upgrade_y) && (y < upgrade_y + UPGRADE_HEIGHT);
// Checking if current pixel is within progress bar bounds
wire in_progress;
assign in_progress = (x >= progress_x) && (x < progress_x + PROGRESS_WIDTH) &&
                   (y >= progress_y) && (y < progress_y + PROGRESS_HEIGHT);
// Checking if current pixel is within green progression bar bounds
wire in_green;
assign in_green = (x >= green_x) && (x < green_x + green_wide) &&
                   (y >= green_y) && (y < green_y + GREEN_HEIGHT);
// Checking if current pixel is within upgrade list bounds
wire in_upgrade_list;
assign in_upgrade_list = (x >= upgrade_list_x) && (x < upgrade_list_x + UPGRADE_LIST_WIDTH) &&
                   (y >= upgrade_list_y) && (y < upgrade_list_y + UPGRADE_LIST_HEIGHT);
// Checking if current pixel is within tucker in prison bounds
wire in_prison;
assign in_prison = (x >= prison_x) && (x < prison_x + PRISON_WIDTH) &&
                   (y >= prison_y) && (y < prison_y + PRISON_HEIGHT);
// Checking if current pixel is within title card bounds
wire in_title;
assign in_title = (x >= title_x) && (x < title_x + TITLE_WIDTH) &&
                   (y >= title_y) && (y < title_y + TITLE_HEIGHT);
// Checking if current pixel is within cursor bounds
wire in_end;
assign in_end = (x >= end_x) && (x < end_x + END_WIDTH) &&
                   (y >= end_y) && (y < end_y + END_HEIGHT);
// Checking if current pixel is within end card bounds
wire in_instructions;
assign in_instructions = (x >= instructions_x) && (x < instructions_x + INSTRUCTIONS_WIDTH) &&
                   (y >= instructions_y) && (y < instructions_y + INSTRUCTIONS_HEIGHT);
// Checking if current pixel is within lose card bounds
wire in_lose;
assign in_lose = (x >= lose_x) && (x < lose_x + LOSE_WIDTH) &&
                   (y >= lose_y) && (y < lose_y + LOSE_HEIGHT);
// Checking if current pixel is within lost card bounds
wire in_lost;
assign in_lost = (x >= lost_x) && (x < lost_x + LOST_WIDTH) &&
                   (y >= lost_y) && (y < lost_y + LOST_HEIGHT);

//vga driver instantiation
vga_driver the_vga(
    .clk(clk),
    .rst(rst),
    .vga_clk(VGA_CLK),
    .hsync(VGA_HS),
    .vsync(VGA_VS),
    .active_pixels(active_pixels),
    .xPixel(x),
    .yPixel(y),
    .VGA_BLANK_N(VGA_BLANK_N),
    .VGA_SYNC_N(VGA_SYNC_N)
);

always @(*)
begin
    {VGA_R, VGA_G, VGA_B} = vga_color;
end

reg [23:0] vga_color;

// Initialize cursor position and allows the cursor to move with the arrow keys on the keyboard
always @(posedge clk or negedge rst)
begin
    if (rst == 1'b0)
    begin
        cursor_x <= 10'd0;  // Initial X position
        cursor_y <= 10'd0;  // Initial Y position
    end
    else
    begin
       if (leftie && cursor_x > 0)           // Move left
            cursor_x <= cursor_x - 15;
        if (rightie && cursor_x < 640 - CURSOR_WIDTH)  // Move right
            cursor_x <= cursor_x + 15;
        if (uppie && cursor_y > 0)           // Move up
            cursor_y <= cursor_y - 15;
		  if (downie && cursor_y < 480 - CURSOR_HEIGHT)  // Move down
            cursor_y <= cursor_y + 15;
   
//Logic for Object interaction with the cursor making count only go up if cursor is on pancake
	if(cursor_x > 45 && cursor_x < 220)
		if(cursor_y > 45 && cursor_y < 220)
		in_pan = 1;
		else
		in_pan = 0;
	else
		in_pan = 0;
//Logic for Object interaction with the cursor making count only go up if cursor is on upgrade box		
	if(cursor_x > 395 && cursor_x < 595)
		if (cursor_y > 45 && cursor_y < 120)
			in_upg = 1;
		else 
			in_upg = 0;
		else 
			in_upg = 0;
	end
end
always @(posedge clk or negedge rst)
begin
    if (rst == 1'b0)
    begin
        pancake_x <= 10'd45;  // Initial X pancake position
        pancake_y <= 10'd45;  // Initial Y pancake position
        upgrade_x <= 10'd395;  // X position for Upgrade
        upgrade_y <= 10'd45;  //Y position  for Upgrade
        upgrade_list_x <= 10'd395;  //X position for Upgrade List
        upgrade_list_y <= 10'd125;  //Y position for Upgrade List
        progress_x <= 10'd295;  // X position for Progress Bar
        progress_y <= 10'd410;  // Y position for Progress Bar
        green_x <= 10'd297;  //X position for Green Progression
        green_y <= 10'd412;  //Y position for Green Progression
        prison_x <= 10'd45;  //X position for Tucker in Prison
        prison_y <= 10'd225;  //Y position for Tucker in Prison
        title_x <= 10'd240;  //X position for Title Card
        title_y <= 10'd120;  //Y position for Title Card
		  end_x <= 10'd240;   //X Position for End Card
		  end_y <= 10'd180;   //Y Position for End Card
		  instructions_x <= 10'd240; //X Position for Instruction Card
		  instructions_y <= 10'd240; //Y Position for Instruction Card	
		  lose_x <= 10'd240; //X Position for Lose Card
		  lose_y <= 10'd120; //Y Position for Lose Card
		  lost_x <= 10'd240; //X Position for Lost Card
		  lost_y <= 10'd240; //Y Position for Lost Card	  
		  
    end
end
// Color selection logic
always @(posedge clk or negedge rst)
begin
    if (rst == 1'b0)
    begin
        vga_color <= 24'h006080;  // Blue background
    end
    else if (active_pixels)
    begin
		  if (S == WIN)
				vga_color <= end_color_24;	 //win screen
		  else if (S == START)
		   begin
		     if (in_title)
					vga_color <= title_color_24; //title screen
			  else if (in_instructions)
					vga_color <= instructions_color_24; //instruction card
			  else
					vga_color <= 24'h006080;
			end
		  else if (S == LOSE)
				begin	
					if(in_lose)
						vga_color <= lose_color_24;	//evil lose screen
					else if(in_lost)
						vga_color <= lost_color_24; 
					else
						vga_color <= 24'hFF0000; //red background
				end
        else if (in_cursor)
            vga_color <= 24'hFFFFFF;  // White cursor
        else if (in_seven_seg)
            vga_color <= seven_seg_color; //red seven segment
		  else if (in_timer)
				vga_color <= timer_color; //red countdown
		  else if(in_pancake)
				vga_color <= pancake_color_24; //pale pancake
		  else if (in_upgrade)
				vga_color <= upgrade_color_24; //upgrade box
		  else if (in_upgrade_list)
				vga_color <= upgrade_list_color_24; //upgrade list box
		  else if (in_prison)
				vga_color <= prison_color_24; //tucker in prison image
		  else if (in_green)
				vga_color <= 24'h099e31; //green progress
		  else if (in_progress)
				vga_color <= 24'hc4bbbc; //progress border
        else if(!win)
            vga_color <= 24'h006080;  // Blue background
		  else
				vga_color <= 24'h006080; //Background Catchall for inferred latches
	 end

end

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////GAME LOGIC START/////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg [19:0]count;
reg [9:0] timer;
reg win;
reg [4:0] S;
reg [4:0] NS;
parameter START = 4'd0,	
			 ONE_CLICK = 4'd1,
			 TWO_CLICK = 4'd2,
			 AUTO_INC = 4'd3,
			 FIVE_CLICK = 4'd4,
			 AUTO10_INC = 4'd5,
			 TWV_CLICK = 4'd6,
			 AUTO50_INC = 4'd7,
			 WIN = 4'd8,
			 LOSE = 4'd9,
			 ERROR = 4'hF;
			 
			 
always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
		S <= START;
	else
		S <= NS;
end

always @ (posedge clk or negedge rst)
case (S)
	START: if (tucker == 1'b1)
				NS <= ONE_CLICK;
			 else
				NS <= START;
	ONE_CLICK: if (count < 20'd10000)
						if (tucker == 1'b1 && count >= 20'd10 && in_upg)
						   NS <= TWO_CLICK;
						else if (timer == 10'd0)
							NS <= LOSE;
						else
							NS <= ONE_CLICK;
				  else 
					 NS <= WIN;
	TWO_CLICK: if (count < 20'd10000)
						if (tucker == 1'b1 && count >= 20'd50 && in_upg)
						   NS <= AUTO_INC;
						else if (timer == 10'd0)
							NS <= LOSE;
						else
							NS <= TWO_CLICK;
				  else
					 NS <= WIN;
	AUTO_INC: if (count < 20'd10000)
					if(tucker == 1'b1 && count >= 20'd250 && in_upg)
						NS <= FIVE_CLICK;
				   else if (timer == 10'd0)
							NS <= LOSE;
					else
						NS <= AUTO_INC;
				else
					NS <= WIN;
	FIVE_CLICK: if (count < 20'd10000)
						if(tucker == 1'b1 && count >= 20'd750 && in_upg)   
							NS <= AUTO10_INC;
						else if (timer == 10'd0)
							NS <= LOSE;
						else
						NS <= FIVE_CLICK;
					else
						NS <= WIN;
	AUTO10_INC: if (count < 20'd10000)
						if(tucker == 1'b1 && count >= 20'd1500 && in_upg)
							NS <= TWV_CLICK;
						else if (timer == 10'd0)
							NS <= LOSE;
						else
							NS <= AUTO10_INC;
					else
						NS <= WIN;
	TWV_CLICK: if (count < 20'd10000)
						if(tucker == 1'b1 && count >= 20'd3000 && in_upg)
							NS <= AUTO50_INC;
						else if (timer == 10'd0)
							NS <= LOSE;
						else
							NS <= TWV_CLICK;
					else
						NS <= WIN;
	AUTO50_INC: if (count < 20'd10000)
						if (timer == 10'd0)
							NS <= LOSE;
						else	
							NS <= AUTO50_INC;
					else
						NS <= WIN;						
	WIN: NS <= WIN;
	LOSE: NS <= LOSE;
	default: NS <= ERROR;
endcase

always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
		begin
			win <= 1'b0;
			count <= 20'd0;
		end
	else
		begin
			case(S)
				START:
					begin
					win <= 1'b0;
					count <= 20'd0;
					end
				ONE_CLICK: if (tucker == 1'b1 && in_pan == 1)
								 count <= count + 1'b1;
							  else if (tucker == 1'b1 && count >= 20'd10 && in_upg == 1)
								 count <= count - 4'd10;
							  else
								 count <= count;
				TWO_CLICK: if (tucker == 1'b1 && in_pan == 1) 
								count <= count + 2'd2;
							  else if (tucker == 1'b1 && count >= 20'd50 && in_upg == 1)
								 count <= count - 6'd50;
							  else
								  count <= count;
				AUTO_INC: if (tucker == 1'b1 && in_pan == 1)
								count <= count + 2'd2 + sec*4;
							 else if (tucker == 1'b1 && count >= 20'd250 && in_upg == 1)
								count <= count - 20'd250;
							 else
								count <= count + sec*4;
				FIVE_CLICK: if (tucker == 1'b1 && in_pan == 1)
								count <= count + 3'd5 + sec*4;
							  else if (tucker == 1'b1 && count >= 20'd750 && in_upg == 1)
								count <= count - 20'd750;
							  else
								count <= count + sec*4;
				AUTO10_INC: if (tucker == 1'b1 && in_pan == 1)
								count <= count + 3'd5 + sec*10;
							  else if (tucker == 1'b1 && count >= 20'd1500 && in_upg == 1)
								count <= count - 20'd1500;
							  else
								count <= count + sec*10;
				TWV_CLICK: if (tucker == 1'b1 && in_pan == 1)
								count <= count + 20'd12 + sec*10;
							  else if (tucker == 1'b1 && count >= 20'd3000 && in_upg == 1)
								count <= count - 20'd3000;
							  else
								count <= count + sec*10;
				AUTO50_INC: if (tucker == 1'b1 && in_pan == 1)
								count <= count + 20'd12 + sec*25;
							  else if (tucker == 1'b1 && count >= 20'd3000 && no_more_up == 1'b0 && in_upg == 1)
								 begin
								  no_more_up <= no_more_up + 1;
								 end
							  else
								  count <= count + sec*25;
				WIN: win <= 1'b1;			
			 endcase
		end
end

always @(posedge clk or negedge rst) 
begin 
	if (rst == 1'b0)
		timer <= 10'd360;
	else if (S != START)
			timer <= timer - sec;
	else if (S == LOSE)
			timer <= 10'd0;
	else 
		timer <= timer;
end 
	

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////INSTANTIATION START//////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

tucker_ticker second(.clk(clk), .rst(rst), .sec(sec));							
click_confirmer my_click(.clk(clk), .rst(rst), .pushed(click), .confirmation(tucker));	
click_confirmer myk1(.clk(clk), .rst(rst), .pushed(left), .confirmation(leftie));
click_confirmer myk2(.clk(clk), .rst(rst), .pushed(right), .confirmation(rightie));
click_confirmer myk3(.clk(clk), .rst(rst), .pushed(up), .confirmation(uppie));
click_confirmer myk4(.clk(clk), .rst(rst), .pushed(down), .confirmation(downie));
keyboard control(.clk(clk), .rst(rst), .PS2_CLK(PS2_CLK), .PS2_DAT(PS2_DAT), .click(click),
						.up(up), .down(down), .left(left), .right(right));
						
////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////SEVEN SEGMENT START//////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////	

wire [6:0]seg7_neg_sign;
wire [6:0]seg7_dig0;
wire [6:0]seg7_dig1;
wire [6:0]seg7_dig2;
wire [6:0]seg7_dig3;
wire [6:0]seg7_dig4;

wire [6:0] timer_dig0;
wire [6:0] timer_dig1;
wire [6:0] timer_dig2;


//Seven Segment on the DE1-SOC
three_decimal_vals_w_neg display(
.val(to_display),
.seg7_neg_sign(seg7_neg_sign),
.seg7_dig0(seg7_dig0),
.seg7_dig1(seg7_dig1),
.seg7_dig2(seg7_dig2),
.seg7_dig3(seg7_dig3),
.seg7_dig4(seg7_dig4)
);

//Seven Segment on VGA
vga_seven_segment seg_display (
 .clk(clk),
 .x(x),
 .y(y),
 .seg7_dig0(seg7_dig0),
 .seg7_dig1(seg7_dig1),
 .seg7_dig2(seg7_dig2),
 .seg7_dig3(seg7_dig3),
 .seg7_dig4(seg7_dig4),
 .seg7_neg_sign(seg7_neg_sign),
 .in_digit(in_seven_seg),
 .digit_color(seven_seg_color)
);

timer my_tim(.timer(timer),
.timer_dig0(timer_dig0),
.timer_dig1(timer_dig1),
.timer_dig2(timer_dig2));


vga_timer my_timer(
 .clk(clk),
 .x(x),
 .y(y),
 .seg7_dig0(timer_dig0),
 .seg7_dig1(timer_dig1),
 .seg7_dig2(timer_dig2),
 .in_digit(in_timer),
 .digit_color(timer_color)
);


assign to_display = count;

////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////HEX IMAGE ENCODING TO PIXELS START///////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////

//PANCAKE HEX TO PIXELS ASSIGNMENTS
wire [11:0] pancake_pixel;
wire pancake_valid;

wire [23:0] pancake_color_24;
assign pancake_color_24 = {pancake_pixel[11:8], 4'b0000,
                           pancake_pixel[7:4],  4'b0000,
                           pancake_pixel[3:0],  4'b0000};
image_rom #(
    .IMAGE_WIDTH(175),
    .IMAGE_HEIGHT(175),
    .MIF_FILE("pancake.hex")
) pancake_image (
    .clk(clk),
    .x(x),
    .y(y),
    .base_x(pancake_x),
    .base_y(pancake_y),
    .pixel_data(pancake_pixel),
    .valid(pancake_valid)
);

//UPGRADE HEX TO PIXELS ASSIGNMENTS
wire [11:0] upgrade_pixel;
wire upgrade_valid;

wire [23:0] upgrade_color_24;
assign upgrade_color_24 = {upgrade_pixel[11:8], 4'b0000,
                           upgrade_pixel[7:4],  4'b0000,
                           upgrade_pixel[3:0],  4'b0000};

image_rom #(
    .IMAGE_WIDTH(200),
    .IMAGE_HEIGHT(75),
    .MIF_FILE("upgrade.hex")
) upgrade_image (
    .clk(clk),
    .x(x),
    .y(y),
    .base_x(upgrade_x),
    .base_y(upgrade_y),
    .pixel_data(upgrade_pixel),
    .valid(upgrade_valid)
);
//Upgrade List HEX TO PIXELS ASSIGNMENTS
wire [11:0] upgrade_list_pixel;
wire upgrade_list_valid;

wire [23:0] upgrade_list_color_24;
assign upgrade_list_color_24 = {upgrade_list_pixel[11:8], 4'b0000,
                           upgrade_list_pixel[7:4],  4'b0000,
                           upgrade_list_pixel[3:0],  4'b0000};

image_rom #(
    .IMAGE_WIDTH(200),
    .IMAGE_HEIGHT(200),
    .MIF_FILE("upgrade_list.hex")
) upgrade_list_image (
    .clk(clk),
    .x(x),
    .y(y),
    .base_x(upgrade_list_x),
    .base_y(upgrade_list_y),
    .pixel_data(upgrade_list_pixel),
    .valid(upgrade_list_valid)
);

//Tucker in Prison HEX TO PIXELS ASSIGNMENTS
wire [11:0] prison_pixel;
wire prison_valid;

wire [23:0] prison_color_24;
assign prison_color_24 = {prison_pixel[11:8], 4'b0000,
                           prison_pixel[7:4],  4'b0000,
                           prison_pixel[3:0],  4'b0000};

image_rom #(
    .IMAGE_WIDTH(175),
    .IMAGE_HEIGHT(175),
    .MIF_FILE("tucker.hex")
) tucker_image (
    .clk(clk),
    .x(x),
    .y(y),
    .base_x(prison_x),
    .base_y(prison_y),
    .pixel_data(prison_pixel),
    .valid(prison_valid)
);
//Title Card HEX TO PIXELS ASSIGNMENTS
wire [11:0] title_pixel;
wire title_valid;

wire [23:0] title_color_24;
assign title_color_24 = {title_pixel[11:8], 4'b0000,
                           title_pixel[7:4],  4'b0000,
                           title_pixel[3:0],  4'b0000};

image_rom #(
    .IMAGE_WIDTH(160),
    .IMAGE_HEIGHT(120),
    .MIF_FILE("title.hex")
) title_image (
    .clk(clk),
    .x(x),
    .y(y),
    .base_x(title_x),
    .base_y(title_y),
    .pixel_data(title_pixel),
    .valid(title_valid)
);
//End Card HEX TO PIXELS ASSIGNMENTS
wire [11:0] end_pixel;
wire end_valid;

wire [23:0] end_color_24;
assign end_color_24 = {end_pixel[11:8], 4'b0000,
                           end_pixel[7:4],  4'b0000,
                           end_pixel[3:0],  4'b0000};

image_rom #(
    .IMAGE_WIDTH(160),
    .IMAGE_HEIGHT(120),
    .MIF_FILE("end.hex")
) end_image (
    .clk(clk),
    .x(x),
    .y(y),
    .base_x(end_x),
    .base_y(end_y),
    .pixel_data(end_pixel),
    .valid(end_valid)
);

//Instruction Card HEX TO PIXELS ASSIGNMENTS
wire [11:0] instructions_pixel;
wire instructions_valid;

wire [23:0] instructions_color_24;
assign instructions_color_24 = {instructions_pixel[11:8], 4'b0000,
                           instructions_pixel[7:4],  4'b0000,
                           instructions_pixel[3:0],  4'b0000};

image_rom #(
    .IMAGE_WIDTH(160),
    .IMAGE_HEIGHT(120),
    .MIF_FILE("instructions.hex")
) instructions_image (
    .clk(clk),
    .x(x),
    .y(y),
    .base_x(instructions_x),
    .base_y(instructions_y),
    .pixel_data(instructions_pixel),
    .valid(instructions_valid)
);


//LOSE CARD HEX TO PIXELS ASSIGNMENTS
wire [11:0] lose_pixel;
wire lose_valid;

wire [23:0] lose_color_24;
assign lose_color_24 = {lose_pixel[11:8], 4'b0000,
                           lose_pixel[7:4],  4'b0000,
                           lose_pixel[3:0],  4'b0000};

image_rom #(
    .IMAGE_WIDTH(160),
    .IMAGE_HEIGHT(120),
    .MIF_FILE("lose.hex")
) lose_image (
    .clk(clk),
    .x(x),
    .y(y),
    .base_x(lose_x),
    .base_y(lose_y),
    .pixel_data(lose_pixel),
    .valid(lose_valid)
);

wire [11:0] lost_pixel;
wire lost_valid;

wire [23:0] lost_color_24;
assign lost_color_24 = {lost_pixel[11:8], 4'b0000,
                           lost_pixel[7:4],  4'b0000,
                           lost_pixel[3:0],  4'b0000};

image_rom #(
    .IMAGE_WIDTH(160),
    .IMAGE_HEIGHT(120),
    .MIF_FILE("lost.hex")
) lost_image (
    .clk(clk),
    .x(x),
    .y(y),
    .base_x(lost_x),
    .base_y(lost_y),
    .pixel_data(lost_pixel),
    .valid(lost_valid)
);

endmodule
