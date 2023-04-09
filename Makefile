# ============================================================
# KyroSoC Full Makefile (RTL + RISC-V SW + Simulation)
# Tool: Cadence Xcelium (irun)
# Arch: RV32IMC
# ============================================================
.ONESHELL:
SHELL := /bin/bash

#=============================================================
#coverage
#=============================================================
COV ?= 0
COV_DIR ?= ./cov_work
COV_TEST_NAME ?= $(SOC_TEST)_$(C_TEST)_$(SEED)

COV_OPTS :=

ifeq ($(COV),1)
COV_OPTS := -coverage all -covdut pinaka -covworkdir $(COV_DIR) -covtest $(COV_TEST_NAME)
endif
# =========================================================
# PHONY
# =========================================================
.PHONY: all gen build spike  rtl compare clean dirs

# =========================================================
# RANDOM SEED + MODE
# =========================================================
SEED := $(or $(SEED),$(shell od -An -N2 -tu2 < /dev/urandom | tr -d ' '))
MODE ?= soc
IMEM_WIDTH ?= 14
DMEM_WIDTH ?= 10
PREFIX = $(MODE)_$(SEED)

# =========================================================
# ROOT 
# =========================================================
ROOT     = $(PWD)/..
RISCV_DV = $(ROOT)/third_party/riscv-dv
SW_DIR   = $(ROOT)/sw
RTL_DIR  = $(ROOT)/rtl
SIM_DIR  = $(ROOT)/sim
RESULT_DIR = $(SIM_DIR)/results
SCRIPT_DIR = $(SIM_DIR)/scripts

USER_EXT = $(RISCV_DV)/user_extension

RTL_SRC = $(ROOT)/rtl/ip

LOG_DIR = $(RESULT_DIR)/logs/$(PREFIX)

CFG_DIR    = $(SIM_DIR)/cfg

# =========================================================
# FILES
# =========================================================
ASM_FILE = $(SW_DIR)/$(PREFIX).S
SEED_DIR = $(RESULT_DIR)/$(PREFIX)

ELF = $(SEED_DIR)/$(PREFIX).elf
BIN = $(SEED_DIR)/$(PREFIX).bin

UVM_LOG   = $(LOG_DIR)/$(PREFIX)_uvm.log
SPIKE_LOG = $(LOG_DIR)/$(PREFIX)_spike.log
RTL_LOG   = $(LOG_DIR)/rtl_trace.log
CMP_LOG   = $(LOG_DIR)/$(PREFIX)_compare.log

RTL_FILELIST = $(CFG_DIR)/$(MODE)_rtl.f
TB_FILELIST  = $(CFG_DIR)/$(MODE)_tb.f

JTAG_RTL_FLIST = $(CFG_DIR)/pinaka_rtl.f
JTAG_TB_FLIST  = $(CFG_DIR)/jtag_tb.f

COMPARE_SCRIPT = $(SCRIPT_DIR)/compare.py







COV_COMPILE_OPTS :=

ifeq ($(C_TEST),i2c_register_nack_test)
COV_COMPILE_OPTS += +define+WR_ACK_ER
endif

ifeq ($(C_TEST),i2c_slave_nack_test)
COV_COMPILE_OPTS += +define+SLV_AD_ER
endif















# =========================================================
# PINAKA 
# =========================================================

#SANITY_DIR    = $(ROOT)/sanity_test
PINAKA_SIM    = $(ROOT)/sim
#
#PINAKA_ASM    = $(SANITY_DIR)/sanity_test.S
#PINAKA_ELF    = $(SANITY_DIR)/sanity_test.elf
#PINAKA_BIN    = $(SANITY_DIR)/sanity_test.bin
#PINAKA_HEX    = $(SANITY_DIR)/instruction.hex
#PINAKA_PTE_HEX = $(SANITY_DIR)/pte.hex
#PINAKA_DATA_HEX = $(SANITY_DIR)/program_data.hex

#added by ganeshks
#-----------------------------------------------------
PINAKA_BIN_DIR	  = $(ROOT)/c_tests/bin
PINAKA_ASM    = $(PINAKA_BIN_DIR)/sanity_test.S
PINAKA_ELF    = $(PINAKA_BIN_DIR)/$(C_TEST).elf
PINAKA_DISASM    = $(PINAKA_BIN_DIR)/$(C_TEST).disasm
PINAKA_BIN    = $(PINAKA_BIN_DIR)/$(C_TEST).bin
PINAKA_MEM    = $(PINAKA_BIN_DIR)/$(C_TEST)_data.mem
PINAKA_DATA_HEX = $(PINAKA_BIN_DIR)/$(C_TEST)_data.hex
PINAKA_HEX    = $(PINAKA_BIN_DIR)/$(C_TEST)_instruction.hex
PINAKA_PTE_HEX = $(PINAKA_BIN_DIR)/pte.hex


SOC_TEST ?=soc_base_test
C_TEST ?=basic_mmio_test
CHECKER ?= none
GPIO ?=none
PTE_RESP_DELAY ?=0
INCLUDE_DIR = $(ROOT)/c_tests/include
TEST_DIR    = $(ROOT)/c_tests/tests
SRC = $(INCLUDE_DIR)/peripheral.c \
$(INCLUDE_DIR)/startup.S \
$(INCLUDE_DIR)/exception_handlers.c \
$(TEST_DIR)/$(C_TEST).c




# ============================================================
# DUAL CORE C TEST OUTPUTS
# ============================================================

CORE0_C_TEST ?= basic_mmio_test
CORE1_C_TEST ?= basic_mmio_test

