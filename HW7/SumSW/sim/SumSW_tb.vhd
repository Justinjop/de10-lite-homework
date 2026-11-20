library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Self-checking testbench (ModelSim). The 10 ms key lockout is shortened to 4 clocks.
entity SumSW_tb is
end SumSW_tb;

architecture sim of SumSW_tb is
	constant TCLK:time := 20 ns;
	signal clk:std_logic := '0';
	signal done:boolean := false;
	signal KEY:std_logic_vector(1 downto 0) := "11";
	signal SW:std_logic_vector(9 downto 0) := (others => '0');
	signal LEDR:std_logic_vector(9 downto 0);
	signal HEX0,HEX1,HEX2,HEX3,HEX4,HEX5:std_logic_vector(6 downto 0);

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
			when "1111111" => return 0;		-- blank
			when others => return -1000000;
		end case;
	end dig;

	impure function val return integer is	-- shown number
	begin
		return ((((dig(HEX5)*10 + dig(HEX4))*10 + dig(HEX3))*10 + dig(HEX2))*10 + dig(HEX1))*10 + dig(HEX0);
	end val;

	function tri(k:integer) return integer is
	begin
		return k*(k+1)/2;
	end tri;
begin
	clk <= not clk after TCLK/2 when not done;

	dut:entity work.SumSW
		generic map(LOCK => 4)
		port map(clk, KEY, SW, LEDR, HEX0, HEX1, HEX2, HEX3, HEX4, HEX5);

	process
		procedure set_n(n:integer) is
		begin
			SW <= std_logic_vector(to_unsigned(n,10));
			wait for 8*TCLK;
		end set_n;

		procedure tap(k:integer) is
		begin
			KEY(k) <= '0'; wait for 6*TCLK;
			KEY(k) <= '1'; wait for 8*TCLK;
		end tap;

		procedure check(v:integer; led:integer; msg:string) is
		begin
			assert val = v and LEDR = std_logic_vector(to_unsigned(led,10))
				report msg & ": expected " & integer'image(v) & " / " & integer'image(led) & " got " & integer'image(val)
				severity failure;
		end check;
	begin
		wait for 10*TCLK;
		check(0,0,"power up");
		assert HEX5 = "1111111" and HEX1 = "1111111" and HEX0 = "1000000" report "leading zeros are not blank" severity failure;

		-- KEY1: single step, n = 5
		set_n(5);
		check(0,0,"n=5");
		for k in 1 to 5 loop
			tap(1);
			check(tri(k),k,"step " & integer'image(k));
		end loop;
		tap(1);
		check(0,0,"step after the end clears");
		tap(1);
		check(1,1,"restart");

		-- KEY0: result at once
		set_n(5);
		tap(0);
		check(15,5,"direct n=5");
		tap(1);
		check(0,0,"step after direct clears");
		set_n(3);
		tap(0);
		check(6,3,"direct n=3");
		assert HEX5 = "1111111" and HEX4 = "1111111" and HEX3 = "1111111" and HEX2 = "1111111" and HEX1 = "1111111" report "leading zeros are not blank (6)" severity failure;
		set_n(100);
		tap(0);
		check(5050,100,"direct n=100");
		set_n(0);
		tap(0);
		check(0,0,"direct n=0");

		-- largest value: every step of n = 1023, then direct
		set_n(1023);
		for k in 1 to 1023 loop
			tap(1);
			assert val = tri(k) and LEDR = std_logic_vector(to_unsigned(k,10))
				report "step " & integer'image(k) & " wrong: " & integer'image(val) severity failure;
		end loop;
		assert val = 523776 report "1+2+...+1023 is not 523776" severity failure;
		set_n(1023);
		tap(0);
		check(523776,1023,"direct n=1023");

		-- changing the switches starts over
		set_n(50);
		tap(1); tap(1); tap(1);
		check(6,3,"3 steps");
		set_n(60);
		check(0,0,"switch change");

		-- bounce: two quick presses count once
		KEY(1) <= '0'; wait for 2*TCLK; KEY(1) <= '1'; wait for TCLK; KEY(1) <= '0'; wait for 2*TCLK; KEY(1) <= '1';
		wait for 10*TCLK;
		check(1,1,"bounce");

		report "SumSW testbench: ALL PASSED" severity note;
		done <= true;
		wait;
	end process;
end sim;
