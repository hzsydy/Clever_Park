library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    use IEEE.std_logic_unsigned.all;
    use IEEE.std_logic_arith.all;
    
entity HCSR04 is
    port (
        clk: in  std_logic;
        rst: in  std_logic;
        --I/O port
        trig: out std_logic;
        echo: in  std_logic;
        dist: out std_logic_vector(15 downto 0)
        --logic port
        trig_en: in std_logic;
        ready: out std_logic
		
    );
end entity;

architecture rtl of HCSR04 is
    signal in_impulse:std_logic := '0';
    signal in_calc:std_logic :='0';
begin
    main : process(clk,rst)
        variable lengthofimpulse :integer range 0 to 13107100:= 0;
        variable calc_time : integer range 0 to 13107100 := 0;
    begin
        if (rst = '1') then
            trig <= '0';
            ready <= '0';
            dist <= "0000000000000000";
			ready <='0';
            lengthofimpulse := 0;
        elsif (clk = '1' and clk'event)then
            if (trig_en = '1' and in_impulse = '0') then
                lengthofimpulse:=0;
                trig <= '1';
                in_impulse <= '1';
            end if;
            if (in_impulse = '1') then
                lengthofimpulse :=lengthofimpulse + 1;
                if (lengthofimpulse = 1000) then
                    lengthofimpulse:=0;
                    trig <= '0';
                    in_impulse <= '0';
                end if;
            end if;
            if (echo = '1' and in_calc = '0') then
                calc_time := 0;
                in_calc <='1';
            elsif(echo = '1') then
                calc_time:=calc_time + 1;
            end if;
            if (echo = '0' and in_calc = '1') then
                dist <= conv_std_logic_vector(calc_time/2900, 15);
					 ready <='1';
                calc_time := 0;
                in_calc <= '0';
            end if;
        end if;
    end process;
end architecture;