CORE0_ELF = $(PINAKA_BIN_DIR)/$(CORE0_C_TEST)_core0.elf
CORE0_BIN = $(PINAKA_BIN_DIR)/$(CORE0_C_TEST)_core0.bin
CORE0_HEX = $(PINAKA_BIN_DIR)/$(CORE0_C_TEST)_core0.hex
CORE0_DISASM = $(PINAKA_BIN_DIR)/$(CORE0_C_TEST)_core0.disasm
CORE1_ELF = $(PINAKA_BIN_DIR)/$(CORE1_C_TEST)_core1.elf
CORE1_BIN = $(PINAKA_BIN_DIR)/$(CORE1_C_TEST)_core1.bin
CORE1_HEX = $(PINAKA_BIN_DIR)/$(CORE1_C_TEST)_core1.hex
CORE1_DISASM = $(PINAKA_BIN_DIR)/$(CORE1_C_TEST)_core1.disasm

DUAL_CORE0_LINKER = $(SCRIPT_DIR)/soc_linker_core0.ld
DUAL_CORE1_LINKER = $(SCRIPT_DIR)/soc_linker_core1.ld


PINAKA_PTE1_HEX = $(PINAKA_BIN_DIR)/pte_1.hex








#======================================================================
# CHECKER CONFIGURATION
#======================================================================

CHECKER_CORE0 ?=
CHECKER_CORE1 ?=
CHECKER_SHARED ?=

CHECKER_FILES =
CHECKER_DEFINES =

empty :=
space := $(empty) $(empty)


CORE0_TAG := $(subst $(space),_,$(strip $(CHECKER_CORE0)))
CORE1_TAG := $(subst $(space),_,$(strip $(CHECKER_CORE1)))
SHARED_TAG := $(subst $(space),_,$(strip $(CHECKER_SHARED)))
CHECKER_TAG = core0_$(CORE0_TAG)_core1_$(CORE1_TAG)_shared_$(SHARED_TAG)
##======================================================================
# CORE0 MMU
#======================================================================

ifneq ($(filter mmu,$(CHECKER_CORE0)),)

    CHECKER_FILES += ../dv/tb/mmu_checker/mmu_checker.sv
    CHECKER_FILES += ../dv/tb/mmu_checker/mmu_binds.sv

    CHECKER_DEFINES += +define+MMU_CHECKER_CORE0

endif


#======================================================================
# CORE1 MMU
#======================================================================

ifneq ($(filter mmu,$(CHECKER_CORE1)),)

    ifeq ($(filter ../dv/tb/mmu_checker/mmu_checker.sv,$(CHECKER_FILES)),)
        CHECKER_FILES += ../dv/tb/mmu_checker/mmu_checker.sv
    endif

    ifeq ($(filter ../dv/tb/mmu_checker/mmu_binds.sv,$(CHECKER_FILES)),)
        CHECKER_FILES += ../dv/tb/mmu_checker/mmu_binds.sv
    endif

    CHECKER_DEFINES += +define+MMU_CHECKER_CORE1

endif


#======================================================================
# CORE0 TRACE IP
#======================================================================

ifneq ($(filter traceip,$(CHECKER_CORE0)),)

    CHECKER_FILES += ../dv/tb/traceIP_checker/traceIP_checker.sv
    CHECKER_FILES += ../dv/tb/traceIP_checker/traceIP_binds.sv

    CHECKER_DEFINES += +define+TRACEIP_CHECKER_CORE0

endif


#======================================================================
# CORE1 TRACE IP
#======================================================================

ifneq ($(filter traceip,$(CHECKER_CORE1)),)

    ifeq ($(filter ../dv/tb/traceIP_checker/traceIP_checker.sv,$(CHECKER_FILES)),)
        CHECKER_FILES += ../dv/tb/traceIP_checker/traceIP_checker.sv
    endif

    ifeq ($(filter ../dv/tb/traceIP_checker/traceIP_binds.sv,$(CHECKER_FILES)),)
        CHECKER_FILES += ../dv/tb/traceIP_checker/traceIP_binds.sv
    endif

    CHECKER_DEFINES += +define+TRACEIP_CHECKER_CORE1

endif


#======================================================================
# CORE0 SPI
#======================================================================

ifneq ($(filter spi,$(CHECKER_CORE0)),)

    CHECKER_FILES += ../dv/tb/spi_checker/spi_monitor_checker.sv
    CHECKER_FILES += ../dv/tb/spi_checker/spi_bind.sv

    CHECKER_DEFINES += +define+SPI_CHECKER_CORE0

endif


#======================================================================
# CORE1 SPI
#======================================================================

ifneq ($(filter spi,$(CHECKER_CORE1)),)

    ifeq ($(filter ../dv/tb/spi_checker/spi_monitor_checker.sv,$(CHECKER_FILES)),)
        CHECKER_FILES += ../dv/tb/spi_checker/spi_monitor_checker.sv
    endif

    ifeq ($(filter ../dv/tb/spi_checker/spi_bind.sv,$(CHECKER_FILES)),)
        CHECKER_FILES += ../dv/tb/spi_checker/spi_bind.sv
    endif

    CHECKER_DEFINES += +define+SPI_CHECKER_CORE1

endif


#======================================================================
# CORE0 MEMORY MAP
#======================================================================

ifneq ($(filter memap,$(CHECKER_CORE0)),)

    CHECKER_FILES += ../dv/tb/mem_checker/memory_map_monitor_checker.sv
    CHECKER_FILES += ../dv/tb/mem_checker/memory_map_binds.sv

    CHECKER_DEFINES += +define+MEMAP_CHECKER_CORE0

endif


#======================================================================
# CORE1 MEMORY MAP
#======================================================================

ifneq ($(filter memap,$(CHECKER_CORE1)),)

    ifeq ($(filter ../dv/tb/mem_checker/memory_map_monitor_checker.sv,$(CHECKER_FILES)),)
        CHECKER_FILES += ../dv/tb/mem_checker/memory_map_monitor_checker.sv
    endif

    ifeq ($(filter ../dv/tb/mem_checker/memory_map_binds.sv,$(CHECKER_FILES)),)
        CHECKER_FILES += ../dv/tb/mem_checker/memory_map_binds.sv
    endif

    CHECKER_DEFINES += +define+MEMAP_CHECKER_CORE1

