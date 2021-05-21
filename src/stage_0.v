module stage_0(  
	CLK,
	FLOAT32_IN,
	FLOAT32_OUT, /*e^b IEEE 745 output*/
	A, 			 /*x - a Q3.23 output*/
	E,           /*e^a Q3.23 output*/
	next_stage_start,
	/*control signal*/
	load,
	start,
	float32tofix_reg_en,
	float32_a_reg_en,
	fixed_reg_en,
	output_ready,
	/*debug*/
	D_FLOAT32_OUT,
	D_A,
	D_E,
	D_int,
	D_frac
);
	input CLK, load, start, float32tofix_reg_en, float32_a_reg_en, fixed_reg_en, output_ready;
	input [31:0] FLOAT32_IN;
	output next_stage_start;
	output reg [31:0] FLOAT32_OUT;
	output reg [25:0] A, E;
	
	output [7:0] D_int;
	output [22:0] D_frac;
	output [31:0] D_FLOAT32_OUT;
	output [25:0] D_A, D_E;
	
	/*input load reg*/
	reg [31:0] reg_input;
	always @ (posedge CLK) begin 
		if(load) 
			reg_input <= FLOAT32_IN;
	end
	wire [7:0] _int;
	wire [22:0] frac;
 	float32tofix my_float32tofix(
		.IN_FLOAT32(reg_input), /*IEEE FP32 input*/
		.OUT_frac(frac), /*fraction output part*/
		.OUT_int(_int) /*integer output part*/
	);
	/*float32 to fixed reg*/
	assign D_int = _int;
	assign D_frac = frac;
	reg [7:0] int_;
	reg [22:0] frac_;
	always @ (posedge CLK) begin
		if(float32tofix_reg_en) begin
			int_ <= _int;
			frac_ <= frac;
		end
	end
	wire [31:0] float32_A;
	LUT_89_88 my_LUT_1( 
		.IN_FIXED_INT(int_), /*FIXED POINT INTEGER input*/
		.OUT_FLOAT32(float32_A)
	);
	wire [25:0] fixed_a, fixed_e;
	LUT_0_1 my_LUT_2(
		.IN_frac(frac_),
		.IN_int(3'd0),
		.OUT_frac(fixed_e[22:0]),
		.OUT_int(fixed_e[25:23]),
		.OUT_a_frac(fixed_a[22:0]),
		.OUT_a_int(fixed_a[25:23])
	);
	/*LUT  0_1  reg*/
	assign D_A = fixed_a;
	assign D_E = fixed_e;
	reg [25:0] fixed_e_out, fixed_a_out;
	always @ (posedge CLK) begin
		if(fixed_reg_en) begin
			fixed_e_out <= fixed_e;
			fixed_a_out <= fixed_a;
		end
	end
	/*LUT 88_89 reg*/
	reg [31:0] float32_88_89_reg;
	assign D_FLOAT32_OUT = float32_88_89_reg;
	always @ (posedge CLK) begin
		if(float32_a_reg_en)
			float32_88_89_reg <= float32_A;
	end
	wire [25:0] neg_a;
	wire [25:0] add_output;
	assign neg_a = ~fixed_a_out + 26'd1;
	adder my_adder_( 
		.IN_FRAC_1(neg_a[22:0]),
		.IN_INT_1(neg_a[25:23]),
		.IN_FRAC_2(frac_),
		.IN_INT_2(3'd0),
		.OUT_FRAC(add_output[22:0]),
		.OUT_INT(add_output[25:23])
	);
	/*pipeline reg*/
	reg stage_1_start;
	always  @ (posedge CLK) begin
		if(output_ready) begin
			stage_1_start <= 1'b1;
			A <= add_output;
			E <= fixed_e_out;
			FLOAT32_OUT <= float32_88_89_reg;
		end else begin
			stage_1_start <= 1'b0;
			//A <= 26'd0; /*fix bug v1.1*/
			//E <= 26'd0;
			//FLOAT32_OUT <= 32'd0; 
		end
	end
	assign next_stage_start = stage_1_start; /*trigger stage 1 to start*/
endmodule