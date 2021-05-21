module stage_0_control( 
	CLK,
	start,
	rst,
	input_ready,
	float32tofix_reg_en,
	float32_a_reg_en,
	fixed_reg_en,
	output_ready,
	load_input,
	load_success,
	/*debug*/
	d_state
);
/*------------------STATE--------------------*/
	parameter state_convert = 0;
	parameter state_LUT_1 = 1;
	parameter state_LUT_2 = 2;
	parameter state_cal_a = 3;
	parameter state_rst = 4;
	parameter state_error = 5;
/*-------------------------------------------*/
	input start, rst, CLK, load_input;
	output input_ready;
	output reg load_success;
	output reg float32tofix_reg_en, float32_a_reg_en, fixed_reg_en, output_ready;
	output [2:0] d_state;
	reg [2:0] state;
	assign d_state = state;
	/*---------------load_success ------------------*/
	always @ (posedge CLK) begin
		if( load_input && (state == state_convert ||state == state_LUT_1 || state == state_LUT_2 || state == state_cal_a || state == state_rst) && !rst)
			load_success <= 1;
		else if(state == state_convert)
			load_success <= 0;
	end
	assign input_ready = (state == state_convert) ? 1'b1 : !load_success;
	/*input*/
	always @ (posedge CLK) begin
		if(rst) 
			state <= state_rst;
		else if(state == state_rst && load_success && start)
			state <= state_convert;
		else if(state == state_convert)
			state <= state_LUT_1;
		else if(state == state_LUT_1)
			state <= state_LUT_2;
		else if(state == state_LUT_2)
			state <= state_cal_a;
		else if(state == state_cal_a && load_success)
			state <= state_convert;
		else 
			state <= state_rst;
	end
	/*output*/
	always @* begin
		float32tofix_reg_en = 0;
		float32_a_reg_en = 0; 
		fixed_reg_en = 0;
		output_ready = 0;
		case(state)
			state_convert : begin 
								 float32tofix_reg_en = 1;
								 end
			state_LUT_1   : begin
								 float32_a_reg_en = 1;
								 end
			state_LUT_2   : begin
								 fixed_reg_en = 1;
								 end
			state_cal_a   : begin
								 output_ready = 1;
								 end
			default: begin
								  output_ready = 0;
						end
		endcase
	end
endmodule