endif


#======================================================================
# CORE0 CLK_RST
#======================================================================

ifneq ($(filter clk_rst,$(CHECKER_CORE0)),)

    CHECKER_FILES += ../dv/tb/mem_checker/clk_rst_monitor_checker.sv
    CHECKER_FILES += ../dv/tb/mem_checker/clk_rst_binds.sv

    CHECKER_DEFINES += +define+CLK_RST_CHECKER_CORE0

endif


#======================================================================
# CORE1 CLK_RST
#======================================================================

ifneq ($(filter clk_rst,$(CHECKER_CORE1)),)

    ifeq ($(filter ../dv/tb/mem_checker/clk_rst_monitor_checker.sv,$(CHECKER_FILES)),)
        CHECKER_FILES += ../dv/tb/mem_checker/clk_rst_monitor_checker.sv
    endif

    ifeq ($(filter ../dv/tb/mem_checker/clk_rst_binds.sv,$(CHECKER_FILES)),)
        CHECKER_FILES += ../dv/tb/mem_checker/clk_rst_binds.sv
    endif

    CHECKER_DEFINES += +define+CLK_RST_CHECKER_CORE1

endif

#Enable required GPIO PIN

GPIO_INC_DIR = ../dv/tb/GPIO_INSTANCE
GPIO_OPTS    = +incdir+$(GPIO_INC_DIR)

ifeq ($(GPIO),gpio)
  GPIO_OPTS += +define+ENABLE_GPIO
endif


#------------------------------------------------------
LOG_DIR = $(RESULT_DIR)/logs/$(PREFIX)





# =========================================================
# ISA (FULL DEFAULT - IMPORTANT)
# =========================================================
ISA ?= RV32I,RV32M,RV32C,RV32F,RV32FC,RV32D,RV32DC,RV32A

# GCC ARCH (separate from ISA)
#ARCH = -march=rv32iac
ARCH = -march=rv32i

#ARCH = -march=rv32imafdc
ABI  = -mabi=ilp32

# =========================================================
# MODE FLAGS (CONTROL INSTR, NOT ISA)
# =========================================================

ifeq ($(MODE),basic)
GEN_MODE_FLAGS = \
+instr_cnt=2000 \
+directed_instr_0=riscv_load_store_rand_addr_instr_stream,20 \
+data_page_size=4096 \
+enable_unaligned_load_store=1 \
+no_branch_jump=0 \
+disable_compressed_instr=1 \
+disable_mul_div_instr=1 \
+disable_floating_point_instr=1 \
+enable_amo=0 \
+no_amo_instr=1 \
+no_compressed_instr=1 \
+no_csr_instr=1 \
+no_fence=1 \
+no_system_instr=1 \
+disable_instr=fence \
+disable_instr=fence_i \
+num_of_sub_program=0

else ifeq ($(MODE),atomic)
GEN_MODE_FLAGS = \
+isa=rv32a \
+instr_cnt=1 \
+bare_program_mode=1 \
+enable_amo=1 \
+disable_compressed_instr=1 \
+disable_mul_div_instr=1 \
+disable_floating_point_instr=1 \
+no_branch_jump=1 \
+no_csr_instr=1 \
+no_load_store=1 \
+cfg_disable_compressed_instr=1 \
+directed_instr_0=riscv_amo_instr_stream,200000 \
+directed_instr_1=riscv_lr_sc_instr_stream,200000 \
+no_fence=1 \
+num_of_sub_program=0


else ifeq ($(MODE),compressed)
GEN_MODE_FLAGS = \
+isa=rv32c \
+instr_cnt=1000 \
+bare_program_mode=1 \
+enable_compressed_instr=1 \
+disable_compressed_instr=0 \
+enable_amo=0 \
+disable_mul_div_instr=1 \
+disable_floating_point_instr=1 \
+no_branch_jump=0 \
+no_load_store=0 \
+no_csr_instr=1 \
+no_system_instr=1 \
+no_data_page=1 \
+no_stack=1 \
+num_of_sub_program=0 \
+force_compressed_instr=1


else ifeq ($(MODE),pinaka_ss)
GEN_MODE_FLAGS = \
+instr_cnt=5000 \
+num_of_sub_program=13 \
+disable_compressed_instr=1 \
+no_load_store_instr=0 \
+disable_instr_cg=1 \
+no_load_store=0 \
+disable_mul_div_instr=1 \
+disable_floating_point_instr=1 \
+enable_amo=0 \
+no_amo_instr=1 \
+enable_unaligned_load_store=0 \
+no_branch_jump=0 \
+enable_branch_jump=1 \
+no_csr_instr=0 \
+fix_sp=1 \
+no_fence=1 \
+boot_mode=m \
+directed_instr_0=riscv_int_numeric_corner_stream,8 \
+directed_instr_1=riscv_jal_instr,8 \
+directed_instr_2=riscv_load_store_rand_instr_stream,4 \
+directed_instr_3=riscv_loop_instr,8 \
+directed_instr_4=riscv_hazard_instr_stream,6 \
+directed_instr_5=riscv_load_store_hazard_instr_stream,4



endif

# =========================================================
# TOOLCHAIN
# =========================================================
RISCV_PREFIX  = /opt/riscv64im/bin/riscv64-unknown-elf
RISCV_GCC     = $(RISCV_PREFIX)-gcc
RISCV_OBJDUMP = $(RISCV_PREFIX)-objdump
RISCV_OBJCOPY = $(RISCV_PREFIX)-objcopy

CFLAGS = $(ARCH) $(ABI) -O0 -static -nostdlib

LINKER = $(SCRIPT_DIR)/linker.ld

SOC_LINKER = $(SCRIPT_DIR)/soc_linker.ld



# Atomic detection
DO_SPLIT = $(if $(filter atomic,$(MODE)),1,0)


HEX_FILE = $(SEED_DIR)/instruction_mem.hex


