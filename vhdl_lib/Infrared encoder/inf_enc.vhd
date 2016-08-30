library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    use IEEE.std_logic_unsigned.all;
    use IEEE.std_logic_arith.all;


entity inf_enc is
    port (
        clk         : in  std_logic;
        rst         : in  std_logic;
        
        --I/O port
        vel         : out std_logic_vector(7 downto 0);
        
        --logic port
        fk          : in std_logic
    );
end entity;

architecture rtl of inf_enc is
    signal lastfk : std_logic := '0';
begin
    main:process(clk, rst)
        variable timer :integer range 0 to 65535 :=0;
        variable num :integer range 0 to 255 := 0;
    begin
        if (rst = '1') then
            vel <="00000000";
            timer := 0;
            lastfk <= '0';  
            num := 0;
        elsif (clk = '1' and clk'event) then
            timer := timer + 1;
            if (timer = 50000) then
                timer := 0;
                vel <= conv_std_logic_vector(num , 8);
					 num := 0;
            end if;
            if (lastfk = '1' and fk = '0') then
                lastfk <= '0';
            elsif(lastfk = '0' and fk = '1') then
                lastfk <= '1';
                num := num + 1;
            end if;
        end if;
    end process;
end architecture;