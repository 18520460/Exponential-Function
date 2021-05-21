module LUT_0_1(
	IN_frac,
	IN_int,
	OUT_frac,
	OUT_int,
	OUT_a_frac,
	OUT_a_int
);
	parameter num_of_int = 3;
	parameter num_of_frac = 23;
	
	input [num_of_frac - 1:0] IN_frac; 
	input [num_of_int -1:0] IN_int; 
	output [num_of_frac - 1:0] OUT_frac; 
	output [num_of_int -1:0] OUT_int; 
	output [num_of_frac - 1:0] OUT_a_frac; 
	output [num_of_int -1:0] OUT_a_int; 
	
	wire [num_of_int + num_of_frac - 1:0] OUT;
	
	reg	[num_of_int + num_of_frac - 1:0]	Imem [0:2**8 - 1];

	initial
		$readmemb ("LUT_1_0.txt", Imem);
	assign OUT = Imem[IN_frac[(num_of_frac - 1)-:8]];
	assign OUT_frac = (IN_int == 0 && IN_frac[(num_of_frac - 1)-:8] == 8'd0)?
							23'd0:OUT[22-:23];
	assign OUT_int = (IN_int == 0 && IN_frac[(num_of_frac - 1)-:8] == 8'd0)?
							3'd1:OUT[(num_of_int + num_of_frac - 1)-:3];
							
	assign OUT_a_int = IN_int;
	assign OUT_a_frac = {IN_frac[(num_of_frac - 1)-:8], 15'd0};

endmodule