INSTR_B0 = $(SEED_DIR)/instruction_mem_B0.hex
INSTR_B1 = $(SEED_DIR)/instruction_mem_B1.hex
INSTR_B2 = $(SEED_DIR)/instruction_mem_B2.hex
INSTR_B3 = $(SEED_DIR)/instruction_mem_B3.hex

# =========================================================
# DEFAULT FLOW
# =========================================================
#all: dirs gen build HEX_GEN spike rtl compare

ifeq ($(MODE),pinaka)
all: pinaka_run

else ifeq ($(MODE),dual_core)
all: dual_core_run

else ifeq ($(MODE),jtag)
all: jtag_run

else ifeq ($(MODE),pinaka_ss)
all: dirs gen build HEX_GEN spike rtl compare
else
all: dirs gen build HEX_GEN spike rtl compare
endif

# =========================================================
# DIR SETUP
# =========================================================
dirs:
	mkdir -p $(SW_DIR)
	mkdir -p $(RESULT_DIR)
	mkdir -p $(LOG_DIR)

# =========================================================
# 1. GENERATION (riscv-dv)
# =========================================================
gen:
	@echo "========== GENERATION =========="
	@echo "MODE = $(MODE)"
	@echo "SEED = $(SEED)"
	@echo "ISA  = $(ISA)"

	mkdir -p $(SEED_DIR)

	
	cd $(RISCV_DV) && \
	xrun -64bit -sv -uvm \
	+svseed=random \
	+asm_file_name=$(PREFIX) \
	+march=$(ISA) \
	-uvmhome /tools/cadence_march2021/XCELIUM2009/tools/methodology/UVM/CDNS-1.2 \
	-f $(ROOT)/sim/cfg/files.f \
	-top riscv_instr_gen_tb_top \
	+UVM_TESTNAME=riscv_instr_base_test \
	+gen_only=1 \
	+bare_program_mode=1 \
	$(GEN_MODE_FLAGS) \
	+ntb_random_seed=random \
	-access +rwc \
	-l $(UVM_LOG)

	# Move ASM to sw/
	@if [ -f $(RISCV_DV)/$(PREFIX).S ]; then \
		mv $(RISCV_DV)/$(PREFIX).S $(SW_DIR)/; \
		echo "? ASM moved to sw/"; \
	else \
		echo "? ERROR: ASM not generated"; exit 1; \
	fi

# =========================================================
# 2. BUILD
# =========================================================
build:
	@echo "========== BUILD =========="

	@if [ ! -f $(ASM_FILE) ]; then \
		echo "ERROR: ASM missing"; exit 1; \
	fi

	mkdir -p $(SEED_DIR)

	$(RISCV_GCC) \
	$(ASM_FILE) \
	$(USER_EXT)/user_init.s \
	$(CFLAGS) \
	-I$(USER_EXT) \
	-T $(LINKER) \
	-o $(ELF)

	$(RISCV_OBJDUMP) -d $(ELF) > $(SEED_DIR)/$(PREFIX).objdump

	$(RISCV_OBJCOPY) -O binary $(ELF) $(BIN)
	
	$(RISCV_OBJCOPY) -O verilog $(ELF) $(SEED_DIR)/$(PREFIX).mem

	$(MAKE) HEX_GEN MODE=$(MODE)

	

# ============================================================
# HEX GENERATION (MODE BASED)
# ============================================================

HEX_GEN:
	echo "MODE = $(MODE)"

	$(RISCV_OBJCOPY) -O binary --only-section=.text $(ELF) $(SEED_DIR)/text.bin

	HEX_FILE=$(SEED_DIR)/instruction_mem.hex

	if [ "$(MODE)" = "basic" ]; then
	    echo "Basic Mode ? 32-bit HEX"
	    xxd -p -c 4 $(SEED_DIR)/text.bin | \
	    sed 's/\(..\)\(..\)\(..\)\(..\)/\4\3\2\1/' > $$HEX_FILE

		echo "Generating single 32-bit data memory hex..."
		cd $(SEED_DIR) && python $(SCRIPT_DIR)/mem_to_word_hex.py \
		$(SEED_DIR)/$(PREFIX).mem \
		$(SEED_DIR)/program_data.hex

	elif [ "$(MODE)" = "atomic" ]; then
	    echo "Atomic Mode ? 32-bit HEX + split"
	    xxd -p -c 4 $(SEED_DIR)/text.bin | \
	    sed 's/\(..\)\(..\)\(..\)\(..\)/\4\3\2\1/' > $$HEX_FILE
	    cd $(SEED_DIR)
		echo "Running split script..."
		cd $(SEED_DIR) && python $(SCRIPT_DIR)/split_hex.py instruction_mem.hex

		echo "Generating single 32-bit data memory hex..."
		cd $(SEED_DIR) && python $(SCRIPT_DIR)/mem_to_word_hex.py \
		$(SEED_DIR)/$(PREFIX).mem \
		$(SEED_DIR)/program_data.hex

	elif [ "$(MODE)" = "compressed" ]; then
	    echo "Compressed Mode ? BYTE HEX"
	    hexdump -v -e '1/1 "%02x\n"' $(SEED_DIR)/text.bin > $$HEX_FILE

	elif [ "$(MODE)" = "pinaka_ss" ]; then
		xxd -p -c 4 $(SEED_DIR)/text.bin | \
	    sed 's/\(..\)\(..\)\(..\)\(..\)/\4\3\2\1/' > $$HEX_FILE

		echo "Generating single 32-bit data memory hex..."
		cd $(SEED_DIR) && python $(SCRIPT_DIR)/mem_to_word_hex.py \
		$(SEED_DIR)/$(PREFIX).mem \
		$(SEED_DIR)/program_data.hex


	else
	    echo "Default Mode ? BYTE HEX"
		xxd -p -c 4 $(SEED_DIR)/text.bin | \
	    sed 's/\(..\)\(..\)\(..\)\(..\)/\4\3\2\1/' > $$HEX_FILE
	fi

	echo "HEX generated: $$HEX_FILE"
