library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

entity SCC is
    port (
        clk: in  std_logic;
        
        cs : out std_logic_vector(3 downto 0)
    );
end entity;

architecture rtl of SCC is
    signal gen : std_logic_vector(3 downto 0) :=  "1000";

begin

    private2public : block
    begin
        cs <= gen;
    end block private2public;

    main : process (clk)
    begin
        if (clk = '1' and clk'Event) then
            --next row_gen
            if (gen = "1000") then
                gen <= "0100";
            elsif (gen = "0100") then
                gen <= "0010";
            elsif (gen = "0010") then
                gen <= "0001";
            elsif (gen = "0001") then
                gen <= "1000";
            else
                gen <= "1000";
            end if;
        end if;
    end process main;
end architecture;