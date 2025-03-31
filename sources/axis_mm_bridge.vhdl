library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

entity axis_mm_bridge is
    generic
    (
        DATA_FRAME_LENGTH   : integer := 4096;
        DATA_USER_LENGTH    : integer := 44;

        ADDR_WIDTH : integer := 32;
        DATA_WIDTH : integer := 32
    );

    port (

        aclk  : in std_logic := '0';
        arstn : in std_logic := '0';

        axis_in_tdata  : in std_logic_vector(ADDR_WIDTH+DATA_WIDTH-1 downto 0) := (others => '0' );
        axis_in_tvalid : in std_logic := '0';
        axis_in_tuser  : in std_logic := '0';
        axis_in_tready : out  std_logic := '0';

        port_a_addr : out std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0' );
        port_a_wren : out std_logic := '0';
        port_a_data : out std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0' )

    );

  end axis_mm_bridge;
  
  architecture impl of axis_mm_bridge is
    constant AXIS_TDATA_WIDTH : integer := ADDR_WIDTH+DATA_WIDTH;

    type axis_mm_bridge_state_type is (
        AXIS_MM_BRIDGE_STATE_IDLE,
        AXIS_MM_BRIDGE_STATE_ACTIVE
    );

    signal axis_mm_bridge_state : axis_mm_bridge_state_type := AXIS_MM_BRIDGE_STATE_IDLE;
    signal axis_in_tvalid_last : std_logic := '0';

  begin

    process(aclk, arstn) begin

        if (arstn = '0') then

            axis_in_tready <= '0';

        else

        if (rising_edge(aclk)) then

            axis_in_tvalid_last <= axis_in_tvalid;

            case(axis_mm_bridge_state) is
                when AXIS_MM_BRIDGE_STATE_IDLE =>

                    axis_in_tready <= '1';
                    
                    if (((axis_in_tvalid_last xor axis_in_tvalid) and axis_in_tvalid) = '1') then
                        axis_mm_bridge_state <= AXIS_MM_BRIDGE_STATE_ACTIVE;
                    end if;

                when AXIS_MM_BRIDGE_STATE_ACTIVE =>
                    
                    port_a_addr <= axis_in_tdata(ADDR_WIDTH+DATA_WIDTH-1 downto DATA_WIDTH);
                    port_a_data <= axis_in_tdata(DATA_WIDTH-1 downto 0);
                    port_a_wren <= axis_in_tvalid;

            end case;

        end if;

        end if;

    end process;

  end impl;