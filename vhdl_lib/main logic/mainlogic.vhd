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
        dffo                :   in std_logic_vector(9 downto 0);    --distance from front obstacles, cm
        dfbo                :   in std_logic_vector(9 downto 0);    --distance from back obstacles, cm
        speedl              :   in std_logic_vector(3 downto 0);    --speed of left wheel, r/min
        speedr              :   in std_logic_vector(3 downto 0);    --speed of right wheel, r/min
        numofgarage         :   in std_logic_vector(3 downto 0);    --num of garage
        wirelessout3        :   out std_logic_vector(7 downto 0);   --send message to upper computer
        wirelessout2        :   out std_logic_vector(7 downto 0);   --send message to upper computer
        wirelessout1        :   out std_logic_vector(7 downto 0);   --send message to upper computer
        wirelessout0        :   out std_logic_vector(7 downto 0);   --send message to upper computer
        wirelessin          :   in std_logic_vector(7 downto 0);    --get message from upper computer
        dutycycle_left      :   out std_logic_vector(3 downto 0);
        dutycycle_right     :   out std_logic_vector(3 downto 0);
        

        --logic port
        HCSR04_front_ready  :   in std_logic;
        HCSR04_back_ready   :   in std_logic;
        roc_enc_left_ready  :   in std_logic;
        roc_enc_right_ready :   in std_logic;
        infrared_left       :   in std_logic;
        infrared_right      :   in std_logic;
        rxupper             :   in std_logic;
        directionleft       :   out std_logic;
        directionright      :   out std_logic;
		  
		  fuck                :   out std_logic_vector(1 downto 0)
    );
end entity;

architecture rtl of mainlogic is    --clk = 5000Hz
    
    type state_type is (waiting, yuri, gotogarage, parking, occupancygarage);
    signal parking_num:integer range 0 to 15 := 0;
    signal state : state_type := waiting;
    signal mode : std_logic := '0';
    signal rxup : std_logic := '0';
        
begin
    main:process(clk,rst)
        variable timer :integer range 0 to 262143 := 0;
    begin
        if(rst='1') then
            state <= waiting;
            wirelessout3 <= "00000000";
            wirelessout2 <= "00000000";
            wirelessout1 <= "00000000";
            wirelessout0 <= "00000000";
            rxup <= '0';
        elsif(clk = '1' and clk'event) then
            case state is 
                when waiting =>
                    if (rxupper = '1' and rxup = '0') then
                        rxup <= '1';
                        --go to manual mode
                        if (wirelessin = "00110000") then
                            state <= yuri;
                            directionleft <= '1';
                            directionright <= '0';
                            dutycycle_left <= "0000";
                            dutycycle_right <= "0000";
                        end if;
                    elsif(rxupper = '0' and rxup = '1') then
                        rxup <= '0';
                    end if;
                    fuck <= "11";
                when gotogarage =>fuck <= "01";
                when parking =>fuck <= "01";
                when occupancygarage =>fuck <= "01";
                when yuri =>
                    if (rxupper = '1' and rxup = '0') then
                        rxup <= '1';
                        if (wirelessin = "01010011") then  --'W'
                            timer := 0;
                            directionleft <= '1';
                            directionright <= '0';
                            dutycycle_left <= "0010";
                            dutycycle_right <= "0010";
                        elsif (wirelessin = "01010111") then --'S'
                            timer := 0;
                            directionleft <= '0';
                            directionright <= '1';
                            dutycycle_left <= "0010";
                            dutycycle_right <= "0010";
                        elsif (wirelessin = "01000001") then --'A'
                            timer := 0;
                            directionleft <= '0';
                            directionright <= '1';
                            dutycycle_left <= "0001";
                            dutycycle_right <= "0010";
                        elsif (wirelessin = "01000100") then --'D'
                            timer := 0;
                            directionleft <= '0';
                            directionright <= '1';
                            dutycycle_left <= "0010";
                            dutycycle_right <= "0001";
                        elsif (wirelessin = "01010001") then --'Q' ¼±Í£
                            timer := 0;
                            directionleft <= '0';
                            directionright <= '1';
                            dutycycle_left <= "0000";
                            dutycycle_right <= "0000";
                        end if;
                    elsif(rxupper = '0' and rxup = '1') then
                        rxup <= '0';
                    end if;
                    timer := timer + 1;
                    if (timer = 262143) then
                        timer := 0;
                        directionleft <= '1';
                        directionright <= '0';
                        dutycycle_left <= "0000";
                        dutycycle_right <= "0000";
                    end if;
                    fuck <= "10";
            end case;
        end if;
    end process;
end architecture;