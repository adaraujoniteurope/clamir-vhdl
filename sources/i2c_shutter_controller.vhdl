library ieee;
library work;

use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.all;

entity i2c_shutter_controller is
    GENERIC(

        repetitions           : integer := 0;
        clk_startup_delay     : integer := 1;

        clk_frequency         : integer := 100000000;
        i2c_frequency         : integer := 100000;
        
        cmd_tune_addr         : std_logic_vector(7 downto 0) := x"08";
        cmd_tune_value        : std_logic_vector(7 downto 0) := x"00";
        
        cmd_open_addr         : std_logic_vector(7 downto 0) := x"17";
        cmd_open_value        : std_logic_vector(7 downto 0) := x"01";
        
        cmd_close_addr        : std_logic_vector(7 downto 0) := x"17";
        cmd_close_value       : std_logic_vector(7 downto 0) := x"00"

    );

    Port (
        
        clk  : in std_logic;
        rst : in std_logic;

        scl_o: out std_logic := '0';
        scl_i: in std_logic;
        scl_t: out std_logic := '1';

        sda_o: out std_logic := '0';
        sda_i: in std_logic;
        sda_t: out std_logic := '1';
        
        cmd_open           : in std_logic     := '0';
        cmd_close          : in std_logic     := '0';
        cmd_tune           : in std_logic     := '0';

        -- TODO: not implemented right now,
        -- shutter can't be reset by software.
        -- cmd_reset          : in std_logic     := '0';

        shutter_nreset : out  std_logic   := '0'

     );

    type i2c_shutter_ctrl_type is (
        I2C_SHUTTER_CTRL_IDLE,

        I2C_SHUTTER_CTRL_STARTUP_START,
        I2C_SHUTTER_CTRL_STARTUP,
        I2C_SHUTTER_CTRL_STARTUP_END,

        I2C_SHUTTER_CTRL_TUNE_START,
        I2C_SHUTTER_CTRL_TUNE_SEND_BYTE_START,
        I2C_SHUTTER_CTRL_TUNE_SEND_BYTE,
        I2C_SHUTTER_CTRL_TUNE_SEND_BYTE_WAIT_READY,
        I2C_SHUTTER_CTRL_TUNE_END,        

        I2C_SHUTTER_CTRL_OPEN_START,
        I2C_SHUTTER_CTRL_OPEN_SEND_BYTE_START,
        I2C_SHUTTER_CTRL_OPEN_SEND_BYTE,
        I2C_SHUTTER_CTRL_OPEN_SEND_BYTE_WAIT_READY,
        I2C_SHUTTER_CTRL_OPEN_END,

        I2C_SHUTTER_CTRL_CLOSE_START,
        I2C_SHUTTER_CTRL_CLOSE_SEND_BYTE_START,
        I2C_SHUTTER_CTRL_CLOSE_SEND_BYTE,
        I2C_SHUTTER_CTRL_CLOSE_SEND_BYTE_WAIT_READY,
        I2C_SHUTTER_CTRL_CLOSE_END
    );

    type i2c_shutter_command_sequence is array (integer range<>) of std_logic_vector(7 downto 0);

end i2c_shutter_controller;

architecture rtl of i2c_shutter_controller is

ATTRIBUTE X_INTERFACE_INFO : STRING;
ATTRIBUTE X_INTERFACE_INFO OF SDA_I: SIGNAL IS "xilinx.com:interface:iic:1.0 IIC SDA_I";
ATTRIBUTE X_INTERFACE_INFO OF SDA_O: SIGNAL IS "xilinx.com:interface:iic:1.0 IIC SDA_O";
ATTRIBUTE X_INTERFACE_INFO OF SDA_T: SIGNAL IS "xilinx.com:interface:iic:1.0 IIC SDA_T";
ATTRIBUTE X_INTERFACE_INFO OF SCL_I: SIGNAL IS "xilinx.com:interface:iic:1.0 IIC SCL_I";
ATTRIBUTE X_INTERFACE_INFO OF SCL_O: SIGNAL IS "xilinx.com:interface:iic:1.0 IIC SCL_O";
ATTRIBUTE X_INTERFACE_INFO OF SCL_T: SIGNAL IS "xilinx.com:interface:iic:1.0 IIC SCL_T";
    
    
constant clk_prescaler : integer := clk_frequency/i2c_frequency;

constant i2c_shutter_command_tune_sequence : i2c_shutter_command_sequence(3 downto 0) := (
    x"00",
    cmd_tune_value,
    cmd_tune_addr,
    x"a4"
);

