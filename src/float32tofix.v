/* Q format float32 to fixed point*/
module float32tofix(
	IN_FLOAT32, /*IEEE FP32 input*/
	overflow,
	OUT_frac, /*fraction output part*/
	OUT_int /*integer output part*/
);
	parameter num_of_int = 8; /*weight of integer*/
	parameter num_of_frac = 23; /* num of frac must be 23*/
   //////////////Q32.23/////////////////
	input [31:0] IN_FLOAT32;
	output overflow;
	output [num_of_frac - 1:0] OUT_frac; 
	output [num_of_int -1:0] OUT_int; 
	
	wire [num_of_frac + num_of_int - 1:0] TMP_1;
	wire [num_of_frac + num_of_int - 1:0] TMP_2;
	wire [num_of_frac + num_of_int - 1:0] FIX;
	wire [7:0] E;

	assign TMP_1 = {1'b1, IN_FLOAT32[22:0]}; /* select fraction section*/
	assign E = IN_FLOAT32[30:23] - 8'd127; /* calculate exponent */
	assign {overflow, TMP_2} = ($signed(E) > 8'sd0)?(TMP_1 << (E)):(TMP_1 >> (8'd0 - E));
	assign FIX = (IN_FLOAT32[31])?(~TMP_2 + 26'd1 /*negetive input handle*/):TMP_2; 
	
	assign OUT_frac = FIX[num_of_frac - 1:0]; 
	assign OUT_int = FIX[num_of_frac + num_of_int - 1:num_of_frac];
	
endmodule
