library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SumSW is
	generic(
			LOCK:integer := 500000
			);
	port(
			CLOCK_50:in std_logic;
			BUTTON:in std_logic_vector(2 downto 0);
			SW:in std_logic_vector(9 downto 0);
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
end SumSW;

architecture SumSW of SumSW is
	component Seg7 is
	port(
			d:in integer range 0 to 15;
			seg:out std_logic_vector(6 downto 0)
			);
	end component;

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
	signal sw1,sw2,swd:std_logic_vector(9 downto 0) := (others => '0');
	signal k0a,k0b,k0c,k1a,k1b,k1c:std_logic := '0';
	signal h1,h2:std_logic := '0';
	signal lock0,lock1:integer range 0 to 16777215 := 0;
	signal p0,p1:std_logic := '0';
	signal n:integer range 0 to 1023;
	signal tri:integer range 0 to 1048575;
	signal i:integer range 0 to 1023 := 0;
	signal shown:integer range 0 to 1048575 := 0;
	signal bcd:std_logic_vector(23 downto 0);
	signal d0,d1,d2,d3,d4,d5:integer range 0 to 9;
	signal big:std_logic;
	signal s0,s1,s2,s3,hi1:integer range 0 to 15;
begin
	clk <= CLOCK_50;
	n <= to_integer(unsigned(sw2));
	tri <= (n*(n+1))/2;

	process(clk)
	begin
		if rising_edge(clk) then
			sw1 <= SW;	sw2 <= sw1;
			h1 <= not BUTTON(2);	h2 <= h1;
			k0a <= not BUTTON(0);	k0b <= k0a;	k0c <= k0b;
			k1a <= not BUTTON(1);	k1b <= k1a;	k1c <= k1b;
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

	process(clk)
	begin
		if rising_edge(clk) then
			swd <= sw2;
			if sw2 /= swd then
				i <= 0;
				shown <= 0;
			elsif p0='1' then
				i <= n;
				shown <= tri;
			elsif p1='1' then
				if i < n then
					i <= i+1;
					shown <= shown + (i+1);
				else
					i <= 0;
					shown <= 0;
				end if;
			end if;
		end if;
	end process;

	LEDG <= std_logic_vector(to_unsigned(i,10));

	bcd <= bin2bcd(shown);
	d0 <= to_integer(unsigned(bcd(3 downto 0)));
	d1 <= to_integer(unsigned(bcd(7 downto 4)));
	d2 <= to_integer(unsigned(bcd(11 downto 8)));
	d3 <= to_integer(unsigned(bcd(15 downto 12)));
	d4 <= to_integer(unsigned(bcd(19 downto 16)));
	d5 <= to_integer(unsigned(bcd(23 downto 20)));
	big <= '1' when d5 /= 0 or d4 /= 0 else '0';

	s3 <= 15 when h2='1' else
	      15 when big='0' and d3=0 else d3;
	s2 <= 15 when h2='1' else
	      15 when big='0' and d3=0 and d2=0 else d2;
	hi1 <= 15 when d5=0 else d5;
	s1 <= hi1 when h2='1' else
	      15 when big='0' and d3=0 and d2=0 and d1=0 else d1;
	s0 <= d4 when h2='1' else d0;

	U3:Seg7 port map(s3,HEX3_D);
	U2:Seg7 port map(s2,HEX2_D);
	U1:Seg7 port map(s1,HEX1_D);
	U0:Seg7 port map(s0,HEX0_D);
	HEX0_DP <= '1';
	HEX1_DP <= '1';
	HEX2_DP <= '1';
	HEX3_DP <= '0' when big='1' and h2='0' else '1';

end SumSW;
