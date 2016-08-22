library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

entity synth is
    port (
        clk: in  std_logic;
        rst: in  std_logic;
        --logic port
        freq: in  std_logic;
        --I/O port
        pwm_out: out std_logic
    );
end entity;

architecture rtl of synth is
begin
end architecture;