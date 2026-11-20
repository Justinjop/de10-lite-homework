HW5 4 位數 BCD 上下數計數器 0~9999, 100 Hz

操作
  BUTTON0  Reset (按下歸零)
  SW0      方向 (往上 = 上數，往下 = 下數)
  HEX3 ~ HEX0 顯示計數值

編譯與燒錄 (板子: DE0, Cyclone III EP3C16F484C6)
  最快: 直接燒錄已編好的 output_files/BCDcnt.sof
    1. 板子接 USB (USB-Blaster) 並通電
    2. Quartus 開 Tools > Programmer，Hardware Setup 選 USB-Blaster，Mode 選 JTAG
    3. Add File 選 output_files/BCDcnt.sof，勾 Program/Configure，按 Start
  自己編譯: 用 Quartus II 13.1 (或更新版本) 開啟 BCDcnt.qpf，Processing > Start Compilation

模擬 (ModelSim)
  cd sim
  vlib work
  vcom -93 ../Seg7.vhd ../BCDcnt.vhd BCDcnt_tb.vhd
  vsim -c work.BCDcnt_tb -do "run -all; quit -f"
  最後出現 "BCDcnt testbench: ALL PASSED" 代表通過。
