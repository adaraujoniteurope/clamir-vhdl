library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity i2c_xfer is
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
       scl_t            : out   std_logic := '0';
       
       sda_o            : out   std_logic := '0';
       sda_i            : in    std_logic;
       sda_t            : out   std_logic := '0'
   );
end i2c_xfer;

architecture rtl of i2c_xfer is

-- ATTRIBUTE X_INTERFACE_INFO : STRING;
-- ATTRIBUTE X_INTERFACE_INFO OF SDA_I: SIGNAL IS "xilinx.com:interface:iic:1.0 IIC SDA_I";
-- ATTRIBUTE X_INTERFACE_INFO OF SDA_O: SIGNAL IS "xilinx.com:interface:iic:1.0 IIC SDA_O";
-- ATTRIBUTE X_INTERFACE_INFO OF SDA_T: SIGNAL IS "xilinx.com:interface:iic:1.0 IIC SDA_T";
-- ATTRIBUTE X_INTERFACE_INFO OF SCL_I: SIGNAL IS "xilinx.com:interface:iic:1.0 IIC SCL_I";
-- ATTRIBUTE X_INTERFACE_INFO OF SCL_O: SIGNAL IS "xilinx.com:interface:iic:1.0 IIC SCL_O";
-- ATTRIBUTE X_INTERFACE_INFO OF SCL_T: SIGNAL IS "xilinx.com:interface:iic:1.0 IIC SCL_T";

signal clk_threshold : std_logic_vector(31 downto 0) := conv_std_logic_vector(2, 32);

type i2c_shutter_command_type is array (0 to 2) of std_logic_vector(7 downto 0);

 type i2c_xfer_state_type is (

    STATE_I2C_START_SDA_FALL,
    STATE_I2C_START_SCL_FALL,

    STATE_I2C_STOP,
    STATE_I2C_STOP_SDA_RISE,
    STATE_I2C_STOP_SCL_RISE,

    STATE_I2C_HOLD,

    STATE_I2C_READ_BYTE_START,
    STATE_I2C_READ_BYTE_SHIFT,
    STATE_I2C_READ_BYTE,
    STATE_I2C_READ_BYTE_END,

    STATE_I2C_READ_BYTE_ACK,
    STATE_I2C_READ_BYTE_ACK_STROBE_RISE,
    STATE_I2C_READ_BYTE_ACK_STROBE_FALL,

    STATE_I2C_READ_BYTE_STROBE_RISE,
    STATE_I2C_READ_BYTE_STROBE_FALL,

    STATE_I2C_WRITE_BYTE_START,
    --STATE_I2C_WRITE_BYTE_SHIFT,
    STATE_I2C_WRITE_BYTE,
    STATE_I2C_WRITE_BYTE_END,
    
    STATE_I2C_WRITE_BYTE_ACK,
    STATE_I2C_WRITE_BYTE_ACK_STROBE_RISE,
    STATE_I2C_WRITE_BYTE_ACK_STROBE_FALL,

    STATE_I2C_WRITE_STROBE_RISE,
    STATE_I2C_WRITE_STROBE_FALL

);

constant i2c_shutter_command_open : i2c_shutter_command_type :=(
    x"a5",
    x"07",
    x"64"
);

constant i2c_shutter_command_close : i2c_shutter_command_type :=(
    x"a5",
    x"07",
    x"9c"
);

constant TRISTATE_OC_HIGH : std_logic := '1';
constant TRISTATE_OC_LOW : std_logic := '0';

signal i2c_start_detect : std_logic := '0';
signal i2c_start_current : std_logic := '0';
signal i2c_start_last : std_logic := '0';

signal i2c_xfer_ack : std_logic := '0'; -- nack

signal shutter_open_last : std_logic := '0';

signal i2c_xfer_bit_counter : std_logic_vector (7 downto 0) := (others => '0');
signal i2c_xfer_counter : std_logic_vector(7 downto 0) := (others => '0');
signal i2c_xfer_pattern : std_logic_vector(7 downto 0) := (others => '1');

signal i2c_xfer_state : i2c_xfer_state_type;
signal i2c_xfer_state_next : i2c_xfer_state_type;

signal i2x_xfer_byte : std_logic_vector(7 downto 0) := (others => '0');

signal i2c_shutter_command_operation : i2c_shutter_command_type;

begin

i2c_start_detect <= (i2c_start xor i2c_start_last) and i2c_start;

process (clk, rst)
begin

