library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    use IEEE.std_logic_unsigned.all;
    use IEEE.std_logic_arith.all;
library work;

entity divider is
    generic (
        len: integer := 2
    );
    port (
        clk: in  std_logic;
        rst: in  std_logic;
        clk_out : out std_logic
    );
end entity;

architecture rtl of divider is
    signal p_time_count : integer;
begin
    main : process(clk,rst)
    begin
        if (rst='1') then
            p_time_count <= 0;
            clk_out <= '0';
        elsif (clk = '1' and clk'Event)then
            if (p_time_count = len-1) then
                p_time_count <= 0;
                clk_out <= '1';
            else
                p_time_count <= p_time_count + 1;
                clk_out <= '0';
            end if;
        end if;
    end process main;

end architecture;