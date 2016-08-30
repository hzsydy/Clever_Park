library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

entity Locker is
    generic (
        width: integer := 8
    );
    port (
        cs : in std_logic;
        input : in std_logic_vector((width-1) downto 0);
        output : out std_logic_vector((width-1) downto 0)
    );
end entity;

architecture rtl of Locker is
begin
    main:process(cs)
    begin
        if (cs = '1') then
            output <= input;
        end if;
    end process;
end architecture;