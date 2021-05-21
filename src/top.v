module top(
	CLK,
	start,				/*EN*/
	rst,					/*reset*/
	load, 				/*load signal*/
	load_success,		/*feedback signal when load success*/
	input_ready,		/*input available*/
	output_ready,		/*output available*/
	FLOAT32_IN, 		/*IEEE x input*/
	FLOAT32_OUT, 		/*IEEE e^x output*/	
	/*debug only*/
	D_state,
	D_FIX_taylor_output,
	D_e,
	D_x,
	D_taylor_1,
	D_taylor_2,
	D_taylor_3
);
	/*---------------------------------------------------*/
	/*-----------------port declare----------------------*/
	/*---------------------------------------------------*/
	input         CLK, start, rst, load;
	output        input_ready, output_ready, load_success;
	output [2:0] D_state;
	input  [31:0] FLOAT32_IN;
	output [31:0] FLOAT32_OUT;
	output [25:0] D_FIX_taylor_output, D_e, D_x, D_taylor_3, D_taylor_2, D_taylor_1;
	/*----------------------------------------------------*/
	/*------------- stage 0 input reprocess---------------*/
	/*----------------------------------------------------*/
	wire   [25:0] IN_A, stage_0_E;
	wire   [31:0] stage_0_FLOAT32_OUT;
	wire stage_1_start;
	input_process_stage my_stage_0( 
		.CLK(CLK),
		.rst(rst),
		.FLOAT32_IN(FLOAT32_IN),				/*IEEE float32 x input*/
		.FLOAT32_OUT(stage_0_FLOAT32_OUT),  /*e^b IEEE 745 output*/
		.A(IN_A), 	  								/*x - a Q3.23 output*/
		.E(stage_0_E),           				/*e^a Q3.23 output*/
		.next_stage_start(stage_1_start),	/*next stage triger signal*/
		/*---------control signal----------*/
		.load(load), 								/*input data load*/
		.start(start), 							/*function like OE*/
		.input_ready(input_ready),  			/*input load available*/
		.load_success(load_success),
		.d_state(D_state)
	);
	assign D_x = IN_A;
	/*----------------------------------------------------*/
	/*------------- stage 1 taylor part 1  ---------------*/
	/*----------------------------------------------------*/
	wire         stage_1_mul_ss, stage_1_add_ss, stage_1_output_ready, stage_1_is_pass, stage_1_mul_ss_en, stage_1_add_ss_en;
	wire  [25:0] stage_1_output;
	wire  [25:0] stage_1_E;
	wire  [31:0] stage_1_FLOAT32_OUT;
	/*control*/
	taylor_stage_1_control my_control_1( 
		.CLK(CLK),
		.start(stage_1_start),
		.rst(rst),
		.output_ready(stage_1_output_ready),
		.mul_ss(stage_1_mul_ss),
		.add_ss(stage_1_add_ss),
		.mul_ss_en(stage_1_mul_ss_en),
		.add_ss_en(stage_1_add_ss_en)
	);
	/*datapath*/
	taylor_stage_1 my_stage_1( 			
		.CLK(CLK),
		.IN_A(IN_A), /*x - a*/
		.OUT(stage_1_output),
		/*control signal*/
		.mul_ss(stage_1_mul_ss),
		.add_ss(stage_1_add_ss),
		.mul_ss_en(stage_1_mul_ss_en),
		.add_ss_en(stage_1_add_ss_en)
	);
	/*----------------------------------------------------*/
	/*-------pipeline register part 1 && part 2-----------*/
	/*----------------------------------------------------*/
	reg [25:0] reg_stage1_stage2;
	reg        reg_stage2_start;
	reg [25:0] reg_stage_1_E;
	reg [25:0] reg_stage_1_A;
	reg [31:0] reg_stage_1_FLOAT32_OUT; 
	assign D_taylor_1 = reg_stage1_stage2;
	always @ (posedge CLK) begin
		if(stage_1_output_ready) begin
			reg_stage_1_A <= IN_A;
			reg_stage_1_E <= stage_0_E;
			reg_stage_1_FLOAT32_OUT <= stage_0_FLOAT32_OUT;
			end
		end
	always @ (posedge CLK) begin
		if(stage_1_output_ready) begin
			reg_stage1_stage2 <= stage_1_output;
			reg_stage2_start <= 1'b1;
			end
		else begin
			reg_stage1_stage2 <= 26'd0;
			reg_stage2_start <= 1'b0;
			end
		end
	/*----------------------------------------------------*/
	/*------------- stage 2 taylor part 2  ---------------*/
	/*----------------------------------------------------*/
	wire stage_2_mul_ss, stage_2_add_ss, stage_2_output_ready, stage_2_mul_ss_en, stage_2_add_ss_en;
	wire [25:0] stage_2_output;
	/*control*/
	taylor_stage_2_control my_control_2( 
		.CLK(CLK),
		.start(reg_stage2_start),
		.rst(rst),
		.output_ready(stage_2_output_ready),
		.mul_ss(stage_2_mul_ss),
		.add_ss(stage_2_add_ss),
		.mul_ss_en(stage_2_mul_ss_en),
		.add_ss_en(stage_2_add_ss_en)
	);
	/*datapath*/
	taylor_stage_2 my_stage_2( 
		.CLK(CLK),
		.IN_A(reg_stage_1_A), /*x - a*/
		.IN_B(reg_stage1_stage2), 
		.OUT(stage_2_output),
		/*control signal*/
		.mul_ss(stage_2_mul_ss),
		.add_ss(stage_2_add_ss),
		.mul_ss_en(stage_2_mul_ss_en),
		.add_ss_en(stage_2_add_ss_en)
	);
	/*----------------------------------------------------*/
	/*-------pipeline register part 1 && part 2-----------*/
	/*----------------------------------------------------*/
	reg [25:0] reg_stage2_stage3;
	reg        reg_stage3_start;
	reg [25:0] reg_stage_2_E;
	reg [25:0] reg_stage_2_A;
	reg [31:0] reg_stage_2_FLOAT32_OUT;
	assign D_taylor_2 = reg_stage2_stage3;
	always @ (posedge CLK) begin
		if(reg_stage2_start) begin
			reg_stage_2_E <= reg_stage_1_E;
			reg_stage_2_FLOAT32_OUT <= reg_stage_1_FLOAT32_OUT;
		end
	end
	always @ (posedge CLK) begin
		if(stage_2_output_ready) begin
			reg_stage_2_A <= reg_stage_1_A;
			reg_stage2_stage3 <= stage_2_output;
			reg_stage3_start <= 1'b1;
		end
		else begin
			reg_stage2_stage3 <= 26'd0;
			reg_stage3_start <= 1'b0;
		end
	end
	/*----------------------------------------------------*/
	/*------------- stage 3 taylor part 3  ---------------*/
	/*----------------------------------------------------*/
	wire stage_3_mul_ss, stage_3_output_ready, stage_3_mul_ss_en, stage_3_add_ss_en;
	wire [25:0] stage_3_output;
	/*control*/
	taylor_stage_3_control my_control_3( 
		.CLK(CLK),
		.start(reg_stage3_start),
		.rst(rst),
		.output_ready(stage_3_output_ready),
		.mul_ss(stage_3_mul_ss),
		.mul_ss_en(stage_3_mul_ss_en),
		.add_ss_en(stage_3_add_ss_en)
	);
	/*datapath*/
	taylor_stage_3 my_stage_3( 
		.CLK(CLK),
		.IN_A(reg_stage_2_A), /*x - a*/
		.IN_B(reg_stage2_stage3), 
		.OUT(stage_3_output),
		/*control signal*/
		.mul_ss(stage_3_mul_ss),
		.mul_ss_en(stage_3_mul_ss_en),
		.add_ss_en(stage_3_add_ss_en)
	);
	/*----------------------------------------------------*/
	/*-------pipeline register part 2 && part 3-----------*/
	/*----------------------------------------------------*/
	reg [25:0] reg_stage3_stage4;
	reg        reg_stage4_start;
	reg [25:0] reg_stage_3_E;
	reg [31:0] reg_stage_3_FLOAT32_OUT;
	assign D_taylor_3 = reg_stage3_stage4;
	always @ (posedge CLK) begin
		if(reg_stage3_start) begin
			reg_stage_3_E <= reg_stage_2_E;
			reg_stage_3_FLOAT32_OUT <= reg_stage_2_FLOAT32_OUT;
		end
	end
	always @ (posedge CLK) begin
		if(stage_3_output_ready) begin
			reg_stage3_stage4 <= stage_3_output;
			reg_stage4_start <= 1'b1;
		end
		else begin
			reg_stage3_stage4 <= 26'd0;
			reg_stage4_start <= 1'b0;
			end
	end
	/*----------------------------------------------------*/
	/*------------- stage 4 output process  --------------*/
	/*----------------------------------------------------*/
	assign D_e = reg_stage_3_E;
	output_process_stage my_stage_5( 
		.CLK(CLK),
		.start(reg_stage4_start),
		.rst(rst),
		.FIXED_taylor_input(reg_stage3_stage4),
		.FIXED_e_input(reg_stage_3_E),
		.FLOAT_e_input(reg_stage_3_FLOAT32_OUT),
		.FLOAT_result_output(FLOAT32_OUT),
		.output_ready(output_ready),
		.D_taylor_output(D_FIX_taylor_output)
	);
endmodule
