module keyboard (
	input 		         clk,
	input	     		rst,
	inout 		          		PS2_CLK,
	inout 		          		PS2_DAT,
	output reg click,
	output reg up,
	output reg down,
	output reg left,
	output reg right
);




 
wire PS2C;
assign PS2C = PS2_CLK;
wire PS2D;
assign PS2D = PS2_DAT;



reg [7:0] keyval1;
reg [7:0] keyval2;
reg [7:0] keyval3;
reg [7:0] ps2c_filter;
reg [7:0] ps2d_filter;
reg PS2Cf;
reg PS2Df;
reg [10:0] shift1;
reg [10:0] shift2;
reg [10:0] shift3;
reg [7:0] keyval1s;
reg [7:0] keyval2s;
reg [7:0] keyval3s;
reg [3:0] bit_count;
parameter bit_count_max = 4'd11;

reg [3:0] S;
reg [3:0] NS;
parameter START = 4'd0,
			 WTCLKLO1 = 4'd1,
			 WTCLKHI1 = 4'd2,
			 GETKEY1 = 4'd3,
			 WTCLKLO2 = 4'd4,
			 WTCLKHI2 = 4'd5,
			 GETKEY2 = 4'd6,
			 BREAKKEY = 4'd7,
			 WTCLKLO3 = 4'd8,
			 WTCLKHI3 = 4'd9,
			 GETKEY3 = 4'd10,
			 ERROR = 4'hF;
			 
always @(posedge clk or negedge rst) //filter signals in
begin
	if (rst == 1'b0)
		begin
			ps2c_filter <= 8'd0;
			ps2d_filter <= 8'd0;
			PS2Cf <= 1'd1;
			PS2Df <= 1'd1;
		end
	else
		begin
			ps2c_filter[7] <= PS2C;
			ps2c_filter[6:0] <= ps2c_filter[7:1];
			ps2d_filter[7] <= PS2D;
			ps2d_filter[6:0] <= ps2d_filter[7:1];
			if (ps2c_filter == 8'hFF)
				PS2Cf <= 1'd1;
			else if (ps2c_filter == 8'h00)
				PS2Cf <= 1'd0;
			if (ps2d_filter == 8'hFF)
				PS2Df <= 1'd1;
			else if (ps2d_filter == 8'h00)
				PS2Df <= 1'd0;
		end
end	

always @(posedge clk or negedge rst) //state progression
	if (rst == 1'b0)
		S <= START;
	else 
		S <= NS;

always @(posedge clk or negedge rst) //State Transitions
case(S)
			START: if (PS2Df == 1'd1)
						NS <= START;
					 else
						NS <= WTCLKLO1;
			WTCLKLO1: if(bit_count < bit_count_max)
							begin
								if(PS2Cf == 1'd1)
									NS <= WTCLKLO1;
								else 
									NS <= WTCLKHI1;
							end
						 else
							NS <= GETKEY1;
			WTCLKHI1: if(PS2Cf == 1'd0)
							NS <= WTCLKHI1;
						 else
							NS <= WTCLKLO1;
			GETKEY1: NS = WTCLKLO2;
			WTCLKLO2: if(bit_count < bit_count_max)
							begin
								if(PS2Cf == 1'd1)
									NS <= WTCLKLO2;
								else 
									NS <= WTCLKHI2;
							end
						 else
							NS <= GETKEY2;
			WTCLKHI2: if(PS2Cf == 1'd0)
							NS <= WTCLKHI2;
						 else
							NS <= WTCLKLO2;
			GETKEY2: NS = BREAKKEY;
			BREAKKEY: if(keyval2s == 8'hF0)
							NS <= WTCLKLO3;
						 else 
							begin
								if(keyval1s == 8'hE0)
									NS <= WTCLKLO1;
								else
									NS <= WTCLKLO2;
							end
			WTCLKLO3: if(bit_count < bit_count_max)
							begin
								if(PS2Cf == 1'd1)
									NS <= WTCLKLO3;
								else 
									NS <= WTCLKHI3;
							end
						 else
							NS <= GETKEY3;
			WTCLKHI3: if(PS2Cf == 1'd0)
							NS <= WTCLKHI3;
						 else
							NS <= WTCLKLO3;
			GETKEY3:NS <= WTCLKLO1;
			default: NS <= ERROR;
endcase

always @(posedge clk or negedge rst) //what it do in the states
begin
	if (rst == 1'b0)
		begin
			bit_count <= 4'd0;
			shift1 <= 11'd0;
			shift2 <= 11'd0;
			shift3 <= 11'd0;
			keyval1s <= 8'd0;
			keyval2s <= 8'd0;
			keyval3s <= 8'd0;
		end
	else
		begin
		keyval1 <= keyval1s;
		keyval2 <= keyval2s;
		keyval3 <= keyval3s;		
			case(S)
				START: bit_count <= 4'd0;
				WTCLKLO1: if(bit_count < bit_count_max)
								if(PS2Cf == 1'd0)
									shift1 <= {PS2Df, shift1[10:1]};
				WTCLKHI1: if(PS2Cf == 1'd1)
								bit_count <= bit_count + 1'd1;
				GETKEY1: 
					begin
						keyval1s <= shift1[9:2];
						bit_count <= 4'd0;
					end
				WTCLKLO2: if(bit_count < bit_count_max)
								if(PS2Cf == 1'd0)
									shift2 <= {PS2Df, shift2[10:1]};	
				WTCLKHI2: if(PS2Cf == 1'd1)
								bit_count <= bit_count + 1'd1;						
				GETKEY2: 
					begin
						keyval2s <= shift2[9:2];
						bit_count <= 4'd0;
					end		
				WTCLKLO3: if(bit_count < bit_count_max)
								if(PS2Cf == 1'd0)
									shift3 <= {PS2Df, shift3[10:1]};
				WTCLKHI3: if(PS2Cf == 1'd1)
								bit_count <= bit_count + 1'd1;	
				GETKEY3: 
					begin
						keyval3s <= shift3[9:2];
						bit_count <= 4'd0;
					end		
			endcase
		end
end




   
always @(posedge clk or negedge rst)
begin
	 if (rst == 1'b0)
		  click <= 1'd0;
	 else if (keyval2 == 8'h5A)  // Enter key detected
		  click <= 1'd1;
	 else
		  click <= 1'd0;
end

always @(posedge clk or negedge rst)
begin
	 if (rst == 1'b0)
		  up <= 1'd0;
	 else if (keyval2 == 8'h75 && keyval1 == 8'hE0)  // up key detected
		  up <= 1'd1;
	 else
		  up <= 1'd0;
end
always @(posedge clk or negedge rst)
begin
	 if (rst == 1'b0)
		  down <= 1'd0;
	 else if (keyval2 == 8'h72 && keyval1 == 8'hE0)  // down key detected
		  down <= 1'd1;
	 else
		  down <= 1'd0;
end
always @(posedge clk or negedge rst)
begin
	 if (rst == 1'b0)
		  left <= 1'd0;
	 else if (keyval2 == 8'h6B && keyval1 == 8'hE0)  // left key detected
		  left <= 1'd1;
	 else
		  left <= 1'd0;
end
always @(posedge clk or negedge rst)
begin
	 if (rst == 1'b0)
		  right <= 1'd0;
	 else if (keyval2 == 8'h74 && keyval1 == 8'hE0)  // right key detected
		  right <= 1'd1;
	 else
		  right <= 1'd0;
end

endmodule