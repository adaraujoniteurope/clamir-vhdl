library IEEE;

use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
use IEEE.numeric_std.all;

-- description
-- this implementations
-- is called transfer signaling...

entity mm_axis_bridge is
    generic
    (
        DATA_FRAME_LENGTH   : integer := 8;

        ADDR_WIDTH : integer := 32;
        DATA_WIDTH : integer := 32
    );

    port (

        aclk  : in std_logic := '0';
        arstn : in std_logic := '0';

        port_a_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0' );
        port_a_wren : in std_logic := '0';
        port_a_data : in std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0' );

        axis_out_tdata  : out std_logic_vector(ADDR_WIDTH+DATA_WIDTH-1 downto 0) := (others => '0' );
        axis_out_tvalid : out std_logic := '0';
        axis_out_tuser  : out std_logic := '0';
        axis_out_tready : in  std_logic := '0'

    );

  end mm_axis_bridge;
  
  architecture impl of mm_axis_bridge is
    constant AXIS_TDATA_WIDTH : integer := ADDR_WIDTH+DATA_WIDTH;

    type mm_axis_bridge_state_type is (
        MM_AXIS_BRIDGE_STATE_IDLE,
        MM_AXIS_BRIDGE_STATE_ACTIVE,
        MM_AXIS_BRIDGE_STATE_USER
    );

    signal mm_axis_bridge_state : mm_axis_bridge_state_type := MM_AXIS_BRIDGE_STATE_IDLE;

    type memory_type is array(integer range<>) of std_logic_vector(DATA_WIDTH-1 downto 0);

    signal port_a_wren_last         : std_logic := '0';
    signal port_a_wren_posedge      : std_logic := '0';

    signal axis_out_tready_last     : std_logic := '0';
    signal axis_out_tready_posedge  : std_logic := '0';

  begin
    
    port_a_wren_posedge <= (port_a_wren xor port_a_wren_last) and port_a_wren;

    main_process: process(aclk, arstn) begin

        if (arstn = '0') then
            axis_out_tvalid <= '0';
            axis_out_tdata <= (others => '0');
        else
        
        if (rising_edge(aclk)) then
            port_a_wren_last <= port_a_wren;
            axis_out_tready_last <= axis_out_tready;

            case(mm_axis_bridge_state) is

                when MM_AXIS_BRIDGE_STATE_IDLE =>
                    if (axis_out_tready = '1' and port_a_wren_posedge = '1') then
                        axis_out_tvalid <= '1';
                        mm_axis_bridge_state <= MM_AXIS_BRIDGE_STATE_ACTIVE;
                        axis_out_tdata <= port_a_addr & port_a_data;
                    else
                        axis_out_tvalid <= '0';
                    end if;

                when MM_AXIS_BRIDGE_STATE_ACTIVE =>
                    axis_out_tdata <= port_a_addr & port_a_data;
                    
                    if (port_a_addr < DATA_FRAME_LENGTH) then
                        axis_out_tuser <= '0';
                    else
                        axis_out_tuser <= '1';
                    end if;
                    
                    if (axis_out_tready = '0' or port_a_wren = '0') then
                        axis_out_tuser <= '0';
                        axis_out_tvalid <= '0';
                        mm_axis_bridge_state <= MM_AXIS_BRIDGE_STATE_IDLE;
                    end if;

                when others =>
                    mm_axis_bridge_state <= MM_AXIS_BRIDGE_STATE_IDLE;    
            end case;
        end if;
        end if;
    end process;

  end impl;