constant i2c_shutter_command_open_sequence : i2c_shutter_command_sequence(3 downto 0) := (
    x"00",
    cmd_open_value,
    cmd_close_addr,
    x"a4"
);

constant i2c_shutter_command_close_sequence : i2c_shutter_command_sequence(3 downto 0) := (
    x"00",
    cmd_close_value,
    cmd_close_addr,
    x"a4"
);

signal i2c_shutter_command_counter : integer := 0;

signal i2c_shutter_ctrl_state : i2c_shutter_ctrl_type := I2C_SHUTTER_CTRL_STARTUP_START;

signal i2c_shutter_command_last : std_logic_vector(2 downto 0) := b"000";
signal i2c_shutter_command : std_logic_vector(2 downto 0);

signal i2c_shutter_startup_delay_threshold  : std_logic_vector(31 downto 0) := std_logic_vector(to_unsigned(clk_prescaler, 32));
signal i2c_shutter_startup_delay_counter    : std_logic_vector(31 downto 0) := x"00000000";

signal i2c_xfer_start : std_logic := '0';
signal i2c_xfer_stop : std_logic := '0';
signal i2c_xfer_wr_nrd : std_logic := '0';

signal i2c_xfer_wr_byte_ack : std_logic := '0';
signal i2c_xfer_wr_byte_done : std_logic := '0';
signal i2c_xfer_wr_byte : std_logic_vector(7 downto 0) := ( others => '0' );

signal i2c_xfer_rd_byte_done : std_logic := '0';
signal i2c_xfer_rd_byte_ack : std_logic := '0';
signal i2c_xfer_rd_byte : std_logic_vector(7 downto 0) := ( others => '0' );

signal i2c_xfer_rst : std_logic := '1';
signal i2c_xfer_clk : std_logic := '0';

component i2c_xfer is
    Port (
       clk              : in    std_logic;
       rst              : in    std_logic;

       i2c_start        : in   std_logic := '0';
       i2c_stop         : in   std_logic := '0';

       i2c_wr_nrd       : in   std_logic := '0';

       i2c_wr_byte_ack  : out  std_logic := '0';
       i2c_wr_byte_done : out  std_logic := '0';
       i2c_wr_byte      : in   std_logic_vector(7 downto 0) := ( others => '0' );

       i2c_rd_byte_ack  : out  std_logic := '0';
       i2c_rd_byte_done : out  std_logic := '0';
       i2c_rd_byte      : out  std_logic_vector(7 downto 0) := ( others => '0' );
       
       scl_o            : out   std_logic := '0';
       scl_i            : in    std_logic;
       scl_t            : out   std_logic := '1';
       
       sda_o            : out   std_logic := '0';
       sda_i            : in    std_logic;
       sda_t            : out   std_logic := '1'
   );
end component;

component i2c_prescaler is

    port (
        clkin   : in std_logic;
        rst     : in std_logic;
        clkout  : out std_logic;
        clkout_threshold : in std_logic_vector(31 downto 0)
      );

end component;

begin

    i2c_prescaler_0 : i2c_prescaler port map(
        clkin => clk,
        rst => rst,
        clkout => i2c_xfer_clk,
        clkout_threshold => std_logic_vector(to_unsigned(clk_prescaler, 32))
    );

    i2c_xfer_0 : i2c_xfer port map(
        clk => i2c_xfer_clk,
        rst => i2c_xfer_rst,
    
        i2c_start => i2c_xfer_start,
        i2c_stop => i2c_xfer_stop,
    
        i2c_wr_nrd => i2c_xfer_wr_nrd,
    
        i2c_wr_byte_ack => i2c_xfer_wr_byte_ack,
        i2c_wr_byte_done => i2c_xfer_wr_byte_done,
        i2c_wr_byte => i2c_xfer_wr_byte,
    
        i2c_rd_byte_ack => i2c_xfer_rd_byte_ack,
        i2c_rd_byte_done => i2c_xfer_rd_byte_done,
        i2c_rd_byte => i2c_xfer_rd_byte,
        
        scl_o => scl_o,
        scl_i => scl_i,
        scl_t => scl_t,
        
        sda_o => sda_o,
        sda_i => sda_i,
        sda_t => sda_t
    );

    -- notes:
    -- ignore open/close command when TUNE requested
    -- it's necesary
    i2c_shutter_command <= cmd_tune & cmd_open & cmd_close;

