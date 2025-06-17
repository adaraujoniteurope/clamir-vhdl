-------------------------------------------------------------------------------
-- Company     : AIMEN
-- Project     : CLAMIR
-- Module      : axi4lite_mngr_arm
-- Description : AXI4-Lite ARM configuration registers manager
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axi4lite_mngr_arm is
	generic (
		C_AXI_ADDR_WIDTH : natural;
		BANK_INDEX_BIT_H : natural;
		BANK_INDEX_BIT_L : natural
	);
	port (
		---------------------------------------------------------------------------
		-- Common register bank connections
		---------------------------------------------------------------------------
		slv_wdata     : out std_logic_vector(31 downto 0);
		slv_addr      : out std_logic_vector(BANK_INDEX_BIT_L-1 downto 0);
		slv_reg_rden  : out std_logic;
		---------------------------------------------------------------------------
		-- Register bank 0 - GEN
		---------------------------------------------------------------------------
		b0_slv_rdata   : in  std_logic_vector(31 downto 0);
		b0_slv_wren    : out std_logic;
		b0_slv_rden    : out std_logic;
		b0_slv_wr_done : in  std_logic;
		b0_slv_rd_done : in  std_logic;
    ---------------------------------------------------------------------------
    -- Register bank 1 - LED
    ---------------------------------------------------------------------------
    b1_slv_rdata   : in  std_logic_vector(31 downto 0);
    b1_slv_wren    : out std_logic;
    b1_slv_rden    : out std_logic;
    b1_slv_wr_done : in  std_logic;
    b1_slv_rd_done : in  std_logic;
		---------------------------------------------------------------------------
		-- AXI4-Lite configuration IF
		---------------------------------------------------------------------------
		s_axi_aclk    : in  std_logic;
		s_axi_aresetn : in  std_logic;
		s_axi_awaddr  : in  std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_awvalid : in  std_logic;
		s_axi_awready : out std_logic;
		s_axi_wdata   : in  std_logic_vector(31 downto 0);
		s_axi_wvalid  : in  std_logic;
		s_axi_wready  : out std_logic;
		s_axi_bresp   : out std_logic_vector(1 downto 0);
		s_axi_bvalid  : out std_logic;
		s_axi_bready  : in  std_logic;
		s_axi_araddr  : in  std_logic_vector(C_AXI_ADDR_WIDTH-1 downto 0);
		s_axi_arvalid : in  std_logic;
		s_axi_arready : out std_logic;
		s_axi_rdata   : out std_logic_vector(31 downto 0);
		s_axi_rresp   : out std_logic_vector(1 downto 0);
		s_axi_rvalid  : out std_logic;
		s_axi_rready  : in  std_logic
	);
end axi4lite_mngr_arm;

architecture behavioral of axi4lite_mngr_arm is

	-- Register bank index
  constant BANK_REG_GEN : integer := 16#44A4#;
  constant BANK_REG_LED : integer := 16#44A5#;
  constant BANK_INDEX   : integer := BANK_INDEX_BIT_H-BANK_INDEX_BIT_L;

  alias s_axi_araddr_bnk : std_logic_vector(BANK_INDEX-1 downto 0) is s_axi_araddr(BANK_INDEX_BIT_H-1 downto BANK_INDEX_BIT_L);

	-- AXI4-Lite signals
	signal axi_awready  : std_logic := '0';
	signal axi_wready   : std_logic := '0';
	signal axi_bresp    : std_logic_vector(1 downto 0) := (others => '0');
	signal axi_bvalid   : std_logic := '0';
	signal axi_arready  : std_logic := '0';
	signal axi_rdata    : std_logic_vector(31 downto 0) := (others => '0');
	signal axi_rresp    : std_logic_vector( 1 downto 0) := (others => '0');
	signal axi_rvalid   : std_logic := '0';

	signal valid_waddr  : std_logic := '0';
	signal slv_rden     : std_logic := '0';
	signal slv_reg_done : std_logic := '0';
	signal slv_rd_addr  : std_logic_vector(BANK_INDEX-1 downto 0) := (others => '0');

	signal all_wready   : std_logic := '0';
	signal b0_wready    : std_logic := '0';
	signal b0_bnk_sel   : std_logic := '0';
  signal b1_wready    : std_logic := '0';
  signal b1_bnk_sel   : std_logic := '0';
	signal bank_wr_done : std_logic := '0';

	signal wr_in_progress : std_logic := '0';
	signal rd_in_progress : std_logic := '0';

