library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    use IEEE.std_logic_unsigned.all;
    use IEEE.std_logic_arith.all;
    
entity motor is
    port (
        clk                 :   in  std_logic;
        rst                 :   in  std_logic;
        --I/O port
        --All work and no play make Jack a dull boy.
        direction_left      :   in std_logic;
        direction_right     :   in std_logic;
        dutycycle_left      :   in std_logic_vector(3 downto 0);
        dutycycle_right     :   in std_logic_vector(3 downto 0);
        Ena                 :   out std_logic;
        out1                :   out std_logic;
        out2                :   out std_logic;
        out3                :   out std_logic;
        out4                :   out std_logic;
        Enb                 :   out std_logic
    );
end entity;

architecture rtl of motor is
signal clk2 :std_logic := '0';

begin
    frequecncy_divider:process(clk) --clk is in basic frequency 50MHz
        variable calc :integer range 0 to 262143 := 0;
    begin
        if(clk = '1' and clk'event) then
            calc := calc + 1;
            if (calc = 200000) then
                calc := 0;
                clk2 <= not clk2;
            end if;
        end if;
    end process;
    
    main:process(clk2,rst)
        variable calcleft       :   integer range 0 to 15 := 0;
        variable calcright      :   integer range 0 to 15 := 0;
        variable percentleft    :   integer range 0 to 15 := 0;
        variable percentright   :   integer range 0 to 15 := 0;
    begin
        if (rst = '1') then
            Ena <= '0';
            Enb <= '0';
            out1 <= '0';
            out2 <= '0';
            out3 <= '0';
            out4 <= '0';
            calcleft := 0;
            calcright := 0;
            percentleft := 0;
            percentright := 0;
        elsif (clk2 = '1' and clk2'event) then
            if (direction_left <= '0') then
                out1 <= '1';
                out2 <= '0';
            elsif(direction_left <= '1') then
                out1 <= '0';
                out2 <= '1';
            end if;
            if (direction_right <= '0') then
                out3 <= '1';
                out4 <= '0';
            elsif(direction_right <= '1') then
                out3 <= '0';
                out4 <= '1';
            end if;
            percentleft := conv_integer(dutycycle_left);
            percentright := conv_integer(dutycycle_right);
            calcleft := calcleft + 1;
            calcright := calcright + 1;
            if (percentleft = 0) then
                Ena <= '0';
            else
                if (calcleft < percentleft) then
                    Ena <= '1';
                else 
                    Ena <= '0';
                end if ;
            end if;
            if (percentright = 0) then
                Enb <= '0';
            else
                if (calcright < percentright) then
                    Enb <= '1';
                else
                    Enb <= '0';
                end if;
            end if;
        end if;
        
    end process;
end architecture;