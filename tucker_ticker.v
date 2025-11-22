module tucker_ticker(clk, rst, sec);

input clk, rst;
output reg sec;

reg [26:0] ticker;

always @ (posedge clk or negedge rst)
begin
	if (rst == 1'b0)
		begin
			 ticker <= 27'd0;
			 sec <= 1'd0;
	   end
	else if (ticker >= 27'd50000000)
		begin
			sec <= 1'd1;
			ticker <= 27'd0;
		end
	else
		begin
			ticker <= ticker + 1'd1;
			sec <= 1'd0;
		end
end
endmodule