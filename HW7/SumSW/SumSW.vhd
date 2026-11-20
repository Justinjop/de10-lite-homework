library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- 1+2+3+...+n on DE10-Lite, n = SW9 ~ SW0 (0 ~ 1023)
--   KEY0 : show the result at once, n(n+1)/2
--   KEY1 : single step, every press adds the next number
--   LEDR : the number added last (how far the single step has gone)
--   HEX5 ~ HEX0 : sum (largest 1+2+...+1023 = 523776)
-- Changing the switches starts over from 0.
entity SumSW is
	generic(
			LOCK:integer := 500000			-- ignore a key for 10 ms after a press
			);
	port(
			MAX10_CLK1_50:in std_logic;
			KEY:in std_logic_vector(1 downto 0);
			SW:in std_logic_vector(9 downto 0);
			LEDR:out std_logic_vector(9 downto 0);
			HEX0:out std_logic_vector(6 downto 0);
			HEX1:out std_logic_vector(6 downto 0);
			HEX2:out std_logic_vector(6 downto 0);
			HEX3:out std_logic_vector(6 downto 0);
			HEX4:out std_logic_vector(6 downto 0);
			HEX5:out std_logic_vector(6 downto 0)
			);
end SumSW;

architecture SumSW of SumSW is
	component Seg7 is
	port(
			d:in integer range 0 to 15;
			seg:out std_logic_vector(6 downto 0)
			);
	end component;

	-- binary to BCD (shift and add 3)
	function bin2bcd(v:integer) return std_logic_vector is
		variable b:unsigned(19 downto 0) := to_unsigned(v,20);
		variable r:unsigned(23 downto 0) := (others => '0');
	begin
		for k in 0 to 19 loop
			for j in 0 to 5 loop
				if r(4*j+3 downto 4*j) >= 5 then
					r(4*j+3 downto 4*j) := r(4*j+3 downto 4*j) + 3;
				end if;
			end loop;
			r := r(22 downto 0) & b(19);
			b := b(18 downto 0) & '0';
		end loop;
		return std_logic_vector(r);
	end bin2bcd;

	signal clk:std_logic;
	signal sw1,sw2,swd:std_logic_vector(9 downto 0) := (others => '0');	-- synchronizer, previous value
	signal k0a,k0b,k0c,k1a,k1b,k1c:std_logic := '0';
	signal lock0,lock1:integer range 0 to 16777215 := 0;
	signal p0,p1:std_logic := '0';					-- one pulse per key press
	signal n:integer range 0 to 1023;
	signal tri:integer range 0 to 1048575;			-- n(n+1)/2
	signal i:integer range 0 to 1023 := 0;			-- numbers added so far
	signal shown:integer range 0 to 1048575 := 0;	-- sum on the display
	signal bcd:std_logic_vector(23 downto 0);
	signal d0,d1,d2,d3,d4,d5:integer range 0 to 9;
	signal b1,b2,b3,b4,b5:integer range 0 to 15;	-- 15 = blank (no leading zeros)
begin
	clk <= MAX10_CLK1_50;
	n <= to_integer(unsigned(sw2));
	tri <= (n*(n+1))/2;

	-- keys (active low): synchronize, detect a press, ignore bounce
	process(clk)
	begin
		if rising_edge(clk) then
			sw1 <= SW;	sw2 <= sw1;
			k0a <= not KEY(0);	k0b <= k0a;	k0c <= k0b;
			k1a <= not KEY(1);	k1b <= k1a;	k1c <= k1b;
			p0 <= '0';
			p1 <= '0';
			if lock0 > 0 then
				lock0 <= lock0-1;
			elsif k0b='1' and k0c='0' then
				p0 <= '1';
				lock0 <= LOCK;
			end if;
			if lock1 > 0 then
				lock1 <= lock1-1;
			elsif k1b='1' and k1c='0' then
				p1 <= '1';
				lock1 <= LOCK;
			end if;
		end if;
	end process;

	-- sum
	process(clk)
	begin
		if rising_edge(clk) then
			swd <= sw2;
			if sw2 /= swd then					-- switches changed: start over
				i <= 0;
				shown <= 0;
			elsif p0='1' then					-- KEY0: result at once
				i <= n;
				shown <= tri;
			elsif p1='1' then					-- KEY1: one step
				if i < n then
					i <= i+1;
					shown <= shown + (i+1);
				else							-- finished: next press starts again
					i <= 0;
					shown <= 0;
				end if;
			end if;
		end if;
	end process;

	LEDR <= std_logic_vector(to_unsigned(i,10));

	-- display, leading zeros are blank
	bcd <= bin2bcd(shown);
	d0 <= to_integer(unsigned(bcd(3 downto 0)));
	d1 <= to_integer(unsigned(bcd(7 downto 4)));
	d2 <= to_integer(unsigned(bcd(11 downto 8)));
	d3 <= to_integer(unsigned(bcd(15 downto 12)));
	d4 <= to_integer(unsigned(bcd(19 downto 16)));
	d5 <= to_integer(unsigned(bcd(23 downto 20)));
	b5 <= 15 when d5=0 else d5;
	b4 <= 15 when d5=0 and d4=0 else d4;
	b3 <= 15 when d5=0 and d4=0 and d3=0 else d3;
	b2 <= 15 when d5=0 and d4=0 and d3=0 and d2=0 else d2;
	b1 <= 15 when d5=0 and d4=0 and d3=0 and d2=0 and d1=0 else d1;

	U5:Seg7 port map(b5,HEX5);
	U4:Seg7 port map(b4,HEX4);
	U3:Seg7 port map(b3,HEX3);
	U2:Seg7 port map(b2,HEX2);
	U1:Seg7 port map(b1,HEX1);
	U0:Seg7 port map(d0,HEX0);

end SumSW;
