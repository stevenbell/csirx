OUTPUT	?= testbench
ROOT 	= ../
FLAGS 	= -g2005 -y $(ROOT)

pckthandler: pckthandler_tb.v
	iverilog $(FLAGS) $^ -o $(OUTPUT)

pckthandler_fsm: pckthandler_fsm_tb.v
	iverilog $(FLAGS) $^ -o $(OUTPUT)

ph_finder: ph_finder_tb.v
	iverilog $(FLAGS) $^ -o $(OUTPUT)

ecc_block: ecc_block_tb.v
	iverilog $(FLAGS) $^ -o $(OUTPUT)

raw10_decoder: raw10_decoder_tb.v
	iverilog $(FLAGS) $^ -o $(OUTPUT)

.PHONY: run, clean
run: $(OUTPUT)
	vvp $(OUTPUT)
clean:
	rm -rf $(OUTPUT)