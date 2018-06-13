
IVERILOG := iverilog -g2005
BUILDDIR := build

.PHONY: all clean

all: ecc_block pckthandler pckthandler_fsm ph_finder raw10_decoder


pckthandler2 : unit_tests/pckthandler_tb2.v
	$(IVERILOG) *.v unit_tests/pckthandler_tb2.v -o $(BUILDDIR)/$@
	cd unit_tests; vvp ../$(BUILDDIR)/$@

# All the unit tests
# Run them from the unit_tests dir since they depend on files
% : %.v
	$(IVERILOG) *.v unit_tests/$*_tb.v -o $(BUILDDIR)/$@
	cd unit_tests; vvp ../$(BUILDDIR)/$@

clean:
	rm -rf build/*


