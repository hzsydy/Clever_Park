library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

entity mux413 is
    port (
        in3 : in std_logic_vector(3 downto 0);
        in2 : in std_logic_vector(3 downto 0);
        in1 : in std_logic_vector(3 downto 0);
        in0 : in std_logic_vector(3 downto 0);
        
        cs : in std_logic_vector(3 downto 0);
        
        out3 : out std_logic;
        out2 : out std_logic;
        out1 : out std_logic;
        out0 : out std_logic
    );
end entity;

architecture rtl of mux413 is
begin
    
    main: process(cs, in0, in1, in2, in3)
    begin
    case cs is
        when "1000" => 
            out3 <= in3(3);
            out2 <= in3(2);
            out1 <= in3(1);
            out0 <= in3(0);
        when "0100" => 
            out3 <= in2(3);
            out2 <= in2(2);
            out1 <= in2(1);
            out0 <= in2(0);
        when "0010" => 
            out3 <= in1(3);
            out2 <= in1(2);
            out1 <= in1(1);
            out0 <= in1(0);
        when others => 
            out3 <= in0(3);
            out2 <= in0(2);
            out1 <= in0(1);
            out0 <= in0(0);
    end case;
    end process;
end architecture;