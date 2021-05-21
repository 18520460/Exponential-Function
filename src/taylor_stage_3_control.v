	module taylor_stage_3_control( 
	CLK,
	rst,
	start,
	ready,
	output_ready,
	mul_ss,
	mul_ss_en,
	add_ss_en
);
	input start, rst, CLK;
	output reg ready, output_ready, mul_ss, mul_ss_en, add_ss_en;
	reg [1:0] state;
	/*input*/
	always @ (posedge CLK or posedge rst) begin
		if(rst)
			state <= 2'd0;
		else if (start) 
			state <= 2'd1;
		else if(state >= 2'd1)
			state <= state + 2'd1;
	end
	/*output*/
	always @* begin
		ready = 0;
		output_ready = 0;
		mul_ss = 0;
		mul_ss_en = 0;
		add_ss_en = 0;
		case(state)
			2'd0 : begin
					 mul_ss = 1;
					 mul_ss_en = 1;
					 end
			2'd1 : add_ss_en  = 1; 
			2'd2 : begin
					 mul_ss = 0;
					 mul_ss_en = 1;
					 end
			2'd3 : begin
						ready = 1;
						output_ready = 1;
					 end
			default: begin
							ready = 0;
							output_ready = 0;
							mul_ss = 0;
						end
		endcase
	end
endmodule