/* Packet Handler FSM: this module represents the core logic of the packet handler FSM
 * Gedeon Nyengele <nyengele@stanford.edu>
 * 08 January 2018
 */

/* 
 * @param rxbyteclkhs the byte clock to synchronize to (input)
 * @param reset an acitve-high synchronous reset signal (input)
 * @param data_stream csi payload stream
 * @param ph_stream packet header data (WC_MSB, WC_LSB, DATA_ID)
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

	parameter PH_DECODE	= 2'b00;
	parameter WAIT_EOT	= 2'b01;
	parameter REC_DATA	= 2'b10;

	/* inputs */
	input rxbyteclkhs, reset, ph_select, valid_stream, ecc_error;
	input [(DATA_STREAM_WIDTH-1):0] data_stream;
	input [(PH_STREAM_WIDTH-1):0] ph_stream;

	/* outputs */	
	output frame_active, frame_valid;	
	output [(DATA_STREAM_WIDTH-1):0] out_stream;

	/* internal decl */
	reg [2:0] state;
	reg fr_active, fr_valid;
	reg [15:0] fr_byte_count;
	reg [15:0] fr_data_size;

	wire sof_id, eof_id, pxdata_id;
	wire data_id_fied = ph_stream[5:0];
	assign sof_id = (data_id_field == 6'h00) ? 1'b1 : 1'b0;
	assign eof_id = (data_id_field == 6'h01) ? 1'b1 : 1'b0;
	assign pxdata_id = (data_id_field == 6'h2B) ? 1'b1 : 1'b0;  // 2B = RAW10
	
	always @(posedge rxbyteclkhs) begin
		if(reset) begin
			state 	<= PH_DECODE;
			fr_valid <= 0;
			fr_active <= 0;
		end
		else begin
			case(state)
				PH_DECODE: begin
							case({valid_stream, ph_select, ecc_error, sof_id, eof_id, pxdata_id})
								6'b111XXX: begin // ECC error in packet header
										   		state <= WAIT_EOT;
										   end
								6'b1101XX: begin // Start-of-Frame received
												state <= PH_DECODE;
												fr_active <= 1'b1;
										   end
								6'b11001X:	begin // End-of-Frame received
												state <= PH_DECODE;
												fr_active <= 1'b0;
											end
								6'b10XXX1: 	begin // Pixel data header received
												fr_byte_count <= 0;
												fr_data_size <= ph_stream[23:8];
												if (fr_active) begin
													fr_valid <= 1'b1;
													state <= REC_DATA;
												end
												else begin
													fr_valid <= 1'b0;
													state <= WAIT_EOT;
												end
											end
								6'b10XXX0: 	begin // other payload packet header received
												state <= WAIT_EOT;
											end

							endcase
						end
				WAIT_EOT: begin
							if (valid_stream) state <= WAIT_EOT;
							else begin
								state <= PH_DECODE;
							end
						end
				REC_DATA: begin
							if(fr_byte_count == fr_data_size) begin
								fr_valid <= 1'b0;
								state <= WAIT_EOT;
							end
							else begin
								fr_byte_count <= fr_byte_count + 2;
								state <= REC_DATA;
							end
						end
				default: begin
							fr_valid <= 0;
							fr_active <= 0;
						end
			endcase
		end
	end


	assign out_stream = data_stream;
	assign frame_active = fr_active;
	assign frame_valid = fr_valid;

endmodule