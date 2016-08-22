library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;
    use IEEE.std_logic_unsigned.all;
    use IEEE.std_logic_arith.all;

entity UART is
    generic (
        CLK_FREQ: integer := 12;    -- Main frequency (MHz)
        baudrate: integer := 9600;  -- Baud rate (bps)
        par_en  : std_logic := '0';  -- Parity bit enable
        sb_one : std_logic := '1' -- stop bit one
    );
    port (
        --debug
        --clock_en      :    buffer std_logic;
        --rx_par_bit    :    buffer std_logic;
        --rx_data_tmp   :    buffer std_logic_vector(7 downto 0);
        --rx_data_cnt   :    buffer integer range 0 to 8-1;
        --tx_par_bit    :    buffer std_logic;
        --tx_data_tmp   :    buffer std_logic_vector(7 downto 0);
        --tx_data_cnt   :    buffer integer range 0 to 8-1;

        -- Control
        clk         : in    std_logic;        -- Main clock
        rst         : in    std_logic;        -- Main reset
        -- External Interface
        rx          : in    std_logic;        -- RS232 received serial data
        tx          : out    std_logic;        -- RS232 transmitted serial data
        -- uPC Interface
        tx_req      : in    std_logic;                        -- Request SEND of data
        tx_end      : out    std_logic;                        -- Data SENDED
        tx_data     : in    std_logic_vector(7 downto 0);    -- Data to transmit
        rx_ready    : out    std_logic;                        -- Received data ready to uPC read
        rx_data     : out    std_logic_vector(7 downto 0)    -- Received data
    );
end entity;

architecture rtl of UART is
    -- Constants
    constant UART_IDLE   :    std_logic := '1';
    constant UART_START  :    std_logic := '0';
    constant PARITY_EN   :    std_logic := '1';
    constant STOP_BIT_ONE:    std_logic := '1';
    constant DATA_BITS   :    integer   := 8;

    -- Types
    type state_type is (idle,data,parity,stop1,stop2);            -- Stop1 and Stop2 are inter frame gap

    -- Signals
    signal rx_fsm        :    state_type;                            -- Control of reception
    signal tx_fsm        :    state_type;                            -- Control of transmission
    signal clock_en      :    std_logic;                        -- Internal clock enable

    -- RX Data Temp
    signal rx_par_bit    :    std_logic;
    signal rx_data_tmp   :    std_logic_vector(7 downto 0);
    signal rx_data_cnt   :    integer range 0 to DATA_BITS-1;

    -- TX Data Temp
    signal tx_par_bit    :    std_logic;
    signal tx_data_tmp   :    std_logic_vector(7 downto 0);
    signal tx_data_cnt   :    integer range 0 to DATA_BITS-1;
