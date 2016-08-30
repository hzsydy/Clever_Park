library IEEE;
    use IEEE.std_logic_1164.all;
    use IEEE.numeric_std.all;

entity parallel2serial is
    port (
        clk : in std_logic;
        rst : in std_logic;
        
        par_in1: in  std_logic_vector(7 downto 0);
        par_in2: in  std_logic_vector(7 downto 0);
        par_in3: in  std_logic_vector(7 downto 0);
        par_in4: in  std_logic_vector(7 downto 0);
        ser_out: out std_logic_vector(7 downto 0);
        
        req: in  std_logic;
        ready: out std_logic;
        
        uart_tx_req : out std_logic;
        uart_tx_end : in  std_logic
    );
end entity;

architecture rtl of parallel2serial is
    -- Types
    type state_type is (
        waiting,
        par1,
        par2,
        par3,
        par4,
        stop1,
        stop2,
        done
    );

    signal state : state_type;
    
    signal lock_txend_en : std_logic;
    signal lock_txend : std_logic;
    
    signal lock_par_in1 : std_logic_vector(7 downto 0);
    signal lock_par_in2 : std_logic_vector(7 downto 0);
    signal lock_par_in3 : std_logic_vector(7 downto 0);
    signal lock_par_in4 : std_logic_vector(7 downto 0);
begin
    
    lock_tx_end : process(uart_tx_end)
    begin
        lock_txend <= lock_txend_en and (lock_txend or uart_tx_end);
    end process;
        
        
    fsm : process(clk)
    begin
        if rst = '1' then
            state             <=    waiting;
            ready             <=    '0';
            uart_tx_req       <=    '0';
        else
            if clk = '1' and clk'event then
                -- FSM description
                case state is
                when waiting =>
                    ready         <=    '0';
                    uart_tx_req   <=    '0';
                    ser_out       <=    "00000000";
                    lock_txend_en <=    '0';
				    if req = '1' then
                        state             <=    par1;
                        lock_par_in1      <=    par_in1;
                        lock_par_in2      <=    par_in2;
                        lock_par_in3      <=    par_in3;
                        lock_par_in4      <=    par_in4;
                    else
                        state             <=    waiting;
                    end if;
                when par1 =>
                    state         <=    par2;
                    ser_out       <=    lock_par_in1;
                    uart_tx_req   <=    '1';
                when par2 =>
                    if lock_txend = '1' then
                        state         <=    par3;
                        ser_out       <=    lock_par_in2;
                        uart_tx_req   <=    '1';
                        lock_txend_en <=    '0';
                    else
                        state         <=    par2;
                        uart_tx_req   <=    '0';
                        lock_txend_en <=    '1';
                    end if;
                when par3 =>
                    if lock_txend = '1' then
                        state         <=    par4;
                        ser_out       <=    lock_par_in3;
                        uart_tx_req   <=    '1';
                        lock_txend_en <=    '0';
                    else
                        state         <=    par3;
                        uart_tx_req   <=    '0';
                        lock_txend_en <=    '1';
                    end if;
                when par4 =>
                    if lock_txend = '1' then
                        state         <=    stop1;
                        ser_out       <=    lock_par_in4;
                        uart_tx_req   <=    '1';
                        lock_txend_en <=    '0';
                    else
                        state         <=    par4;
                        uart_tx_req   <=    '0';
                        lock_txend_en <=    '1';
                    end if;
                when stop1 =>
                    if lock_txend = '1' then
                        state         <=    stop2;
                        ser_out       <=    "00001101";
                        uart_tx_req   <=    '1';
                        lock_txend_en <=    '0';
                    else
                        state         <=    stop1;
                        uart_tx_req   <=    '0';
                        lock_txend_en <=    '1';
                    end if;
                when stop2 =>
                    if lock_txend = '1' then
                        state         <=    done;
                        ser_out       <=    "00001010";
                        uart_tx_req   <=    '1';
                        lock_txend_en <=    '0';
                    else
                        state         <=    stop2;
                        uart_tx_req   <=    '0';
                        lock_txend_en <=    '1';
                    end if;
                when done =>
                    if lock_txend = '1' then
                        state         <=    waiting;
                        ready         <=    '1';
                        uart_tx_req   <=    '0';
                        lock_txend_en <=    '0';
                    else
                        state         <=    done;
                        lock_txend_en <=    '1';
                    end if;
                when others =>
                    null;
                end case;
            end if;
        end if;
    end process;
    
    
end architecture;