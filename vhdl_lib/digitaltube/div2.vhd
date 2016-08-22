library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity div2 is 
	port(clk:in std_logic;
		c:out std_logic);
end div2;

architecture structure of div2 is
signal reset:std_logic;
signal sum:integer range 0 to 1048576:=0;

component counter19
port(clk:in std_logic;
		clr:in std_logic;
		q:out integer range 0 to 1048576);
end component;
begin
	U0:counter19 port map
	(
	clr=>reset,
	q=>sum,
	clk=>clk
	);
	process (clk)
	variable q1:std_logic;
	begin
		if (clk'event and clk='1') then
			if (sum>=4000) then
				reset <= '0';
				q1:=not q1;
			elsif (reset='0') then
				reset <='1';
			end if;
		end if;
		c<=q1;
	end process;
end structure;