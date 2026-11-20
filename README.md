# DE0 digital system homework

VHDL projects for the Terasic DE0 (Cyclone III EP3C16F484C6), pins from the course pin sheet. Each project folder contains the source, a Quartus II 13.1 project (`.qpf`), and the compiled `output_files/*.sof`.

To run on the board: Quartus **Tools > Programmer**, Hardware Setup = USB-Blaster, Mode = JTAG, Add File = the `.sof`, tick Program/Configure, Start. To rebuild, open the `.qpf` and press Start Compilation.

| Folder | Project | Description |
|---|---|---|
| `HW5/BCDcnt` | 4-digit BCD up/down counter | 0000 ~ 9999, 100 Hz. BUTTON0 = reset, SW0 = up/down |
| `HW6/PingPong` | Table tennis on 10 LEDs | 3 points per game, best of 3 games, the winner stays. BUTTON2 = player A (left), BUTTON0 = player B (right), SW0 = reset |
| `HW7/SumSW` | 1 + 2 + ... + n | n = SW9 ~ SW0 (0 ~ 1023). BUTTON0 = show the result at once, BUTTON1 = single step, hold BUTTON2 = digits above the thousands |

Each project has its own `README.txt` (operation) and a self-checking ModelSim testbench in `sim/`.
