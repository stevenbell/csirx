module ecc_block_tb;
	
	parameter PH_SIZE	= 32;
	parameter ECC_SIZE	= 8;
	parameter DATA_SIZE	= PH_SIZE - ECC_SIZE;

	parameter PH 	= 32'h09000110;	

	reg [(PH_SIZE-1):0] PH_in;
	wire [(DATA_SIZE-1):0] PH_out;
	wire no_error, corrected_error, error;

	ecc_block eb(.PH_in(PH_in), .PH_out(PH_out), .no_error(no_error), .error(error), .corrected_error(corrected_error));

	initial begin
		#0	PH_in = PH; // no errors

		#1 	PH_in = PH ^ (1 << 0); 	// error in bit0
		#1 	PH_in = PH ^ (1 << 1); 	// error in bit1
		#1 	PH_in = PH ^ (1 << 2); 	// error in bit2
		#1 	PH_in = PH ^ (1 << 3); 	// error in bit3
		#1 	PH_in = PH ^ (1 << 16); // error in bit16
		#1 	PH_in = PH ^ (1 << 17); // error in bit17
		#1 	PH_in = PH ^ (1 << 18); // error in bit18
		#1 	PH_in = PH ^ (1 << 19); // error in bit19
		#1 	PH_in = PH ^ (1 << 20);	// error in bit20
		#1 	PH_in = PH ^ (1 << 21); // error in bit21
		#1 	PH_in = PH ^ (1 << 22); // error in bit22
		#1 	PH_in = PH ^ (1 << 23); // error in bit23

		#1 	PH_in = PH ^ (1 << 0) ^ (1 << 16); // errors (bit0 and 16)
		#1	PH_in = PH ^ (1 << 1) ^ (1 << 21); // errors (bit1 and 21)
		
		#1	$finish;
	end

	initial
		$monitor("PH_in = %h, PH_out = %h, no_error = %b, error = %b, corrected_error = %b",
				PH_in, PH_out, no_error, error, corrected_error);

endmodule