module three_decimal_vals_w_neg (
input [7:0]val,
output [6:0]seg7_neg_sign,
output [6:0]seg7_dig0,
output [6:0]seg7_dig1,
output [6:0]seg7_dig2
);

reg [3:0] result_one_digit;
reg [3:0] result_ten_digit;
reg [3:0] result_hundred_digit;
reg result_is_negative;

reg [7:0]twos_comp;

/* convert the binary value into 4 signals */
always @(*)
begin
	if (val[7] == 1'b1) begin
		twos_comp = ~val + 1;
		result_is_negative = 1'b1;
		result_ten_digit = (twos_comp / 10) % 10;
		result_one_digit = twos_comp % 10;
		result_hundred_digit = twos_comp / 100;
	end
	else begin
		result_is_negative = 1'b0;
		result_ten_digit = (val / 10) % 10;
		result_one_digit = val % 10;
		result_hundred_digit = (val) / 100;
	end
end

/* instantiate the modules for each of the seven seg decoders including the negative one */
seven_segment dig2(.i(result_hundred_digit),.o(seg7_dig2));
seven_segment dig1(.i(result_ten_digit),.o(seg7_dig1));
seven_segment dig0(.i(result_one_digit),.o(seg7_dig0));
seven_segment_negative neg(.i(result_is_negative),.o(seg7_neg_sign));

endmodule