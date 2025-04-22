----------------------------------------------------------------------------------
-- company: 
-- engineer: 
-- 
-- create date: 20.02.2017 18:37:46
-- design name: 
-- module name: adc_temp_vu - behavioral
-- project name: 
-- target devices: 
-- tool versions: 
-- description: 
-- 
-- dependencies: 
-- 
-- revision:
-- revision 0.01 - file created
-- additional comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

-- uncomment the following library declaration if using
-- arithmetic functions with signed or unsigned values
--use ieee.numeric_std.all;

-- uncomment the following library declaration if instantiating
-- any xilinx leaf cells in this code.
--library unisim;
--use unisim.vcomponents.all;


--new version for 16 bits ad5060 (ad5040 its obsolete)
--change from 16 bits (00 + data) to 24 bits 00000000 + data16
--input 14 bits shifted 2 positiones 00000000 + data14 + 00


entity spi_ctrl_vu is
generic(
      CLK_PRESCALER  : integer := 8); 

port (
  --sys
      clk  : in std_logic;
      reset : in std_logic;
      
      adc_csn : out std_logic;
      dac_csn : out std_logic;
      sclk: out std_logic;
      din: in std_logic;
      dout: out std_logic;
       
      temp1 : out std_logic_vector (11 downto 0):=(others => '0');
      temp2 : out std_logic_vector (11 downto 0):=(others => '0');
      temp3 : out std_logic_vector (11 downto 0):=(others => '0');
      temp4 : out std_logic_vector (11 downto 0):=(others => '0');
      
      dac : in std_logic_vector (13 downto 0);
      --dac_test_in  : in std_logic;
            
      --ap_ctrl_chain last block
      ap_start_adc : in std_logic;
      ap_done_adc : out std_logic;  
      ap_idle_adc: out std_logic;  
      
       --ap_ctrl_chain last block
      ap_start_dac : in std_logic;
      ap_done_dac : out std_logic;  
      ap_idle_dac: out std_logic
                
     );
end spi_ctrl_vu;

architecture behavioral of spi_ctrl_vu is

type tipo_spi_state is (spi_idle, adc_tx, dac_tx);
  signal spi_state: tipo_spi_state;

signal clk_counter : std_logic_vector (7 downto 0);
signal bits_counter : std_logic_vector (5 downto 0);

signal data_in_reg : std_logic_vector (11 downto 0):=(others => '0');
signal dac_counter : std_logic_vector (3 downto 0);
signal ap_start_adc_reg: std_logic:='0';
signal ap_start_dac_reg: std_logic:='0';
signal dac_reg: std_logic_vector (15 downto 0):=(others => '0');
signal dac_test_counter: std_logic_vector (9 downto 0):=(others => '0');



begin

process (clk)
begin

