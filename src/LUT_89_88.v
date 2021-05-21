module LUT_89_88( 
	IN_FIXED_INT, /*FIXED POINT INTEGER input*/
	OUT_FLOAT32
);


	parameter num_of_int = 8;
	reg [31:0] memory [0:191];
	initial
		$readmemb("LUT_neg103_88.txt", memory);
	input [num_of_int - 1:0] IN_FIXED_INT;
	output [31:0] OUT_FLOAT32;
	
	assign OUT_FLOAT32 = ((IN_FIXED_INT + 8'd103 >= 8'sd0) && (IN_FIXED_INT + 8'sd103 <= 8'd191)) ? memory[IN_FIXED_INT + 8'd103] : //fix
								($signed(IN_FIXED_INT) >= 8'sd0) ? {1'b0, 8'hff, 23'd0} : 32'd0; //fix E^x (x>>) = 0
								
endmodule
