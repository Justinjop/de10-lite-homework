# DE10-Lite digital system homework

VHDL projects for the Terasic DE10-Lite (MAX 10, 10M50DAF484C7G). Open the `.qpf` of a project with Quartus Prime Lite (16.1 or later), compile, and program `output_files/*.sof` with the USB-Blaster.

| Folder | Project | Description |
|---|---|---|
| `HW5/BCDcnt` | 4-digit BCD up/down counter | 0000 ~ 9999, 100 Hz. KEY0 = reset, SW0 = up/down |
| `HW6/PingPong` | Table tennis on 10 LEDs | 3 points per game, best of 3 games, the winner stays. KEY1 = player A, KEY0 = player B, SW0 = reset |
| `HW7/SumSW` | 1 + 2 + ... + n | n = SW9 ~ SW0 (0 ~ 1023). KEY0 = show the result at once, KEY1 = single step |

Each project has its own `README.txt` (operation) and a self-checking ModelSim testbench in `sim/`.

HW7 shows the sum on HEX5 ~ HEX0; the HEX4 / HEX5 pins in `HW7/SumSW/SumSW.qsf` come from the DE10-Lite user manual, not from the course pin sheet.
