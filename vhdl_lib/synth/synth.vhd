library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

entity synth is
    generic (
        CLK_FREQ: integer := 50000000    -- Main frequency 
    );
    port (
        clk: in  std_logic;
        rst: in  std_logic;
        --logic port
        trig0_stop: in std_logic;
        trig1_alart: in std_logic;
        --I/O port
        pwm_out: out std_logic
    );
end entity;

architecture rtl of synth is
    component pwm_half is
        generic (
            CLK_FREQ: integer := 50000000;    -- Main frequency
            PWM_FREQ : integer := 1000   -- Main frequency
        );
        port (
            clk: in  std_logic;
            rst: in  std_logic;

            output : out std_logic
        );
    end component;
    
    signal pwm_392Hz : std_logic;
    signal pwm_294Hz : std_logic;
    signal pwm_1Hz : std_logic;
    
    signal trig1_state : std_logic;
begin
    divider_392Hz : pwm_half
        generic map (
            CLK_FREQ => CLK_FREQ,
            PWM_FREQ => 392
        )
        port map (
            clk => clk,
            rst => rst,
            output => pwm_392Hz
        );
    
    divider_294Hz : pwm_half
        generic map (
            CLK_FREQ => CLK_FREQ,
            PWM_FREQ => 294
        )
        port map (
            clk => clk,
            rst => rst,
            output => pwm_294Hz
        );
    
    divider_1Hz : pwm_half
        generic map (
            CLK_FREQ => CLK_FREQ*2,
            PWM_FREQ => 1
        )
        port map (
            clk => clk,
            rst => rst,
            output => trig1_state
        );
   
    
    main : process(clk)
    begin   
        if (clk = '1' and clk'event) then
            if trig0_stop = '1' then
                pwm_out <= '0';
            elsif trig1_alart = '1' then
                if trig1_state = '0' then
                    pwm_out <= pwm_392Hz;
                elsif trig1_state = '1' then
                    pwm_out <= pwm_294Hz;
                end if;
            else
                pwm_out <= '0';
                    --pwm_out <= pwm_294Hz;
            end if;
        end if;
    end process main;
end architecture;