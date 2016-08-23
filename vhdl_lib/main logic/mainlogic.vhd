library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    use IEEE.std_logic_unsigned.all;
    use IEEE.std_logic_arith.all;

entity mainlogic is
    port (
        clk                 :   in  std_logic;
        rst                 :   in  std_logic;

        --I/O port
        dffo                :   in std_logic_vector(15 downto 0);    --distance from front obstacles, cm
        dfbo                :   in std_logic_vector(15 downto 0);    --distance from back obstacles, cm
        speedl              :   in std_logic_vector(7 downto 0);     --speed of left wheel, r/min
        speedr              :   in std_logic_vector(7 downto 0);     --speed of right wheel, r/min
        numofgarage         :   in std_logic_vector(3 downto 0);    --num of garage

        --logic port
        HCSR04_front_ready  :   in std_logic;
        HCSR04_back_ready   :   in std_logic;
        roc_enc_left_ready  :   in std_logic;
        roc_enc_right_ready :   in std_logic;
        can_parking         :   in std_logic;
        parked              :   out std_logic;                         --sent to occupy a parking lot
        infrared_left       :   in std_logic;
        infrared_right      :   in std_logic;
        open_the_door       :   out std_logic
    );
end entity;

architecture rtl of mainlogic is
    
    type state_type is (waiting, receiving, gotogarage, parking, occupancygarage);
    signal parking_num:integer range 0 to 15 := 0;
    signal state : state_type := waiting;
    
begin
    main:process(clk,rst)
        
    begin
        if(rst='1') then
            state <= waiting;
            parked <= '0';
            
        elsif(clk = '1' and clk'event) then
            case state is 
                when waiting =>
                    if (can_parking='1') then
                        parking_num <= conv_integer(numofgarage);
                        state <= gotogarage;
                        --then rolling the Electric machinery
                    end if;
                when receiving=>
                    if (can_parking='1') then
                        parking_num <= conv_integer(numofgarage);
                        state <= gotogarage;
                    end if;
                when gotogarage =>
                when parking =>
                when occupancygarage =>
                    parked <= '1';
            end case;
        end if;
    end process;
end architecture;