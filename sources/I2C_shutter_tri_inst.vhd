----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.04.2017 17:05:46
-- Design Name: 
-- Module Name: I2C_shutter - Behavioral
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
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity I2C_shutter_clamir is
GENERIC(
      repetitions :INTEGER:=0;  
      clk_prescaler  : INTEGER := 250); 
      --clk_prescaler  : INTEGER := 300);

Port (
  --sys
      CLK  : in std_logic;
      RESET : in std_logic;
      
      OPEN_nCLOSE : in std_logic;
      
      --SCL: inout std_logic:='Z';
      SCL_O: out std_logic:='0';
      SCL_I: in std_logic;
      SCL_T: out std_logic:='1';
      --SDA: inout std_logic:='Z';
      SDA_O: out std_logic:='0';
      SDA_I: in std_logic;
      SDA_T: out std_logic:='1';
      Shutter_nReset: out std_logic;
      
      debug_high_z: in std_logic;
       
      --ap_ctrl_chain last block
      ap_start : in STD_logic;
      ap_ready : out STD_logic;  
      ap_idle: out STD_logic;  
       
      dbg_r: in std_logic;  
      calibration: in std_logic;
      --system_control
      ENA_sys: in std_logic
                
     );
end I2C_shutter_clamir;

architecture Behavioral of I2C_shutter_clamir is

constant shutter_adress: std_logic_vector (7 downto 0):= x"A4";
constant move_command: std_logic_vector (7 downto 0):= x"17";
constant calibration_command: std_logic_vector (7 downto 0):= x"08";

 attribute dont_touch : string;

type TIPO_I2C_state is (I2C_RESET, I2C_CALIBRATION_DELAY,I2C_IDLE,I2C_START, I2C_TX, I2C_ACK, I2C_Delay, I2C_STOP, wait_ap_start);
  signal I2C_state: TIPO_I2C_state;
   attribute dont_touch of I2C_state : signal is "true";

signal clk_counter : std_logic_vector (11 downto 0);
attribute dont_touch of clk_counter : signal is "true";
signal bits_counter : std_logic_vector (2 downto 0);
attribute dont_touch of bits_counter : signal is "true";

signal data_in_reg : std_logic_vector (11 downto 0);
attribute dont_touch of data_in_reg : signal is "true";
signal ap_start_REG: std_logic;
signal calibration_REG: std_logic:='1';
signal quarter : std_logic_vector (2 downto 0);
attribute dont_touch of quarter : signal is "true";
signal byte: std_logic_vector (1 downto 0);
attribute dont_touch of byte : signal is "true";

signal cnt_repetitions: std_logic_vector (3 downto 0);
signal open_nclose_reg: std_logic:='0';
attribute dont_touch of open_nclose_reg : signal is "true";
signal SDA_reg1:std_logic:='1';
signal SDA_reg2:std_logic:='1';
signal SDA_reg3:std_logic:='1';
signal SDA_reg4:std_logic:='1';
signal SDA_reg5:std_logic:='1';

signal SCL_meta1:std_logic:='0';
attribute dont_touch of SCL_meta1 : signal is "true";
signal SCL_meta2:std_logic:='0';
attribute dont_touch of SCL_meta2 : signal is "true";
signal SCL_meta3:std_logic:='0';
attribute dont_touch of SCL_meta3 : signal is "true";

signal cnt_reset: std_logic_vector (26 downto 0);



begin

process (CLK)
begin

