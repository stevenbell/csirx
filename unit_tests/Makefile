OUTPUT	?= testbench
ROOT 	= ../
FLAGS 	= -g2005 -y $(ROOT)

ph_finder: ph_finder_tb.v
	iverilog $(FLAGS) $^ -o $(OUTPUT)

ecc_block: ecc_block_tb.v
	iverilog $(FLAGS) $^ -o $(OUTPUT)

.PHONY: run, clean
run: $(OUTPUT)
	vvp $(OUTPUT)
clean:
	rm -rf $(OUTPUT)