if (clk'event and clk = '1') then
    if(reset ='1') 
    then
--        temp1 <= (others => '0');
--        temp2 <= (others => '0');
--        temp3 <= (others => '0');
--        temp4 <= (others => '0');
        ap_done_adc <= '0';
        ap_idle_adc <= '0';  
        ap_done_dac <= '0';
        ap_idle_dac <= '0';  
        clk_counter <= (others => '0');
        bits_counter <= (others => '0');
        --data_in_reg <= (others => '0');
        dac_counter<= (others => '0');
        --dac_test_counter<= (others => '0');
        --dac_reg<= (others => '0'); 
        adc_csn <= '1';
        dac_csn <= '1';
        sclk <='1';
        dout <='0';
        --ap_start_adc_reg <= '0';
        --ap_start_dac_reg <= '0';
        spi_state <= spi_idle;
    
    else
    
    if (ap_start_adc ='1') then
    ap_start_adc_reg<= '1';
    end if;
    
    if (ap_start_dac ='1') then
      ap_start_dac_reg<= '1';
    end if;
        
        case spi_state is
            
            when spi_idle =>
                sclk <='1';
                dout <='0';
                adc_csn <= '1';
                dac_csn <= '1';
                ap_done_adc <= '0';
                ap_idle_adc <= '1';  
                bits_counter<= (others => '0');
                data_in_reg<= (others => '0');
                dac_counter <= x"f";
                
                               
                if (ap_start_adc_reg = '1') then
                    ap_start_adc_reg<='0';
                   spi_state <= adc_tx;
                   adc_csn <= '0';
                   clk_counter <=(others => '0');
                   ap_idle_adc <= '0'; 
                elsif (ap_start_dac_reg = '1') then
                if (dac_reg = (dac & "00")) then
                     ap_start_dac_reg<='0';
                else     
                     
                -- if (dac_test_in = '1') then 
                --      dac_reg<=dac + (dac_test_counter & "0000");
                --  else
                      dac_reg<= dac & "00";
               --   end if;
                
                   ap_start_dac_reg<='0';
                   spi_state <= dac_tx;
                   dac_csn <= '0';
                   clk_counter <=(others => '0');
                   ap_idle_dac <= '0'; 
                end if;   
               end if; 
            
           when adc_tx =>
           
            clk_counter <= clk_counter + 1 ;
                                      
                         if(clk_counter = conv_std_logic_vector((CLK_PRESCALER/2),8)) then
                             data_in_reg <= data_in_reg(10 downto 0) & din; 
                             if (bits_counter = 15) then
                             temp1 <= data_in_reg(10 downto 0) & din; 
                             end if;  
                             if (bits_counter = 31) then
                             temp2 <= data_in_reg(10 downto 0) & din; 
                             end if; 
                             if (bits_counter = 47) then
                             temp3 <= data_in_reg(10 downto 0) & din; 
                             end if; 
                             if (bits_counter = 63) then
                             temp4 <= data_in_reg(10 downto 0) & din; 
                             end if; 
                         end if;
                         
                         if (clk_counter =  conv_std_logic_vector(CLK_PRESCALER-1,8)) then
                            clk_counter <=(others => '0');
                            sclk <= '1';
                            bits_counter <= bits_counter +1 ;
                            if (bits_counter = 63) then
                                     spi_state <= spi_idle; 
                                     ap_done_adc <= '1';
                                
                            end if;  
                            
                         
                         
                         elsif(clk_counter >= conv_std_logic_vector(CLK_PRESCALER/2,8)) then
                             sclk <= '1';
                           
                         else
                             sclk <= '0';
                         end if;
                         
                         if(bits_counter = 4) or (bits_counter = 19) or (bits_counter = 35) or (bits_counter = 36) then
                         dout<= '1';
                         else
                         dout<= '0';
                         end if;
                         
                
            
            when dac_tx =>
            
            clk_counter <= clk_counter + 1 ;
                            
            if (clk_counter =  conv_std_logic_vector(CLK_PRESCALER-1,8)) then
                clk_counter <=(others => '0');
                sclk <= '0';
                bits_counter <= bits_counter +1 ;
                if(bits_counter >7)and (dac_counter > 0)  then
                   dac_counter <=   dac_counter - 1;
                end if; 
                               
                if (bits_counter = 23) then              
                --if (bits_counter = 15) then
                   spi_state <= spi_idle; 
                   dac_test_counter <= dac_test_counter + 1; 
                   ap_done_dac <= '1';
                    
                end if;  
            
             elsif(clk_counter = conv_std_logic_vector(CLK_PRESCALER/2,8)) then
                 sclk <= '0';
                 
             elsif(clk_counter > conv_std_logic_vector(CLK_PRESCALER/2,8)) then
                 sclk <= '0';
             else
                 sclk <= '1';
             end if;
             
             if(bits_counter < 8) then
                dout<= '0';
             else
                dout<= dac_reg(conv_integer(dac_counter));
             end if;
            
            when others =>
            
            end case;
               
  end if;
end if;

end process;

end behavioral;