# =========================================================
# 3. SPIKE
# =========================================================
spike:
	@echo "========== SPIKE =========="

	timeout 60 \
	env LD_LIBRARY_PATH=/home/sgeuser51/gcc-10-install/lib64:$$LD_LIBRARY_PATH \
	/home/sgeuser51/riscv-isa-sim/build_gcc10/spike -m0x00000000:0x10000,0x00010000:0x40000 \
	-l --log-commits --isa=RV32I $(ELF) \
	> $(SPIKE_LOG) 2>&1 

	if [ $$? -eq 124 ]; then \
        echo "SPIKE TIMEOUT"; \
        touch $(SEED_DIR)/spike_timeout; \
    fi



# =========================================================
# 4. RTL
# =========================================================

rtl:
	@echo "========== RTL =========="
	@echo "MODE = $(MODE)"

	mkdir -p $(LOG_DIR)

ifeq ($(MODE),atomic)
	@echo "Atomic Mode ? Using split instruction memory"
	cd $(SIM_DIR) && \
	xrun -access +rwc \
	-f $(SIM_DIR)/cfg/$(MODE)_rtl.f \
	-f $(SIM_DIR)/cfg/$(MODE)_tb.f \
	+test=$(PREFIX) \
	+seed=$(SEED) \
	+log_dir=$(LOG_DIR) \
	+instr_file_B0=$(INSTR_B0) \
	+instr_file_B1=$(INSTR_B1) \
	+instr_file_B2=$(INSTR_B2) \
	+instr_file_B3=$(INSTR_B3) \
	+data_file=$(SEED_DIR)/program_data.hex \
	+trace_file=$(LOG_DIR)/rtl_trace.log \
	-l $(LOG_DIR)/rtl_run.log 

else
	@echo "Basic/Compressed Mode ? Using single HEX"
	cd $(SIM_DIR) && \
	xrun -access +rwc \
	-defparam pinaka_tb.top_instance.INST_MEMORY_ADDR_WIDTH=$(IMEM_WIDTH) \
	-defparam pinaka_tb.top_instance.DATA_MEMORY_ADDR_WIDTH=$(DMEM_WIDTH) \
	-f $(SIM_DIR)/cfg/$(MODE)_rtl.f \
	-f $(SIM_DIR)/cfg/$(MODE)_tb.f \
	+test=$(PREFIX) \
	+seed=$(SEED) \
	+log_dir=$(LOG_DIR) \
	+IMEM_FILE=$(SEED_DIR)/instruction_mem.hex \
	+DMEM_FILE=$(SEED_DIR)/program_data.hex \
	+trace_file=$(LOG_DIR)/rtl_trace.log \
	-l $(LOG_DIR)/rtl_run.log 

endif


# =========================================================
# 5. COMPARE
# =========================================================
compare:
	@echo "========== COMPARE =========="

	python $(SCRIPT_DIR)/$(MODE)_compare.py \
    $(LOG_DIR)/$(PREFIX)_spike.log \
    $(LOG_DIR)/rtl_trace.log | tee $(LOG_DIR)/compare.log	

	@echo "TEST = $(PREFIX)"
	@echo "ISA  = $(ISA)"



# =========================================================
# XCELIUM SNAPSHOT CONFIGURATION
# =========================================================

# Snapshot is shared by tests having the same RTL/TB/checker configuration.
# C_TEST and SEED are runtime-only and must NOT be part of snapshot name.

SNAPSHOT_ROOT = $(SIM_DIR)/results/xcelium_snapshot

SNAPSHOT_NAME = pinaka_$(MODE)_$(CHECKER_CORE0)_$(CHECKER_CORE1)_$(CHECKER_SHARED)_cov$(COV)

SNAPSHOT_DIR  = $(SNAPSHOT_ROOT)/$(SNAPSHOT_NAME)

SNAPSHOT_LIB  = $(SNAPSHOT_DIR)/xcelium.d

XRUN = /tools/eda/cadence//XCELIUM2009/tools/bin/xrun

DUAL_SNAPSHOT_NAME = pinaka_dual_$(CHECKER_CORE0)_$(CHECKER_CORE1)_$(CHECKER_SHARED)_cov$(COV)
DUAL_SNAPSHOT_DIR  = $(SNAPSHOT_ROOT)/$(DUAL_SNAPSHOT_NAME)
DUAL_SNAPSHOT_LIB  = $(DUAL_SNAPSHOT_DIR)/xcelium.d

# =========================================================
# PINAKA CORE FLOW
# =========================================================

