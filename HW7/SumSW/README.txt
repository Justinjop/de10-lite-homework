HW7 1+2+3+...+n (DE10-Lite, MAX 10 10M50DAF484C7G)

編譯與燒錄
  1. 用 Quartus Prime Lite (16.1 以上，需支援 MAX 10) 開啟 SumSW.qpf
  2. Processing > Start Compilation
  3. Tools > Programmer，選 USB-Blaster，燒錄 output_files/SumSW.sof

操作
  SW9 ~ SW0  n，二進位 0 ~ 1023
  KEY0       按下直接顯示結果 n(n+1)/2
  KEY1       每按一下加一個數字 (單步)，LEDR 顯示加到第幾個；加完再按一次歸零重新開始
  HEX5 ~ HEX0 顯示總和 (最大 1+2+...+1023 = 523776)，前面的 0 不顯示
  撥動 SW 會從 0 重新開始

模擬 (ModelSim)
  vlib work
  vcom -93 ../Seg7.vhd ../SumSW.vhd SumSW_tb.vhd
  vsim -c work.SumSW_tb -do "run -all; quit -f"
  最後出現 "SumSW testbench: ALL PASSED" 代表通過。
