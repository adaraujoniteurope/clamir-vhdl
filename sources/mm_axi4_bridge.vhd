library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mm_axi4_bridge is
	generic (
		-- users to add parameters here

		-- user parameters ends
		-- do not modify the parameters beyond this line

		-- width of id for for write address, write data, read address and read data
		C_S_AXI_ID_WIDTH	: integer	:= 1;
		-- width of s_axi data bus
		d	: integer	:= 32;
		-- width of s_axi address bus
		C_S_AXI_ADDR_WIDTH	: integer	:= 6;
		-- width of optional user defined signal in write address channel
		C_S_AXI_AWUSER_WIDTH	: integer	:= 0;
		-- width of optional user defined signal in read address channel
		C_S_AXI_ARUSER_WIDTH	: integer	:= 0;
		-- width of optional user defined signal in write data channel
		C_S_AXI_WUSER_WIDTH	: integer	:= 0;
		-- width of optional user defined signal in read data channel
		C_S_AXI_RUSER_WIDTH	: integer	:= 0;
		-- width of optional user defined signal in write response channel
		C_S_AXI_BUSER_WIDTH	: integer	:= 0
	);
	port (
		-- users to add ports here

		-- user ports ends
		-- do not modify the ports beyond this line

		-- global clock signal
		s_axi_aclk	: in std_logic;
		-- global reset signal. this signal is active low
		s_axi_aresetn	: in std_logic;
		-- write address id
		s_axi_awid	: in std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
		-- write address
		s_axi_awaddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- burst length. the burst length gives the exact number of transfers in a burst
		s_axi_awlen	: in std_logic_vector(7 downto 0);
		-- burst size. this signal indicates the size of each transfer in the burst
		s_axi_awsize	: in std_logic_vector(2 downto 0);
		-- burst type. the burst type and the size information, 
    -- determine how the address for each transfer within the burst is calculated.
		s_axi_awburst	: in std_logic_vector(1 downto 0);
		-- lock type. provides additional information about the
    -- atomic characteristics of the transfer.
		s_axi_awlock	: in std_logic;
		-- memory type. this signal indicates how transactions
    -- are required to progress through a system.
		s_axi_awcache	: in std_logic_vector(3 downto 0);
		-- protection type. this signal indicates the privilege
    -- and security level of the transaction, and whether
    -- the transaction is a data access or an instruction access.
		s_axi_awprot	: in std_logic_vector(2 downto 0);
		-- quality of service, qos identifier sent for each
    -- write transaction.
		s_axi_awqos	: in std_logic_vector(3 downto 0);
		-- region identifier. permits a single physical interface
    -- on a slave to be used for multiple logical interfaces.
		s_axi_awregion	: in std_logic_vector(3 downto 0);
		-- optional user-defined signal in the write address channel.
		s_axi_awuser	: in std_logic_vector(C_S_AXI_AWUSER_WIDTH-1 downto 0);
		-- write address valid. this signal indicates that
    -- the channel is signaling valid write address and
    -- control information.
		s_axi_awvalid	: in std_logic;
		-- write address ready. this signal indicates that
    -- the slave is ready to accept an address and associated
    -- control signals.
		s_axi_awready	: out std_logic;
		-- write data
		s_axi_wdata	: in std_logic_vector(d-1 downto 0);
		-- write strobes. this signal indicates which byte
    -- lanes hold valid data. there is one write strobe
    -- bit for each eight bits of the write data bus.
		s_axi_wstrb	: in std_logic_vector((d/8)-1 downto 0);
		-- write last. this signal indicates the last transfer
    -- in a write burst.
		s_axi_wlast	: in std_logic;
		-- optional user-defined signal in the write data channel.
		s_axi_wuser	: in std_logic_vector(c_s_axi_wuser_width-1 downto 0);
		-- write valid. this signal indicates that valid write
    -- data and strobes are available.
		s_axi_wvalid	: in std_logic;
		-- write ready. this signal indicates that the slave
    -- can accept the write data.
		s_axi_wready	: out std_logic;
		-- response id tag. this signal is the id tag of the
    -- write response.
		s_axi_bid	: out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
		-- write response. this signal indicates the status
    -- of the write transaction.
		s_axi_bresp	: out std_logic_vector(1 downto 0);
		-- optional user-defined signal in the write response channel.
		s_axi_buser	: out std_logic_vector(C_S_AXI_BUSER_WIDTH-1 downto 0);
		-- write response valid. this signal indicates that the
    -- channel is signaling a valid write response.
		s_axi_bvalid	: out std_logic;
		-- response ready. this signal indicates that the master
    -- can accept a write response.
		s_axi_bready	: in std_logic;
		-- read address id. this signal is the identification
    -- tag for the read address group of signals.
		s_axi_arid	: in std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
		-- read address. this signal indicates the initial
    -- address of a read burst transaction.
		s_axi_araddr	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		-- burst length. the burst length gives the exact number of transfers in a burst
		s_axi_arlen	: in std_logic_vector(7 downto 0);
		-- burst size. this signal indicates the size of each transfer in the burst
		s_axi_arsize	: in std_logic_vector(2 downto 0);
		-- burst type. the burst type and the size information, 
    -- determine how the address for each transfer within the burst is calculated.
		s_axi_arburst	: in std_logic_vector(1 downto 0);
		-- lock type. provides additional information about the
    -- atomic characteristics of the transfer.
		s_axi_arlock	: in std_logic;
		-- memory type. this signal indicates how transactions
    -- are required to progress through a system.
		s_axi_arcache	: in std_logic_vector(3 downto 0);
		-- protection type. this signal indicates the privilege
    -- and security level of the transaction, and whether
    -- the transaction is a data access or an instruction access.
		s_axi_arprot	: in std_logic_vector(2 downto 0);
		-- quality of service, qos identifier sent for each
    -- read transaction.
		s_axi_arqos	: in std_logic_vector(3 downto 0);
		-- region identifier. permits a single physical interface
    -- on a slave to be used for multiple logical interfaces.
		s_axi_arregion	: in std_logic_vector(3 downto 0);
		-- optional user-defined signal in the read address channel.
		s_axi_aruser	: in std_logic_vector(C_S_AXI_ARUSER_WIDTH-1 downto 0);
		-- write address valid. this signal indicates that
    -- the channel is signaling valid read address ANd
    -- control information.
		s_axi_arvalid	: in std_logic;
		-- read address ready. this signal indicates that
    -- the slave is ready to accept an address and associated
    -- control signals.
		s_axi_arready	: out std_logic;
		-- read id tag. this signal is the identification tag
    -- for the read data group of signals generated by the slave.
		s_axi_rid	: out std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
		-- read data
		s_axi_rdata	: out std_logic_vector(d-1 downto 0);
		-- read response. this signal indicates the status of
    -- the read transfer.
		s_axi_rresp	: out std_logic_vector(1 downto 0);
		-- read last. this signal indicates the last transfer
    -- in a read burst.
		s_axi_rlast	: out std_logic;
		-- optional user-defined signal in the read address channel.
		s_axi_ruser	: out std_logic_vector(C_S_AXI_RUSER_WIDTH-1 downto 0);
		-- read valid. this signal indicates that the channel
    -- is signaling the required read data.
		s_axi_rvalid	: out std_logic;
		-- read ready. this signal indicates that the master can
    -- accept the read data and response information.
		s_axi_rready	: in std_logic
	);