pinaka_run:
	@echo "======================================"
	@echo " Running PINAKA CORE "
	@echo "======================================"\

	# Create required directories
	# -----------------------------------------------------
	mkdir -p $(PINAKA_BIN_DIR)
	mkdir -p $(RESULT_DIR)
	mkdir -p $(LOG_DIR)
	mkdir -p $(SNAPSHOT_ROOT)
	mkdir -p $(SNAPSHOT_DIR)

	@echo "Compiling $(C_TEST).c"
	$(RISCV_GCC) \
	$(ARCH) \
	$(ABI) \
	-T $(SOC_LINKER) \
	-I$(INCLUDE_DIR) \
	-static -nostdlib \
	$(SRC) \
	-o $(PINAKA_ELF) 

	@echo "Generating $(C_TEST).bin"
	$(RISCV_OBJCOPY) -O binary \
	$(PINAKA_ELF) \
	$(PINAKA_BIN)

	@echo "Generating $(C_TEST).disasm"
	$(RISCV_OBJDUMP) -d -S \
	$(PINAKA_ELF) > $(PINAKA_DISASM)

	@echo "Generating $(C_TEST).mem"
	$(RISCV_OBJCOPY) -O verilog $(PINAKA_ELF) $(PINAKA_MEM)

	@echo "Generating $(C_TEST)_data.hex"
	python $(SCRIPT_DIR)/pinaka_mem_to_word_hex.py \
	$(PINAKA_MEM) \
	$(PINAKA_DATA_HEX)

	@echo "Generating $(C_TEST)_instruction.hex"
	xxd -p -c 4 $(PINAKA_BIN) | \
	sed 's/\(..\)\(..\)\(..\)\(..\)/\4\3\2\1/' \
	> $(PINAKA_HEX)

	# Check Xcelium snapshot
	# -----------------------------------------------------
	@echo ""
	@echo "======================================"
	@echo " Checking Xcelium Snapshot "
	@echo "======================================"

	@if [ ! -d "$(SNAPSHOT_LIB)" ]; then \
		echo "No snapshot found."; \
		echo "Creating new snapshot: $(SNAPSHOT_NAME)"; \
		echo "======================================"; \
		echo " FIRST TEST - BUILD + ELABORATE + RUN"; \
		echo "======================================"; \
		cd $(PINAKA_SIM) && \
		$(XRUN) \
			-uvm \
			-sv \
			-top chip_top_tb \
			-access +rwc \
			+UVM_VERBOSITY=UVM_NONE \
			-timescale 1ns/1ps \
			$(COV_COMPILE_OPTS) \
			+define+TSMC_UNIT_DELAY \
			-xmlibdirname "$(abspath $(SNAPSHOT_LIB))" \
			-snapshot "$(SNAPSHOT_NAME)" \
			$(COV_OPTS) \
			-f "$(SIM_DIR)/cfg/$(MODE)_rtl.f" \
			-f "$(SIM_DIR)/cfg/$(MODE)_tb.f" \
			+notimingchecks \
			+define+TSMC_NO_WARNING \
			$(CHECKER_FILES) \
			$(GPIO_OPTS) \
			+pte_resp_delay=$(PTE_RESP_DELAY) \
			+HEX_FILE="$(abspath $(PINAKA_HEX))" \
			+DATA_FILE="$(abspath $(PINAKA_DATA_HEX))" \
			+PTE_HEX_FILE="$(abspath $(PINAKA_PTE_HEX))" \
			+UVM_TESTNAME="$(SOC_TEST)" \
			+C_TEST=$(C_TEST) \
			+ntb_random_seed=$(SEED) \
			+log_dir="$(abspath $(LOG_DIR))" \
			-l "$(abspath $(LOG_DIR)/rtl_run.log)"; \
		RET=$$?; \
		if [ $$RET -ne 0 ]; then \
			echo "ERROR: Xcelium build/elaboration failed."; \
			exit $$RET; \
		fi; \
	else \
		echo "Snapshot found."; \
		echo "Using existing snapshot: $(SNAPSHOT_NAME)"; \
		echo "======================================"; \
		echo " FOLLOWING TEST - REUSE SNAPSHOT"; \
		echo "======================================"; \
		cd $(PINAKA_SIM) && \
		$(XRUN) \
			-R \
			-xmlibdirname "$(abspath $(SNAPSHOT_LIB))" \
			-snapshot "$(SNAPSHOT_NAME)" \
			$(COV_COMPILE_OPTS) \
			$(COV_OPTS) \
			+pte_resp_delay=$(PTE_RESP_DELAY) \
			+HEX_FILE="$(abspath $(PINAKA_HEX))" \
			+DATA_FILE="$(abspath $(PINAKA_DATA_HEX))" \
			+PTE_HEX_FILE="$(abspath $(PINAKA_PTE_HEX))" \
			+UVM_TESTNAME="$(SOC_TEST)" \
			+C_TEST="$(C_TEST)" \
			+ntb_random_seed=$(SEED) \
			+log_dir="$(abspath $(LOG_DIR))" \
			-l "$(abspath $(LOG_DIR)/rtl_run.log)"; \
		RET=$$?; \
		if [ $$RET -ne 0 ]; then \
			echo "ERROR: Xcelium snapshot run failed."; \
			exit $$RET; \
		fi; \
	fi

	# -----------------------------------------------------
	# Final status
	# -----------------------------------------------------
	@echo ""
	@echo "======================================"
	@echo " TEST COMPLETE"
	@echo " TEST         = $(C_TEST)"
	@echo " UVM TEST     = $(SOC_TEST)"
	@echo " CHECKER      = $(CHECKER)"
	@echo " SEED         = $(SEED)"
	@echo " SNAPSHOT     = $(SNAPSHOT_NAME)"
	@echo "======================================"





# =========================================================
# DUAL CORE FLOW
# =========================================================

dual_core_run:
	@echo "======================================"
	@echo " Running PINAKA DUAL CORE"
	@echo "======================================"
	@echo "CORE0 C_TEST = $(CORE0_C_TEST)"
	@echo "CORE1 C_TEST = $(CORE1_C_TEST)"
	@echo "UVM TEST     = $(SOC_TEST)"
	@echo "SEED         = $(SEED)"
	@echo "SNAPSHOT     = $(DUAL_SNAPSHOT_NAME)"
	@echo "======================================"

	mkdir -p $(PINAKA_BIN_DIR)
	mkdir -p $(RESULT_DIR)
	mkdir -p $(LOG_DIR)
	mkdir -p $(SNAPSHOT_ROOT)
	mkdir -p $(DUAL_SNAPSHOT_DIR)


	@echo "======================================"
	@echo " BUILD CORE 0"
	@echo "======================================"

ifeq ($(CORE0_C_TEST),dummy)

	$(RISCV_GCC) \
		$(ARCH) \
		$(ABI) \
		-T $(DUAL_CORE0_LINKER) \
		-nostdlib -nostartfiles \
		$(INCLUDE_DIR)/dummy.S \
		-o $(CORE0_ELF)

else

	$(RISCV_GCC) \
		$(ARCH) \
		$(ABI) \
		-T $(DUAL_CORE0_LINKER) \
		-I$(INCLUDE_DIR) \
		-static -nostdlib \
		$(INCLUDE_DIR)/peripheral.c \
		$(INCLUDE_DIR)/startup.S \
		$(INCLUDE_DIR)/exception_handlers.c \
		$(TEST_DIR)/$(CORE0_C_TEST).c \
		-o $(CORE0_ELF)

