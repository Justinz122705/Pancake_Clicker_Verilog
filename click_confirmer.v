module click_confirmer (clk, rst, pushed, confirmation);
input clk, rst;
input pushed;
output reg confirmation;

reg [1:0] S;
reg [1:0] NS;

parameter REST = 2'd0,
			 PRESS = 2'd1,
			 RELEASED = 2'd2,
			 ERROR = 2'd3;
			 
			 
always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
		S <= REST;
	else
		S <= NS;
end

always @(posedge clk or negedge rst)
begin 
	case(S)
		REST: if (pushed == 1'd1)
					NS <= PRESS;
				else 
					NS <= REST;
		PRESS: if(pushed == 1'd0)
					NS <= RELEASED;
				 else 
					NS <= PRESS;
		RELEASED: NS <= REST;
		default: NS <= ERROR;
	endcase
end

always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
		confirmation <= 1'b0;
	else 
	begin
		case(S)
			REST: confirmation <= 1'b0;
			PRESS: confirmation <= 1'b0;
			RELEASED: confirmation <= 1'b1;
		endcase
	end
end

endmodule
		
