library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

entity roc_enc is
    port (
        clk: in  std_logic;
        rst: in  std_logic;
        --I/O port
        io_CLK: in  std_logic;
        io_DT: in  std_logic;
        --logic port
        vel : out std_logic
    );
end entity;

architecture rtl of roc_enc is
begin
end architecture;