--
-- convert clk to 12MHz
-- Du 2016.5.4
--
library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    use IEEE.std_logic_arith.all;
    use IEEE.std_logic_unsigned.all;

entity clk_12M is
    port (
        clk_50MHz: in  std_logic;
        rst      : in  std_logic;
        clk_12MHz: out std_logic
    );
end entity;

architecture rtl of clk_12M is
    signal clk_out : std_logic := '0';
    
    signal is_4div : std_logic := '0';
    signal cnt_4div : integer range 0 to 5;
    signal cnt: integer range 0 to 5;
begin
    output : process(clk_out)
    begin
        clk_12MHz <= clk_out;
    end process output;
    
    main : process (clk_50MHz, rst)
        variable reverse: std_logic;
    begin
        if (clk_50MHz = '1' and clk_50MHz'event) then
            if (rst = '1') then
                is_4div <= '0';
                clk_out <= '0';
                cnt <= 0;
                cnt_4div <= 0;
            else
                reverse := '0';
                if (is_4div = '1') then 
                    if (cnt = 3) then
                        reverse := '1';
                    end if;
                end if;
                if (is_4div = '0') then
                    if (cnt = 4) then
                        reverse := '1';
                    end if;
                end if;
                if (reverse = '1') then
                    cnt <= 0;
                    clk_out <= '1';
                    if (is_4div = '0') then
                        is_4div <= '1';
                        cnt_4div <= 0;
                    else
                        if (cnt_4div = 4) then
                            is_4div <= '0';
                        else 
                            cnt_4div <= cnt_4div + 1;
                        end if;
                    end if;
                else
                    cnt <= cnt + 1;
                    clk_out <= '0';
                end if;
            end if;
        end if;
    end process main;
    
end architecture;