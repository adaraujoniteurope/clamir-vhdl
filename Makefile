# vhdl files
PACKAGES = packages/*.vhdl
TESTBENCHES = testbenches/*_tb.vhdl
SOURCES = sources/*.vhdl
OBJECTS = $(patsubst %.vhdl,%.o,$(SOURCES))
PACKAGE_OBJECTS = $(patsubst %.vhdl,%.o,$(PACKAGES))
TARGETS = $(patsubst %_tb.vhdl,%_tb,$(TESTBENCHES))

# testbench
TESTBENCH = mm_drift
TESTBENCHPATH = testbenches/${TESTBENCHFILE}*
TESTBENCHFILE = ${TESTBENCH}_tb
WORKDIR = work

#GHDL CONFIG
GHDL_CMD = ghdl
GHDL_FLAGS  = --std=08 -frelaxed -fexplicit --ieee=synopsys --warn-no-vital-generic --workdir=$(WORKDIR) -Wl,-lm

STOP_TIME = 100us
# Simulation break condition
#GHDL_SIM_OPT = --assert-level=error
GHDL_SIM_OPT = --stop-time=$(STOP_TIME)

# WAVEFORM_VIEWER = flatpak run io.github.gtkwave.GTKWave
WAVEFORM_VIEWER = gtkwave

.PHONY: clean

# all: $(TARGETS)

# %.o: %.vhdl
# 	@$(GHDL_CMD) -a $(GHDL_FLAGS) $<

# %_tb.o: %_tb.vhdl $(PACKAGE_OBJECTS) $(OBJECTS)
# 	@$(GHDL_CMD) -e $(GHDL_FLAGS) $<

# $(TARGETS): $(TESTBENCHES)

make:
ifeq ($(strip $(TESTBENCH)),)
	@echo "TESTBENCH not set. Use TESTBENCH=<value> to set it."
	@exit 1
endif

	@mkdir -p $(WORKDIR)
	@$(GHDL_CMD) -a $(GHDL_FLAGS) $(PACKAGES)
	@$(GHDL_CMD) -a $(GHDL_FLAGS) $(SOURCES)
	@$(GHDL_CMD) -a $(GHDL_FLAGS) $(TESTBENCHPATH)
	@$(GHDL_CMD) -e $(GHDL_FLAGS) $(TESTBENCHFILE)

run:
	@$(GHDL_CMD) -r $(GHDL_FLAGS) --workdir=$(WORKDIR) $(TESTBENCHFILE) --wave=$(TESTBENCHFILE).ghw $(GHDL_SIM_OPT)
	@mv $(TESTBENCHFILE).ghw $(WORKDIR)/

view:
	@$(WAVEFORM_VIEWER) --dump=$(WORKDIR)/$(TESTBENCHFILE).ghw

clean:
	@rm -rf $(WORKDIR)