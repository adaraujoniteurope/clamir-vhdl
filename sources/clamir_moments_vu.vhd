----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.03.2017 17:26:41
-- Design Name: 
-- Module Name: procc_offset - Behavioral
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



library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MOMENTS is

GENERIC(
      sys_clk         : INTEGER := 100_000_000; --system clock frequency in Hz
      IMG_bits        : INTEGER := 16;    
      ADDR_bits : INTEGER := 12);          
  Port ( 
  
      CLK  : in std_logic;
      RESET : in std_logic;
  
  --IMG_Memory
      IMG_Data_In : in STD_LOGIC_VECTOR (IMG_bits -1 downto 0);
      IMG_Address_in : out STD_LOGIC_VECTOR (ADDR_bits-1 downto 0);
      
      BIN_threshold :  in STD_LOGIC_VECTOR (13 downto 0);
      
      IMG_address_out: out STD_LOGIC_VECTOR (ADDR_bits downto 0);
      IMG_Data_Out : out STD_LOGIC_VECTOR (IMG_bits -1 downto 0);
      IMG_web_out : out STD_LOGIC;
       
      --Metadata
       Power :  in STD_LOGIC_VECTOR (31 downto 0);
      
       IO_status :  in STD_LOGIC_VECTOR (31 downto 0);
       Median_in :  in STD_LOGIC_VECTOR (31 downto 0);--tocado mediana
       
       M00 : out STD_LOGIC_VECTOR (31 downto 0);
       M10 : out STD_LOGIC_VECTOR (31 downto 0);
       M01 : out STD_LOGIC_VECTOR (31 downto 0);
       M11 : out STD_LOGIC_VECTOR (31 downto 0);
       M20 : out STD_LOGIC_VECTOR (31 downto 0);
       M02 : out STD_LOGIC_VECTOR (31 downto 0);
       Frame_max: out std_logic_vector (31 downto 0);
       
       --time_stamp
       rst_time_stamp : in std_logic;
       rst_frame_number : in std_logic;
        
      --ap_ctrl_chain last block
      ap_start : in STD_logic;
      ap_ready : out STD_logic;  
      ap_idle: out STD_logic  
          
  
  );
  
  attribute DONT_TOUCH : string;
    attribute DONT_TOUCH of MOMENTS : entity is "true";
end MOMENTS;

architecture Behavioral of MOMENTS is

constant TS_SPAN : natural := 1e8/1e4;

type TIPO_GLOBAL_STATE is (IDLE, MOMENT,LAST_pixel, METADATA, READY);
  signal GLOBAL_STATE: TIPO_GLOBAL_STATE;
 attribute dont_touch of GLOBAL_STATE : signal is "true";  


signal Address_counter: std_logic_vector (ADDR_bits-1 downto 0);

signal IMG_address_out_reg: std_logic_vector (ADDR_bits-1 downto 0):=(others =>'0'); 
signal IMG_web_out_reg: std_logic:='0';

--señales momentos

signal row  : std_logic_vector (5 downto 0):=(others =>'0');
signal col  : std_logic_vector (5 downto 0):=(others =>'0'); 
signal row_row  : std_logic_vector (11 downto 0):=(others =>'0');
signal col_col  : std_logic_vector (11 downto 0):=(others =>'0');
signal row_col  : std_logic_vector (11 downto 0):=(others =>'0');
signal Binary_pixel : std_logic;
attribute dont_touch of Binary_pixel : signal is "true"; 

signal M00_reg: std_logic_vector (31 downto 0):=(others =>'0');
signal M10_reg: std_logic_vector (31 downto 0):=(others =>'0');
signal M01_reg: std_logic_vector (31 downto 0):=(others =>'0');
signal M11_reg: std_logic_vector (31 downto 0):=(others =>'0');
signal M20_reg: std_logic_vector (31 downto 0):=(others =>'0');
signal M02_reg: std_logic_vector (31 downto 0):=(others =>'0');

signal sys_ts_reg: std_logic_vector (31 downto 0);
signal ticks: std_logic_vector (31 downto 0);
signal sys_fn_reg: std_logic_vector (31 downto 0);


--signal Frame_max_reg: std_logic_vector (15 downto 0):=(others =>'0');
signal Frame_max_reg: signed (15 downto 0):=(others =>'0');
attribute dont_touch of Frame_max_reg : signal is "true";  

