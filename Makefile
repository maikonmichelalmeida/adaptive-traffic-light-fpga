IVERILOG ?= iverilog
VVP      ?= vvp
BUILD    ?= build/iverilog

.PHONY: test clean

test:
	mkdir -p $(BUILD)
	$(IVERILOG) -g2012 -Wall -s tb_adaptive_traffic_controller \
		-o $(BUILD)/controller.vvp \
		rtl/adaptive_traffic_controller.sv \
		tb/tb_adaptive_traffic_controller.sv
	cd $(BUILD) && $(VVP) controller.vvp

clean:
	rm -rf build
