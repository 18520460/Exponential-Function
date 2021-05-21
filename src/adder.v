module adder ( 
	IN_FRAC_1,
	IN_INT_1,
	IN_FRAC_2,
	IN_INT_2,
	OUT_FRAC,
	OUT_INT
);
	parameter num_of_int = 3; /*weight of integer*/
	parameter num_of_frac = 23; /* num of frac must be 23*/
	input [num_of_int - 1:0] IN_INT_1;
	input [num_of_int - 1:0] IN_INT_2;
	input [num_of_frac - 1:0] IN_FRAC_1;
	input [num_of_frac - 1:0] IN_FRAC_2;
	output [num_of_int - 1:0] OUT_INT;
	output [num_of_frac - 1:0] OUT_FRAC;
	
	assign {OUT_INT, OUT_FRAC} = {IN_INT_1, IN_FRAC_1} + {IN_INT_2, IN_FRAC_2};
endmodule
