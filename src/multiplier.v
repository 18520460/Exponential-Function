module multiplier ( 
	IN_FRAC_1,
	IN_INT_1,
	IN_FRAC_2,
	IN_INT_2,
	OUT_FRAC,
	OUT_INT

);
	parameter num_of_int = 32; /*weight of integer*/
	parameter num_of_frac = 23; /* num of frac must be 23*/
	input [num_of_int - 1:0] IN_INT_1;
	input [num_of_int - 1:0] IN_INT_2;
	input [num_of_frac - 1:0] IN_FRAC_1;
	input [num_of_frac - 1:0] IN_FRAC_2;
	output [num_of_int - 1:0] OUT_INT;
	output [num_of_frac - 1:0] OUT_FRAC;

	wire [(num_of_int + num_of_frac) * 2 - 1:0] result;
	assign result = {IN_INT_1, IN_FRAC_1} * {IN_INT_2, IN_FRAC_2};
	assign OUT_INT = result[(num_of_frac * 2)+:num_of_int]; /**/ 
	assign OUT_FRAC = result[(num_of_frac * 2 - 1)-:num_of_frac];

endmodule	