//+incdir+../dv/tb/agents/I2C_slave_agent
+incdir+../dv/tb/agents/i2c_agent
//+incdir+../dv/tb/agents/spi_master_agent
+incdir+../dv/tb/agents/spi_agent
+incdir+../dv/tb/agents/uart_serial_agent
+incdir+../dv/tb/agents/gpio_agent
+incdir+../dv/tb/agents/int_agent
+incdir+../dv/tb/GPIO_INSTANCE

+incdir+../dv/tb/env
+incdir+../dv/tb/tests
+incdir+../dv/tb/agents/jtag_agent
+incdir+../dv/tb/tests/jtag_test
+incdir+../dv/tb/env
+incdir+../dv/tb/scoreboards
+incdir+../dv/tb/pinmux_checker

//+incdir+$UVM_HOME/src
//../dv/tb/tests/soc_base_test.sv
//../dv/tb/tests/dual_core_soc_test.sv
//$UVM_HOME/src/uvm_pkg.sv
../dv/tb/pinmux_checker/pinmux_assert.sv
../dv/tb/pinmux_checker/pinmux_bind.sv
//../dv/tb/mem_checker/memory_map_monitor_checker.sv
//../dv/tb/mem_checker/memory_map_binds.sv
//../dv/tb/mem_checker/clk_rst_monitor_checker.sv
//../dv/tb/mem_checker/clk_rst_binds.sv
//../dv/tb/mmu_checker/mmu_checker.sv
//../dv/tb/mmu_checker/mmu_binds.sv
//../dv/tb/spi_checker/spi_monitor_checker.sv
//../dv/tb/spi_checker/spi_bind.sv
../dv/tb/agents/jtag_agent/interface.sv 
../dv/tb/agents/int_agent/intf.sv
../dv/tb/pkg/tb_sync_pkg.sv
../dv/tb/pkg/soc_tb_pkg.sv
//../dv/tb/top/tb_top.v
../dv/tb/top/chip_top_tb.v


