module stage_5_control( 
	CLK,
	start,
	rst,
	reg_mul_output_en,
	reg_fixtofloat_output_en,
	reg_binary_mul_output_en,
	output_oe
);
	input start, rst, CLK;
	output reg reg_mul_output_en, reg_fixtofloat_output_en, reg_binary_mul_output_en, output_oe;
	reg [1:0] state;
	/*input*/
	always @ (posedge CLK or posedge rst) begin
		if(rst)
			state <= 2'd0;
		else if (start && state == 2'd0) 
			state <= 2'd1;
		else if(state >= 2'd1)
			state <= state + 2'd1;
	end
	/*output*/
	always @* begin
		reg_mul_output_en = 0;
		reg_fixtofloat_output_en = 0;
		reg_binary_mul_output_en = 0;
		output_oe = 0;
		case(state)
			2'd0 : reg_mul_output_en = 1;
			2'd1 : reg_fixtofloat_output_en = 1;
			2'd2 : reg_binary_mul_output_en = 1;
			2'd3 : output_oe = 1;
			default: output_oe  = 0;
		endcase
	end
endmodule