endif

	$(RISCV_OBJCOPY) -O binary \
		$(CORE0_ELF) \
		$(CORE0_BIN)

	$(RISCV_OBJDUMP) -d \
	$(CORE0_ELF) \
	> $(PINAKA_BIN_DIR)/$(CORE0_C_TEST)_core0.disasm

	xxd -p -c 4 \
		$(CORE0_BIN) | \
		sed 's/\(..\)\(..\)\(..\)\(..\)/\4\3\2\1/' \
		> $(CORE0_HEX)


	@echo "======================================"
	@echo " BUILD CORE 1"
	@echo "======================================"

ifeq ($(CORE1_C_TEST),dummy)

	$(RISCV_GCC) \
		$(ARCH) \
		$(ABI) \
		-T $(DUAL_CORE1_LINKER) \
		-nostdlib -nostartfiles \
		$(INCLUDE_DIR)/dummy.S \
		-o $(CORE1_ELF)

else

	$(RISCV_GCC) \
		$(ARCH) \
		$(ABI) \
		-T $(DUAL_CORE1_LINKER) \
		-I$(INCLUDE_DIR) \
		-static -nostdlib \
		$(INCLUDE_DIR)/peripheral_1.c \
		$(INCLUDE_DIR)/startup1.S \
		$(INCLUDE_DIR)/exception_handlers.c \
		$(TEST_DIR)/$(CORE1_C_TEST).c \
		-o $(CORE1_ELF)

endif

	$(RISCV_OBJCOPY) -O binary \
		$(CORE1_ELF) \
		$(CORE1_BIN)

	$(RISCV_OBJDUMP) -d \
	$(CORE1_ELF) \
	> $(PINAKA_BIN_DIR)/$(CORE1_C_TEST)_core1.disasm

	xxd -p -c 4 \
		$(CORE1_BIN) | \
		sed 's/\(..\)\(..\)\(..\)\(..\)/\4\3\2\1/' \
		> $(CORE1_HEX)


	@echo "======================================"
	@echo " HEX FILES GENERATED"
	@echo "======================================"
	@echo "CORE0 = $(CORE0_HEX)"
	@echo "CORE1 = $(CORE1_HEX)"
	@echo "======================================"


	@echo "======================================"
	@echo " CHECKING DUAL-CORE SNAPSHOT"
	@echo "======================================"

	@if [ ! -d "$(DUAL_SNAPSHOT_LIB)" ]; then \
		echo "No dual-core snapshot found."; \
		echo "Creating snapshot: $(DUAL_SNAPSHOT_NAME)"; \
		echo "======================================"; \
		echo " FIRST RUN - BUILD + ELABORATE + RUN"; \
		echo "======================================"; \
		cd $(PINAKA_SIM) && \
		$(XRUN) \
			-uvm \
			-sv \
			-top chip_top_tb \
			-access +rwc \
			-timescale 1ns/1ps \
			+UVM_VERBOSITY=UVM_NONE \
			$(COV_COMPILE_OPTS) \
			+define+TSMC_UNIT_DELAY \
			$(CHECKER_DEFINES) \
			-xmlibdirname "$(abspath $(DUAL_SNAPSHOT_LIB))" \
			-snapshot "$(DUAL_SNAPSHOT_NAME)" \
			$(COV_OPTS) \
			-f "$(SIM_DIR)/cfg/pinaka_rtl.f" \
			-f "$(SIM_DIR)/cfg/dual_core_tb.f" \
			+notimingchecks \
			+define+TSMC_NO_WARNING \
			$(CHECKER_FILES) \
			$(GPIO_OPTS) \
			+pte_resp_delay=$(PTE_RESP_DELAY) \
			+CORE0_HEX_FILE="$(abspath $(CORE0_HEX))" \
			+CORE1_HEX_FILE="$(abspath $(CORE1_HEX))" \
			+PTE_HEX_FILE="$(abspath $(PINAKA_PTE_HEX))" \
			+PTE1_HEX_FILE="$(abspath $(PINAKA_PTE1_HEX))" \
			+UVM_TESTNAME="dual_core_soc_test" \
			+CORE0_SOC_TEST="$(CORE0_SOC_TEST)" \
			+CORE1_SOC_TEST="$(CORE1_SOC_TEST)" \
			+CORE0_C_TEST="$(CORE0_C_TEST)" \
			+CORE1_C_TEST="$(CORE1_C_TEST)" \
			+ntb_random_seed=$(SEED) \
			+log_dir="$(abspath $(LOG_DIR))" \
			-l "$(abspath $(LOG_DIR)/rtl_run.log)"; \
		RET=$$?; \
		if [ $$RET -ne 0 ]; then \
			echo "ERROR: Dual-core Xcelium build/elaboration failed."; \
			exit $$RET; \
		fi; \
	else \
		echo "Dual-core snapshot found."; \
		echo "Reusing snapshot: $(DUAL_SNAPSHOT_NAME)"; \
		echo "======================================"; \
		echo " FOLLOWING RUN - REUSE SNAPSHOT"; \
		echo "======================================"; \
		cd $(PINAKA_SIM) && \
		$(XRUN) \
			-R \
			-xmlibdirname "$(abspath $(DUAL_SNAPSHOT_LIB))" \
			-snapshot "$(DUAL_SNAPSHOT_NAME)" \
			$(COV_COMPILE_OPTS) \
			$(COV_OPTS) \
			+pte_resp_delay=$(PTE_RESP_DELAY) \
			+CORE0_HEX_FILE="$(abspath $(CORE0_HEX))" \
			+CORE1_HEX_FILE="$(abspath $(CORE1_HEX))" \
			+PTE_HEX_FILE="$(abspath $(PINAKA_PTE_HEX))" \
			+PTE1_HEX_FILE="$(abspath $(PINAKA_PTE1_HEX))" \
			+UVM_TESTNAME="dual_core_soc_test" \
			+CORE0_SOC_TEST="$(CORE0_SOC_TEST)" \
			+CORE1_SOC_TEST="$(CORE1_SOC_TEST)" \
			+CORE0_C_TEST="$(CORE0_C_TEST)" \
			+CORE1_C_TEST="$(CORE1_C_TEST)" \
			+ntb_random_seed=$(SEED) \
			+log_dir="$(abspath $(LOG_DIR))" \
			-l "$(abspath $(LOG_DIR)/rtl_run.log)"; \
		RET=$$?; \
		if [ $$RET -ne 0 ]; then \
			echo "ERROR: Dual-core snapshot run failed."; \
			exit $$RET; \
		fi; \
	fi



