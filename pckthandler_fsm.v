/* Packet Handler FSM
 * @ description: this module represents the core logic of the packet handler FSM
 * @param rxbyteclkhs the byte clock to synchronize to (input)
 * @param reset an acitve-high synchronous reset signal (input)
 * @param data_stream csi payload stream
 * @param ph_stream packet header data
 * @param ph_select defines whether to select the ph_stream or not
 * @param valid_stream determines if either stream is valid
 * @param ecc_error determines if the PH has an error
 * @param out_stream csi payload stream to next module
 * @param frame_active determines if we're either about to/in the middle TX'ing a frame
 * @param frame_valid signals that a frame output is in progress
 */

module pckthandler_fsm(rxbyteclkhs, reset, data_stream, ph_stream, ph_select, valid_stream, ecc_error,
	out_stream, frame_active, frame_valid
);
	
	/* parameters */
	parameter DATA_STREAM_WIDTH		= 16;
	parameter PH_STREAM_WIDTH		= 24;

	/* inputs */
	input rxbyteclkhs, reset, ph_select, valid_stream, ecc_error;
	input [(DATA_STREAM_WIDTH-1):0] data_stream;
	input [(PH_STREAM_WIDTH-1):0] ph_stream;

	/* outputs */	
	output frame_active, frame_valid;	
	output [(DATA_STREAM_WIDTH-1):0] out_stream;

	/* internal decl */
	// To Do:

endmodule