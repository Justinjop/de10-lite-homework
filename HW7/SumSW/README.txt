HW7 1+2+3+...+n

操作
  SW9 ~ SW0  n，二進位 0 ~ 1023
  BUTTON0    按下直接顯示結果 n(n+1)/2
  BUTTON1    每按一下加一個數字 (單步)，LEDG 顯示加到第幾個；加完再按一次歸零重新開始
  BUTTON2    按住顯示萬位以上的數字 (總和最大 1+2+...+1023 = 523776，但板子只有 4 位數)
  HEX3 ~ HEX0 顯示總和的後 4 位數，總和 >= 10000 時 HEX3 的小數點會亮
  撥動 SW 會從 0 重新開始

編譯與燒錄 (板子: DE0, Cyclone III EP3C16F484C6)
  最快: 直接燒錄已編好的 output_files/SumSW.sof
    1. 板子接 USB (USB-Blaster) 並通電
    2. Quartus 開 Tools > Programmer，Hardware Setup 選 USB-Blaster，Mode 選 JTAG
    3. Add File 選 output_files/SumSW.sof，勾 Program/Configure，按 Start
  自己編譯: 用 Quartus II 13.1 (或更新版本) 開啟 SumSW.qpf，Processing > Start Compilation

模擬 (ModelSim)
  cd sim
  vlib work
  vcom -93 ../Seg7.vhd ../SumSW.vhd SumSW_tb.vhd
  vsim -c work.SumSW_tb -do "run -all; quit -f"
  最後出現 "SumSW testbench: ALL PASSED" 代表通過。
