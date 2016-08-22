library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

entity UART_test_module is
    port (
        clk: in  std_logic;
        rst: in  std_logic;
        rx : in  std_logic;
        tx : out std_logic
    );
end entity;

architecture rtl of UART_test_module is
    component UART is
        generic (
            CLK_FREQ: integer := 50;    -- Main frequency (MHz)
            baudrate: integer := 9600;  -- Baud rate (bps)
            par_en  : std_logic := '0';  -- Parity bit enable
            sb_one : std_logic := '1' -- stop bit one
        );
        port (
            --debug
            --rx_par_bit    : buffer  std_logic;
            --rx_data_tmp   : buffer  std_logic_vector(7 downto 0);
            --rx_data_cnt   : buffer  integer range 0 to 8-1;
            --tx_par_bit    : buffer  std_logic;
            --tx_data_tmp   : buffer  std_logic_vector(7 downto 0);
            --tx_data_cnt   : buffer  integer range 0 to 8-1;
            --clock_en      : buffer std_logic;

            --origin
            clk         : in    std_logic;                       -- Main clock
            rst         : in    std_logic;                      -- Main reset
            rx          : in    std_logic;                      -- UART received serial data
            tx          : out   std_logic;                     -- UART transmitted serial data
            tx_req      : in    std_logic;                        -- Request SEND of data
            tx_end      : out   std_logic;                        -- Data SENDED
            tx_data     : in    std_logic_vector(7 downto 0);    -- Data to transmit
            rx_ready    : out   std_logic;                        -- Received data ready to uPC read
            rx_data     : out   std_logic_vector(7 downto 0)    -- Received data
        );
    end component;

    
    signal tx_req      : std_logic;
    signal tx_end      : std_logic;
    signal tx_data     : std_logic_vector(7 downto 0);
    signal rx_ready    : std_logic;
    signal rx_data     : std_logic_vector(7 downto 0);

    --debug
    --signal rx_par_bit    :    std_logic;
    --signal rx_data_tmp   :    std_logic_vector(7 downto 0);
    --signal rx_data_cnt   :    integer range 0 to 8-1;
    --signal tx_par_bit    :    std_logic;
    --signal tx_data_tmp   :    std_logic_vector(7 downto 0);
    --signal tx_data_cnt   :    integer range 0 to 8-1;
    --signal clock_en      :    std_logic;

begin

    --init port map
    init_testbench : UART port map
        (
        --rx_par_bit  => rx_par_bit  ,
        --rx_data_tmp => rx_data_tmp ,
        --rx_data_cnt => rx_data_cnt ,
        --tx_par_bit  => tx_par_bit  ,
        --tx_data_tmp => tx_data_tmp ,
        --tx_data_cnt => tx_data_cnt ,
        --clock_en    => clock_en    ,
        clk        => clk      ,
        rst        => rst      ,
        rx         => rx       ,
        tx         => tx       ,
        tx_req     => tx_req   ,
        tx_end     => tx_end   ,
        tx_data    => tx_data  ,
        rx_ready   => rx_ready ,
        rx_data    => rx_data
    );

    --UART process code
    --get rx and then send the same back
    echo : process(rx_ready)
    begin
        if (rx_ready = '1') then
            tx_req <= '1';
            tx_data <= rx_data;
        else
            tx_req <= '0';
            tx_data <= (others => '0');
        end if;
    end process;

end architecture;