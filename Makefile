
all:
	iverilog -g2005-sv csirx_tb.v csirx.v csirx_wordalign.v -o csirx_tb
	vvp csirx_tb


