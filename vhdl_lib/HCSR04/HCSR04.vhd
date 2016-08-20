library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

entity HCSR04 is
    port (
        clk: in  std_logic;
        rst: in  std_logic;
        --I/O port
        trig: out std_logic;
        echo: in  std_logic;
        --logic port
        trig_en: in std_logic;
        ready: out std_logic;
        result: out std_logic
    );
end entity;

architecture rtl of HCSR04 is
begin
    
end architecture;