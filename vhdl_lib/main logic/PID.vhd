library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

entity PID is
    generic (
        Kp : integer := 6;        --proportional constant
        Ki : integer := 0;        --integral constant
        Kd : integer := 0;        --differential constant
        K_base : integer := 64;        --dividend of K*
        BUFFER_LEN : integer := 16;        --buffer of inter vars
        INPUT_LEN : integer := 8;
        OUTPUT_LEN : integer := 8
    );
    port (
        clk: in  std_logic;
        rst: in  std_logic;
        input : in std_logic_vector(INPUT_LEN-1 downto 0);
        goal : in std_logic_vector(INPUT_LEN-1 downto 0);
        output : out std_logic_vector(OUTPUT_LEN-1 downto 0)
    );
end entity;

architecture rtl of PID is
    type state_type is (Reset,        --user defined type to determine the flow of the system
        CalculateNewerror,
        CalculatePID,
        DivideKg,
        SOverload,
        ConvDac,
        Write2DAC
    );
    
    subtype buffer_len_int is integer range -(2**BUFFER_LEN-1) to (2**BUFFER_LEN-1);
    constant max_output : buffer_len_int := 2**OUTPUT_LEN - 1;
    constant min_output : buffer_len_int := 1;
    
    signal state,next_state : state_type := Reset;
    signal output_temp : buffer_len_int := 1;    --intermediate output
    signal lock_input : buffer_len_int := 0 ;    --stores the integer converted value of the input
    signal lock_goal : buffer_len_int := 0 ;    --stores the integer converted value of the input
    signal error: buffer_len_int := 0;        --Stores the deviation of the input from the set point
    signal DataCarrier : std_logic_vector (OUTPUT_LEN-1 downto 0); --contains the binary converted value to be output to the DAC
    
    signal output_old : buffer_len_int := 0;
    signal error_old : buffer_len_int:= 0;
    signal p,i,d : buffer_len_int := 0;    --Contain the proportional, derivative and integral errors respectively

begin
    process(clk, rst, state)        --sensitive to Clock and current state  
    begin
        if clk'event and clk='1' then
            if rst = '1' then
                state <= Reset;
            else
                state <= next_state;
            end if;
        end if;
        case state is
            when Reset =>
                lock_input <= to_integer(unsigned(input));  --Get the input for PID
                lock_goal <= to_integer(unsigned(goal));  --Get the input for PID
                next_state <= CalculateNewerror;
                error_old <= error;  --Capture old error
                output_old <= output_temp;    --Capture old PID output

            when CalculateNewerror =>
                next_state <= CalculatePID;
                error <= to_integer(to_unsigned(lock_goal-lock_input,buffer_len+1));

            when CalculatePID =>
                next_state <= DivideKg;
                p <= Kp * (error);              --Calculate PID
                i <= Ki * (error+error_old);
                d <= Kd * (error-error_old);

            when DivideKg =>
                next_state <= SOverload;
                output_temp <=  output_old+(p+i+d)/K_base; --Calculate new output (/2048 to scale the output correctly)
 
            when SOverload =>
                next_state <= ConvDac;    --done to keep output within 16 bit range
                if output_temp > max_output then
                    output_temp <= max_output ;
                end if;
                if output_temp < min_output then
                    output_temp <= min_output;
                end if;
 
            when ConvDac =>                --Send the output to port
                DataCarrier <= std_logic_vector(to_unsigned(output_temp ,OUTPUT_LEN));
                next_state <= Write2DAC;

            when Write2DAC =>                --send output to the DAC
                next_state <= Reset;
                output <= DataCarrier;
        end case;


    end process;    --end of process
end architecture;