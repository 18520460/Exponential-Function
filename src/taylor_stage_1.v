module taylor_stage_1( 
	CLK,
	IN_A, /*x - a*/
	OUT,
	/*control signal*/
	mul_ss,
	add_ss,
	mul_ss_en,
	add_ss_en
);
	
	input CLK, mul_ss, add_ss, mul_ss_en, add_ss_en;
	input [25:0] IN_A;
	output [25:0] OUT;
	wire [25:0] mul_port_B;
	wire [25:0] add_port_B;
	wire [25:0] mul_out, add_out;
	reg [25:0] reg_mul, reg_add;
	assign mul_port_B = (mul_ss) ? 26'b00000000000010110110000010 /*1/720*/ : reg_add;
	multiplier my_mul( 
		.IN_FRAC_1(IN_A[22:0]),
		.IN_INT_1(IN_A[25:23]),
		.IN_FRAC_2(mul_port_B[22:0]),
		.IN_INT_2(mul_port_B[25:23]),
		.OUT_FRAC(mul_out[22:0]),
		.OUT_INT(mul_out[25:23])
	);
	assign add_port_B = (add_ss) ? 26'b00000000010001000100010001/*1/120*/ : 26'b00000001010101010101010101/*1/24*/;
   adder my_add( 
		.IN_FRAC_1(reg_mul[22:0]),
		.IN_INT_1(reg_mul[25:23]),
		.IN_FRAC_2(add_port_B[22:0]),
		.IN_INT_2(add_port_B[25:23]),
		.OUT_FRAC(add_out[22:0]),
		.OUT_INT(add_out[25:23])
	);
	always @ (posedge CLK) begin
		if(add_ss_en)
			reg_add <= add_out;
		else if(mul_ss_en)
			reg_mul <= mul_out;
		end
	assign OUT = add_out;	
endmodule