p_ctrl: process(i2c_xfer_clk, rst) begin

    if (rising_edge(i2c_xfer_clk)) then

        if (rst = '1') then
            i2c_shutter_startup_delay_threshold <= std_logic_vector(to_unsigned(clk_frequency/1000*clk_startup_delay, 32));
            i2c_shutter_startup_delay_counter <= x"00000000";
            i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_STARTUP_START;
            i2c_xfer_rst <= '1';
        else

            case(i2c_shutter_ctrl_state) is
    
                when I2C_SHUTTER_CTRL_IDLE =>
                report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_IDLE";

                if (i2c_shutter_command_last /= i2c_shutter_command ) then

                    i2c_shutter_command_last <= i2c_shutter_command;

                    case( i2c_shutter_command ) is
    
                        when "001" =>
                            i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_CLOSE_START;
        
                        when "010" =>
                            i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_OPEN_START;

                        -- notes:
                        -- ignore open/close command when TUNE requested
                        when "100" | "101" | "110" | "111" =>
                            i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_TUNE_START;
        
                        when others =>
                            i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_IDLE;
        
                    end case;

                end if;

                -- start shutter reset sequence
                when I2C_SHUTTER_CTRL_STARTUP_START =>
                    report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_STARTUP_START";
                    
                    shutter_nreset <= '0';
                    i2c_shutter_startup_delay_counter <= x"00000000";

                    i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_STARTUP;
                    
    
                when I2C_SHUTTER_CTRL_STARTUP =>
                    report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_STARTUP";

                    i2c_shutter_startup_delay_counter <= i2c_shutter_startup_delay_counter + 1;
    
                    if (i2c_shutter_startup_delay_counter = i2c_shutter_startup_delay_threshold) then
                        i2c_shutter_startup_delay_counter <= x"00000000";
                        i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_STARTUP_END;
                    end if;
    
                when I2C_SHUTTER_CTRL_STARTUP_END =>
                    report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_STARTUP_END";

                    shutter_nreset <= '1';
                    i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_TUNE_START;

                --- TUNE ---
                when I2C_SHUTTER_CTRL_TUNE_START =>
                    report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_TUNE_START";
                    i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_TUNE_SEND_BYTE_START;
                    i2c_shutter_command_counter <= 0;

                when I2C_SHUTTER_CTRL_TUNE_SEND_BYTE_START =>
                    report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_TUNE_SEND_BYTE_START";

                    if (i2c_shutter_command_counter < i2c_shutter_command_tune_sequence'length) then
                        report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_TUNE_SEND_BYTE: Sending byte " & integer'image(i2c_shutter_command_counter);
                        i2c_xfer_start <= '0';
                        i2c_xfer_stop <= '0';
                        i2c_xfer_rst <= '0';
                        i2c_xfer_wr_nrd <= '1';
                        i2c_xfer_wr_byte <= i2c_shutter_command_tune_sequence(i2c_shutter_command_counter);
                        i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_TUNE_SEND_BYTE;
                    else
                        report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_TUNE_SEND_BYTE: No new bytes";
                        i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_TUNE_END;
                    end if;
    
                when I2C_SHUTTER_CTRL_TUNE_SEND_BYTE =>
                    report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_TUNE_SEND_BYTE";
                    i2c_xfer_start <= '1';
                    i2c_xfer_stop <= '0';
                    i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_TUNE_SEND_BYTE_WAIT_READY;

                when I2C_SHUTTER_CTRL_TUNE_SEND_BYTE_WAIT_READY =>
                report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_TUNE_SEND_BYTE_WAIT_READY";
                    -- send the next byte
                    if (i2c_xfer_wr_byte_done = '1' and i2c_shutter_command_counter = i2c_shutter_command_tune_sequence'length) then
                        i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_TUNE_END;
                    elsif (i2c_xfer_wr_byte_done = '1') then
                        -- i2c_xfer_rst <= '1';
                        i2c_shutter_command_counter <= i2c_shutter_command_counter + 1;
                        i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_TUNE_SEND_BYTE_START;
                    else
                        i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_TUNE_SEND_BYTE_WAIT_READY;
                    end if;
    
                when I2C_SHUTTER_CTRL_TUNE_END =>
                    report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_TUNE_END";

                    i2c_xfer_start <= '0';
                    i2c_xfer_stop <= '1';
                    i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_IDLE;

                --- OPEN ---
                when I2C_SHUTTER_CTRL_OPEN_START =>
                    report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_OPEN_START";
                    i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_OPEN_SEND_BYTE_START;
                    i2c_shutter_command_counter <= 0;

                when I2C_SHUTTER_CTRL_OPEN_SEND_BYTE_START =>
                    report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_OPEN_SEND_BYTE_START";

                    if (i2c_shutter_command_counter < i2c_shutter_command_open_sequence'length) then
                        report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_OPEN_SEND_BYTE: Sending byte " & integer'image(i2c_shutter_command_counter);
                        i2c_xfer_start <= '0';
                        i2c_xfer_stop <= '0';
                        i2c_xfer_rst <= '0';
                        i2c_xfer_wr_nrd <= '1';
                        i2c_xfer_wr_byte <= i2c_shutter_command_open_sequence(i2c_shutter_command_counter);
                        i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_OPEN_SEND_BYTE;
                    else
                        report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_OPEN_SEND_BYTE: No new bytes";
                        i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_OPEN_END;
                    end if;
    
                when I2C_SHUTTER_CTRL_OPEN_SEND_BYTE =>
                    report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_OPEN_SEND_BYTE";
                    i2c_xfer_start <= '1';
                    i2c_xfer_stop <= '0';
                    i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_OPEN_SEND_BYTE_WAIT_READY;

                when I2C_SHUTTER_CTRL_OPEN_SEND_BYTE_WAIT_READY =>
                report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_OPEN_SEND_BYTE_WAIT_READY";
                    -- send the next byte
                    if (i2c_xfer_wr_byte_done = '1' and i2c_shutter_command_counter = i2c_shutter_command_open_sequence'length) then
                        i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_OPEN_END;
                    elsif (i2c_xfer_wr_byte_done = '1') then
                        -- i2c_xfer_rst <= '1';
                        i2c_shutter_command_counter <= i2c_shutter_command_counter + 1;
                        i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_OPEN_SEND_BYTE_START;
                    else
                        i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_OPEN_SEND_BYTE_WAIT_READY;
                    end if;
    
                when I2C_SHUTTER_CTRL_OPEN_END =>
                    report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_OPEN_END";

                    i2c_xfer_start <= '0';
                    i2c_xfer_stop <= '1';
                    i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_IDLE;

                --- CLOSE ---
                when I2C_SHUTTER_CTRL_CLOSE_START =>
                    report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_CLOSE_START";
                    i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_CLOSE_SEND_BYTE_START;
                    i2c_shutter_command_counter <= 0;

                when I2C_SHUTTER_CTRL_CLOSE_SEND_BYTE_START =>
                    report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_CLOSE_SEND_BYTE_START";

                    if (i2c_shutter_command_counter < i2c_shutter_command_close_sequence'length) then
                        report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_CLOSE_SEND_BYTE: Sending byte " & integer'image(i2c_shutter_command_counter);
                        i2c_xfer_start <= '0';
                        i2c_xfer_stop <= '0';
                        i2c_xfer_rst <= '0';
                        i2c_xfer_wr_nrd <= '1';
                        i2c_xfer_wr_byte <= i2c_shutter_command_close_sequence(i2c_shutter_command_counter);
                        i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_CLOSE_SEND_BYTE;
                    else
                        report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_CLOSE_SEND_BYTE: No new bytes";
                        i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_CLOSE_END;
                    end if;
    
                when I2C_SHUTTER_CTRL_CLOSE_SEND_BYTE =>
                    report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_CLOSE_SEND_BYTE";
                    i2c_xfer_start <= '1';
                    i2c_xfer_stop <= '0';
                    i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_CLOSE_SEND_BYTE_WAIT_READY;

                when I2C_SHUTTER_CTRL_CLOSE_SEND_BYTE_WAIT_READY =>
                report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_CLOSE_SEND_BYTE_WAIT_READY";
                    -- send the next byte
                    if (i2c_xfer_wr_byte_done = '1' and i2c_shutter_command_counter = i2c_shutter_command_close_sequence'length) then
                        i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_CLOSE_END;
                    elsif (i2c_xfer_wr_byte_done = '1') then
                        -- i2c_xfer_rst <= '1';
                        i2c_shutter_command_counter <= i2c_shutter_command_counter + 1;
                        i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_CLOSE_SEND_BYTE_START;
                    else
                    end if;
    
                when I2C_SHUTTER_CTRL_CLOSE_END =>
                    report "i2c_shutter_ctrl_state: I2C_SHUTTER_CTRL_CLOSE_END";

                    i2c_xfer_start <= '0';
                    i2c_xfer_stop <= '1';
                    i2c_shutter_ctrl_state <= I2C_SHUTTER_CTRL_IDLE;
    
                when others =>
                    report "I2C Shutter CTRL State: invalid state reached " & i2c_shutter_ctrl_type'image(i2c_shutter_ctrl_state);
            end case;
        end if;
    end if;
end process;

p_open: process(clk, rst) begin
end process;

p_close: process(clk, rst) begin
end process;

p_TUNE: process(clk, rst) begin
end process;

end rtl;