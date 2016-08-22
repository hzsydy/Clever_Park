library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity counter19 is 
	port(clk:in std_logic;
		clr:in std_logic;
		q:out integer range 0 to 1048576);
end counter19;

architecture behav of counter19 is
begin
	process(clk,clr) 
	variable q1:integer range 0 to 1048576;
	begin
		if (clr='0') then
		q1:=0;
		elsif (clk'event and clk='1') then
		q1:=q1+1;
		end if;
		q<=q1;
	end process;
end behav;