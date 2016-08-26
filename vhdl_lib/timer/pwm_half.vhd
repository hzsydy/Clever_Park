library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

entity pwm_half is
    generic (
        CLK_FREQ: integer := 50000000;    -- Main frequency
        PWM_FREQ : integer := 1000   -- Main frequency
    );
    port (
        clk: in  std_logic;
        rst: in  std_logic;
        
        output : out std_logic
    );
end entity;

architecture rtl of pwm_half is
    component divider is
        generic (
            len: integer := 2
        );
        port (
            clk: in  std_logic;
            rst: in  std_logic;
            clk_out : out std_logic
        );
    end component;
    
    signal reverse : std_logic;
begin
    divider_x : divider
        generic map (
            len => CLK_FREQ/PWM_FREQ/2
        )
        port map (
            clk => clk,
            rst => rst,
            clk_out => reverse
        );
    
    divider_2 : divider
        generic map (
            len => 2
        )
        port map (
            clk => reverse,
            rst => rst,
            clk_out => output
        );
end architecture;