begin

  -- Assign output signals
	s_axi_awready <= axi_awready;
	s_axi_wready  <= axi_wready;
	s_axi_bresp   <= axi_bresp;
	s_axi_bvalid  <= axi_bvalid;
	s_axi_arready <= axi_arready;
	s_axi_rdata   <= axi_rdata;
	s_axi_rresp   <= axi_rresp;
	s_axi_rvalid  <= axi_rvalid;

	slv_wdata     <= s_axi_wdata;

  -----------------------------------------------------------------------------
  -- AXI4-Lite WRITE
  -----------------------------------------------------------------------------

	p_wr_flag : process(s_axi_aclk)
	begin
		if rising_edge(s_axi_aclk) then
			if (s_axi_aresetn = '0') then
				wr_in_progress <= '0';
			else
				if ((s_axi_bready = '1') and (axi_bvalid = '1')) then
					wr_in_progress <= '0';
				else
					if (((axi_awready = '1') and (s_axi_awvalid = '1')) or
					    ((axi_wready = '1') and (s_axi_wvalid = '1'))) then
						wr_in_progress <= '1';
					end if;
				end if;
			end if;
		end if;
	end process;

	p_awready : process(s_axi_aclk)
	begin
		if rising_edge(s_axi_aclk) then
			if (s_axi_aresetn = '0') then
				axi_awready <= '0';
			else
				if ((s_axi_arvalid = '0') and (rd_in_progress = '0')) then
					if ((axi_awready = '0') and (s_axi_awvalid = '1') and (valid_waddr = '0')) then
						axi_awready <= '1';
					else
						axi_awready <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;

	p_valid_waddr : process(s_axi_aclk)
	begin
		if rising_edge(s_axi_aclk) then
			if (s_axi_aresetn = '0') then
				valid_waddr <= '0';
			else
				if ((s_axi_arvalid = '0') and (rd_in_progress = '0')) then
					if ((s_axi_bready = '1') and (axi_bvalid = '1')) then
						valid_waddr <= '0';
  				else
  					if ((axi_awready = '0') and (s_axi_awvalid = '1')) then
  						valid_waddr <= '1';
  					end if;
				  end if;
        end if;
			end if;
		end if;
	end process;

	p_bnk_wready : process(s_axi_aclk)
	begin
		if rising_edge(s_axi_aclk) then
			if (s_axi_aresetn = '0') then
				b0_wready <= '0';
        b1_wready <= '0';
			else
				if (s_axi_arvalid = '0') then
					if ((b0_wready = '0') and (s_axi_wvalid = '1') and
						  (valid_waddr = '1') and (b0_bnk_sel = '1')) then
						b0_wready <= '1';
					else
						b0_wready <= '0';
					end if;

          if ((b1_wready = '0') and (s_axi_wvalid = '1') and
              (valid_waddr = '1') and (b1_bnk_sel = '1')) then
            b1_wready <= '1';
          else
            b1_wready <= '0';
          end if;
				end if;
			end if;
		end if;
	end process;

	p_wr_access : process(s_axi_aclk)
	begin
		if rising_edge(s_axi_aclk) then
			if (s_axi_aresetn = '0') then
				axi_wready <= '0';
			else
				if (s_axi_arvalid = '0') then
					if ((axi_wready = '0') and (s_axi_wvalid = '1') and (valid_waddr = '1')) then
						axi_wready <= '1';
					else
						axi_wready <= '0';
					end if;
				end if;
			end if;
		end if;
	end process;

  all_wready   <= b0_wready and b1_wready;
  b0_slv_wren  <= b0_wready and s_axi_wvalid;
  b1_slv_wren  <= b1_wready and s_axi_wvalid;
  bank_wr_done <= b0_slv_wr_done or b1_slv_wr_done;

  p_bresp : process(s_axi_aclk)
  begin
  	if rising_edge(s_axi_aclk) then
  		if (s_axi_aresetn = '0') then
  			axi_bresp <= "00";
  			axi_bvalid <= '0';
  		else
        if ((axi_bvalid = '0') and (bank_wr_done = '1')) then
  				axi_bvalid <= '1';
  				axi_bresp <= "00";
  			else
  				if ((s_axi_bready = '1') and (axi_bvalid = '1')) then
  					axi_bvalid <= '0';
  					axi_bresp <= "00";
  				end if;
  			end if;
  		end if;
  	end if;
  end process;

  -----------------------------------------------------------------------------
  -- AXI4-Lite READ
  -----------------------------------------------------------------------------

  p_slv_addr : process(s_axi_aclk)
  begin
    if rising_edge(s_axi_aclk) then
      if (s_axi_aresetn = '0') then
        slv_addr    <= (others => '0');
        slv_rd_addr <= (others => '0');
      else
        if (valid_waddr = '0') then
          if ((s_axi_arvalid = '1') and (rd_in_progress = '0')) then
            slv_addr    <= s_axi_araddr(BANK_INDEX_BIT_L-1 downto 0);
            slv_rd_addr <= s_axi_araddr(BANK_INDEX_BIT_H-1 downto BANK_INDEX_BIT_L);
          elsif ((axi_awready = '0') and (s_axi_awvalid = '1')) then
            slv_addr    <= s_axi_awaddr(BANK_INDEX_BIT_L-1 downto 0);
            slv_rd_addr <= s_axi_awaddr(BANK_INDEX_BIT_H-1 downto BANK_INDEX_BIT_L);
          end if;
        end if;
      end if;
    end if;
  end process;

  b0_bnk_sel <= '1' when (to_integer(unsigned(slv_rd_addr)) = BANK_REG_GEN) else '0';
  b1_bnk_sel <= '1' when (to_integer(unsigned(slv_rd_addr)) = BANK_REG_LED) else '0';

  p_rd_flag : process(s_axi_aclk)
  begin
  	if rising_edge(s_axi_aclk) then
  		if (s_axi_aresetn = '0') then
  			rd_in_progress <= '0';
  		else
  			if ((s_axi_rready = '1') and (axi_rvalid = '1')) then
  				rd_in_progress <= '0';
        end if;
  			if ((axi_arready = '1') and (s_axi_arvalid = '1')) then
  				rd_in_progress <= '1';
  			end if;
  		end if;
  	end if;
  end process;

  p_arready : process(s_axi_aclk)
  begin
  	if rising_edge(s_axi_aclk) then
  		if (s_axi_aresetn = '0') then
  			axi_arready <= '0';
  		else
  			if (((axi_arready = '0') and (s_axi_arvalid = '1')) and
  				  (rd_in_progress = '0') and (wr_in_progress = '0')) then
  				axi_arready <= '1';
  			else
  				axi_arready <= '0';
  			end if;
  		end if;
  	end if;
  end process;

  p_rvalid : process(s_axi_aclk)
  begin
  	if rising_edge(s_axi_aclk) then
  		if (s_axi_aresetn = '0') then
  			axi_rvalid <= '0';
  			axi_rresp  <= (others => '0');
  		else
  			if (((rd_in_progress = '1') and (axi_rvalid = '0')) or
  					((slv_reg_done = '1') and (axi_rvalid = '0') and 
  					 (rd_in_progress = '1'))) then
  				axi_rvalid <= '1';
  				axi_rresp  <= "00";
  			elsif ((axi_rvalid = '1') and (s_axi_rready = '1')) then
  				axi_rvalid <= '0';
  			end if;
  		end if;
  	end if;
  end process;

  p_slv_rd : process(s_axi_aclk)
  begin
  	if rising_edge(s_axi_aclk) then
  		if (s_axi_aresetn = '0') then
  			slv_rden    <= '0';
  			b0_slv_rden <= '0';
        b1_slv_rden <= '0';
  		else
  			if ((axi_arready = '1') and (s_axi_arvalid = '1') and (axi_rvalid = '0')) then
  				slv_rden    <= '1';
  				if (to_integer(unsigned(s_axi_araddr_bnk)) = BANK_REG_GEN) then
	  				b0_slv_rden  <= '1';
	  		  else
	  		    b0_slv_rden  <= '0';
	  			end if;
          if (to_integer(unsigned(s_axi_araddr_bnk)) = BANK_REG_LED) then
            b1_slv_rden  <= '1';
          else
            b1_slv_rden  <= '0';
          end if;
	  		else
	  			if (slv_reg_done = '1') then
	  				slv_rden    <= '0';
	  				b0_slv_rden <= '0';
            b1_slv_rden <= '0';
	  			end if;
	  		end if;
  		end if;
  	end if;
  end process;

  p_bnk_rd : process(s_axi_aclk)
  begin
  	if rising_edge(s_axi_aclk) then
  		if (s_axi_aresetn = '0') then
  			axi_rdata <= (others => '0');
  		else
  			if (slv_rden = '1') then
          case (to_integer(unsigned(slv_rd_addr))) is
            when BANK_REG_GEN => axi_rdata <= b0_slv_rdata;
            when BANK_REG_LED => axi_rdata <= b1_slv_rdata;
            when others       => axi_rdata <= (others => 'X');
          end case;
  			end if;
  		end if;
  	end if;
  end process;

  slv_reg_rden <= slv_rden;

  slv_reg_done <= b0_slv_rd_done when(to_integer(unsigned(slv_rd_addr)) = BANK_REG_GEN) else
                  b1_slv_rd_done when(to_integer(unsigned(slv_rd_addr)) = BANK_REG_LED) else
                  '1';

end behavioral;