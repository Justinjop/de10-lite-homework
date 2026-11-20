library ieee;
use ieee.std_logic_1164.all;

-- 4-digit BCD up/down counter 0~9999 on DE10-Lite (HEX3 ~ HEX0), 100 Hz
--   KEY0 : Reset (press = 0000)
--   SW0  : direction (1 = up, 0 = down)
entity BCDcnt is
	generic(
			STEP_CLKS:integer := 500000		-- clocks per count, 100 Hz
			);
	port(
			MAX10_CLK1_50:in std_logic;
			KEY:in std_logic_vector(0 downto 0);
			SW:in std_logic_vector(0 downto 0);
			HEX0:out std_logic_vector(6 downto 0);
			HEX1:out std_logic_vector(6 downto 0);
			HEX2:out std_logic_vector(6 downto 0);
			HEX3:out std_logic_vector(6 downto 0)
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
	signal tick:std_logic := '0';					-- one pulse per count
	signal d0,d1,d2,d3:integer range 0 to 9 := 0;	-- digits, d3 = thousands
begin
	clk <= MAX10_CLK1_50;
	Reset <= KEY(0);
	up <= SW(0);

	-- 100 Hz count rate
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

	-- cascaded BCD digits, count up or down, wrap around
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

	U3:Seg7 port map(d3,HEX3);
	U2:Seg7 port map(d2,HEX2);
	U1:Seg7 port map(d1,HEX1);
	U0:Seg7 port map(d0,HEX0);

end BCDcnt;
