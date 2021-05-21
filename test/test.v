`timescale 1ns/1ps
module test();
	parameter number_of_test = 500000;
	parameter start_addr = 0;
	reg CLK;
	reg rst;
	reg en;
	reg load;
	reg [31:0] FLOAT32_IN;
	reg [31:0] result;
	reg [63:0] test_case [0:500000];
	wire [31:0] FLOAT32_OUT;
	reg [31:0] FLOAT32_OUT_REF;
	reg [31:0] TMP_FLOAT32_OUT_REF;
	reg [31:0] TMP_FLOAT32_IN;
	reg [31:0] compare;
	wire input_ready;
	wire output_ready;
	wire load_success;
	/*----------------------var-------------------------*/
	integer addr_load;
	integer output_count;
	/*--------------------------------------------------*/
	initial begin
		rst = 1;
		CLK = 0;
		en = 1;
		addr_load = 0;
		output_count = 0;
		$readmemb ("test_case.txt", test_case);
		result = $fopen("result.txt");
	end
	/*----------------------INST------------------------*/	
	top my_top(
		.CLK(CLK),
		.start(en),						/*EN*/
		.rst(rst),						/*reset*/
		.load(load), 					/*input data load*/
		.input_ready(input_ready),		/*input load available*/
		.output_ready(output_ready),	/*output readly*/
		.FLOAT32_IN(FLOAT32_IN), 		/*IEEE x input*/
		.FLOAT32_OUT(FLOAT32_OUT), 		/*IEEE e^x output*/	
		.load_success(load_success)
	);
	/*------------------CLK gen-------------------------*/
	always begin //12ns
		#6 CLK = 1;
		#6 CLK = 0;
	end
	/*--------------------rst---------------------------*/
	always @ (posedge CLK) begin
		#5 rst = 0;
	end
	/*------------------input load----------------------*/
	always @ (input_ready) begin
		if(input_ready == 1) begin
			load = 1;
			{FLOAT32_IN, FLOAT32_OUT_REF} = test_case[addr_load + start_addr];
		end
		else
			load = 0;
	end
	/*--------------------address load update-----------*/
	always @ (negedge load) begin
		if(!rst)
			addr_load <= addr_load + 1;
	end
	/*-----------------------stop-----------------------*/
	always @ (posedge output_ready) begin
		output_count <= output_count + 1;
		if(output_count == number_of_test - 1) begin
			#10;
			$finish;
		end
	end
	/*--------------------result process----------------*/
	always @ (output_ready) begin
		if(output_ready) begin
			{TMP_FLOAT32_IN, TMP_FLOAT32_OUT_REF} = test_case[addr_load + start_addr - 6];
			#5;
			compare = TMP_FLOAT32_OUT_REF ^ FLOAT32_OUT;
			if(compare[31-:20] == 20'd0)
				$fdisplay(result, "x = %b", TMP_FLOAT32_IN, " result = %b", FLOAT32_OUT, " expect = %b", TMP_FLOAT32_OUT_REF, " ==> PASS");
			else
				$fdisplay(result, "x = %b", TMP_FLOAT32_IN, " result = %b", FLOAT32_OUT, " expect = %b", TMP_FLOAT32_OUT_REF, " ==> FAIL");
			end	
	end

endmodule