end mm_axi4_bridge;

architecture arch_imp of mm_axi4_bridge is

	-- axi4full signals
	signal axi_awaddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_awready	: std_logic;
	signal axi_wready	: std_logic;
	signal axi_bid	: std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
	signal axi_bresp	: std_logic_vector(1 downto 0);
	signal axi_buser	: std_logic_vector(C_S_AXI_BUSER_WIDTH-1 downto 0);
	signal axi_bvalid	: std_logic;
	signal axi_araddr	: std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
	signal axi_arready	: std_logic;
	signal axi_rid	: std_logic_vector(C_S_AXI_ID_WIDTH-1 downto 0);
	signal axi_rresp	: std_logic_vector(1 downto 0);
	signal axi_rlast	: std_logic;
	signal axi_ruser	: std_logic_vector(C_S_AXI_RUSER_WIDTH-1 downto 0);
	signal axi_rvalid	: std_logic;
	-- aw_wrap_en determines wrap boundary and enables wrapping
	signal  aw_wrap_en : std_logic; 
	-- ar_wrap_en determines wrap boundary and enables wrapping
	signal  ar_wrap_en : std_logic;
	-- aw_wrap_size is the size of the write transfer, the
	-- write address wraps to a lower address if upper address
	-- limit is reached
	signal aw_wrap_size : integer;
	-- ar_wrap_size is the size of the read transfer, the
	-- read address wraps to a lower address if upper address
	-- limit is reached
	signal ar_wrap_size : integer;
	-- the axi_awlen_cntr internal write address counter to keep track of beats in a burst transaction
	signal axi_awlen_cntr      : std_logic_vector(7 downto 0);
	--the axi_arlen_cntr internal read address counter to keep track of beats in a burst transaction
	signal axi_arlen_cntr      : std_logic_vector(7 downto 0);
	signal axi_arburst      : std_logic_vector(2-1 downto 0);
	signal axi_awburst      : std_logic_vector(2-1 downto 0);
	signal axi_arlen      : std_logic_vector(8-1 downto 0);
	signal axi_awlen      : std_logic_vector(8-1 downto 0);
	--local parameter for addressing 32 bit / 64 bit d
	--addr_lsb is used for addressing 32/64 bit registers/memories
	--addr_lsb = 2 for 32 bits (n downto 2) 
	--addr_lsb = 3 for 64 bits (n downto 3)

	--addr_lsb = 4 for 128 bits (n downto 4)

	constant addr_lsb  : integer := (d/32)+ 1;
	constant opt_mem_addr_bits : integer := 3;
	constant user_num_mem: integer := 1;
	constant low : std_logic_vector (C_S_AXI_ADDR_WIDTH - 1 downto 0) := "000000";

	------------------------------------------------
	---- signals for user logic memory space example
	--------------------------------------------------
	signal mem_address_read : std_logic_vector(opt_mem_addr_bits downto 0);
	signal mem_address_write : std_logic_vector(opt_mem_addr_bits downto 0);
	type word_array is array (0 to user_num_mem-1) of std_logic_vector(d-1 downto 0);
	signal mem_data_out : word_array;

	signal i : integer;
	signal j : integer;
	signal mem_byte_index : integer;
	type byte_ram_type is array (0 to 15) of std_logic_vector(7 downto 0);
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
	s_axi_buser	<= axi_buser;
	s_axi_bvalid	<= axi_bvalid;
	s_axi_arready	<= axi_arready;
	s_axi_rresp	<= axi_rresp;
	s_axi_rlast	<= axi_rlast;
	s_axi_ruser	<= axi_ruser;
	s_axi_rvalid	<= axi_rvalid;
	s_axi_bid <= axi_bid;
	s_axi_rid <= axi_rid;
	s_axi_rdata	<= mem_data_out(0);
	aw_wrap_size <= ((d)/8 * to_integer(unsigned(axi_awlen))); 
	ar_wrap_size <= ((d)/8 * to_integer(unsigned(axi_arlen))); 
	aw_wrap_en <= '1' when (((axi_awaddr and std_logic_vector(to_unsigned(aw_wrap_size,C_S_AXI_ADDR_WIDTH))) xor std_logic_vector(to_unsigned(aw_wrap_size,C_S_AXI_ADDR_WIDTH))) = low) else '0';
	ar_wrap_en <= '1' when (((axi_araddr and std_logic_vector(to_unsigned(ar_wrap_size,C_S_AXI_ADDR_WIDTH))) xor std_logic_vector(to_unsigned(ar_wrap_size,C_S_AXI_ADDR_WIDTH))) = low) else '0';

	--implement write state machine
	--outstanding write transactions are not supported by the slave i.e., master should assert bready to receive response on or before it starts sending the new transaction
	 process (s_axi_aclk)                                  
	   begin                                  
	     if rising_edge(s_axi_aclk) then                                   
	       if s_axi_aresetn = '0' then                                  
	        --asserting initial values to all 0's during reset                                  
	        axi_awready <= '0';                                  
	        axi_wready <= '0';                                  
	        axi_bvalid <= '0';                                  
	        axi_buser <= (others => '0');                                  
	        axi_awburst <= (others => '0');                                  
	        axi_bid <= (others => '0');                                  
	        axi_awlen <= (others => '0');                                  
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
	              if (s_axi_wvalid = '1' and s_axi_wlast = '1') then                                  
	                axi_bvalid <= '1';                                  
	                axi_awready <= '1';                                  
	                state_write <= waddr;                                  
	              else                                   
	                if(s_axi_bready = '1' and axi_bvalid = '1') then                                  
	                  axi_bvalid <= '0';                                  
	                end if;                                  
	                state_write <= wdata;                                  
	                axi_awready <= '0';                                  
	             end if;                                  
	             axi_awburst <= s_axi_awburst;                                  
	             axi_awlen <= s_axi_awlen;                                  
	             axi_bid <= s_axi_awid;                                  
	           else                                  
	             state_write <= state_write;                                  
	             if(s_axi_bready = '1' and axi_bvalid = '1') then                                  
	               axi_bvalid <= '0';                                  
	             end if;                                  
	           end if;                                  
	         when wdata =>		--at this state, slave is ready to receive the data packets until the number of transfers is equal to burst length                                  
	           if (s_axi_wvalid = '1' and s_axi_wlast = '1') then                                  
	             state_write <= waddr;                                  
	             axi_bvalid <= '1';                                  
	             axi_awready <= '1';                                  
	           else                                  
	             state_write <= state_write;                                  
	           end if;                                  
	         when others =>      --reserved                                  
	           axi_awready <= '0';                                  
	           axi_wready <= '0';                                  
	           axi_bvalid <= '0';                                  
	       end case;                                  
	     end if;                                  
	   end if;                                           
	 end process;                                   
	--implement read state machine
	--outstanding read transactions are not supported by the slave

	 process (s_axi_aclk)                                     
	   begin                                     
	     if rising_edge(s_axi_aclk) then                                      
	       if s_axi_aresetn = '0' then                                     
	         --asserting initial values to all 0's during reset                                     
	         axi_arready <= '0';                                     
	         axi_rvalid <= '0';                                     
	         axi_rlast <= '0';                                     
	         axi_ruser <= (others => '0');                                     
	         axi_arburst <= (others => '0');                                     
	         axi_rid <= (others => '0');                                     
	         axi_arlen <= (others => '0');                                     
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
	               if (s_axi_arlen = "00000000") then                                     
	                 axi_rlast <= '1';                                     
	               end if;                                     
	               axi_arburst <= s_axi_arburst;                                     
	               axi_arlen <= s_axi_arlen;                                     
	               axi_rid <= s_axi_arid;                                     
	            else                                     
	              state_read <= state_read;                                     
	            end if;                                     
	          when rdata =>		--at this state, slave is ready to send the data packets until the number of transfers is equal to burst length                                     
	            if ((axi_arlen_cntr = std_logic_vector(unsigned(axi_arlen(7 downto 0))-1)) and axi_rlast = '0' and s_axi_rready = '1') then                                     
	              axi_rlast <= '1';                                     
	            end if;                                     
	            if (axi_rvalid = '1' and s_axi_rready = '1' and axi_rlast = '1') then                                     
	              axi_rvalid <= '0';                                     
	              axi_arready <= '1';                                     
	              axi_rlast <= '0';                                     
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
	--this always block handles the write address increment
	 process (s_axi_aclk)                             
	   begin                             
	     if rising_edge(s_axi_aclk) then                              
	       if s_axi_aresetn = '0' then                             
	       --both axi_awlen_cntr and axi_awaddr will increment after each successfull data received until the number of the transfers is equal to burst length                             
	         axi_awaddr <= (others => '0');                             
	         axi_awlen_cntr <= (others => '0');                             
	       else                             
	        if (s_axi_awvalid = '1' and axi_awready = '1') then                             
	          if (s_axi_wvalid = '1') then                             
	            axi_awlen_cntr <= "00000001";                             
	            if ((s_axi_awburst = "01") or ((s_axi_awburst = "10") and (s_axi_awlen /= "00000000"))  ) then                             
	              axi_awaddr(C_S_AXI_ADDR_WIDTH - 1 downto addr_lsb) <= std_logic_vector (unsigned(s_axi_awaddr(C_S_AXI_ADDR_WIDTH - 1 downto addr_lsb)) + 1);--awaddr aligned to 4 byte boundary                             
	            else                             
	              axi_awaddr <= axi_awaddr;                             
	            end if;                             
	          else                             
	            axi_awlen_cntr <= "00000000";                             
	            axi_awaddr <= std_logic_vector (unsigned(s_axi_awaddr(C_S_AXI_ADDR_WIDTH -1 downto 0)));                             
	          end if;                             
	        elsif((axi_awlen_cntr < axi_awlen) and s_axi_wvalid = '1') then                              
	          axi_awlen_cntr <= std_logic_vector (unsigned(axi_awlen_cntr) + 1);                             
	          case (axi_awburst) is                             
	            when "00" => -- fixed burst                             
	              -- the write address for all the beats in the transaction are fixed                             
	              axi_awaddr     <= axi_awaddr;       ----for awsize = 4 bytes (010)                             
	            when "01" => --incremental burst                             
	              -- the write address for all the beats in the transaction are increments by awsize                             
	              axi_awaddr(C_S_AXI_ADDR_WIDTH - 1 downto addr_lsb) <= std_logic_vector (unsigned(axi_awaddr(C_S_AXI_ADDR_WIDTH - 1 downto addr_lsb)) + 1);--awaddr aligned to 4 byte boundary            
	              axi_awaddr(addr_lsb-1 downto 0)  <= (others => '0');  ----for awsize = 4 bytes (010)                             
	            when "10" => --wrapping burst                             
	              -- the write address wraps when the address reaches wrap boundary                             
	              if (aw_wrap_en = '1') then                             
	                axi_awaddr <= std_logic_vector (unsigned(axi_awaddr) - (to_unsigned(aw_wrap_size,C_S_AXI_ADDR_WIDTH)));                             
	              else                              
	                axi_awaddr(C_S_AXI_ADDR_WIDTH - 1 downto addr_lsb) <= std_logic_vector (unsigned(axi_awaddr(C_S_AXI_ADDR_WIDTH - 1 downto addr_lsb)) + 1);--awaddr aligned to 4 byte boundary                      
	                axi_awaddr(addr_lsb-1 downto 0)  <= (others => '0');  ----for awsize = 4 bytes (010)                             
	              end if;                             
	            when others => --reserved (incremental burst for example)                             
	              axi_awaddr(C_S_AXI_ADDR_WIDTH - 1 downto addr_lsb) <= std_logic_vector (unsigned(axi_awaddr(C_S_AXI_ADDR_WIDTH - 1 downto addr_lsb)) + 1);--for awsize = 4 bytes (010)                             
	              axi_awaddr(addr_lsb-1 downto 0)  <= (others => '0');                             
	          end case;                                     
	        end if;                             
	      end if;                             
	    end if;                             
	 end process;                              
	--this always block handles the read address increment
	 process (s_axi_aclk)                                   
	   begin                                   
	     if rising_edge(s_axi_aclk) then                                    
	       if s_axi_aresetn = '0' then                                   
	         --both axi_arlen_cntr and axi_araddr will increment after each successfull data received until the number of the transfers is equal to burst length                                   
	         axi_araddr <= (others => '0');                                   
	         axi_arlen_cntr <= (others => '0');                                   
	       else                                   
	         if (s_axi_arvalid = '1' and axi_arready = '1') then                                   
	           axi_arlen_cntr <= (others => '0');                                   
	           axi_araddr <= std_logic_vector (unsigned(s_axi_araddr(C_S_AXI_ADDR_WIDTH -1 downto 0)));                                   
	         elsif((axi_arlen_cntr <= axi_arlen) and axi_rvalid = '1' and s_axi_rready = '1') then                                        
	           axi_arlen_cntr <= std_logic_vector (unsigned(axi_arlen_cntr) + 1);                                   
	           case (axi_arburst) is                                   
	             when "00" => -- fixed burst                                   
	               -- the read address for all the beats in the transaction are fixed                                   
	               axi_araddr     <= axi_araddr;       ----for arsize = 4 bytes (010)                                   
	             when "01" => --incremental burst                                   
	               -- the read address for all the beats in the transaction are increments by arsize                                   
	               axi_araddr(C_S_AXI_ADDR_WIDTH - 1 downto addr_lsb) <= std_logic_vector (unsigned(axi_araddr(C_S_AXI_ADDR_WIDTH - 1 downto addr_lsb)) + 1);--araddr aligned to 4 byte boundary                                   
	               axi_araddr(addr_lsb-1 downto 0)  <= (others => '0');  ----for arsize = 4 bytes (010)                                   
	             when "10" => --wrapping burst                                   
	               -- the read address wraps when the address reaches wrap boundary                                    
	               if (ar_wrap_en = '1') then                                   
	                 axi_araddr <= std_logic_vector (unsigned(axi_araddr) - (to_unsigned(ar_wrap_size,C_S_AXI_ADDR_WIDTH)));                                   
	               else                                    
	                 axi_araddr(C_S_AXI_ADDR_WIDTH - 1 downto addr_lsb) <= std_logic_vector (unsigned(axi_araddr(C_S_AXI_ADDR_WIDTH - 1 downto addr_lsb)) + 1);--araddr aligned to 4 byte boundary                                   
	                 axi_araddr(addr_lsb-1 downto 0)  <= (others => '0');  ----for arsize = 4 bytes (010)                                   
	               end if;                                   
	             when others => --reserved (incremental burst for example)                                   
	               axi_araddr(C_S_AXI_ADDR_WIDTH - 1 downto addr_lsb) <= std_logic_vector (unsigned(axi_araddr(C_S_AXI_ADDR_WIDTH - 1 downto addr_lsb)) + 1);--for arsize = 4 bytes (010)                                   
	               axi_araddr(addr_lsb-1 downto 0)  <= (others => '0');                                   
	           end case;                                           
	         end if;                                   
	       end if;                                   
	     end if;                                   
	 end process;                                   
	---- ------------------------------------------
	---- -- example code to access user logic memory region
	---- ------------------------------------------
	 gen_mem_sel: if (user_num_mem >= 1) generate                                 
	   begin                                 
	     mem_address_read <= axi_araddr(addr_lsb+opt_mem_addr_bits downto addr_lsb);                                 
	      mem_address_write <= s_axi_awaddr(addr_lsb+opt_mem_addr_bits downto addr_lsb) when (s_axi_awvalid = '1' and s_axi_wvalid = '1') else                                 
	                       axi_awaddr(addr_lsb+opt_mem_addr_bits downto addr_lsb);                                 
	 end generate gen_mem_sel;                                  
	 -- implement block ram(s)                                 
	 bram_gen : for i in 0 to user_num_mem-1 generate                                 
	    signal mem_wren : std_logic;                                 
	    begin                                 
	      mem_wren <= axi_wready and s_axi_wvalid ;                                 
	      byte_bram_gen : for mem_byte_index in 0 to (d/8-1) generate                                 
	      signal byte_ram : byte_ram_type;                                 
	      signal data_in  : std_logic_vector(8-1 downto 0);                                 
	      signal data_out : std_logic_vector(8-1 downto 0);                                 
	      begin                                 
	       --assigning 8 bit data                                 
	        data_in  <= s_axi_wdata((mem_byte_index*8+7) downto mem_byte_index*8);                                 
	        data_out <= byte_ram(to_integer(unsigned(mem_address_read)));                                 
	        byte_ram_proc : process( s_axi_aclk ) is                                 
	          begin                                 
	           if ( rising_edge (s_axi_aclk) ) then                                 
	             if ( mem_wren = '1' and s_axi_wstrb(mem_byte_index) = '1' ) then                                 
	                byte_ram(to_integer(unsigned(mem_address_write))) <= data_in;                                 
	             end if;                                 
	          end if;                                   
	        end process byte_ram_proc;                                 
	       mem_data_out(i)((mem_byte_index*8+7) downto mem_byte_index*8) <= data_out;                                  
	     end generate byte_bram_gen;                                 
	 end generate bram_gen;                                 
	-- add user logic here
 	-- user logic ends 


	-- add user logic here

	-- user logic ends

end arch_imp;
