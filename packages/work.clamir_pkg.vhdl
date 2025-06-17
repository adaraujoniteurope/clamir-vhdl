-------------------------------------------------------------------------------
-- Company     : AIMEN
-- Project     : CLAMIR
-- Module      : clamir_pkg
-- Description : NIT Processing block common utilities package
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package clamir_pkg is

  -----------------------------------------------------------------------------
  -- Types and constants
  -----------------------------------------------------------------------------

  constant CLK_PERIOD   : time := 10 ns;
  constant CLK_PERIOD_2 : time := 5 ns;

  constant C_S_IMAGE_SIZE      : natural := 64;
  constant C_S_BRAM_ADDR_WIDTH : natural := 12;
  constant C_S_BRAM_DATA_WIDTH : natural := 16;
  constant C_S_BRAM_DATA_SHIFT : natural := 2;
  constant C_S_AXIS_DATA_WIDTH : natural := 16;
  constant C_S_BRAM_INDEX_H    : natural := 13;
  constant C_S_BRAM_INDEX_L    : natural := 0;
  constant C_S_SENSOR_IMG_RES  : natural := C_S_BRAM_INDEX_H - C_S_BRAM_INDEX_L + 1;

  constant C_S_AXI_ADDR_WIDTH : integer := 32;
  constant C_S_AXI_DATA_WIDTH : integer := 32;

  -- Configuration regiter banks
  type cnf_bank_t is (SEL, ROI, MOM, PWM, DMA);

  -- Register access type
  type reg_access_t is (RO, RW);

  type reg_rec is record
    addr : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0);
    regt : reg_access_t;
    data : std_logic_vector(C_S_AXI_DATA_WIDTH - 1 downto 0);
  end record reg_rec;

  type reg_rec_v is array (31 downto 0) of reg_rec;

  type reg_cnf is record
    num_cmd : integer;
    cmd_lst : reg_rec_v;
  end record reg_cnf;

  constant GEN_BNK_ADDR : std_logic_vector(15 downto 0) := x"44A0";
  constant MOM_BNK_ADDR : std_logic_vector(15 downto 0) := x"44A1";
  constant ROI_BNK_ADDR : std_logic_vector(15 downto 0) := x"44A2";
  constant PWM_BNK_ADDR : std_logic_vector(15 downto 0) := x"44A3";
  constant ARM_BNK_ADDR : std_logic_vector(15 downto 0) := x"44A4";

  constant GEN_REG_VERSION_ADDR    : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := GEN_BNK_ADDR & x"0000";
  constant GEN_REG_MOM_ENABLE_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := GEN_BNK_ADDR & x"0004";
  constant GEN_REG_ROI_ENABLE_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := GEN_BNK_ADDR & x"0008";
  constant GEN_REG_PWM_ENABLE_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := GEN_BNK_ADDR & x"000C";
  constant GEN_REG_IRQ_ENABLE_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := GEN_BNK_ADDR & x"0010";
  constant GEN_REG_TRK_RST_ADDR    : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := GEN_BNK_ADDR & x"0014";
  constant GEN_REG_IRQ_MB_ADDR     : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := GEN_BNK_ADDR & x"0018";

  constant GEN_CNF_WR0 : reg_cnf := (num_cmd => 5
  , cmd_lst => (0 => (addr => GEN_REG_MOM_ENABLE_ADDR, regt => RW, data => std_logic_vector(to_unsigned(1, C_S_AXI_DATA_WIDTH)))
  , 1 => (addr => GEN_REG_ROI_ENABLE_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 2 => (addr => GEN_REG_PWM_ENABLE_ADDR, regt => RW, data => std_logic_vector(to_unsigned(1, C_S_AXI_DATA_WIDTH)))
  , 3 => (addr => GEN_REG_IRQ_ENABLE_ADDR, regt => RW, data => std_logic_vector(to_unsigned(1, C_S_AXI_DATA_WIDTH)))
  , 4 => (addr => GEN_REG_IRQ_MB_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , others => (addr => (others => '1'), regt => RO, data => (others => '1'))));

  constant GEN_CNF_RD0 : reg_cnf := (num_cmd => 5
  , cmd_lst => (0 => (addr => GEN_REG_VERSION_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 1 => (addr => GEN_REG_MOM_ENABLE_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 2 => (addr => GEN_REG_ROI_ENABLE_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 3 => (addr => GEN_REG_PWM_ENABLE_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 4 => (addr => GEN_REG_IRQ_ENABLE_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , others => (addr => (others => '1'), regt => RO, data => (others => '1'))));

  constant MOM_REG_BIN_THRS_ADDR  : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := MOM_BNK_ADDR & x"0000";
  constant MOM_REG_INT_MIN_ADDR   : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := MOM_BNK_ADDR & x"0004";
  constant MOM_REG_INT_MAX_ADDR   : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := MOM_BNK_ADDR & x"0008";
  constant MOM_REG_MOMENT_00_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := MOM_BNK_ADDR & x"000C";
  constant MOM_REG_MOMENT_01_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := MOM_BNK_ADDR & x"0010";
  constant MOM_REG_MOMENT_10_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := MOM_BNK_ADDR & x"0014";
  constant MOM_REG_MOMENT_11_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := MOM_BNK_ADDR & x"0018";
  constant MOM_REG_MOMENT_02_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := MOM_BNK_ADDR & x"001C";
  constant MOM_REG_MOMENT_20_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := MOM_BNK_ADDR & x"0020";
  constant MOM_REG_TRK_THRS_ADDR  : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := MOM_BNK_ADDR & x"0024";
  constant MOM_REG_TRK_NUM_ADDR   : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := MOM_BNK_ADDR & x"0028";
  constant MOM_REG_TRK_MODE_ADDR  : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := MOM_BNK_ADDR & x"002C";
  constant MOM_REG_TRK_CNT_L_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := MOM_BNK_ADDR & x"0030";
  constant MOM_REG_TRK_CNT_H_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := MOM_BNK_ADDR & x"0034";
  constant MOM_REG_FRAME_MAX_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := MOM_BNK_ADDR & x"0038";
  constant MOM_REG_TRK_START_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := MOM_BNK_ADDR & x"003C";
  constant MOM_REG_MIN_MOM00_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := MOM_BNK_ADDR & x"0040";

  constant MOM_CNF_WR0 : reg_cnf := (num_cmd => 9
  , cmd_lst => (0 => (addr => MOM_REG_BIN_THRS_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 1 => (addr => MOM_REG_INT_MAX_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 2 => (addr => MOM_REG_INT_MIN_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 3 => (addr => MOM_REG_TRK_THRS_ADDR, regt => RW, data => std_logic_vector(to_unsigned(15, C_S_AXI_DATA_WIDTH)))
  , 4 => (addr => MOM_REG_TRK_MODE_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 5 => (addr => MOM_REG_TRK_CNT_L_ADDR, regt => RW, data => std_logic_vector(to_unsigned(255, C_S_AXI_DATA_WIDTH)))
  , 6 => (addr => MOM_REG_TRK_CNT_H_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 7 => (addr => MOM_REG_TRK_START_ADDR, regt => RW, data => std_logic_vector(to_unsigned(4, C_S_AXI_DATA_WIDTH)))
  , 8 => (addr => MOM_REG_MIN_MOM00_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , others => (addr => (others => '1'), regt => RO, data => (others => '1'))));

  constant MOM_CNF_RD0 : reg_cnf := (num_cmd => 17
  , cmd_lst => (0 => (addr => MOM_REG_BIN_THRS_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 1 => (addr => MOM_REG_INT_MAX_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 2 => (addr => MOM_REG_INT_MIN_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 3 => (addr => MOM_REG_MOMENT_00_ADDR, regt => RO, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 4 => (addr => MOM_REG_MOMENT_01_ADDR, regt => RO, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 5 => (addr => MOM_REG_MOMENT_10_ADDR, regt => RO, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 6 => (addr => MOM_REG_MOMENT_11_ADDR, regt => RO, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 7 => (addr => MOM_REG_MOMENT_02_ADDR, regt => RO, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 8 => (addr => MOM_REG_MOMENT_20_ADDR, regt => RO, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 9 => (addr => MOM_REG_TRK_THRS_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 10 => (addr => MOM_REG_TRK_NUM_ADDR, regt => RO, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 11 => (addr => MOM_REG_TRK_MODE_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 12 => (addr => MOM_REG_TRK_CNT_L_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 13 => (addr => MOM_REG_TRK_CNT_H_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 14 => (addr => MOM_REG_FRAME_MAX_ADDR, regt => RO, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 15 => (addr => MOM_REG_TRK_START_ADDR, regt => RO, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 16 => (addr => MOM_REG_MIN_MOM00_ADDR, regt => RO, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , others => (addr => (others => '1'), regt => RO, data => (others => '1'))));

  constant ROI_REG_X1_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := ROI_BNK_ADDR & x"0000";
  constant ROI_REG_Y1_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := ROI_BNK_ADDR & x"0004";
  constant ROI_REG_X2_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := ROI_BNK_ADDR & x"0008";
  constant ROI_REG_Y2_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := ROI_BNK_ADDR & x"000C";

  constant ROI_CNF_000 : reg_cnf := (num_cmd => 4
  , cmd_lst => (0 => (addr => ROI_REG_X1_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 1 => (addr => ROI_REG_Y1_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 2 => (addr => ROI_REG_X2_ADDR, regt => RW, data => std_logic_vector(to_unsigned(63, C_S_AXI_DATA_WIDTH)))
  , 3 => (addr => ROI_REG_Y2_ADDR, regt => RW, data => std_logic_vector(to_unsigned(63, C_S_AXI_DATA_WIDTH)))
  , others => (addr => (others => '1'), regt => RO, data => (others => '1'))));

  constant PWM_REG_LIMIT_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := PWM_BNK_ADDR & x"0000";
  constant PWM_REG_DUTY_ADDR  : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := PWM_BNK_ADDR & x"0004";
  constant PWM_REG_POWER_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := PWM_BNK_ADDR & x"0008";

  constant PWM_CNF_WR0 : reg_cnf := (num_cmd => 3
  , cmd_lst => (0 => (addr => PWM_REG_LIMIT_ADDR, regt => RW, data => std_logic_vector(to_unsigned(63, C_S_AXI_DATA_WIDTH)))
  , 1 => (addr => PWM_REG_DUTY_ADDR, regt => RW, data => std_logic_vector(to_unsigned(31, C_S_AXI_DATA_WIDTH)))
  , 2 => (addr => PWM_REG_POWER_ADDR, regt => RW, data => std_logic_vector(to_unsigned(7, C_S_AXI_DATA_WIDTH)))
  , others => (addr => (others => '1'), regt => RO, data => (others => '1'))));

  constant PWM_CNF_RD0 : reg_cnf := (num_cmd => 3
  , cmd_lst => (0 => (addr => PWM_REG_LIMIT_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 1 => (addr => PWM_REG_DUTY_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , 2 => (addr => PWM_REG_POWER_ADDR, regt => RW, data => std_logic_vector(to_unsigned(0, C_S_AXI_DATA_WIDTH)))
  , others => (addr => (others => '1'), regt => RO, data => (others => '1'))));

  constant ARM_REG_IP_MODE_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := ARM_BNK_ADDR & x"0000";
  constant ARM_REG_IRQ_ARM_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := ARM_BNK_ADDR & x"0004";
  constant ARM_REG_IRQ_DBG_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := ARM_BNK_ADDR & x"0008";
  constant ARM_REG_RST_FN_ADDR  : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := ARM_BNK_ADDR & x"000C";
  constant ARM_REG_RST_TS_ADDR  : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := ARM_BNK_ADDR & x"0010";
  constant ARM_REG_SW_RSTN_ADDR : std_logic_vector(C_S_AXI_ADDR_WIDTH - 1 downto 0) := ARM_BNK_ADDR & x"0014";

  constant IP_MODE_WR0 : reg_cnf := (num_cmd => 1
  , cmd_lst => (0 => (addr => ARM_REG_IP_MODE_ADDR, regt => RW, data => std_logic_vector(to_unsigned(1, C_S_AXI_DATA_WIDTH)))
  , others => (addr => (others => '1'), regt => RO, data => (others => '1'))));

  constant IRQ_DBG_WR0 : reg_cnf := (num_cmd => 1
  , cmd_lst => (0 => (addr => ARM_REG_IRQ_DBG_ADDR, regt => RW, data => std_logic_vector(to_unsigned(1, C_S_AXI_DATA_WIDTH)))
  , others => (addr => (others => '1'), regt => RO, data => (others => '1'))));

  -----------------------------------------------------------------------------
  -- Components
  -----------------------------------------------------------------------------

  component img_rom is
    port (
      clka  : in std_logic;
      addra : in std_logic_vector(C_S_BRAM_ADDR_WIDTH - 1 downto 0);
      douta : out std_logic_vector(C_S_BRAM_DATA_WIDTH - 1 downto 0)
    );
  end component;

end clamir_pkg;