module taylor_stage_2( 
	CLK,
	IN_A, /*x - a*/
	IN_B, 
	OUT,
	/*control signal*/
	mul_ss,
	add_ss,
	mul_ss_en,
	add_ss_en
);
	input CLK, mul_ss, add_ss, mul_ss_en, add_ss_en;
	input [25:0] IN_A, IN_B;
	output [25:0] OUT;
	wire [25:0] mul_port_B;
	wire [25:0] add_port_B;
	wire [25:0] mul_out, add_out;
	reg [25:0] reg_mul, reg_add;
	assign mul_port_B = (mul_ss) ? IN_B : reg_add;
	multiplier my_mul( 
		.IN_FRAC_1(23'b00000000111001000101100),
		.IN_INT_1(3'd0),
		//.IN_FRAC_1(IN_A[22:0]),
		//.IN_INT_1(IN_A[25:23]),
		.IN_FRAC_2(mul_port_B[22:0]),
		.IN_INT_2(mul_port_B[25:23]),
		.OUT_FRAC(mul_out[22:0]),
		.OUT_INT(mul_out[25:23])
	);
	assign add_port_B = (add_ss) ? 26'b00010000000000000000000000/*1/2*/ : 26'b00000101010101010101010101/*1/6*/;
   adder my_add( 
		.IN_FRAC_1(reg_mul[22:0]),
		.IN_INT_1(reg_mul[25:23]),
		.IN_FRAC_2(add_port_B[22:0]),
		.IN_INT_2(add_port_B[25:23]),
		.OUT_FRAC(add_out[22:0]),
		.OUT_INT(add_out[25:23])
	);
	always @ (posedge CLK) begin
		if(mul_ss_en)
			reg_mul <= mul_out;
		else if(add_ss_en)
			reg_add <= add_out;
		end
	assign OUT = add_out;	
endmodule
