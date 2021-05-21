module fixedtofloat32(
	IN_FRAC, /*fraction part input*/
	IN_INT, /*integer part input*/
	OUT_FLOAT32 /*float32 output*/
);
	parameter num_of_int = 3;
	parameter num_of_frac = 23;

	input [num_of_int - 1:0] IN_INT;
	input [num_of_frac - 1:0] IN_FRAC;
	output [31:0] OUT_FLOAT32;
	
	wire [7:0] E;
	wire [(num_of_frac + num_of_int) - 1:0] TMP;
	
	assign TMP = (OUT_FLOAT32[31])?({~IN_INT, ~IN_FRAC} + 26'd1):{IN_INT, IN_FRAC}; /*abs of INPUT*/
	assign OUT_FLOAT32[31] /*sign bit*/ = ($signed(IN_INT) < 3'sd0)?1'b1:1'b0; 
	assign OUT_FLOAT32[30-:8] /*exponent calulate*/ = E + 8'd127; 
	assign {E, OUT_FLOAT32[22:0]} =  (TMP[25])?{8'sd2, TMP[24-:23]}:
												(TMP[24])?{8'sd1, TMP[23-:23]}:
												(TMP[23])?{8'sd0, TMP[22-:23]}:
												(TMP[22])?{-8'sd1, {TMP[21:0], 1'd0}}:
												(TMP[21])?{-8'sd2, {TMP[20:0], 2'd0}}:
												(TMP[20])?{-8'sd3, {TMP[19:0], 3'd0}}:
												(TMP[19])?{-8'sd4, {TMP[18:0], 4'd0}}:
												(TMP[18])?{-8'sd5, {TMP[17:0], 5'd0}}:
												(TMP[17])?{-8'sd6, {TMP[16:0], 6'd0}}:
												(TMP[16])?{-8'sd7, {TMP[15:0], 7'd0}}:
												(TMP[15])?{-8'sd8, {TMP[14:0], 8'd0}}:
												(TMP[14])?{-8'sd9, {TMP[13:0], 9'd0}}:
												(TMP[13])?{-8'sd10, {TMP[12:0], 10'd0}}:
												(TMP[12])?{-8'sd11, {TMP[11:0], 11'd0}}:
												(TMP[11])?{-8'sd12, {TMP[10:0], 12'd0}}:
												(TMP[10])?{-8'sd13, {TMP[9:0], 13'd0}}:
												(TMP[9])?{-8'sd14, {TMP[8:0], 14'd0}}:
												(TMP[8])?{-8'sd15, {TMP[7:0], 15'd0}}:
												(TMP[7])?{-8'sd16, {TMP[6:0], 16'd0}}:
												(TMP[6])?{-8'sd17, {TMP[5:0], 17'd0}}:
												(TMP[6])?{-8'sd18, {TMP[4:0], 18'd0}}:
												(TMP[4])?{-8'sd19, {TMP[3:0], 19'd0}}:
												(TMP[3])?{-8'sd20, {TMP[2:0], 20'd0}}:
												(TMP[2])?{-8'sd21, {TMP[1:0], 21'd0}}:
												(TMP[1])?{-8'sd22, {TMP[0], 22'd0}}:
												(TMP[0])?{-8'sd23, 23'd0}:{-8'sd127, 23'd0};
				  
	
	
endmodule

