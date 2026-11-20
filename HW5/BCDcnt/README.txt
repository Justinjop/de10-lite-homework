HW5 4 位數 BCD 上下數計數器 0~9999, 100 Hz (DE10-Lite, MAX 10 10M50DAF484C7G)

編譯與燒錄
  1. 用 Quartus Prime Lite (16.1 以上，需支援 MAX 10) 開啟 BCDcnt.qpf
  2. Processing > Start Compilation
  3. Tools > Programmer，選 USB-Blaster，燒錄 output_files/BCDcnt.sof

操作
  KEY0 Reset (按下歸零)
  SW0  方向 (往上 = 上數，往下 = 下數)
  HEX3 ~ HEX0 顯示計數值

模擬 (ModelSim)
  vlib work
  vcom -93 ../Seg7.vhd ../BCDcnt.vhd BCDcnt_tb.vhd
  vsim -c work.BCDcnt_tb -do "run -all; quit -f"
  最後出現 "BCDcnt testbench: ALL PASSED" 代表通過。
