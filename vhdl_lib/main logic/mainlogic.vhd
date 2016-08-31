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
        dffo                :   in std_logic_vector(7 downto 0);    --distance from front obstacles, cm
        dfbo                :   in std_logic_vector(7 downto 0);    --distance from back obstacles, cm
        speedl              :   in std_logic_vector(7 downto 0);    --speed of left wheel, r/min
        speedr              :   in std_logic_vector(7 downto 0);    --speed of right wheel, r/min
        wirelessout3        :   out std_logic_vector(7 downto 0);   --send message to upper computer
        wirelessout2        :   out std_logic_vector(7 downto 0);   --send message to upper computer
        wirelessout1        :   out std_logic_vector(7 downto 0);   --send message to upper computer
        wirelessout0        :   out std_logic_vector(7 downto 0);   --send message to upper computer
        wirelessin          :   in std_logic_vector(7 downto 0);    --get message from upper computer
        dutycycle_left      :   out std_logic_vector(7 downto 0);
        dutycycle_right     :   out std_logic_vector(7 downto 0);


        --logic port
        infrared_left1      :   in std_logic;
        infrared_left2      :   in std_logic;
        infrared_right1     :   in std_logic;
        infrared_right2     :   in std_logic;
        rxupper             :   in std_logic;
        directionleft       :   out std_logic;
        directionright      :   out std_logic;
        outputupperready    :   out std_logic;


        fuck                :   out std_logic_vector(1 downto 0)
    );
end entity;

architecture rtl of mainlogic is    --clk = 500kHz
    constant INFRARED_BLACK   :    std_logic := '1';
    constant INFRARED_WHITE   :    std_logic := '0';
    constant ZERO : std_logic_vector(7 downto 0):="00000000";

    constant SPEED_VERYHIGH : std_logic_vector(7 downto 0):="00011100";
    constant SPEED_HIGH : std_logic_vector(7 downto 0):="00010000";
    constant SPEED_LOW : std_logic_vector(7 downto 0):="00001100";


    type state_type is (waiting, yuri, gotogarage, parking, occupancygarage);

    signal state : state_type := waiting;
    signal rxup : std_logic := '0';
    signal state_car : std_logic_vector(1 downto 0):="00";
    signal direction : std_logic := '0';

begin

    wirelessout0 <= (infrared_left1,infrared_left2,infrared_right2,infrared_right1,'0','0','0','0');
    wirelessout1 <= speedr;
    wirelessout2 <= speedl;
    wirelessout3 <= dffo;


    main:process(clk,rst)
        variable timerformotor :integer range 0 to 8388607 := 0;
        --variable timer:integer range 0 to 262143 := 0;
    begin
        if(rst='1') then
            state <= waiting;
            timerformotor := 0;
            rxup <= '0';
        elsif(clk = '1' and clk'event) then

            case state is
                when waiting =>
                    if (rxupper = '1' and rxup = '0') then
                        rxup <= '1';
                        --go to manual mode
                        if (wirelessin = "00110000") then
                            state <= yuri;
                            directionleft <= '0';
                            directionright <= '1';
                            dutycycle_left <= ZERO;
                            dutycycle_right <= ZERO;
                        elsif (wirelessin = "00110001") then
                            state <= gotogarage;
                            state_car <= "11";
                            directionleft <= '0';
                            directionright <= '1';
                            dutycycle_left <= SPEED_HIGH;
                            dutycycle_right <= SPEED_HIGH;
                        end if;
                    elsif(rxupper = '0' and rxup = '1') then
                        rxup <= '0';
                    end if;
                    fuck <= "11";
                when gotogarage =>
                    fuck <= "01";
                    if (rxupper = '1' and rxup = '0') then
                        rxup <= '1';
                        --go to manual mode
                        if (wirelessin = "00110000") then
                            state <= yuri;
                            directionleft <= '0';
                            directionright <= '1';
                            dutycycle_left <= ZERO;
                            dutycycle_right <= ZERO;
                        end if;
                    elsif(rxupper = '0' and rxup = '1') then
                        rxup <= '0';
                    end if;
                    if (infrared_right2 = INFRARED_BLACK) then
                        dutycycle_left <= SPEED_LOW;
                        dutycycle_right <= SPEED_VERYHIGH;
                    elsif(infrared_left2 = INFRARED_BLACK) then
                        dutycycle_left <= SPEED_VERYHIGH;
                        dutycycle_right <= SPEED_LOW;
                    else
                        dutycycle_left <= SPEED_HIGH;
                        dutycycle_right <= SPEED_HIGH;
                    end if;

                when parking =>fuck <= "01";
                when occupancygarage =>fuck <= "01";
                when yuri =>
                    timerformotor := timerformotor + 1;
                    if (timerformotor = 524287) then
                        timerformotor := 0;
                        directionleft <= '1';
                        directionright <= '0';
                        dutycycle_left <= ZERO;
                        dutycycle_right <= ZERO;
                    else
                        
                        if (rxupper = '1' and rxup = '0') then
                            rxup <= '1';
                            if (wirelessin = "01010011") then  --'S'
                                timerformotor := 0;
                                directionleft <= '1';
                                directionright <= '0';
                                dutycycle_left <= SPEED_HIGH;
                                dutycycle_right <= SPEED_HIGH;
                            elsif (wirelessin = "01010111") then --'W'
                                timerformotor := 0;
                                directionleft <= '0';
                                directionright <= '1';
                                dutycycle_left <= SPEED_HIGH;
                                dutycycle_right <= SPEED_HIGH;
                            elsif (wirelessin = "01000001") then --'A'
                                timerformotor := 0;
                                directionleft <= '0';
                                directionright <= '1';
                                dutycycle_left <= SPEED_LOW;
                                dutycycle_right <= SPEED_HIGH;
                            elsif (wirelessin = "01000100") then --'D'
                                timerformotor := 0;
                                directionleft <= '0';
                                directionright <= '1';
                                dutycycle_left <= SPEED_HIGH;
                                dutycycle_right <= SPEED_LOW;
                            elsif (wirelessin = "01010001") then --'Q'
                                timerformotor := 0;
                                directionleft <= '0';
                                directionright <= '1';
                                dutycycle_left <= ZERO;
                                dutycycle_right <= ZERO;
                            elsif (wirelessin = "00110001") then --'1'
                                state <= gotogarage;
                                state_car <= "11";
                                directionleft <= '1';
                                directionright <= '0';
                                dutycycle_left <= ZERO;
                                dutycycle_right <= ZERO;
                            end if;
                        elsif(rxupper = '0' and rxup = '1') then
                            rxup <= '0';
                        end if;
                    end if;
                    fuck <= "10";
            end case;
        end if;
    end process;
end architecture;