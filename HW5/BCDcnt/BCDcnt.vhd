library ieee;
use ieee.std_logic_1164.all;

entity BCDcnt is
	generic(
			STEP_CLKS:integer := 500000
			);
	port(
			CLOCK_50:in std_logic;
			BUTTON:in std_logic_vector(0 downto 0);
			SW:in std_logic_vector(0 downto 0);
			HEX0_D:out std_logic_vector(6 downto 0);
			HEX0_DP:out std_logic;
			HEX1_D:out std_logic_vector(6 downto 0);
			HEX1_DP:out std_logic;
			HEX2_D:out std_logic_vector(6 downto 0);
			HEX2_DP:out std_logic;
			HEX3_D:out std_logic_vector(6 downto 0);
			HEX3_DP:out std_logic
			);
end BCDcnt;

architecture BCDcnt of BCDcnt is
	component Seg7 is
	port(
			d:in integer range 0 to 15;
			seg:out std_logic_vector(6 downto 0)
			);
	end component;

	signal clk,Reset,up:std_logic;
	signal cnt:integer range 0 to 16777215;
	signal tick:std_logic := '0';
	signal d0,d1,d2,d3:integer range 0 to 9 := 0;
begin
	clk <= CLOCK_50;
	Reset <= BUTTON(0);
	up <= SW(0);

	process(clk)
	begin
		if rising_edge(clk) then
			if cnt >= STEP_CLKS-1 then
				cnt <= 0;
				tick <= '1';
			else
				cnt <= cnt+1;
				tick <= '0';
			end if;
		end if;
	end process;

	process(clk,Reset)
	begin
		if Reset='0' then
			d0 <= 0;
			d1 <= 0;
			d2 <= 0;
			d3 <= 0;
		elsif rising_edge(clk) then
			if tick='1' then
				if up='1' then
					if d0 = 9 then
						d0 <= 0;
						if d1 = 9 then
							d1 <= 0;
							if d2 = 9 then
								d2 <= 0;
								if d3 = 9 then d3 <= 0; else d3 <= d3+1; end if;
							else
								d2 <= d2+1;
							end if;
						else
							d1 <= d1+1;
						end if;
					else
						d0 <= d0+1;
					end if;
				else
					if d0 = 0 then
						d0 <= 9;
						if d1 = 0 then
							d1 <= 9;
							if d2 = 0 then
								d2 <= 9;
								if d3 = 0 then d3 <= 9; else d3 <= d3-1; end if;
							else
								d2 <= d2-1;
							end if;
						else
							d1 <= d1-1;
						end if;
					else
						d0 <= d0-1;
					end if;
				end if;
			end if;
		end if;
	end process;

	U3:Seg7 port map(d3,HEX3_D);
	U2:Seg7 port map(d2,HEX2_D);
	U1:Seg7 port map(d1,HEX1_D);
	U0:Seg7 port map(d0,HEX0_D);
	HEX0_DP <= '1';
	HEX1_DP <= '1';
	HEX2_DP <= '1';
	HEX3_DP <= '1';

end BCDcnt;
