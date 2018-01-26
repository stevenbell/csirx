/* Top-level module for CSI receiver which takes input from a Xilinx
 * MIPI D-PHY core and produces an AXI video stream.
 * Steven Bell <sebell@stanford.edu>
 * 15 December 2017
 */


module csirx # (
  // TODO: Test this with other numbers of lanes
  parameter integer N_DATA_LANES = 2
)
(
  // PPI input from Xilinx D-PHY core
  input wire cl_stopstate,
  input wire dl0_rxactivehs, // Whether high-speed receive is in progress
  input wire dl1_rxactivehs,
  input wire dl0_rxsynchs, // Pulse at the beginning of high-speed transmission
  input wire dl1_rxsynchs,
  output wire cl_enable, // Clock enable
  output wire dl0_enable, // Data lane 0 enable
  output wire dl1_enable, // Data lane 1 enables
  output wire dl0_forcerxmode,
  output wire dl1_forcerxmode,
  input wire dl0_rxvalidhs, // Lane 0 valid
  input wire dl1_rxvalidhs, // Lane 1 valid
  input wire [7:0] dl0_rxdatahs, // Lane 0 data
  input wire [7:0] dl1_rxdatahs, // Lane 1 data

  // Byte clock (not part of PPI, but clocks it)
  input wire rxbyteclkhs,
  input wire rxbyteclkhs_resetn,

  // AXI-stream master output
  // Uses the clock and reset from rxbyteclkhs
  output wire  m_axis_tvalid,
  //output wire [(N_DATA_LANES*8)-1 : 0] m_axis_tdata,
  output wire [63 : 0] m_axis_tdata,
  //output wire [N_DATA_LANES-1 : 0] m_axis_tstrb,
  output wire [7 : 0] m_axis_tstrb,
  output wire  m_axis_tlast,
  input wire  m_axis_tready
);

  wire reset;
  wire[(N_DATA_LANES*8)-1:0] aligned_word_out;
  wire aligned_word_valid;

  wire frame_active; // Whether we're in the process of receiving a frame
  wire frame_valid; // Whether the output frame data is actually valid
  wire [(N_DATA_LANES*8)-1 : 0] frame_out;

  wire [63:0] unpacked_out;
  wire unpacked_out_valid;

  assign reset = ~rxbyteclkhs_resetn; // Make an active-high reset

  wordalign align(
    .clk(rxbyteclkhs),
    .resetn(rxbyteclkhs_resetn),
    .dl0_rxvalidhs(dl0_rxvalidhs),
    .dl1_rxvalidhs(dl1_rxvalidhs),
    .dl0_rxdatahs(dl0_rxdatahs),
    .dl1_rxdatahs(dl1_rxdatahs),
    .word_out(aligned_word_out),
    .word_valid(aligned_word_valid));

  pckthandler depacket(
    .rxbyteclkhs(rxbyteclkhs),
    .reset(reset),
    .in_stream_valid(aligned_word_valid),
    .in_stream(aligned_word_out),
    .frame_active(frame_active),
    .frame_valid(frame_valid),
    .out_stream(frame_out));

  raw10_decoder unpack(
    .rxbyteclkhs(rxbyteclkhs),
    .reset(reset),
    .frame_active(frame_active),
    .frame_valid(frame_valid),
    .data_in(frame_out),
    .out_valid(unpacked_out_valid),
    .data_out(unpacked_out));

    assign m_axis_tdata = unpacked_out;
    assign m_axis_tvalid = unpacked_out_valid;
    assign m_axis_tstrb = 8'b1;
    assign m_axis_tlast = 1'b0;

    // Always enable the D-PHY
    assign cl_enable = 1'b1;
    assign dl0_enable = 1'b1;
    assign dl1_enable = 1'b1;

    // And don't force it into reset
    assign dl0_forcerxmode = 1'b0;
    assign dl1_forcerxmode = 1'b0;

endmodule

