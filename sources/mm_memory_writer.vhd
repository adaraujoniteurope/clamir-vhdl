----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/16/2025 12:21:10 PM
-- Design Name: 
-- Module Name: mm_memory_writer - impl
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_MISC.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mm_memory_writer is
Generic (
    ADDR_WIDTH : integer := 32;
    DATA_WIDTH : integer := 16;
    
    FIFO_LENGTH : integer := 20;
    FIFO_ELEMENT_SIZE : integer := 8192+256;
    
    -- Width of S_AXI data bus
    C_S_AXI_DATA_WIDTH	: integer	:= 32;
    -- Width of S_AXI address bus
    C_S_AXI_ADDR_WIDTH	: integer	:= 7
);
Port (
    --aclk    : std_logic := '0';
    --arstn   : std_logic := '0';
    
    fifo_head : out std_logic_vector(7 downto 0) := ( others => '0');
    
    a_mm_addr : in std_logic_vector(ADDR_WIDTH-1 downto 0) := ( others => '0');
    a_mm_data : in std_logic_vector(DATA_WIDTH-1 downto 0) := ( others => '0');
    a_mm_wren : in std_logic := '0';
    
    intr : out std_logic := '0';
    
    register_0_debug : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0) := ( OTHERS => '0' );
    
    bram_clk : OUT STD_LOGIC := '0';
    bram_rst : OUT STD_LOGIC := '0';
    bram_ena : OUT STD_LOGIC := '1';
    bram_wea : OUT STD_LOGIC_VECTOR((2*DATA_WIDTH)/8 - 1 DOWNTO 0) := (OTHERS => '0');
    bram_addr : OUT STD_LOGIC_VECTOR(ADDR_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
    bram_din : OUT STD_LOGIC_VECTOR(2*DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
    bram_dout : IN STD_LOGIC_VECTOR(2*DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
    

		-- Do not modify the ports beyond this line

		-- Global Clock Signal
		S_AXI_ACLK	: in std_logic;
		-- Global Reset Signal. This Signal is Active LOW
		S_AXI_ARESETN	: in std_logic;
		-- Write address (issued by master, acceped by Slave)
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Write channel Protection type. This signal indicates the
    		-- privilege and security level of the transaction, and whether
    		-- the transaction is a data access or an instruction access.
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		-- Write address valid. This signal indicates that the master signaling
    		-- valid write address and control information.
		S_AXI_AWVALID	: in std_logic;
		-- Write address ready. This signal indicates that the slave is ready
    		-- to accept an address and associated control signals.
		S_AXI_AWREADY	: out std_logic;
		-- Write data (issued by master, acceped by Slave) 
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Write strobes. This signal indicates which byte lanes hold
    		-- valid data. There is one write strobe bit for each eight
    		-- bits of the write data bus.    
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		-- Write valid. This signal indicates that valid write
    		-- data and strobes are available.
		S_AXI_WVALID	: in std_logic;
		-- Write ready. This signal indicates that the slave
    		-- can accept the write data.
		S_AXI_WREADY	: out std_logic;
		-- Write response. This signal indicates the status
    		-- of the write transaction.
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		-- Write response valid. This signal indicates that the channel
    		-- is signaling a valid write response.
		S_AXI_BVALID	: out std_logic;
		-- Response ready. This signal indicates that the master
    		-- can accept a write response.
		S_AXI_BREADY	: in std_logic;
		-- Read address (issued by master, acceped by Slave)
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- Protection type. This signal indicates the privilege
    		-- and security level of the transaction, and whether the
    		-- transaction is a data access or an instruction access.
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		-- Read address valid. This signal indicates that the channel
    		-- is signaling valid read address and control information.
		S_AXI_ARVALID	: in std_logic;
		-- Read address ready. This signal indicates that the slave is
    		-- ready to accept an address and associated control signals.
		S_AXI_ARREADY	: out std_logic;
		-- Read data (issued by slave)
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- Read response. This signal indicates the status of the
    		-- read transfer.
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		-- Read valid. This signal indicates that the channel is
    		-- signaling the required read data.
		S_AXI_RVALID	: out std_logic;
		-- Read ready. This signal indicates that the master can
    		-- accept the read data and response information.
		S_AXI_RREADY	: in std_logic
    
);
end mm_memory_writer;

architecture impl of mm_memory_writer is

    ATTRIBUTE X_INTERFACE_INFO : STRING;

    ATTRIBUTE X_INTERFACE_INFO OF bram_clk : SIGNAL IS "xilinx.com:interface:bram:1.0 bram CLK";
    ATTRIBUTE X_INTERFACE_INFO OF bram_addr : SIGNAL IS "xilinx.com:interface:bram:1.0 bram ADDR";
    ATTRIBUTE X_INTERFACE_INFO OF bram_rst : SIGNAL IS "xilinx.com:interface:bram:1.0 bram RST";
    ATTRIBUTE X_INTERFACE_INFO OF bram_wea : SIGNAL IS "xilinx.com:interface:bram:1.0 bram WE";
    ATTRIBUTE X_INTERFACE_INFO OF bram_ena : SIGNAL IS "xilinx.com:interface:bram:1.0 bram EN";
    ATTRIBUTE X_INTERFACE_INFO OF bram_din : SIGNAL IS "xilinx.com:interface:bram:1.0 bram DIN";
    ATTRIBUTE X_INTERFACE_INFO OF bram_dout : SIGNAL IS "xilinx.com:interface:bram:1.0 bram DOUT";
    
    signal a_mm_data_d0 : std_logic_vector(a_mm_data'length - 1 downto 0) := ( others => '0');
    signal a_mm_wren_d0 : std_logic := '0';
    
    signal intr_reg : std_logic := '0';
    signal fifo_head_reg : std_logic_vector(7 downto 0) := ( others => '0');
    
    signal bram_write_enable : std_logic := '0';
    

	-- AXI4LITE signals
	signal axi_awaddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_awready	: std_logic;
	signal axi_wready	: std_logic;
	signal axi_bresp	: std_logic_vector(1 downto 0);
	signal axi_bvalid	: std_logic;
	signal axi_araddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_arready	: std_logic;
	signal axi_rresp	: std_logic_vector(1 downto 0);
	signal axi_rvalid	: std_logic;

	-- Example-specific design signals
	-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	-- ADDR_LSB is used for addressing 32/64 bit registers/memories
	-- ADDR_LSB = 2 for 32 bits (n downto 2)
	-- ADDR_LSB = 3 for 64 bits (n downto 3)
	constant ADDR_LSB  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
	constant OPT_MEM_ADDR_BITS : integer := 4;
	------------------------------------------------
	---- Signals for user logic register space example
	--------------------------------------------------
	---- Number of Slave Registers 32
    type register_bank_type is array(integer range<>) of std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);

    signal register_bank_wr : register_bank_type(0 to 31) := ( others => ( others => '0' ) );
    signal register_bank_rd : register_bank_type(0 to 31) := ( others => ( others => '0' ) );

	signal byte_index	: integer;

	 signal mem_logic  : std_logic_vector(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);
	 
	 signal offsets : register_bank_type(0 to FIFO_LENGTH-1) := (
        x"00000000",
        x"00002100",
        x"00004200",
        x"00006300",
        x"00008400",
        x"0000A500",
        x"0000C600",
        x"0000E700",
        x"00010800",
        x"00012900",
        x"00014A00",
        x"00016B00",
        x"00018C00",
        x"0001AD00",
        x"0001CE00",
        x"0001EF00",
        x"00021000",
        x"00023100",
        x"00025200",
        x"00027300"
	 );

	 --State machine local parameters
	constant Idle : std_logic_vector(1 downto 0) := "00";
	constant Raddr: std_logic_vector(1 downto 0) := "10";
	constant Rdata: std_logic_vector(1 downto 0) := "11";
	constant Waddr: std_logic_vector(1 downto 0) := "10";
	constant Wdata: std_logic_vector(1 downto 0) := "11";
	 --State machine variables
	signal state_read : std_logic_vector(1 downto 0);
	signal state_write: std_logic_vector(1 downto 0); 
    
begin

    fifo_head <= fifo_head_reg;
    intr <= intr_reg;
    
    register_0_debug <= register_bank_rd(0);

	-- I/O Connections assignments

	S_AXI_AWREADY	<= axi_awready;
	S_AXI_WREADY	<= axi_wready;
	S_AXI_BRESP	<= axi_bresp;
	S_AXI_BVALID	<= axi_bvalid;
	S_AXI_ARREADY	<= axi_arready;
	S_AXI_RRESP	<= axi_rresp;
	S_AXI_RVALID	<= axi_rvalid;
	    mem_logic     <= S_AXI_AWADDR(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB) when (S_AXI_AWVALID = '1') else axi_awaddr(ADDR_LSB + OPT_MEM_ADDR_BITS downto ADDR_LSB);

	-- Implement Write state machine
	-- Outstanding write transactions are not supported by the slave i.e., master should assert bready to receive response on or before it starts sending the new transaction
	 process (S_AXI_ACLK)                                       
	   begin                                       
	     if rising_edge(S_AXI_ACLK) then                                       
	        if S_AXI_ARESETN = '0' then                                       
	          --asserting initial values to all 0's during reset                                       
	          axi_awready <= '0';                                       
	          axi_wready <= '0';                                       
	          axi_bvalid <= '0';                                       
	          axi_bresp <= (others => '0');                                       
	          state_write <= Idle;                                       
	        else                                       
	          case (state_write) is                                       
	             when Idle =>		--Initial state inidicating reset is done and ready to receive read/write transactions                                       
	               if (S_AXI_ARESETN = '1') then                                       
	                 axi_awready <= '1';                                       
	                 axi_wready <= '1';                                       
	                 state_write <= Waddr;                                       
	               else state_write <= state_write;                                       
	               end if;                                       
	             when Waddr =>		--At this state, slave is ready to receive address along with corresponding control signals and first data packet. Response valid is also handled at this state                                       
	               if (S_AXI_AWVALID = '1' and axi_awready = '1') then                                       
	                 axi_awaddr <= S_AXI_AWADDR;                                       
	                 if (S_AXI_WVALID = '1') then                                       
	                   axi_awready <= '1';                                       
	                   state_write <= Waddr;                                       
	                   axi_bvalid <= '1';                                       
	                 else                                       
	                   axi_awready <= '0';                                       
	                   state_write <= Wdata;                                       
	                   if (S_AXI_BREADY = '1' and axi_bvalid = '1') then                                       
	                     axi_bvalid <= '0';                                       
	                   end if;                                       
	                 end if;                                       
	               else                                        
	                 state_write <= state_write;                                       
	                 if (S_AXI_BREADY = '1' and axi_bvalid = '1') then                                       
	                   axi_bvalid <= '0';                                       
	                 end if;                                       
	               end if;                                       
	             when Wdata =>		--At this state, slave is ready to receive the data packets until the number of transfers is equal to burst length                                       
	               if (S_AXI_WVALID = '1') then                                       
	                 state_write <= Waddr;                                       
	                 axi_bvalid <= '1';                                       
	                 axi_awready <= '1';                                       
	               else                                       
	                 state_write <= state_write;                                       
	                 if (S_AXI_BREADY ='1' and axi_bvalid = '1') then                                       
	                   axi_bvalid <= '0';                                       
	                 end if;                                       
	               end if;                                       
	             when others =>      --reserved                                       
	               axi_awready <= '0';                                       
	               axi_wready <= '0';                                       
	               axi_bvalid <= '0';                                       
	           end case;                                       
	        end if;                                       
	      end if;                                                
	 end process;                                       
	-- Implement memory mapped register select and write logic generation
	-- The write data is accepted and written to memory mapped registers when
	-- axi_awready, S_AXI_WVALID, axi_wready and S_AXI_WVALID are asserted. Write strobes are used to
	-- select byte enables of slave registers while writing.
	-- These registers are cleared when reset (active low) is applied.
	-- Slave register write enable is asserted when valid address and data are available
	-- and the slave is ready to accept the write address and write data.
	

	process (S_AXI_ACLK)
	begin
	  if rising_edge(S_AXI_ACLK) then 
	    if S_AXI_ARESETN = '0' then
	      register_bank_wr <= (others => ( others => '0' ));
	    else
	      if (S_AXI_WVALID = '1') then
            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
                if ( S_AXI_WSTRB(byte_index) = '1' ) then
                    -- Respective byte enables are asserted as per write strobes                   
                    -- slave registor 0
                    register_bank_wr(to_integer(unsigned(mem_logic)))(byte_index*8+7 downto byte_index*8) <= S_AXI_WDATA(byte_index*8+7 downto byte_index*8);
                else
                    -- not necessary
                    -- register_bank_wr(to_integer(unsigned(mem_logic)))(byte_index*8+7 downto byte_index*8) <= register_bank_wr(to_integer(unsigned(mem_logic)))(byte_index*8+7 downto byte_index*8);
                end if;
            end loop;
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- Implement read state machine
	 process (S_AXI_ACLK)                                          
	   begin                                          
	     if rising_edge(S_AXI_ACLK) then                                           
	        if S_AXI_ARESETN = '0' then                                          
	          --asserting initial values to all 0's during reset                                          
	          axi_arready <= '0';                                          
	          axi_rvalid <= '0';                                          
	          axi_rresp <= (others => '0');                                          
	          state_read <= Idle;                                          
	        else                                          
	          case (state_read) is                                          
	            when Idle =>		--Initial state inidicating reset is done and ready to receive read/write transactions                                          
	                if (S_AXI_ARESETN = '1') then                                          
	                  axi_arready <= '1';                                          
	                  state_read <= Raddr;                                          
	                else state_read <= state_read;                                          
	                end if;                                          
	            when Raddr =>		--At this state, slave is ready to receive address along with corresponding control signals                                          
	                if (S_AXI_ARVALID = '1' and axi_arready = '1') then                                          
	                  state_read <= Rdata;                                          
	                  axi_rvalid <= '1';                                          
	                  axi_arready <= '0';                                          
	                  axi_araddr <= S_AXI_ARADDR;                                          
	                else                                          
	                  state_read <= state_read;                                          
	                end if;                                          
	            when Rdata =>		--At this state, slave is ready to send the data packets until the number of transfers is equal to burst length                                          
	                if (axi_rvalid = '1' and S_AXI_RREADY = '1') then                                          
	                  axi_rvalid <= '0';                                          
	                  axi_arready <= '1';                                          
	                  state_read <= Raddr;                                          
	                else                                          
	                  state_read <= state_read;                                          
	                end if;                                          
	            when others =>      --reserved                                          
	                axi_arready <= '0';                                          
	                axi_rvalid <= '0';                                          
	           end case;                                          
	         end if;                                          
	       end if;                                                   
	  end process;                                          
	-- Implement memory mapped register select and read logic generation
	 S_AXI_RDATA <= register_bank_rd(to_integer(unsigned(axi_araddr(ADDR_LSB+OPT_MEM_ADDR_BITS downto ADDR_LSB))));

	-- Add user logic here

    bram_clk <= S_AXI_ACLK;
    bram_rst <= '0';
    bram_ena <= '1';
    
    process(S_AXI_ACLK) begin
    if (rising_edge(S_AXI_ACLK)) then
        if (S_AXI_ARESETN = '0') then
            bram_addr <= ( others => '0' );
            bram_din <= ( others => '0' );
            bram_wea <= ( others => '0' );
            fifo_head_reg <= ( others => '0' );
            intr_reg <= '0';
            
        else

            register_bank_rd(0) <= register_bank_wr(0)(register_bank_wr(0)'length-1 downto fifo_head_reg'length) & fifo_head_reg;
            register_bank_rd(1) <= register_bank_wr(1)(register_bank_wr(1)'length-1 downto 1) & intr_reg;
            register_bank_rd(3) <= std_logic_vector(to_unsigned(FIFO_LENGTH, register_bank_rd(3)'length));

            a_mm_wren_d0 <= a_mm_wren;
            
            if (((a_mm_wren xor a_mm_wren_d0) and a_mm_wren) = '1') then
            
                if (fifo_head_reg < (FIFO_LENGTH-1)) then
                    fifo_head_reg <= (std_logic_vector(unsigned(fifo_head_reg) + 1));
                else
                    fifo_head_reg <= ( others => '0' ); 
                end if;
                
                intr_reg <= '1';
            else
                intr_reg <= register_bank_wr(1)(0);
            end if;
            
            if (a_mm_wren = '1') then
                a_mm_data_d0 <= a_mm_data; 
                bram_din <= a_mm_data & a_mm_data_d0;
                
                if (a_mm_addr(0) = '0') then
                    bram_addr <= std_logic_vector(shift_left(unsigned(a_mm_addr), 1) + unsigned(offsets(to_integer(unsigned(fifo_head_reg)))));
                    bram_wea <= ( others => '0');
                else
                    bram_wea <= ( others => '1');
                end if;
            end if;
        end if;
    end if;
end process;

-- User logic ends

end impl;
