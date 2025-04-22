library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mm_linear_correction_ctrl is
	generic (
		-- users to add parameters here

		-- user parameters ends
		-- do not modify the parameters beyond this line

		-- width of s_axi data bus
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		-- width of s_axi address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 7
	);
	port (
		-- users to add ports here
		
        reg0	    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg1	    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg2	    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg3	    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg4	    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg5	    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg6	    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
        reg7	    : out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		
		-- user ports ends
		-- do not modify the ports beyond this line

		-- global clock signal
		s_axi_aclk	: in std_logic;
		-- global reset signal. this signal is active low
		s_axi_aresetn	: in std_logic;
		-- write address (issued by master, acceped by slave)
		s_axi_awaddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- write channel protection type. this signal indicates the
    		-- privilege and security level of the transaction, and whether
    		-- the transaction is a data access or an instruction access.
		s_axi_awprot	: in std_logic_vector(2 downto 0);
		-- write address valid. this signal indicates that the master signaling
    		-- valid write address and control information.
		s_axi_awvalid	: in std_logic;
		-- write address ready. this signal indicates that the slave is ready
    		-- to accept an address and associated control signals.
		s_axi_awready	: out std_logic;
		-- write data (issued by master, acceped by slave) 
		s_axi_wdata	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- write strobes. this signal indicates which byte lanes hold
    		-- valid data. there is one write strobe bit for each eight
    		-- bits of the write data bus.    
		s_axi_wstrb	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		-- write valid. this signal indicates that valid write
    		-- data and strobes are available.
		s_axi_wvalid	: in std_logic;
		-- write ready. this signal indicates that the slave
    		-- can accept the write data.
		s_axi_wready	: out std_logic;
		-- write response. this signal indicates the status
    		-- of the write transaction.
		s_axi_bresp	: out std_logic_vector(1 downto 0);
		-- write response valid. this signal indicates that the channel
    		-- is signaling a valid write response.
		s_axi_bvalid	: out std_logic;
		-- response ready. this signal indicates that the master
    		-- can accept a write response.
		s_axi_bready	: in std_logic;
		-- read address (issued by master, acceped by slave)
		s_axi_araddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- protection type. this signal indicates the privilege
    		-- and security level of the transaction, and whether the
    		-- transaction is a data access or an instruction access.
		s_axi_arprot	: in std_logic_vector(2 downto 0);
		-- read address valid. this signal indicates that the channel
    		-- is signaling valid read address and control information.
		s_axi_arvalid	: in std_logic;
		-- read address ready. this signal indicates that the slave is
    		-- ready to accept an address and associated control signals.
		s_axi_arready	: out std_logic;
		-- read data (issued by slave)
		s_axi_rdata	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		-- read response. this signal indicates the status of the
    		-- read transfer.
		s_axi_rresp	: out std_logic_vector(1 downto 0);
		-- read valid. this signal indicates that the channel is
    		-- signaling the required read data.
		s_axi_rvalid	: out std_logic;
		-- read ready. this signal indicates that the master can
    		-- accept the read data and response information.
		s_axi_rready	: in std_logic
	);
end mm_linear_correction_ctrl;

architecture arch_imp of mm_linear_correction_ctrl is

	-- axi4lite signals
	signal axi_awaddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_awready	: std_logic;
	signal axi_wready	: std_logic;
	signal axi_bresp	: std_logic_vector(1 downto 0);
	signal axi_bvalid	: std_logic;
	signal axi_araddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_arready	: std_logic;
	signal axi_rresp	: std_logic_vector(1 downto 0);
	signal axi_rvalid	: std_logic;

	-- example-specific design signals
	-- local parameter for addressing 32 bit / 64 bit C_S_AXI_DATA_WIDTH
	-- addr_lsb is used for addressing 32/64 bit registers/memories
	-- addr_lsb = 2 for 32 bits (n downto 2)
	-- addr_lsb = 3 for 64 bits (n downto 3)
	constant addr_lsb  : integer := (C_S_AXI_DATA_WIDTH/32)+ 1;
	constant opt_mem_addr_bits : integer := 4;
	------------------------------------------------
	---- signals for user logic register space example
	--------------------------------------------------
	---- number of slave registers 32
	signal slv_reg0	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg1	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg2	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg3	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg4	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg5	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg6	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg7	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg8	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg9	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg10	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg11	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg12	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg13	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg14	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg15	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg16	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg17	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg18	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg19	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg20	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg21	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg22	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg23	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg24	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg25	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg26	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg27	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg28	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg29	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg30	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal slv_reg31	:std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
	signal byte_index	: integer;

	 signal mem_logic  : std_logic_vector(addr_lsb + opt_mem_addr_bits downto addr_lsb);

	 --state machine local parameters
	constant idle : std_logic_vector(1 downto 0) := "00";
	constant raddr: std_logic_vector(1 downto 0) := "10";
	constant rdata: std_logic_vector(1 downto 0) := "11";
	constant waddr: std_logic_vector(1 downto 0) := "10";
	constant wdata: std_logic_vector(1 downto 0) := "11";
	 --state machine variables
	signal state_read : std_logic_vector(1 downto 0);
	signal state_write: std_logic_vector(1 downto 0); 
