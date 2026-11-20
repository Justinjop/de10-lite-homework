HW6 桌球對打 (DE10-Lite, MAX 10 10M50DAF484C7G)

編譯與燒錄
  1. 用 Quartus Prime Lite (16.1 以上，需支援 MAX 10) 開啟 PingPong.qpf
  2. Processing > Start Compilation
  3. Tools > Programmer，選 USB-Blaster，燒錄 output_files/PingPong.sof

操作
  SW0  Reset (往下 = Reset，往上 = 開始)
  KEY1 選手 A (左，LEDR9 側)    KEY0 選手 B (右，LEDR0 側)
  HEX3 HEX2 = A 局數 / A 分數    HEX1 HEX0 = B 分數 / B 局數

規則
  Reset 後 A 發球；誰失分對方發球；每局 3 分、3 局 2 勝；
  贏方換對手 (贏方 LED 閃爍，輸的一方按自己的鍵代表新對手上場，贏方留場先發球)。

模擬 (ModelSim)
  sim/PingPong_tb.vhd 是自動檢查的 testbench：
  vlib work
  vcom -93 ../Seg7.vhd ../PingPong.vhd PingPong_tb.vhd
  vsim -c work.PingPong_tb -do "run -all; quit -f"
  最後出現 "PingPong testbench: ALL PASSED" 代表通過。
