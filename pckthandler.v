/* Packet Handler: implements the csi protocol and part of the application-layer protocol
 * Gedeon Nyengele <nyengele@stanford.edu>
 * 08 January 2018
 */


/*
 * @param rxbyteclkhs byte clock to synchronize to (input)
 * @param reset active-high synchronous reset signal (input)
 * @param in_stream byte-and-lane-aligned input stream (input)
 * @param in_stream_valid determines whether the input stream is valid (input)
 * @param out_stream csi payload stream (output)
 * @param frame_active determines whether new frame either about to transmitted or in progress (output)
 * @param frame_valid determines whether a frame output is in progress (output)
 */
module pckhandler(rxbyteclkhs, reset, in_stream, in_stream_valid, out_stream, frame_active, frame_valid);
	
	/* parameters */
	parameter IN_STREAM_WIDTH		= 16;
	parameter OUT_STREAM_WIDTH		= IN_STREAM_WIDTH;

	/* inputs */
	input rxbyteclkhs, reset, in_stream_valid;
	input [(IN_STREAM_WIDTH-1):0] in_stream;

	/* outputs */
	output frame_active, frame_valid;
	output [(OUT_STREAM_WIDTH-1):0] out_stream;

	/* internal decl */
	wire [31:0] ph_finder_out;
	wire ph_finder_ph_select;
	wire ph_finder_valid, ecc_error;
	wire [23:0] ecc_ph;
	wire ph_finder_reset;

	assign ph_finder_reset = reset | (~in_stream_valid);

	// Packet Finder
	ph_finder phf(
		.rxbyteclkhs(rxbyteclkhs),
		.reset(ph_finder_reset),
		.word_in({in_stream[7:0], in_stream[15:8]}),
		.in_valid(in_stream_valid),
		.out(ph_finder_out),
		.out_valid(ph_finder_valid),
		.ph_select(ph_finder_ph_select)
	);

	// ECC block
	ecc_block eccb(.PH_in(ph_finder_out), .PH_out(ecc_ph), .error(ecc_error));

	// Packet Handler FSM
	pckthandler_fsm fsm(
		.rxbyteclkhs(rxbyteclkhs),
		.reset(reset),
		.data_stream(ph_finder_out[31:16]),
		.ph_stream(ecc_ph),
		.ph_select(ph_finder_ph_select),
		.valid_stream(ph_finder_valid),
		.ecc_error(ecc_error),
		.out_stream({out_stream[7:0], out_stream[15:8]}),
		.frame_active(frame_active),
		.frame_valid(frame_valid)
	);
endmodule