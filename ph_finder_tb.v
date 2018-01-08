module ph_finder_tb;
	reg reset = 0, in_valid = 0, clk = 0;
	reg [7:0] byte1, byte2;

	wire[31:0] out;
	wire out_valid, ph_select;

	ph_finder pf(.rxbyteclkhs(clk), .reset(reset), .byte1(byte1), .byte2(byte2),
				.in_valid(in_valid), .out(out), .out_valid(out_valid), .ph_select(ph_select));

	always #1 clk = !clk;

	initial begin
		#0	reset = 0; in_valid = 1; byte1 = 8'h01; byte2=8'h02;
		#1	reset = 1;
		#2	reset = 0; byte1 = 8'h46; byte2= 'h47;	
		#2	byte1 = 8'h56; byte2 = 'h57;
		#2	byte1 = 8'h88; byte2 = 'h34;
		#2	byte1 = 8'h91; byte2 = 'hE2;
		#4	in_valid = 0;
		#4 	in_valid = 1;
		#2  reset = 1;
		#2  reset = 0; byte1 = 8'h46; byte2= 'h47;
		#2	byte1 = 8'h56; byte2 = 'h57;
		#2	byte1 = 8'h88; byte2 = 'h34;
		#2	byte1 = 8'h91; byte2 = 'hE2;
		#4	in_valid = 0;
		#1	$stop;
	end

	initial
		$monitor("time = %t, out = %h, out_valid = %b, ph_select = %b",
				$time, out, out_valid, ph_select);
endmodule