IF (CLK'EVENT AND CLK = '1') THEN
    if(RESET ='1') 
    then
        ap_ready <= '0';
        ap_idle <= '0';  
        ap_ready <= '0';
        clk_counter <= (others => '0');
        bits_counter <= (others => '0');
        data_in_reg <= (others => '0');
        SCL_O <='0';
        SDA_O <='0';
        SCL_T <='1';
        SDA_T <='1';
        ap_start_REG <= '0';
        quarter <=(others => '0');
        byte <= (others => '0');
        Shutter_nReset<='0';
        cnt_repetitions <= (others => '0');
        --I2C_state <= I2C_IDLE;
        I2C_state <= I2C_RESET;
        calibration_REG<='1';
        cnt_reset <=(others =>'0');
           
    else
        
        
    if (ap_start ='1') then
      ap_start_REG<= '1';
    end if;
    
     if (calibration ='1') then
         calibration_REG<= '1';
       end if;
    
     if (dbg_r ='1') then
         ap_ready <= '0';
             ap_idle <= '0';  
             ap_ready <= '0';
             clk_counter <= (others => '0');
             bits_counter <= (others => '0');
             data_in_reg <= (others => '0');
             SCL_O <='0';
             SDA_O <='0';
             SCL_T <='1';
             SDA_T <='1';
             ap_start_REG <= '0';
             quarter <=(others => '0');
             byte <= (others => '0');
             Shutter_nReset<='0';
             cnt_repetitions <= (others => '0');
             --I2C_state <= I2C_IDLE;
             I2C_state <= I2C_RESET;
             cnt_reset <=(others =>'0');
       else
        
        case I2C_state is
            
            when I2C_RESET =>
                    Shutter_nReset<='0';
                    cnt_reset <= cnt_reset + 1;
                if (cnt_reset >= 20000000) then
                     Shutter_nReset<='1';
                end if;
                
                if (cnt_reset >= 22000000)
                then
                    Shutter_nReset<='1';
                    calibration_REG<= '1';
                    cnt_reset <=(others =>'0');
                    I2C_state <= I2C_IDLE;
                end if;
                
            when I2C_CALIBRATION_DELAY =>
                   cnt_reset <= cnt_reset + 1;
               if (cnt_reset >= 100000000)
               then
                   cnt_reset <=(others =>'0');
                   calibration_REG <='0';
                   I2C_state <= I2C_IDLE;
               end if;    
                
            
            
            when I2C_IDLE =>
            Shutter_nReset<='1';
                SCL_O <='0';
                SDA_O <='0';
                SCL_T <='1';
                SDA_T <='1';
                scl_meta3<='0';
                scl_meta2<='0';
                scl_meta1<='0';
                
                ap_ready <= '0';
                ap_idle<= '1';  
                bits_counter<= conv_std_logic_vector(7,3);
                if (ap_start_REG = '1' or calibration_REG='1') then
                   ap_start_REG<='0';
                   I2C_state <= I2C_START;
                   open_nclose_reg<=OPEN_nCLOSE;
                   clk_counter <=(others => '0');
                   ap_idle <= '0'; 
                end if; 
                
                                
            when I2C_START =>
            Shutter_nReset<='1';
                 clk_counter <= clk_counter + 1 ;
                if (clk_counter =  conv_std_logic_vector(clk_prescaler-1,12)) then
                   clk_counter <=(others => '0');
                   quarter <= quarter + 1;
                   if (quarter = 0)  then                
                         SDA_T <='0';
                         SDA_O <='0';
                       end if;
                    if (quarter = 2)  then                
                         SCL_T <='0';
                         SCL_O <='0';
                       end if;     
                    if (quarter = 3)  then 
                       quarter<=(others =>'0');                
                       I2C_state <= I2C_TX;
                       clk_counter <=(others => '0');
                    end if;  
                end if;   
            
    
            when I2C_TX =>
            Shutter_nReset<='1';
            
            clk_counter <= clk_counter + 1 ;
                            
            if (clk_counter =  conv_std_logic_vector(clk_prescaler-1,12)) then
                clk_counter <=(others => '0');
                quarter <= quarter + 1;
                if (quarter = 1) then
                    case byte is
                    when "00" =>
                        SDA_O <='0';
                        SDA_T<= shutter_adress(conv_integer(bits_counter));
                        --SDA_O<= shutter_adress(conv_integer(bits_counter));
                    when "01" =>
                        if(calibration_REG ='1') then
                            SDA_O <='0';
                            SDA_T<= calibration_command(conv_integer(bits_counter));
                            --SDA_O<= calibration_command(conv_integer(bits_counter));
                        else
                            SDA_O <='0';
                            SDA_T<= move_command(conv_integer(bits_counter));
                            --SDA_O<= move_command(conv_integer(bits_counter));
                        end if;
                    when "10" =>
                        if(bits_counter = 0) then
                            
                            SDA_O <='0';
                            SDA_T<=open_nclose_reg;
                            --SDA_O <=open_nclose_reg;
                        else 
                            SDA_O<='0';
                            SDA_T<='0';  
                        end if;  
                    when "11" =>
                        SDA_O <='0';
                        SDA_T<='0'; 
                    when others => 
                        SDA_O <='0'; 
                        SDA_T<='0';   
                    end case;
                end if;
                                
                if (quarter = 3)  then 
                    quarter<=(others =>'0');               
                    bits_counter <= bits_counter -1 ;
                                                 
                --if (bits_counter = 23) then              
                if (bits_counter = 0) then
                    --sda<='1';
                   I2C_state <= I2C_ACK; 
                   clk_counter <=(others => '0');
                   bits_counter <= conv_std_logic_vector(7,3);                   
                 end if;    
                end if;  
            
             if(quarter >= 2) then
                --SCL_T<='0';
                -- SCL_O <= '1';
                SCL_T<='1';
                SCL_O <= '0';
             else
                SCL_T<='0';
                 SCL_O <= '0';
             end if;
             end if;
             
                         
            when I2C_ACK => 
            Shutter_nReset<='1';
             clk_counter <= clk_counter + 1 ;
             if (clk_counter =  conv_std_logic_vector(clk_prescaler-1,12)) then
             clk_counter <=(others => '0');
             quarter <= quarter + 1;
              if(quarter >= 2) then
                  --SCL_O <= '1';
                  SCL_T<='1';
                  SCL_O <= '0';
              else
                  SCL_O <= '0';
                  SCL_T<='0';
              end if;
             
                    
             if(quarter =0) then
                --SDA_O<='1';
                SDA_O<='0';
                SDA_T<='1';
             end if; 
             
             if(quarter =1) then
              SDA_T<='1';
             end if;  
                if (quarter = 4)then
                quarter<=(others =>'0');
                clk_counter <=(others => '0');
                    I2C_state <= I2C_Delay;
                    SCL_O<='0';
                    SCL_T<='0';
                end if;  
             end if;   
    
    
             
            when I2C_Delay =>
            Shutter_nReset<='1';
             clk_counter <= clk_counter + 1 ;
             if (clk_counter=conv_std_logic_vector((clk_prescaler)-1,12)) then
                     SDA_T<='0';
                     SDA_O<='0';
                
             
             elsif (clk_counter=conv_std_logic_vector((clk_prescaler*2)-1,12)) then
             
                 SCL_T<='1';
                                 
             elsif(clk_counter>conv_std_logic_vector((clk_prescaler*3)-1,12)) then
             
               scl_meta1<=scl_I;
               scl_meta2<=scl_meta1;
               scl_meta3<=scl_meta2;
                  
           
           --if (clk_counter =  conv_std_logic_vector((clk_prescaler*9)-1,12)) then
           --if (clk_counter =  conv_std_logic_vector(4000,12)) then
           
           --if (scl_meta3 = '1') then --cambio julio debug shutter
           if (scl_meta3 = '1' and scl_meta2 = '1') then --cambio julio debug shutter
              clk_counter <=(others => '0');
              scl_meta1<='0';
              scl_meta2<='0';
              scl_meta3<='0';
              --SCL_T<='0';
              SCL_T<='1';
                 
              if(byte >= 3)then
                  I2C_state <= I2C_stop;
                   byte<=(others => '0');
                  --clk_counter <=(others => '0');
                  quarter<=(others => '0');
                  --SCL_T<='0';
                  --SCL_O <= '1';
                  SCL_T<='1';
                  SCL_O <= '0';
              else
                  byte<=byte+1;  
                  I2C_state <= I2C_TX;   
                  --clk_counter <=(others => '0');
                  quarter<=conv_std_logic_vector(2,3);
                  --SCL_T<='0';
                  --SCL_O <= '1';
                  SCL_T<='1';
                  SCL_O <= '0';
              end if; 
            end if;
             
            end if;                   
             
            when I2C_STOP =>
            Shutter_nReset<='1';
            
             clk_counter <= clk_counter + 1 ;
             
             if (clk_counter =  conv_std_logic_vector(clk_prescaler-1,12)) then
                clk_counter <=(others => '0');
                quarter <= quarter + 1;
                
                if (quarter = 0)  then                
                   --SCL_T<='0';
                   --SCL_O <= '1';
                   SCL_T<='1';
                   SCL_O <= '0';
                   
                elsif (quarter = 2)  then                
                      --SDA_T<='0';
                      --SDA_O<='1';
                      SDA_T<='1';
                      SDA_O<='0';
                     
                 elsif (quarter = 3)  then     
                 
                 --if(cnt_repetitions >= repetitions) then   
                    quarter<=(others =>'0');           
                    --I2C_state <= I2C_IDLE;
                    I2C_state <= wait_ap_start;
                    ap_ready <= '1';
                    byte<=(others=>'0');
                    --cnt_repetitions<=(others =>'0'); 
                  --else  
                    --I2C_state <= I2C_START;
                    --clk_counter <=(others => '0');
                    --cnt_repetitions<=cnt_repetitions+1;                 
                  --end if;  
                 end if;  
             end if;   
            
            when wait_ap_start =>
            
            if (ap_start ='0') then
               I2C_state <= I2C_IDLE;
               else
                I2C_state <= wait_ap_start;
            end if;
            if (calibration_REG='1') then
                I2C_state <= I2C_CALIBRATION_DELAY;
            end if;
                
                 
            
            when others =>
                I2C_state <= I2C_IDLE;
            
            end case;
               end if;
  end if;
end if;

end process;

end Behavioral;