begin

 p_timestamp : process(clk)
  begin
    IF (CLK'EVENT AND CLK = '1') THEN
      if (RESET = '1') then
        sys_ts_reg <= (others => '0');
        ticks <= (others => '0');
      else
        if (rst_time_stamp = '1') then
          ticks <= (others => '0');  
          sys_ts_reg <= (others => '0');
        elsif (ticks = TS_SPAN-1) then
          ticks <= (others => '0');  
          sys_ts_reg <= sys_ts_reg + 1;
          else
          ticks <= ticks +1;
        end if;
      end if;
    end if;
  end process;
  
 p_frame_number : process(clk)
    begin
      IF (CLK'EVENT AND CLK = '1') THEN
        if (RESET = '1') then
          sys_fn_reg <= (others => '0');
         
        else
          if (rst_frame_number = '1') then
             sys_fn_reg <= (others => '0');
          elsif (ap_start ='1') then
           
            sys_fn_reg <= sys_fn_reg + 1;
            
          end if;
        end if;
      end if;
    end process; 

--Address_in<=Address_signal(ADDR_bits-1 downto 0);

--col <=  Address_counter(5 downto 0);
--row <=  Address_counter (11 downto 6);

row_row <= row * row;
col_col <= col * col;
row_col <= row * col;

Binary_pixel <= '1' when (IMG_Data_in >= ("00" & BIN_threshold)) else '0';

process (CLK)
begin


IF (CLK'EVENT AND CLK = '1') THEN

col <=  Address_counter(5 downto 0);
row <=  Address_counter (11 downto 6);

    if(RESET ='1') then
    
     ap_ready <= '0';
     ap_idle <=  '0';
     Global_state <= IDLE;     
     IMG_Address_in<= (others => '0');
     IMG_Data_Out <= (others => '0');
     
     
     IMG_address_out <= (others => '0' );
     IMG_Data_Out <= (others => '0' );
     IMG_web_out <= '0';
     
     Address_counter<= (others => '0');
    else
    
--  Address_out<=Address_signal_reg(ADDR_bits-1 downto 0);
        case Global_state is
            
         when IDLE =>

              ap_idle <=  '1';  
              ap_ready <= '0';
              IMG_web_out<= '0';
              if (ap_start ='1') 
                then
                   ap_idle <=  '0';
                   Global_state<= MOMENT;
                   IMG_Address_in <= conv_std_logic_vector (1, 12);
                   Address_counter <= conv_std_logic_vector (1, 12);
                   --IMG_web_out<= '1';
                   IMG_Data_Out<=IMG_data_in;
                   IMG_address_out_reg <= (others => '0');
                   
                   M00_reg <=  (others => '0');
                   M10_reg <= (others => '0');
                   M01_reg <=  (others => '0');
                   M11_reg <=  (others => '0');
                   M20_reg <=  (others => '0');
                   M02_reg <=  (others => '0');
                   
                   frame_max_reg <= (others => '0');
                   
                 else
                      Global_state <= IDLE;     
                            
              end if;
        
       
         
        
        when MOMENT =>
                    
                    IMG_Address_in <=Address_counter+1;
                    IMG_Data_Out<=IMG_data_in;
                    Address_counter <=Address_counter+1;
                    --IMG_address_out<= '0' & Address_counter;
                    IMG_address_out<= '0' & IMG_address_out_reg;
                    IMG_address_out_reg <= Address_counter;
                    IMG_web_out<= '1';
                    --IMG_web_out<= IMG_web_out_reg;
                    --IMG_web_out_reg<= '1';
                    
                    if (frame_max_reg > signed(IMG_data_in))
                    then
                        frame_max_reg <= frame_max_reg;
                    else
                        frame_max_reg  <= signed(IMG_data_in);
                    end if;
                    
                     if (Binary_pixel = '1')
                     then
                      M00_reg <= M00_reg + 1;
                      M10_reg <= M10_reg + row;
                      M01_reg <= M01_reg + col;
                      M11_reg <= M11_reg + row_col;
                      M20_reg <= M20_reg + row_row;
                      M02_reg <= M02_reg + col_col;
                      
                     end if;
                    
                    if (Address_counter = 4095)
                    then
                         Global_state<= LAST_pixel;
                         --Global_state<= METADATA;
                         --IMG_address_out_reg<=(others => '0');
                         --Address_counter  <=(others => '0');
                    else
                       Global_state<= MOMENT;
                    end if;
                
                when LAST_pixel =>
                      Global_state<= METADATA;
                      IMG_Data_Out<=IMG_data_in;
                      IMG_address_out<= '0' & IMG_address_out_reg;
                      IMG_address_out_reg<=(others => '0');
                      Address_counter  <=(others => '0');
                
                when METADATA =>
                
                    if (address_counter = 0)
                    then
                    if (Binary_pixel = '1')
                    then
                     M00_reg <= M00_reg + 1;
                     M10_reg <= M10_reg + row;
                     M01_reg <= M01_reg + col;
                     M11_reg <= M11_reg + row_col;
                     M20_reg <= M20_reg + row_row;
                     M02_reg <= M02_reg + col_col;
                     
                    end if;
                    end if;
                    
                        
                    --IMG_Data_Out<=IMG_data_in;
                    Address_counter <=Address_counter+1;
                    IMG_address_out<= '1' & Address_counter;
                    --IMG_address_out<= '1' & IMG_address_out_reg;
                    --IMG_address_out_reg <= Address_counter;
                    IMG_web_out<= '1';
                    --IMG_web_out<= IMG_web_out_reg;
                    --IMG_web_out_reg<= '1';
                    
                    Case Address_counter is
                    when x"000" =>
                    IMG_Data_Out <= power (15 downto 0);  
                    when x"001" =>
                    IMG_Data_Out <= power (31 downto 16);
                    when x"002" =>
                    IMG_Data_Out <= M00_reg (15 downto 0);
                    when x"003" =>
                    IMG_Data_Out <= M00_reg (31 downto 16);
                    when x"004" =>
                    IMG_Data_Out <= M10_reg (15 downto 0);
                    when x"005" =>
                    IMG_Data_Out <= M10_reg (31 downto 16);
                    when x"006" =>
                    IMG_Data_Out <= M01_reg (15 downto 0);
                    when x"007" =>
                    IMG_Data_Out <= M01_reg (31 downto 16);
                    when x"008" =>
                    IMG_Data_Out <= M11_reg (15 downto 0);
                    when x"009" =>
                    IMG_Data_Out <= M11_reg (31 downto 16);
                    when x"00a" =>
                    IMG_Data_Out <= M20_reg (15 downto 0);
                    when x"00b" =>
                    IMG_Data_Out <= M20_reg (31 downto 16);
                    when x"00c" =>
                    IMG_Data_Out <= M02_reg (15 downto 0);
                    when x"00d" =>
                    IMG_Data_Out <= M02_reg (31 downto 16);
                    when x"00e" =>
                    --IMG_Data_Out <= x"ffff";
                    IMG_Data_Out <= std_logic_vector(Median_in (15 downto 0)); --tocado mediana
                    when x"00f" =>
                    --IMG_Data_Out <= x"ffff";
                    IMG_Data_Out <= x"0000";
                    when x"010" =>
                    IMG_Data_Out <= std_logic_vector(frame_max_reg (15 downto 0)); --tocado para mediana
                   -- IMG_Data_Out <= std_logic_vector(Median_in (15 downto 0)); --tocado mediana
                    when x"011" =>
                    IMG_Data_Out <= x"0000";
                    when x"012" =>
                    IMG_Data_Out <= sys_fn_reg (15 downto 0);
                    when x"013" =>
                    IMG_Data_Out <= sys_fn_reg (31 downto 16);
                    when x"014" =>
                    IMG_Data_Out <= sys_ts_reg (15 downto 0);
                    when x"015" =>
                    IMG_Data_Out <= sys_ts_reg (31 downto 16);
                    when x"016" =>
                    IMG_Data_Out <= IO_status (15 downto 0);
                    when x"017" =>
                    IMG_Data_Out <= IO_status (31 downto 16);
                    when others=>
                     IMG_web_out<= '0';
                    end case;
                    
                    
                    
                    
                    if (Address_counter = 23)
                    then
                         Global_state<= READY;
                         M00 <= M00_reg;
                         M10 <= M10_reg;
                         M01 <= M01_reg;
                         M11 <= M11_reg;
                         M20 <= M20_reg;
                         M02 <= M02_reg;
                         frame_max <= x"0000" & std_logic_vector(Frame_max_reg);
                         
                         
                    else
                       Global_state<= METADATA;
                    end if;
                
                when READY =>
                
                ap_ready <= '1';
                IMG_address_out_reg<=(others => '0');
                IMG_address_out<='0' & IMG_address_out_reg;
                Address_counter<=(others => '0');
                IMG_Data_Out<=IMG_data_in;
                --IMG_web_out_reg<= '0';
                IMG_web_out<= '0';
                Global_state<= IDLE;
                 
                      
                 when others =>
                      
                      Global_state <= IDLE;        
                end case;            
        
    end if;
    
    end if;
    
    end process;
    
    
    end Behavioral;
    
    
    
    
