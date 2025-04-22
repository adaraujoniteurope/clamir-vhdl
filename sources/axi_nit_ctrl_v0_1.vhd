library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi_NIT_ctrl_v0_1 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 8
	);
	port (
		-- Users to add ports here
        integration_time_out 	: out std_logic_vector(15 downto 0);
        Bias_Voltage_out         : out std_logic_vector(13 downto 0);
        offset_enable_out         : out std_logic_vector( 0 downto 0);
        offset_upd_out           : out std_logic_vector( 0 downto 0);
        Shutter_out             : out std_logic_vector( 0 downto 0);
        Shutter_upd_out         : out std_logic_vector( 0 downto 0);
        BPC_Enable_out             : out std_logic_vector( 0 downto 0);
        BPC_identify_out         : out std_logic_vector( 0 downto 0);
        TEMP1_in                : in  std_logic_vector(11 downto 0);
        TEMP2_in                : in  std_logic_vector(11 downto 0);
        TEMP3_in                : in  std_logic_vector(11 downto 0);
        TEMP4_in                : in  std_logic_vector(11 downto 0);
        Trigger_USEC_out        : out std_logic_vector(15 downto 0);
        Black_level_out            : out std_logic_vector(15 downto 0);
        Drift_position            : out std_logic_vector(3 downto 0);
        Drift_enable            : out std_logic_vector(0 downto 0);
        Drift_level            : in std_logic_vector(15 downto 0);
        ---------------------------------------------------------------------------
        -- Register bank members DUT direct access
        ---------------------------------------------------------------------------
        led_r_out     : out std_logic_vector(0 downto 0);
        led_g_out     : out std_logic_vector(0 downto 0);
        led_b_out     : out std_logic_vector(0 downto 0);
        shutter_res_out   : out std_logic_vector(0 downto 0);
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end axi_NIT_ctrl_v0_1;

architecture arch_imp of axi_NIT_ctrl_v0_1 is

	-- component declaration
	component axi_NIT_ctrl_v0_1_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 8
		);
		port (
		integration_time_out 	: out std_logic_vector(15 downto 0);
        Bias_Voltage_out         : out std_logic_vector(13 downto 0);
        offset_enable_out         : out std_logic_vector( 0 downto 0);
        offset_upd_out           : out std_logic_vector( 0 downto 0);
        Shutter_out             : out std_logic_vector( 0 downto 0);
        Shutter_upd_out         : out std_logic_vector( 0 downto 0);
        BPC_Enable_out             : out std_logic_vector( 0 downto 0);
        BPC_identify_out         : out std_logic_vector( 0 downto 0);
        TEMP1_in                : in  std_logic_vector(11 downto 0);
        TEMP2_in                : in  std_logic_vector(11 downto 0);
        TEMP3_in                : in  std_logic_vector(11 downto 0);
        TEMP4_in                : in  std_logic_vector(11 downto 0);
        Trigger_USEC_out        : out std_logic_vector(15 downto 0);
        Black_level_out            : out std_logic_vector(15 downto 0);
        Drift_position            : out std_logic_vector(3 downto 0);
        Drift_enable            : out std_logic_vector(0 downto 0);
        Drift_level            : in std_logic_vector(15 downto 0);
        ---------------------------------------------------------------------------
        -- Register bank members DUT direct access
        ---------------------------------------------------------------------------
        led_r_out     : out std_logic_vector(0 downto 0);
        led_g_out     : out std_logic_vector(0 downto 0);
        led_b_out     : out std_logic_vector(0 downto 0);
        shutter_res_out   : out std_logic_vector(0 downto 0);
		
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component axi_NIT_ctrl_v0_1_S00_AXI;

begin

-- Instantiation of Axi Bus Interface S00_AXI
axi_NIT_ctrl_v0_1_S00_AXI_inst : axi_NIT_ctrl_v0_1_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
	
	
	-- Users to add ports here
        integration_time_out =>    integration_time_out,    
        Bias_Voltage_out     =>    Bias_Voltage_out,        
        offset_enable_out    =>    offset_enable_out,       
        offset_upd_out       =>    offset_upd_out,          
        Shutter_out          	=>   Shutter_out ,            
        Shutter_upd_out      	=>   Shutter_upd_out,         
        BPC_Enable_out       =>    BPC_Enable_out ,         
        BPC_identify_out     	=>   BPC_identify_out,        
        TEMP1_in             	=>   TEMP1_in ,               
        TEMP2_in            =>     TEMP2_in ,               
        TEMP3_in            =>     TEMP3_in ,               
        TEMP4_in            =>     TEMP4_in ,               
        Trigger_USEC_out    =>     Trigger_USEC_out,        
        Black_level_out     	=>    Black_level_out,
        Drift_position =>Drift_position,
        Drift_enable =>Drift_enable,
        Drift_level =>Drift_level,
        led_r_out =>  led_r_out,
        led_g_out =>  led_g_out,
        led_b_out =>  led_b_out,
        shutter_res_out => shutter_res_out,
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

	-- Add user logic here

	-- User logic ends

end arch_imp;
