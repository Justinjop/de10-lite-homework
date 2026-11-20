library ieee;
use ieee.std_logic_1164.all;

entity PingPong_tb is
end PingPong_tb;

architecture sim of PingPong_tb is
	constant TCLK:time := 20 ns;
	signal clk:std_logic := '0';
	signal done:boolean := false;
	signal SW:std_logic_vector(0 downto 0) := "0";
	signal BUTTON:std_logic_vector(2 downto 0) := "111";
	signal LEDG:std_logic_vector(9 downto 0);
	signal HEX0,HEX1,HEX2,HEX3:std_logic_vector(6 downto 0);
	signal DP0,DP1,DP2,DP3:std_logic;

	function one_hot(n:integer) return std_logic_vector is
		variable v:std_logic_vector(9 downto 0) := (others => '0');
	begin
		v(n) := '1';
		return v;
	end one_hot;

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
			when "0001000" => return 10;
			when "0000011" => return 11;
			when "0111111" => return 12;
			when "1111111" => return 15;
			when others => return -1;
		end case;
	end dig;
begin
	clk <= not clk after TCLK/2 when not done;

	dut:entity work.PingPong
		generic map(STEP_CLKS => 40, BLINK_HALF => 40)
		port map(clk, SW, BUTTON, LEDG, HEX0, DP0, HEX1, DP1, HEX2, DP2, HEX3, DP3);

	process
		variable t0,t1:time;

		procedure tap(signal k:out std_logic) is
		begin
			k <= '0';
			wait for 5*TCLK;
			k <= '1';
			wait for 5*TCLK;
		end tap;

		procedure wait_led(n:integer) is
			variable c:integer := 0;
		begin
			while LEDG /= one_hot(n) loop
				wait until rising_edge(clk);
				c := c+1;
				assert c < 3000 report "timeout waiting for LED " & integer'image(n) severity failure;
			end loop;
		end wait_led;

		procedure wait_off is
			variable c:integer := 0;
		begin
			while LEDG /= "0000000000" loop
				wait until rising_edge(clk);
				c := c+1;
				assert c < 3000 report "timeout waiting for ball to leave" severity failure;
			end loop;
			wait for 5*TCLK;
		end wait_off;

		procedure check(ga,pa,pb,gb:integer; msg:string) is
		begin
			assert dig(HEX3)=ga and dig(HEX2)=pa and dig(HEX1)=pb and dig(HEX0)=gb
				report msg & ": expected " & integer'image(ga) & integer'image(pa) & "-" & integer'image(pb) & integer'image(gb)
					& " got " & integer'image(dig(HEX3)) & integer'image(dig(HEX2)) & "-" & integer'image(dig(HEX1)) & integer'image(dig(HEX0))
				severity failure;
		end check;

		procedure a_scores is
		begin
			tap(BUTTON(2));
			wait_led(0);
			wait_off;
		end a_scores;

		procedure b_scores is
		begin
			tap(BUTTON(0));
			wait_led(9);
			wait_off;
		end b_scores;

		procedure reset_game is
		begin
			SW <= "0";
			wait for 4*TCLK;
			SW <= "1";
			wait for 4*TCLK;
		end reset_game;
	begin
		BUTTON <= "111";

		reset_game;
		tap(BUTTON(2)); wait_led(8); t0 := now; wait_led(7); t1 := now;
		assert t1-t0 = 40*TCLK report "slow step is not 40 clocks" severity failure;

		reset_game;
		assert LEDG = "0000000000" report "LEDs not off after reset" severity failure;
		check(0,0,0,0,"after reset");
		tap(BUTTON(0));
		wait for 10*TCLK;
		assert LEDG = "0000000000" report "B served before A" severity failure;

		tap(BUTTON(2)); wait_led(9);
		wait_led(0); tap(BUTTON(0));
		wait_led(9); tap(BUTTON(2));
		wait_led(8);
		wait_led(0); wait_off;
		check(0,1,0,0,"A 1-0");

		a_scores; check(0,2,0,0,"A 2-0");
		a_scores; check(1,3,0,0,"game 1 to A");
		tap(BUTTON(2)); wait_led(9);
		check(1,0,0,0,"points cleared at serve");

		wait_led(1); tap(BUTTON(0)); wait_off;
		check(1,1,0,0,"B early");
		a_scores;
		a_scores;
		check(2,3,0,0,"match to A");
		wait until LEDG(9 downto 5) = "11111" for 20*TCLK*40;
		assert LEDG(9 downto 5) = "11111" and LEDG(4 downto 0) = "00000" report "A side does not blink" severity failure;

		tap(BUTTON(2));
		for i in 1 to 200 loop
			wait for TCLK;
			assert (LEDG(9 downto 5) = "00000" or LEDG(9 downto 5) = "11111") and LEDG(4 downto 0) = "00000"
				report "ball appeared after the match" severity failure;
		end loop;

		tap(BUTTON(0));
		check(0,0,0,0,"new match");
		tap(BUTTON(2)); wait_led(9);
		wait_led(0); tap(BUTTON(0));
		wait_led(9); wait_off;
		check(0,0,1,0,"B 1");

		b_scores; check(0,0,2,0,"B 2");
		b_scores; check(0,0,3,1,"game 1 to B");
		tap(BUTTON(0)); wait_led(1);
		check(0,0,0,1,"points cleared at serve (B)");
		wait_led(8); tap(BUTTON(2)); wait_off;
		check(0,0,1,1,"A early");
		b_scores;
		b_scores;
		check(0,0,3,2,"match to B");
		wait until LEDG(4 downto 0) = "11111" for 20*TCLK*40;
		assert LEDG(4 downto 0) = "11111" and LEDG(9 downto 5) = "00000" report "B side does not blink" severity failure;

		tap(BUTTON(2));
		check(0,0,0,0,"new match 2");
		tap(BUTTON(2));
		wait for 10*TCLK;
		assert LEDG = "0000000000" report "A served before B" severity failure;

		for i in 1 to 5 loop b_scores; end loop;
		tap(BUTTON(0)); wait_led(9); wait_off;
		check(0,0,3,2,"second match to B");

		report "PingPong testbench: ALL PASSED" severity note;
		done <= true;
		wait;
	end process;
end sim;
