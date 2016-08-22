library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

entity byte2led is
    port (
        cs: in std_logic;
        byte : in std_logic_vector(7 downto 0);
        led7 : out std_logic;
        led6 : out std_logic;
        led5 : out std_logic;
        led4 : out std_logic;
        led3 : out std_logic;
        led2 : out std_logic;
        led1 : out std_logic;
        led0 : out std_logic
    );
end entity;

architecture rtl of byte2led is
begin
    main:process(cs)
    begin
        if (cs = '1') then
            led7 <= byte(7);
            led6 <= byte(6);
            led5 <= byte(5);
            led4 <= byte(4);
            led3 <= byte(3);
            led2 <= byte(2);
            led1 <= byte(1);
            led0 <= byte(0);
        end if;
    end process;
end architecture;