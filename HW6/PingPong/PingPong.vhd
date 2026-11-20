library ieee;
use ieee.std_logic_1164.all;

entity PingPong is
	generic(
			STEP_CLKS:integer := 10000000;
			BLINK_HALF:integer := 12500000
			);
	port(
			CLOCK_50:in std_logic;
			SW:in std_logic_vector(0 downto 0);
			BUTTON:in std_logic_vector(2 downto 0);
			LEDG:out std_logic_vector(9 downto 0);
			HEX0_D:out std_logic_vector(6 downto 0);
			HEX0_DP:out std_logic;
			HEX1_D:out std_logic_vector(6 downto 0);
			HEX1_DP:out std_logic;
			HEX2_D:out std_logic_vector(6 downto 0);
			HEX2_DP:out std_logic;
			HEX3_D:out std_logic_vector(6 downto 0);
			HEX3_DP:out std_logic
			);
end PingPong;

architecture PingPong of PingPong is
	component Seg7 is
	port(
			d:in integer range 0 to 15;
			seg:out std_logic_vector(6 downto 0)
			);
	end component;

	signal clk,Reset:std_logic;
	signal a1,a2,a3,b1,b2,b3:std_logic := '0';
	signal pa,pb:std_logic := '0';
	signal cnt,bcnt:integer range 0 to 16777215;
	signal tick,blink:std_logic := '0';

	signal st:integer range 0 to 20 := 0;
	signal winA,winB,serve:std_logic := '0';
	signal canserve:std_logic;

	signal ptsA,ptsB:integer range 0 to 3 := 0;
	signal gmA,gmB:integer range 0 to 2 := 0;
	signal newgame,over:std_logic := '0';
	signal champ:integer range 0 to 2 := 0;
begin
	clk <= CLOCK_50;
	Reset <= SW(0);
	canserve <= '1' when over='0' and winA='0' and winB='0' else '0';

	process(clk)
	begin
		if rising_edge(clk) then
			a1 <= not BUTTON(2);	a2 <= a1;	a3 <= a2;
			b1 <= not BUTTON(0);	b2 <= b1;	b3 <= b2;

			if serve='1' then
				cnt <= 0;
				tick <= '0';
			elsif cnt >= STEP_CLKS-1 then
				cnt <= 0;
				tick <= '1';
			else
				cnt <= cnt+1;
				tick <= '0';
			end if;

			if tick='1' then
				pa <= '0';
				pb <= '0';
			end if;
			if a2='1' and a3='0' then pa <= '1'; end if;
			if b2='1' and b3='0' then pb <= '1'; end if;

			if bcnt >= BLINK_HALF-1 then
				bcnt <= 0;
				blink <= not blink;
			else
				bcnt <= bcnt+1;
			end if;
		end if;
	end process;

	process(clk,Reset)
	begin
		if Reset='0' then
			st <= 0;
			winA <= '0';
			winB <= '0';
			serve <= '0';
		elsif rising_edge(clk) then
			winA <= '0';
			winB <= '0';
			serve <= '0';
			case st is
				when 0 =>
					if pa='1' and canserve='1' then
						st <= 1;
						serve <= '1';
					end if;
				when 1 to 8 | 11 to 17 =>
					if tick='1' then st <= st+1; end if;
				when 9 =>
					if tick='1' then
						if pb='1' then
							st <= 0;
							winA <= '1';
						else
							st <= 10;
						end if;
					end if;
				when 10 =>
					if tick='1' then
						if pb='1' then
							st <= 11;
						else
							st <= 0;
							winA <= '1';
						end if;
					end if;
				when 18 =>
					if tick='1' then
						if pa='1' then
							st <= 20;
							winB <= '1';
						else
							st <= 19;
						end if;
					end if;
				when 19 =>
					if tick='1' then
						if pa='1' then
							st <= 2;
						else
							st <= 20;
							winB <= '1';
						end if;
					end if;
				when 20 =>
					if pb='1' and canserve='1' then
						st <= 11;
						serve <= '1';
					end if;
				when others => null;
			end case;
		end if;
	end process;

	process(clk,Reset)
	begin
		if Reset='0' then
			ptsA <= 0;
			ptsB <= 0;
			gmA <= 0;
			gmB <= 0;
			newgame <= '0';
			over <= '0';
			champ <= 0;
		elsif rising_edge(clk) then
			if over='1' then

				if (champ=1 and pb='1') or (champ=2 and pa='1') then
					over <= '0';
					newgame <= '0';
					ptsA <= 0;
					ptsB <= 0;
					gmA <= 0;
					gmB <= 0;
				end if;
			elsif serve='1' then
				if newgame='1' then
					newgame <= '0';
					ptsA <= 0;
					ptsB <= 0;
				end if;
			elsif winA='1' then
				if ptsA=2 then
					ptsA <= 3;
					newgame <= '1';
					if gmA=1 then
						gmA <= 2;
						over <= '1';
						champ <= 1;
					else
						gmA <= gmA+1;
					end if;
				else
					ptsA <= ptsA+1;
				end if;
			elsif winB='1' then
				if ptsB=2 then
					ptsB <= 3;
					newgame <= '1';
					if gmB=1 then
						gmB <= 2;
						over <= '1';
						champ <= 2;
					else
						gmB <= gmB+1;
					end if;
				else
					ptsB <= ptsB+1;
				end if;
			end if;
		end if;
	end process;

	process(st,over,champ,blink)
	begin
		LEDG <= "0000000000";
		if over='1' then
			if blink='1' then
				if champ=1 then
					LEDG(9 downto 5) <= "11111";
				else
					LEDG(4 downto 0) <= "11111";
				end if;
			end if;
		else
			for i in 0 to 9 loop
				if st = 10-i or st = 10+i then
					LEDG(i) <= '1';
				end if;
			end loop;
		end if;
	end process;

	U3:Seg7 port map(gmA,HEX3_D);
	U2:Seg7 port map(ptsA,HEX2_D);
	U1:Seg7 port map(ptsB,HEX1_D);
	U0:Seg7 port map(gmB,HEX0_D);
	HEX0_DP <= '1';
	HEX1_DP <= '1';
	HEX2_DP <= '1';
	HEX3_DP <= '1';

end PingPong;