if (rising_edge(clk)) then


    if (rst = '1') then

        i2c_start_last <= i2c_start;
        i2c_rd_byte_done <= '0';
        i2c_wr_byte_done <= '0';

    else

        i2c_start_last <= i2c_start;
        i2c_xfer_state <= i2c_xfer_state_next;

        case i2c_xfer_state is

        when STATE_I2C_HOLD =>

            report "STATE_I2C_HOLD";

            i2c_rd_byte_done <= '0';
            i2c_wr_byte_done <= '0';

            if (i2c_start_detect = '1') then
                

                if (i2c_wr_nrd = '1') then
                    report "STATE_I2C_HOLD: Triggering Write";
                    i2c_xfer_state <= STATE_I2C_WRITE_BYTE_START;
                else
                    report "STATE_I2C_HOLD: Triggering Read";
                    i2c_xfer_state <= STATE_I2C_READ_BYTE_START;
                end if;

            elsif (i2c_stop = '1') then
                report "STATE_I2C_HOLD: Stop Detected";
                i2c_xfer_state <= STATE_I2C_STOP_SCL_RISE;
            else
                report "STATE_I2C_HOLD: No Action Detected";
                i2c_xfer_state <= STATE_I2C_HOLD;
            end if;

        when STATE_I2C_STOP_SDA_RISE =>
            report "STATE_I2C_STOP_SDA_RISE";
            sda_t <= TRISTATE_OC_HIGH;
            i2c_xfer_state <= STATE_I2C_STOP;

        when STATE_I2C_STOP_SCL_RISE =>
            report "STATE_I2C_STOP_SCL_RISE";
            scl_t <= TRISTATE_OC_HIGH;
            i2c_xfer_state <= STATE_I2C_STOP_SDA_RISE;

        when STATE_I2C_STOP =>
            report "STATE_I2C_STOP";
            sda_t <= TRISTATE_OC_HIGH;

            if i2c_start_detect = '1' then
                report "STATE_I2C_START_DETECTED";
                i2c_xfer_state <= STATE_I2C_START_SDA_FALL;
            else
                i2c_xfer_state <= STATE_I2C_STOP;
            end if;

        when STATE_I2C_START_SDA_FALL =>
            report "STATE_I2C_START_SDA_FALL";
            sda_t <= TRISTATE_OC_LOW;
            scl_t <= TRISTATE_OC_HIGH;

            i2c_xfer_state <= STATE_I2C_START_SCL_FALL;

        when STATE_I2C_START_SCL_FALL =>
            report "STATE_I2C_START_SCL_FALL";
            sda_t <= TRISTATE_OC_LOW;
            scl_t <= TRISTATE_OC_LOW;
            
            if (i2c_wr_nrd = '1') then
                i2c_xfer_state <= STATE_I2C_WRITE_BYTE_START;
            else
                i2c_xfer_state <= STATE_I2C_READ_BYTE_START;
            end if;

        when STATE_I2C_READ_BYTE_START =>
            report "STATE_I2C_READ_BYTE_START";
            i2x_xfer_byte <= (others => '0');
            i2c_xfer_state <= STATE_I2C_READ_BYTE_STROBE_RISE;

        when STATE_I2C_READ_BYTE_STROBE_RISE =>
            report "STATE_I2C_READ_BYTE_STROBE_RISE";
            scl_t <= TRISTATE_OC_HIGH;
            i2c_xfer_state <= STATE_I2C_READ_BYTE;

        when STATE_I2C_READ_BYTE_STROBE_FALL =>
            report "STATE_I2C_READ_BYTE_STROBE_FALL";
            scl_t <= TRISTATE_OC_LOW;

            if (i2c_xfer_bit_counter = (i2x_xfer_byte'length)) then
                i2c_xfer_bit_counter <= (others => '0');
                i2c_xfer_state <= STATE_I2C_READ_BYTE_END;
            else
                i2c_xfer_state <= STATE_I2C_READ_BYTE_SHIFT;
            end if;

        when STATE_I2C_READ_BYTE =>
            report "STATE_I2C_READ_BYTE";
            i2x_xfer_byte(0) <= sda_i;
            i2c_xfer_bit_counter <= i2c_xfer_bit_counter + 1;
            i2c_xfer_state <= STATE_I2C_READ_BYTE_STROBE_FALL;

        when STATE_I2C_READ_BYTE_SHIFT =>
            report "STATE_I2C_READ_BYTE_SHIFT";
            i2x_xfer_byte <= i2x_xfer_byte(6 downto 0) & '0';
            i2c_xfer_state <= STATE_I2C_READ_BYTE_STROBE_RISE;

        when STATE_I2C_READ_BYTE_END =>
            report "STATE_I2C_READ_BYTE_END";
            sda_t <= TRISTATE_OC_HIGH;
            i2c_xfer_state <= STATE_I2C_READ_BYTE_ACK_STROBE_RISE;

        when STATE_I2C_READ_BYTE_ACK_STROBE_RISE =>
            report "STATE_I2C_READ_BYTE_ACK_STROBE_RISE";
            i2c_xfer_state <= STATE_I2C_READ_BYTE_ACK;
            scl_t <= TRISTATE_OC_HIGH;
            i2c_rd_byte <= i2x_xfer_byte;

        when STATE_I2C_READ_BYTE_ACK =>
            report "STATE_I2C_READ_BYTE_ACK";
            i2c_xfer_ack <= not sda_i;
            i2c_xfer_state <= STATE_I2C_READ_BYTE_ACK_STROBE_FALL;

        when STATE_I2C_READ_BYTE_ACK_STROBE_FALL =>
            report "STATE_I2C_READ_BYTE_ACK_STROBE_FALL";
            scl_t <= TRISTATE_OC_LOW;
            i2c_rd_byte_done <= '1';
            i2c_xfer_counter <= i2c_xfer_counter + 1;
            if (i2c_stop = '1') then
                i2c_xfer_state <= STATE_I2C_STOP_SCL_RISE;
            else
                i2c_xfer_state <= STATE_I2C_HOLD;
            end if;

        when STATE_I2C_WRITE_BYTE_START =>
            report "STATE_I2C_WRITE_BYTE_START";
            i2x_xfer_byte <= i2c_wr_byte;
            i2c_xfer_state <= STATE_I2C_WRITE_BYTE;

        -- when STATE_I2C_WRITE_BYTE_SHIFT =>
        --     report "STATE_I2C_WRITE_BYTE_SHIFT";

        when STATE_I2C_WRITE_BYTE =>
            report "STATE_I2C_WRITE_BYTE";

            sda_t <= i2x_xfer_byte(7);
            i2x_xfer_byte <= i2x_xfer_byte(6 downto 0) & '0';
            i2c_xfer_state <= STATE_I2C_WRITE_BYTE;
            i2c_xfer_bit_counter <= i2c_xfer_bit_counter + 1;
            i2c_xfer_state <= STATE_I2C_WRITE_STROBE_RISE;

        when STATE_I2C_WRITE_BYTE_END =>
            report "STATE_I2C_WRITE_BYTE_END";
            sda_t <= TRISTATE_OC_HIGH;

            i2c_xfer_state <= STATE_I2C_WRITE_BYTE_ACK_STROBE_RISE;

        when STATE_I2C_WRITE_BYTE_ACK_STROBE_RISE =>
            report "STATE_I2C_WRITE_BYTE_ACK_STROBE_RISE";
            scl_t <= TRISTATE_OC_HIGH;
            i2c_xfer_state <= STATE_I2C_WRITE_BYTE_ACK;

        when STATE_I2C_WRITE_BYTE_ACK =>
            i2c_xfer_ack <= not sda_i;
            report "STATE_I2C_WRITE_BYTE_ACK";
            i2c_xfer_state <= STATE_I2C_WRITE_BYTE_ACK_STROBE_FALL;

        when STATE_I2C_WRITE_BYTE_ACK_STROBE_FALL =>
            report "STATE_I2C_WRITE_BYTE_ACK_STROBE_FALL";
            scl_t <= TRISTATE_OC_LOW;
            i2c_wr_byte_done <= '1';

            i2c_xfer_counter <= i2c_xfer_counter + 1;

            if (i2c_stop = '1') then
                i2c_xfer_state <= STATE_I2C_STOP;
            else
                i2c_xfer_state <= STATE_I2C_HOLD;
            end if;

        when STATE_I2C_WRITE_STROBE_RISE =>
            report "STATE_I2C_WRITE_STROBE_RISE";
            scl_t <= TRISTATE_OC_HIGH;

            i2c_xfer_state <= STATE_I2C_WRITE_STROBE_FALL;

        when STATE_I2C_WRITE_STROBE_FALL =>
            report "STATE_I2C_WRITE_STROBE_FALL";
            scl_t <= TRISTATE_OC_LOW;

            if (i2c_xfer_bit_counter = (i2x_xfer_byte'length)) then
                i2c_xfer_bit_counter <= (others => '0');
                i2c_xfer_state <= STATE_I2C_WRITE_BYTE_END;
            else
                i2c_xfer_state <= STATE_I2C_WRITE_BYTE;
            end if;

        when others =>
        end case;
    end if;

end if;

end process;

end rtl;
