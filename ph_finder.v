/* Packet Header Finder
 * @description: this module searches for the packet header in a stream of data
 * @param rxbyteclkhs the byte clock to synchrnize to (input)
 * @param reset an active-high reset signal (input)
 * @param word_in 16-bit word (input)
 * @param in_valid defines if word_in is valid (input)
 * @param out 32-bit output containing either  the packet header or forwarded data stream (output)
 * @param out_valid defines if out is valid (output)
 * @param ph_select defines whether 'out' contains the PH or not
 */
 
module ph_finder(rxbyteclkhs, reset, word_in, in_valid, out, out_valid, ph_select);
	
	input rxbyteclkhs, reset, in_valid;
	input [15:0] word_in;
	output [31:0] out;
	output out_valid, ph_select;

	parameter STATE_INIT		= 2'b00;
	parameter STATE_HALF_PH		= 2'b01;
	parameter STATE_FULL_PH		= 2'b10;
	parameter STATE_BYPASS		= 2'b11;

	wire [7:0] byte1, byte2;
	reg [1:0] state;
	reg [7:0] prev_byte1, prev_byte2;

	always @(posedge rxbyteclkhs) begin
		if(reset) begin
			state <= STATE_INIT;
			prev_byte1 <= 8'h00;
			prev_byte2 <= 8'h00;
		end
		else if(in_valid) begin
			case(state)
				STATE_INIT: begin prev_byte1 <= byte1; prev_byte2 <= byte2; state <= STATE_HALF_PH; end
				STATE_HALF_PH: state <= STATE_FULL_PH;
				STATE_FULL_PH: state <= STATE_BYPASS;
				STATE_BYPASS: state <= STATE_BYPASS;		
			endcase
		end
	end

	assign byte1 = word_in[7:0];
	assign byte2 = word_in[15:8];
	assign out = {byte2, byte1, prev_byte2, prev_byte1};
	assign out_valid = ((state == STATE_FULL_PH) || (state == STATE_BYPASS)) ? 1'b1 : 1'b0;
	assign ph_select = (state == STATE_FULL_PH) ? 1'b1 : 1'b0;

endmodule