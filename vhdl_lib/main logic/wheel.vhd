library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

entity wheel is
    generic (
        INPUT_LEN : integer := 8;
        OUTPUT_LEN : integer := 8;
        START_VEL : std_logic_vector := "01100000"
    );
    
    port (
        clk: in  std_logic;
        rst: in  std_logic;
        
        input: in std_logic_vector(INPUT_LEN - 1 downto 0);
        goal: in std_logic_vector(INPUT_LEN - 1 downto 0);
        output: out std_logic_vector(OUTPUT_LEN - 1 downto 0)

    );
end entity;

architecture rtl of wheel is
    constant Kp: integer := 6;
    constant Ki: integer := 0;
    constant Kd: integer := 0;
    constant K_base: integer := 64;
    constant buffer_len: integer := 16;
    
    constant input_zero : std_logic_vector(INPUT_LEN - 1 downto 0)
        := std_logic_vector(to_unsigned(0, INPUT_LEN));
    constant output_zero : std_logic_vector(OUTPUT_LEN - 1 downto 0) 
        := std_logic_vector(to_unsigned(0, OUTPUT_LEN));

    --signal pid_rst: std_logic;
    --signal pid_input: std_logic_vector(INPUT_LEN - 1 downto 0);
    --signal pid_goal: std_logic_vector(INPUT_LEN - 1 downto 0);
    signal pid_output: std_logic_vector(OUTPUT_LEN - 1 downto 0);
begin
    PID_inst: entity work.PID
        generic map (
            Kp         => Kp,
            Ki         => Ki,
            Kd         => Kd,
            K_base     => K_base,
            buffer_len => buffer_len,
            INPUT_LEN  => INPUT_LEN,
            OUTPUT_LEN => OUTPUT_LEN
        )
        port map (
            clk        => clk,
            rst        => rst,
            input      => input,
            goal       => goal,
            output     => pid_output
        );
    
    main : process(clk, rst)
    begin
        if rst = '1' then
            output <= output_zero;
        elsif clk = '1' and clk'event then
            if input = input_zero then 
                if goal = input_zero then
                    output <= output_zero;
                else
                    output <= START_VEL;
                end if;
            else
                output <= pid_output;
            end if;
        end if;
    end process main;
    
    
end architecture;