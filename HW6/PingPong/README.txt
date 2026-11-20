HW6 桌球對打

操作
  SW0      Reset (往下 = Reset，往上 = 開始)
  BUTTON2  選手 A (左，LEDG9 側)    BUTTON0  選手 B (右，LEDG0 側)
  HEX3 HEX2 = A 局數 / A 分數    HEX1 HEX0 = B 分數 / B 局數

規則
  Reset 後 A 發球；誰失分對方發球；每局 3 分、3 局 2 勝；
  贏方換對手 (贏方 LED 閃爍，輸的一方按自己的鍵代表新對手上場，贏方留場先發球)。
  球在 LED 上每 0.2 秒移動一格；球到最右邊 (LEDG0) 時 B 按鍵擊球，到最左邊 (LEDG9) 時 A 按鍵擊球，
  太早按或沒按都算失分。

編譯與燒錄 (板子: DE0, Cyclone III EP3C16F484C6)
  最快: 直接燒錄已編好的 output_files/PingPong.sof
    1. 板子接 USB (USB-Blaster) 並通電
    2. Quartus 開 Tools > Programmer，Hardware Setup 選 USB-Blaster，Mode 選 JTAG
    3. Add File 選 output_files/PingPong.sof，勾 Program/Configure，按 Start
  自己編譯: 用 Quartus II 13.1 (或更新版本) 開啟 PingPong.qpf，Processing > Start Compilation

模擬 (ModelSim)
  cd sim
  vlib work
  vcom -93 ../Seg7.vhd ../PingPong.vhd PingPong_tb.vhd
  vsim -c work.PingPong_tb -do "run -all; quit -f"
  最後出現 "PingPong testbench: ALL PASSED" 代表通過。