begin
	-- i/o connections assignments

	s_axi_awready	<= axi_awready;
	s_axi_wready	<= axi_wready;
	s_axi_bresp	<= axi_bresp;
	s_axi_bvalid	<= axi_bvalid;
	s_axi_arready	<= axi_arready;
	s_axi_rresp	<= axi_rresp;
	s_axi_rvalid	<= axi_rvalid;
	    mem_logic     <= s_axi_awaddr(addr_lsb + opt_mem_addr_bits downto addr_lsb) when (s_axi_awvalid = '1') else axi_awaddr(addr_lsb + opt_mem_addr_bits downto addr_lsb);

    reg0 <= slv_reg0;
    reg1 <= slv_reg1;
    reg2 <= slv_reg2;
    reg3 <= slv_reg3;
    reg4 <= slv_reg4;
    reg5 <= slv_reg5;
    reg6 <= slv_reg6;
    reg7 <= slv_reg7;

	-- implement write state machine
	-- outstanding write transactions are not supported by the slave i.e., master should assert bready to receive response on or before it starts sending the new transaction
	 process (s_axi_aclk)                                       
	   begin                                       
	     if rising_edge(s_axi_aclk) then                                       
	        if s_axi_aresetn = '0' then                                       
	          --asserting initial values to all 0's during reset                                       
	          axi_awready <= '0';                                       
	          axi_wready <= '0';                                       
	          axi_bvalid <= '0';                                       
	          axi_bresp <= (others => '0');                                       
	          state_write <= idle;                                       
	        else                                       
	          case (state_write) is                                       
	             when idle =>		--initial state inidicating reset is done and ready to receive read/write transactions                                       
	               if (s_axi_aresetn = '1') then                                       
	                 axi_awready <= '1';                                       
	                 axi_wready <= '1';                                       
	                 state_write <= waddr;                                       
	               else state_write <= state_write;                                       
	               end if;                                       
	             when waddr =>		--at this state, slave is ready to receive address along with corresponding control signals and first data packet. response valid is also handled at this state                                       
	               if (s_axi_awvalid = '1' and axi_awready = '1') then                                       
	                 axi_awaddr <= s_axi_awaddr;                                       
	                 if (s_axi_wvalid = '1') then                                       
	                   axi_awready <= '1';                                       
	                   state_write <= waddr;                                       
	                   axi_bvalid <= '1';                                       
	                 else                                       
	                   axi_awready <= '0';                                       
	                   state_write <= wdata;                                       
	                   if (s_axi_bready = '1' and axi_bvalid = '1') then                                       
	                     axi_bvalid <= '0';                                       
	                   end if;                                       
	                 end if;                                       
	               else                                        
	                 state_write <= state_write;                                       
	                 if (s_axi_bready = '1' and axi_bvalid = '1') then                                       
	                   axi_bvalid <= '0';                                       
	                 end if;                                       
	               end if;                                       
	             when wdata =>		--at this state, slave is ready to receive the data packets until the number of transfers is equal to burst length                                       
	               if (s_axi_wvalid = '1') then                                       
	                 state_write <= waddr;                                       
	                 axi_bvalid <= '1';                                       
	                 axi_awready <= '1';                                       
	               else                                       
	                 state_write <= state_write;                                       
	                 if (s_axi_bready ='1' and axi_bvalid = '1') then                                       
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
	-- implement memory mapped register select and write logic generation
	-- the write data is accepted and written to memory mapped registers when
	-- axi_awready, s_axi_wvalid, axi_wready and s_axi_wvalid are asserted. write strobes are used to
	-- select byte enables of slave registers while writing.
	-- these registers are cleared when reset (active low) is applied.
	-- slave register write enable is asserted when valid address and data are available
	-- and the slave is ready to accept the write address and write data.
	

	process (s_axi_aclk)
	begin
	  if rising_edge(s_axi_aclk) then 
	    if s_axi_aresetn = '0' then
	      slv_reg0 <= (others => '0');
	      slv_reg1 <= (others => '0');
	      slv_reg2 <= (others => '0');
	      slv_reg3 <= (others => '0');
	      slv_reg4 <= (others => '0');
	      slv_reg5 <= (others => '0');
	      slv_reg6 <= (others => '0');
	      slv_reg7 <= (others => '0');
	      slv_reg8 <= (others => '0');
	      slv_reg9 <= (others => '0');
	      slv_reg10 <= (others => '0');
	      slv_reg11 <= (others => '0');
	      slv_reg12 <= (others => '0');
	      slv_reg13 <= (others => '0');
	      slv_reg14 <= (others => '0');
	      slv_reg15 <= (others => '0');
	      slv_reg16 <= (others => '0');
	      slv_reg17 <= (others => '0');
	      slv_reg18 <= (others => '0');
	      slv_reg19 <= (others => '0');
	      slv_reg20 <= (others => '0');
	      slv_reg21 <= (others => '0');
	      slv_reg22 <= (others => '0');
	      slv_reg23 <= (others => '0');
	      slv_reg24 <= (others => '0');
	      slv_reg25 <= (others => '0');
	      slv_reg26 <= (others => '0');
	      slv_reg27 <= (others => '0');
	      slv_reg28 <= (others => '0');
	      slv_reg29 <= (others => '0');
	      slv_reg30 <= (others => '0');
	      slv_reg31 <= (others => '0');
	    else
	      if (s_axi_wvalid = '1') then
	          case (mem_logic) is
	          when b"00000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 0
	                slv_reg0(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"00001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 1
	                slv_reg1(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"00010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 2
	                slv_reg2(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"00011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 3
	                slv_reg3(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"00100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 4
	                slv_reg4(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"00101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 5
	                slv_reg5(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"00110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 6
	                slv_reg6(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"00111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 7
	                slv_reg7(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"01000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 8
	                slv_reg8(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"01001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 9
	                slv_reg9(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"01010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 10
	                slv_reg10(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"01011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 11
	                slv_reg11(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"01100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 12
	                slv_reg12(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"01101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 13
	                slv_reg13(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"01110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 14
	                slv_reg14(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"01111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 15
	                slv_reg15(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"10000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 16
	                slv_reg16(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"10001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 17
	                slv_reg17(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"10010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 18
	                slv_reg18(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"10011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 19
	                slv_reg19(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"10100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 20
	                slv_reg20(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"10101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 21
	                slv_reg21(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"10110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 22
	                slv_reg22(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"10111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 23
	                slv_reg23(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"11000" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 24
	                slv_reg24(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"11001" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 25
	                slv_reg25(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"11010" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 26
	                slv_reg26(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"11011" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 27
	                slv_reg27(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"11100" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 28
	                slv_reg28(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"11101" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 29
	                slv_reg29(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"11110" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 30
	                slv_reg30(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when b"11111" =>
	            for byte_index in 0 to (C_S_AXI_DATA_WIDTH/8-1) loop
	              if ( s_axi_wstrb(byte_index) = '1' ) then
	                -- respective byte enables are asserted as per write strobes                   
	                -- slave registor 31
	                slv_reg31(byte_index*8+7 downto byte_index*8) <= s_axi_wdata(byte_index*8+7 downto byte_index*8);
	              end if;
	            end loop;
	          when others =>
	            slv_reg0 <= slv_reg0;
	            slv_reg1 <= slv_reg1;
	            slv_reg2 <= slv_reg2;
	            slv_reg3 <= slv_reg3;
	            slv_reg4 <= slv_reg4;
	            slv_reg5 <= slv_reg5;
	            slv_reg6 <= slv_reg6;
	            slv_reg7 <= slv_reg7;
	            slv_reg8 <= slv_reg8;
	            slv_reg9 <= slv_reg9;
	            slv_reg10 <= slv_reg10;
	            slv_reg11 <= slv_reg11;
	            slv_reg12 <= slv_reg12;
	            slv_reg13 <= slv_reg13;
	            slv_reg14 <= slv_reg14;
	            slv_reg15 <= slv_reg15;
	            slv_reg16 <= slv_reg16;
	            slv_reg17 <= slv_reg17;
	            slv_reg18 <= slv_reg18;
	            slv_reg19 <= slv_reg19;
	            slv_reg20 <= slv_reg20;
	            slv_reg21 <= slv_reg21;
	            slv_reg22 <= slv_reg22;
	            slv_reg23 <= slv_reg23;
	            slv_reg24 <= slv_reg24;
	            slv_reg25 <= slv_reg25;
	            slv_reg26 <= slv_reg26;
	            slv_reg27 <= slv_reg27;
	            slv_reg28 <= slv_reg28;
	            slv_reg29 <= slv_reg29;
	            slv_reg30 <= slv_reg30;
	            slv_reg31 <= slv_reg31;
	        end case;
	      end if;
	    end if;
	  end if;                   
	end process; 

	-- implement read state machine
	 process (s_axi_aclk)                                          
	   begin                                          
	     if rising_edge(s_axi_aclk) then                                           
	        if s_axi_aresetn = '0' then                                          
	          --asserting initial values to all 0's during reset                                          
	          axi_arready <= '0';                                          
	          axi_rvalid <= '0';                                          
	          axi_rresp <= (others => '0');                                          
	          state_read <= idle;                                          
	        else                                          
	          case (state_read) is                                          
	            when idle =>		--initial state inidicating reset is done and ready to receive read/write transactions                                          
	                if (s_axi_aresetn = '1') then                                          
	                  axi_arready <= '1';                                          
	                  state_read <= raddr;                                          
	                else state_read <= state_read;                                          
	                end if;                                          
	            when raddr =>		--at this state, slave is ready to receive address along with corresponding control signals                                          
	                if (s_axi_arvalid = '1' and axi_arready = '1') then                                          
	                  state_read <= rdata;                                          
	                  axi_rvalid <= '1';                                          
	                  axi_arready <= '0';                                          
	                  axi_araddr <= s_axi_araddr;                                          
	                else                                          
	                  state_read <= state_read;                                          
	                end if;                                          
	            when rdata =>		--at this state, slave is ready to send the data packets until the number of transfers is equal to burst length                                          
	                if (axi_rvalid = '1' and s_axi_rready = '1') then                                          
	                  axi_rvalid <= '0';                                          
	                  axi_arready <= '1';                                          
	                  state_read <= raddr;                                          
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
	-- implement memory mapped register select and read logic generation
	 s_axi_rdata <= slv_reg0 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "00000" ) else 
	 slv_reg1 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "00001" ) else 
	 slv_reg2 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "00010" ) else 
	 slv_reg3 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "00011" ) else 
	 slv_reg4 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "00100" ) else 
	 slv_reg5 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "00101" ) else 
	 slv_reg6 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "00110" ) else 
	 slv_reg7 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "00111" ) else 
	 slv_reg8 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "01000" ) else 
	 slv_reg9 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "01001" ) else 
	 slv_reg10 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "01010" ) else 
	 slv_reg11 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "01011" ) else 
	 slv_reg12 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "01100" ) else 
	 slv_reg13 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "01101" ) else 
	 slv_reg14 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "01110" ) else 
	 slv_reg15 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "01111" ) else 
	 slv_reg16 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "10000" ) else 
	 slv_reg17 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "10001" ) else 
	 slv_reg18 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "10010" ) else 
	 slv_reg19 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "10011" ) else 
	 slv_reg20 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "10100" ) else 
	 slv_reg21 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "10101" ) else 
	 slv_reg22 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "10110" ) else 
	 slv_reg23 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "10111" ) else 
	 slv_reg24 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "11000" ) else 
	 slv_reg25 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "11001" ) else 
	 slv_reg26 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "11010" ) else 
	 slv_reg27 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "11011" ) else 
	 slv_reg28 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "11100" ) else 
	 slv_reg29 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "11101" ) else 
	 slv_reg30 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "11110" ) else 
	 slv_reg31 when (axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) = "11111" ) else 
	 (others => '0');

	-- add user logic here

	-- user logic ends

end arch_imp;
