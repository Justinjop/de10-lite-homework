library ieee;
use ieee.std_logic_1164.all;

-- Self-checking testbench (ModelSim). 100 Hz is shortened to 4 clocks per count.
entity BCDcnt_tb is
end BCDcnt_tb;

architecture sim of BCDcnt_tb is
	constant TCLK:time := 20 ns;
	signal clk:std_logic := '0';
	signal done:boolean := false;
	signal BUTTON:std_logic_vector(0 downto 0) := "1";
	signal SW:std_logic_vector(0 downto 0) := "1";		-- SW0 direction
	signal HEX0,HEX1,HEX2,HEX3:std_logic_vector(6 downto 0);
	signal DP0,DP1,DP2,DP3:std_logic;

	function dig(s:std_logic_vector(6 downto 0)) return integer is
	begin
		case s is
			when "1000000" => return 0;
			when "1111001" => return 1;
			when "0100100" => return 2;
			when "0110000" => return 3;
			when "0011001" => return 4;
			when "0010010" => return 5;
			when "0000010" => return 6;
			when "1111000" => return 7;
			when "0000000" => return 8;
			when "0010000" => return 9;
			when others => return -1;
		end case;
	end dig;

	impure function val return integer is			-- shown number
	begin
		return ((dig(HEX3)*10 + dig(HEX2))*10 + dig(HEX1))*10 + dig(HEX0);
	end val;
begin
	clk <= not clk after TCLK/2 when not done;

	dut:entity work.BCDcnt
		generic map(STEP_CLKS => 4)
		port map(clk, BUTTON, SW, HEX0, DP0, HEX1, DP1, HEX2, DP2, HEX3, DP3);

	process
		variable old,v:integer;
		variable t0,t1:time;

		procedure next_val is						-- wait for the next change of the display
			variable c:integer := 0;
		begin
			old := val;
			while val = old loop
				wait until rising_edge(clk);
				c := c+1;
				assert c < 100 report "display does not change" severity failure;
			end loop;
			wait for 2 ns;
			v := val;
		end next_val;

		procedure steps(n,dir:integer) is			-- n counts, each one +1 / -1 (wrapping)
		begin
			for i in 1 to n loop
				next_val;
				assert v = (old + dir + 10000) mod 10000
					report "expected " & integer'image((old + dir + 10000) mod 10000) & " after " & integer'image(old) & " got " & integer'image(v)
					severity failure;
			end loop;
		end steps;
	begin
		-- reset
		wait for 3*TCLK;
		BUTTON <= "0"; wait for 3*TCLK; BUTTON <= "1"; wait for TCLK;
		assert val = 0 report "not 0000 after reset" severity failure;
		assert DP0 = '1' and DP1 = '1' and DP2 = '1' and DP3 = '1' report "decimal points are on" severity failure;

		-- up through the wrap around 9999 -> 0000
		steps(10001,1);
		assert val = 1 report "wrap around failed" severity failure;

		-- down through 0000 -> 9999
		SW <= "0";
		steps(3,-1);
		assert val = 9998 report "down wrap failed" severity failure;
		SW <= "1";
		steps(5,1);

		-- reset while counting
		BUTTON <= "0"; wait for 3*TCLK; assert val = 0 report "reset while counting failed" severity failure;
		BUTTON <= "1"; wait for TCLK;

		-- 100 Hz step
		next_val; t0 := now; next_val; t1 := now;
		assert t1-t0 = 4*TCLK report "count step is not 4 clocks" severity failure;

		report "BCDcnt testbench: ALL PASSED" severity note;
		done <= true;
		wait;
	end process;
end sim;