# =========================================================
# UVM TEST
# =========================================================
BOOT_CHECKER_OPT =


ifdef ENABLE_BOOT_CHECKER
BOOT_CHECKER_OPT = +ENABLE_BOOT_CHECKER
endif



UVM_TEST ?= jtag_base_test

jtag_run:

	@echo "======================================"
	@echo " Running JTAG UVM Verification "
	@echo "======================================"
	
	@echo "Compiling $(C_TEST).c"

	$(RISCV_GCC) \
	$(ARCH) \
	$(ABI) \
	-T $(SOC_LINKER) \
	-I$(INCLUDE_DIR) \
	-static -nostdlib \
	$(SRC) \
	-o $(PINAKA_ELF)

	@echo "Generating BIN"

	$(RISCV_OBJCOPY) \
	-O binary \
	$(PINAKA_ELF) \
	$(PINAKA_BIN)

	@echo "Generating DISASM"

	$(RISCV_OBJDUMP) \
	-d -S \
	$(PINAKA_ELF) \
	> $(PINAKA_DISASM)

	@echo "Generating MEM"

	$(RISCV_OBJCOPY) \
	-O verilog \
	$(PINAKA_ELF) \
	$(PINAKA_MEM)

	@echo "Generating DATA HEX"

	python $(SCRIPT_DIR)/pinaka_mem_to_word_hex.py \
	$(PINAKA_MEM) \
	$(PINAKA_DATA_HEX)

	@echo "Generating INSTRUCTION HEX"

	xxd -p -c 4 $(PINAKA_BIN) | \
	sed 's/\(..\)\(..\)\(..\)\(..\)/\4\3\2\1/' \
	> $(PINAKA_HEX)

	@echo "Running JTAG UVM"

	cd $(PINAKA_SIM) && \
	irun \
	-uvm \
	-sv \
	-access +rwc \
	-timescale 1ns/1ps \
	-f $(JTAG_RTL_FLIST) \
	-f $(JTAG_TB_FLIST) \
	+HEX_FILE=../c_tests/bin/$(C_TEST)_instruction.hex \
	+PTE_HEX_FILE=../c_tests/bin/pte.hex \
	+DATA_FILE=$(PINAKA_DATA_HEX) \
	+UVM_TESTNAME=$(UVM_TEST) \
	$(BOOT_CHECKER_OPT) \
	+ntb_random_seed=$(SEED) \
	+log_dir=$(LOG_DIR) \
	-l $(LOG_DIR)/$(UVM_TEST).log

	
# ============================================================
# Help (Updated)
# ============================================================

.PHONY: help
help:
	@echo "===================================================="
	@echo " KyroSoC Makefile Help"
	@echo "===================================================="
	@echo ""
	@echo "Simulation:"
	@echo " make run TEST=<test> SEED=<seed>"
	@echo " make gui TEST=<test>"
	@echo ""
	@echo "RISC-V Build:"
	@echo " make sw_build PROG=<name>"
	@echo ""
	@echo "Run with SW:"
	@echo " make run_sw PROG=<name> TEST=<test>"
	@echo " make run_hex PROG=<name> TEST=<test>"
	@echo ""
	@echo "Regression:"
	@echo " make regress"
	@echo ""
	@echo "Clean:"
	@echo " make clean"
	@echo " make distclean"
	@echo ""
	@echo "Variables:"
	@echo " TEST         = $(TEST)"
	@echo " SEED         = $(SEED)"
	@echo " PROG         = $(PROG)"
	@echo " RISCV_ARCH   = $(RISCV_ARCH)"
	@echo " RISCV_ABI    = $(RISCV_ABI)"
	@echo ""
	@echo "Examples:"
	@echo " make run TEST=basic_test"
	@echo " make run_sw PROG=hello TEST=core_test"
	@echo " make run_hex PROG=hello"

#make MODE=dual_core \
#CORE0_C_TEST=uart_test \
#CORE1_C_TEST=spi_test \
#SOC_TEST=dual_core_boot_test \

#make MODE=dual_core \
#CORE0_C_TEST=boot_test \
#CORE1_C_TEST=boot_test \
#CORE0_SOC_TEST=boot_flow_test \
#CORE1_SOC_TEST=boot_flow_test \
#GPIO=gpio
# ============================================================
# Help for JTAG UVM RUN
# ============================================================
	@echo "JTAG UVM"
	@echo " make MODE=jtag UVM_TEST=<testname>"
	@echo " make MODE=jtag UVM_TEST=<testname> SEED=<seed>"
	@echo ""
	@echo "Examples:"
	@echo " make MODE=jtag UVM_TEST=jtag_base_test"
	@echo " make MODE=jtag UVM_TEST=dmi_read_test"
	@echo "===================================================="


# =========================================================
# SNAPSHOT CLEANUP
# =========================================================

.PHONY: clean_snapshot clean_all_snapshots

clean_snapshot:
	@echo "Removing snapshot: $(SNAPSHOT_NAME)"
	rm -rf "$(SNAPSHOT_DIR)"

clean_all_snapshots:
	@echo "Removing all Xcelium snapshots"
	rm -rf "$(SNAPSHOT_ROOT)"