begin
    clock_manager:process(clk)
        variable counter : integer range 0 to conv_integer((CLK_FREQ*1_000_000)/baudrate-1);
    begin
        if clk'event and clk = '1' then
            -- Normal Operation
            if counter = (CLK_FREQ*1_000_000)/baudrate-1 then
                clock_en <= '1';
                counter  := 0;
            else
                clock_en <= '0';
                counter := counter + 1;
            end if;
            -- Reset condition
            if rst = '1' then
                counter := 0;
            end if;
        end if;
    end process;

    tx_proc:process(clk)
    begin
        if clk'event and clk = '1' then
            if clock_en = '1' then
                -- Reset condition
                if rst = '1' then
                    tx                <=    UART_IDLE;
                    tx_fsm            <=    idle;
                    tx_par_bit        <=    '0';
                    tx_data_tmp       <=    (others=>'0');
                    tx_data_cnt       <=    DATA_BITS-1;
                else
                    -- FSM description
                    case tx_fsm is
                    -- Wait to transfer data
                    when idle =>
                        -- Send Init Bit
                        if tx_req = '1' then
                            tx            <=    UART_START;
                            tx_data_tmp   <=    tx_data;
                            tx_fsm        <=    data;
                            tx_data_cnt   <=    DATA_BITS-1;
                            tx_par_bit    <=    '0';
                        else
                            tx            <=    UART_IDLE;
                        end if;
                        tx_end            <=    '0';
                    when data =>
                        -- Data receive
                        tx                <=    tx_data_tmp(0);
                        tx_par_bit        <=    tx_par_bit xor tx_data_tmp(0);
                        if tx_data_cnt = 0 then
                            if par_en = PARITY_EN then
                                tx_fsm    <=    parity;
                            elsif sb_one = STOP_BIT_ONE then
                                tx_fsm    <=    stop2;
                            else
                                tx_fsm    <=    stop1;
                            end if;
                        else
                            tx_data_tmp   <=    '0' & tx_data_tmp(7 downto 1); --SHR 1 bit
                            tx_data_cnt   <=    tx_data_cnt - 1;
                        end if;
                    when parity =>
                        tx                <=    tx_par_bit;
                        if sb_one = STOP_BIT_ONE then
                            tx_fsm        <=    stop2;
                        else
                            tx_fsm        <=    stop1;
                        end if;
                    when stop1 =>
                        -- Send Stop Bit
                        tx                <=    UART_IDLE;
                        tx_fsm            <=    stop2;
                    when stop2 =>
                        -- Send Stop Bit
                        tx_end            <=    '1';
                        tx                <=    UART_IDLE;
                        tx_fsm            <=    idle;
                    end case;
                end if;
            end if;
        end if;
    end process;

    rx_proc:process(clk)
    begin
        if clk'event and clk = '1' then
            if clock_en = '1' then
                -- Reset condition
                if rst = '1' then
                    rx_fsm              <=    idle;
                    rx_ready            <=    '0';
                    rx_data             <=    (others=>'0');
                    rx_data_tmp         <=    (others=>'0');
                    rx_data_cnt         <=    DATA_BITS-1;
                else
                    -- FSM description
                    case rx_fsm is
                        when idle =>
                            -- Wait to transfer data
                            rx_ready <= '0';
                            if rx = UART_START then
                                rx_fsm          <=    data;
                            end if;
                            rx_par_bit          <=    '0';
                            rx_data_cnt         <=    DATA_BITS-1;
                            -- Data receive
                        when data =>
                            rx_ready <= '0';
                            -- Check data to generate parity
                            if par_en = PARITY_EN then
                                rx_par_bit      <=    rx_par_bit xor rx;
                            end if;
                            rx_data_tmp         <=    rx & rx_data_tmp(7 downto 1);
                            if rx_data_cnt = 0 then
                                if par_en = PARITY_EN then
                                    -- With parity verification
                                    rx_fsm      <=    parity;
                                else
                                    -- Without parity verification
                                    rx_fsm      <=    stop1;
                                end if;
                            else
                                rx_data_cnt     <=    rx_data_cnt - 1;
                            end if;
                        when parity =>
                            -- Check received parity
                            if rx_par_bit = rx then
                                rx_fsm          <=    stop2;
                                rx_ready        <=    '1';
                                rx_data         <=    rx_data_tmp;
                            else
                                rx_fsm          <=    idle;
                            end if;
                        when stop1 =>
                            -- Without parity verification;
                            if rx = UART_START then
                                rx_fsm          <=    data;
                            else
                                rx_fsm          <=    stop2;
                            end if;
                            rx_par_bit          <=    '0';
                            rx_data_cnt         <=    DATA_BITS-1;
                            rx_data             <=    rx_data_tmp;
                        when stop2 =>
                            -- wait for rx; fuck jing zheng mao xian
                            rx_ready <= '1';
                            if rx = UART_START then
                                rx_fsm          <=    data;
                            else
                                rx_fsm          <=    idle;
                            end if;
                    end case;
                end if;
            end if;
        end if;
    end process;

end architecture;