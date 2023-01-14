YOSYS?=yosys
ARACHNE_PNR?=arachne-pnr
ICEPACK?=icepack
ICEPROG?=iceprog

.SECONDARY:

.PHONY: image
image: out/main.bin
.PHONY: program
program: out/main.bin
	$(ICEPROG) $<

out:
	mkdir -p out

out/%.blif: %.v | out
	$(YOSYS) -q -p "synth_ice40 -blif $@" $^

out/%.txt: out/%.blif icestick.pcf | out
	$(ARACHNE_PNR) -p icestick.pcf $< -o $@

out/%.bin: out/%.txt
	$(ICEPACK) $^ $@

.PHONY: clean
clean:
	rm -rf out
