`timescale 1ns/1ps
module test();
	parameter number_of_test = 100;
	
	reg CLK;
	reg rst;
	reg load;
	reg [31:0] FLOAT32_IN;
	reg [63:0] test_case [0:number_of_test - 1];
	wire [31:0] FLOAT32_OUT;
	reg [31:0] FLOAT32_OUT_REF;
	wire input_ready;
	wire output_ready;
	
	/*var*/
	integer start_up;
	integer count;
	integer pre_run;
	/*----------------------------------*/
	initial begin
		CLK = 0;
		start_up = 1; /*first start*/
		pre_run  = 1;
		count = 0;
		$readmemb ("test_case.dat", test_case);
	end
	/*----------------------------------*/
	always @ (count) begin
		if(count == number_of_test - 1)
			$finish;
		end
	always @ (input_ready) begin
		if(input_ready && pre_run == 1) begin
			{FLOAT32_IN, FLOAT32_OUT_REF} = test_case[count];
			load = 1;
			pre_run = 0;
			end
		else if(!input_ready) begin
			pre_run = 1;
			load = 0;
			count = count + 1;
			end
		end
	always @ (CLK) begin
		if(start_up == 1) begin
			rst = 1;
			start_up = 0;
			end
		else
			rst = 0;
		#50 CLK = !CLK;
		end
	/*----------------------------------*/	
	top my_top(
		.CLK(CLK),
		.start(1'b1),						/*EN*/
		.rst(rst),							/*reset*/
		.load(load), 						/*input data load*/
		.input_ready(input_ready),		/*input load available*/
		.output_ready(output_ready),	/*output readly*/
		.FLOAT32_IN(FLOAT32_IN), 		/*IEEE x input*/
		.FLOAT32_OUT(FLOAT32_OUT) 		/*IEEE e^x output*/	
	);
endmodule
