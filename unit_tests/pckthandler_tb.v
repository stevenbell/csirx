module pckthandler_tb;
	reg clk, reset, din_valid;
	reg [15:0] din;
	wire dout_valid, fr_active, fr_valid;
	wire [15:0] dout;

	reg [15:0] dout_exp;
	reg fr_valid_exp, fr_active_exp;
	integer fd, status;
	reg [128*8-1:0] string;

	pckthandler DUT(clk, reset, din, din_valid, dout, fr_active, fr_valid);

	// clock & reset
	initial begin
		clk = 0; reset = 1;
		repeat(4) #10 clk = ~clk;
		reset = 0;
		forever #10 clk = ~clk;
	end

	// files
	initial begin
		fd = $fopen("pckthandler_testvec.txt", "r");
	end

	// data provider
	initial begin
		din = 0; din_valid = 0;
		@(negedge reset);
		while(!$feof(fd)) begin
			status = $fgets(string, fd);
			if($sscanf(string, "%h, %h, %h, %h, %h\n", din, din_valid, dout_exp, fr_active_exp, fr_valid_exp) == 5) begin
				@(posedge clk);
				#1 $display("din=%h, din_valid=%h, dout=%h, dout_exp=%h, fr_active=%h, fr_active_exp=%h, fr_valid=%h, fr_valid_exp=%h",
					din, din_valid, dout, dout_exp, fr_active, fr_active_exp, fr_valid, fr_valid_exp);
			end			
		end
		repeat(25) @(posedge clk);
		$fclose(fd);
		$finish;
	end
endmodule