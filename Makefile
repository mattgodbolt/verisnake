YOSYS?=yosys
ARACHNE_PNR?=arachne-pnr
ICEPACK?=icepack
ICEPROG?=iceprog
IVERILOG?=iverilog
VVP?=vvp
GTKWAVE?=gtkwave
COCOTB_PREFIX:=$(shell cocotb-config --prefix)
COCOTB_LIBS=$(COCOTB_PREFIX)/cocotb/libs

export COCOTB_REDUCED_LOG_FMT=1
export PYTHONPATH:=test:$(PYTHONPATH)
export PATH:=$(OSS_CAD_SUITE)/py3bin:$(PATH)

INPUTS:=$(wildcard *.v)

.SECONDARY:

.PHONY: image
image: out/main.bin
.PHONY: program
program: out/main.bin
	$(ICEPROG) $<

out:
	mkdir -p out

out/main.blif: $(INPUTS) | out
	$(YOSYS) -q -p "synth_ice40 -top top_ice -blif $@" $^

out/%.txt: out/%.blif icestick.pcf | out
	$(ARACHNE_PNR) -p icestick.pcf $< -o $@

out/%.bin: out/%.txt
	$(ICEPACK) $^ $@

.PHONY: clean
clean:
	rm -rf out

.PHONY: format
format: $(VERIBLE_FORMAT)

out/%.vvp: $(INPUTS) | out
	$(IVERILOG) -Wall -o out/$*.vvp -s $* -g2012 $(INPUTS)

out/%.vcd: test/test_%.py $(INPUTS) | out
	echo "module dump (); initial begin \$$dumpfile(\"out/$*.vcd\"); \$$dumpvars(0, $*); #1; end endmodule" > out/dump_$*.v
	$(IVERILOG) -Wall -o out/$*_dump.vvp -s $* -s dump -g2012 out/dump_$*.v $(INPUTS)
	# NB deliberately using `test.*`  which breaks the pytest rewriting so that PYTHONOPTIMIZE works
	# https://docs.pytest.org/en/latest/how-to/assert.html#disabling-assert-rewriting m,aybe?
	env PYTHONOPTIMIZE=1 COCOTB_RESULTS_FILE=/dev/null MODULE=test.test_$* $(VVP) -M $(COCOTB_LIBS) -m libcocotbvpi_icarus out/$*_dump.vvp

out/%.test.xml: out/%.vvp test/test_%.py
	env MODULE=test_$* COCOTB_RESULTS_FILE=$@.tmp $(VVP) -M $(COCOTB_LIBS) -m libcocotbvpi_icarus $<
	@! grep failure $@.tmp
	@mv $@.tmp $@

show_%: out/%.vcd gtkwave/%.gtkw
	$(GTKWAVE) $^

.PHONY: test
test: out/vga.test.xml out/play_area.test.xml
