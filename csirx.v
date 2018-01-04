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
  output wire [(N_DATA_LANES*8)-1 : 0] m_axis_tdata,
  output wire [N_DATA_LANES-1 : 0] m_axis_tstrb,
  output wire  m_axis_tlast,
  input wire  m_axis_tready
);

  wire[(N_DATA_LANES*8)-1:0] word_out;
  wire word_valid;

  csirx_wordalign align(
    .clk(rxbyteclkhs),
    .resetn(rxbyteclkhs_resetn),
    .dl0_rxvalidhs(dl0_rxvalidhs),
    .dl1_rxvalidhs(dl1_rxvalidhs),
    .dl0_rxdatahs(dl0_rxdatahs),
    .dl1_rxdatahs(dl1_rxdatahs),
    .word_out(word_out),
    .word_valid(word_valid));

    assign m_axis_tdata = word_out;
    assign m_axis_tvalid = word_valid;
    assign m_axis_tstrb = 2'b1;
    assign m_axis_tlast = 1'b0;

    // Always enable the D-PHY
    assign cl_enable = 1'b1;
    assign dl0_enable = 1'b1;
    assign dl1_enable = 1'b1;

    // And don't force it into reset
    assign dl0_forcerxmode = 1'b0;
    assign dl1_forcerxmode = 1'b0;

endmodule

