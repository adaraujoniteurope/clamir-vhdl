----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 20.02.2017 18:37:46
-- Design Name: 
-- Module Name: ADC_temp_VU - Behavioral
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

entity ROI_round_fly is

Port (
  --sys
      CLK  : in std_logic;
      RESET : in std_logic;
      
      ADDRESS_in: in std_logic_vector (11 downto 0);
      DATA_in: in std_logic_vector(15 downto 0);
      write_in: in std_logic;
      
      
      --ROI
      enable_roi: in std_logic;
      X1: in std_logic_vector (5 downto 0);
      X2: in std_logic_vector (5 downto 0);
      Y1: in std_logic_vector (5 downto 0);
      Y2: in std_logic_vector (5 downto 0);
      round: in std_logic_vector (1 downto 0);
      
      ADDRESS_out: out std_logic_vector (11 downto 0);
      DATA_out: out std_logic_vector(15 downto 0);
      write_out: out std_logic;
      
      ap_start: in std_logic;
      ap_ready: out std_logic
                
     );
end ROI_round_fly;

architecture Behavioral of ROI_round_fly is

signal DATA_in_reg: std_logic_vector (15 downto 0);
signal flag: std_logic:='0';

--segnales auxiliaes

signal X1p1: std_logic_vector (5 downto 0);
signal X1p2: std_logic_vector (5 downto 0);
signal X1p3: std_logic_vector (5 downto 0);
signal X1p4: std_logic_vector (5 downto 0);
signal X1p5: std_logic_vector (5 downto 0);
signal X1p6: std_logic_vector (5 downto 0);
signal X1p7: std_logic_vector (5 downto 0);
signal X1p8: std_logic_vector (5 downto 0);
signal X1p9: std_logic_vector (5 downto 0);
signal X1p10: std_logic_vector (5 downto 0);
signal X1p11: std_logic_vector (5 downto 0);

signal X2m1: std_logic_vector (5 downto 0);
signal X2m2: std_logic_vector (5 downto 0);
signal X2m3: std_logic_vector (5 downto 0);
signal X2m4: std_logic_vector (5 downto 0);
signal X2m5: std_logic_vector (5 downto 0);
signal X2m6: std_logic_vector (5 downto 0);
signal X2m7: std_logic_vector (5 downto 0);
signal X2m8: std_logic_vector (5 downto 0);
signal X2m9: std_logic_vector (5 downto 0);
signal X2m10: std_logic_vector (5 downto 0);
signal X2m11: std_logic_vector (5 downto 0);


signal Y1p1: std_logic_vector (5 downto 0);
signal Y1p2: std_logic_vector (5 downto 0);
signal Y1p3: std_logic_vector (5 downto 0);
signal Y1p4: std_logic_vector (5 downto 0);
signal Y1p5: std_logic_vector (5 downto 0);
signal Y1p6: std_logic_vector (5 downto 0);
signal Y1p7: std_logic_vector (5 downto 0);
signal Y1p8: std_logic_vector (5 downto 0);
signal Y1p9: std_logic_vector (5 downto 0);
signal Y1p10: std_logic_vector (5 downto 0);
signal Y1p11: std_logic_vector (5 downto 0);


signal Y2m1: std_logic_vector (5 downto 0);
signal Y2m2: std_logic_vector (5 downto 0);
signal Y2m3: std_logic_vector (5 downto 0);
signal Y2m4: std_logic_vector (5 downto 0);
signal Y2m5: std_logic_vector (5 downto 0);
signal Y2m6: std_logic_vector (5 downto 0);
signal Y2m7: std_logic_vector (5 downto 0);
signal Y2m8: std_logic_vector (5 downto 0);
signal Y2m9: std_logic_vector (5 downto 0);
signal Y2m10: std_logic_vector (5 downto 0);
signal Y2m11: std_logic_vector (5 downto 0);



begin



process (CLK)
begin

IF (CLK'EVENT and CLK = '1') 
then
    if(RESET ='1') 
    then
    ADDRESS_out <= (others =>'0');
    DATA_out  <= (others =>'0');
    write_out <= '0'; 
    DATA_in_reg <= (others =>'0');      
    else
    
    if (write_in = '0') then
    
    X1p1 <= X1 + 1;
    X1p2 <= X1 + 2;
    X1p3 <= X1 + 3;
    X1p4 <= X1 + 4;
    X1p5 <= X1 + 5;
    X1p6 <= X1 + 6;
    X1p7 <= X1 + 7;
    X1p8 <= X1 + 8;
    X1p9 <= X1 + 9;
    X1p10 <= X1 + 10;
    X1p11 <= X1 + 11;
    
    Y1p1 <= Y1 + 1;
    Y1p2 <= Y1 + 2;
    Y1p3 <= Y1 + 3;
    Y1p4 <= Y1 + 4;
    Y1p5 <= Y1 + 5;
    Y1p6 <= Y1 + 6;
    Y1p7 <= Y1 + 7;
    Y1p8 <= Y1 + 8;
    Y1p9 <= Y1 + 9;
    Y1p10 <= Y1 + 10;
    Y1p11 <= Y1 + 11;
        
    X2m1 <= X2 - 1;
    X2m2 <= X2 - 2;
    X2m3 <= X2 - 3;
    X2m4 <= X2 - 4;
    X2m5 <= X2 - 5;
    X2m6 <= X2 - 6;
    X2m7 <= X2 - 7;
    X2m8 <= X2 - 8;
    X2m9 <= X2 - 9;
    X2m10 <= X2 - 10;
    X2m11 <= X2 - 11;
        
    
    Y2m1 <= Y2 - 1;
    Y2m2 <= Y2 - 2;
    Y2m3 <= Y2 - 3;
    Y2m4 <= Y2 - 4;
    Y2m5 <= Y2 - 5;
    Y2m6 <= Y2 - 6;
    Y2m7 <= Y2 - 7;
    Y2m8 <= Y2 - 8;
    Y2m9 <= Y2 - 9;
    Y2m10 <= Y2 - 10;
    Y2m11 <= Y2 - 11;
        
    
    end if;
    
    
    ap_ready <= ap_start;
    ADDRESS_out<= ADDRESS_in;
    write_out <= write_in;  
    
    --condiciones roi
    
    
    
    if (enable_roi = '0') then
        DATA_out <=  DATA_in;
    else
    
    if ((Address_in (5 downto 0)>X1) and (Address_in (5 downto 0)<X2) and (Address_in (11 downto 6)>Y1) and (Address_in (11 downto 6)<Y2)) 
   -- if ((Address_in (5 downto 0)>=X1) and (Address_in (5 downto 0)<X2) and (Address_in (11 downto 6)>=Y1) and (Address_in (11 downto 6)<Y2))
    then 
      DATA_out <=  DATA_in;
    else
      DATA_out <=  (others => '0');
    end if;
    
    if (round = "01") then
    
     if(((Address_in (5 downto 0)=X1p1) and (((Address_in (11 downto 6)>=Y1p1) and (Address_in (11 downto 6)<=Y1p5)) or  ((Address_in (11 downto 6)<=Y2m1) and (Address_in (11 downto 6)>=Y2m5))))
              or
              ((Address_in (5 downto 0)=X2m1) and (((Address_in (11 downto 6)>=Y1p1) and (Address_in (11 downto 6)<=Y1p5)) or  ((Address_in (11 downto 6)<=Y2m1) and (Address_in (11 downto 6)>=Y2m5))))
              or
              ((Address_in (5 downto 0)=X1p2) and (((Address_in (11 downto 6)>=Y1p1) and (Address_in (11 downto 6)<=Y1p3))or ((Address_in (11 downto 6)<=Y2m1)and (Address_in (11 downto 6)>=Y2m3))))
              or
              ((Address_in (5 downto 0)=X2m2) and (((Address_in (11 downto 6)>=Y1p1) and (Address_in (11 downto 6)<=Y1p3))or ((Address_in (11 downto 6)<=Y2m1)and (Address_in (11 downto 6)>=Y2m3))))
              or
              ((Address_in (5 downto 0)=X1p3) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y1p2) or (Address_in (11 downto 6)=Y2m1)or (Address_in (11 downto 6)=Y2m2)))
              or
              ((Address_in (5 downto 0)=X2m3) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y1p2) or (Address_in (11 downto 6)=Y2m1)or (Address_in (11 downto 6)=Y2m2)))
              or
              ((Address_in (5 downto 0)=X1p4) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y2m1)))
              or
              ((Address_in (5 downto 0)=X2m4) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y2m1)))
              or
              ((Address_in (5 downto 0)=X1p5) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y2m1)))
              or
              ((Address_in (5 downto 0)=X2m5) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y2m1)))              
              )
              then
               DATA_out <=  (others => '0');
              end if;
    
    end if;
    
    if (round = "10") then
    
    if(     ((Address_in (5 downto 0)=X1p1) and (((Address_in (11 downto 6)>=Y1p1) and (Address_in (11 downto 6)<=Y1p7)) or  ((Address_in (11 downto 6)<=Y2m1) and (Address_in (11 downto 6)>=Y2m7))))
            or
            ((Address_in (5 downto 0)=X2m1) and (((Address_in (11 downto 6)>=Y1p1) and (Address_in (11 downto 6)<=Y1p7)) or  ((Address_in (11 downto 6)<=Y2m1) and (Address_in (11 downto 6)>=Y2m7))))
            or
            ((Address_in (5 downto 0)=X1p2) and (((Address_in (11 downto 6)>=Y1p1) and (Address_in (11 downto 6)<=Y1p5)) or  ((Address_in (11 downto 6)<=Y2m1) and (Address_in (11 downto 6)>=Y2m5))))
            or
            ((Address_in (5 downto 0)=X2m2) and (((Address_in (11 downto 6)>=Y1p1) and (Address_in (11 downto 6)<=Y1p5)) or  ((Address_in (11 downto 6)<=Y2m1) and (Address_in (11 downto 6)>=Y2m5))))
            or
            ((Address_in (5 downto 0)=X1p3) and (((Address_in (11 downto 6)>=Y1p1) and (Address_in (11 downto 6)<=Y1p3)) or  ((Address_in (11 downto 6)<=Y2m1) and (Address_in (11 downto 6)>=Y2m3))))
            or
            ((Address_in (5 downto 0)=X2m3) and (((Address_in (11 downto 6)>=Y1p1) and (Address_in (11 downto 6)<=Y1p3)) or  ((Address_in (11 downto 6)<=Y2m1) and (Address_in (11 downto 6)>=Y2m3))))
            or
            ((Address_in (5 downto 0)=X1p4) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y1p2) or (Address_in (11 downto 6)=Y2m1)or (Address_in (11 downto 6)=Y2m2)))
            or
            ((Address_in (5 downto 0)=X2m4) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y1p2) or (Address_in (11 downto 6)=Y2m1)or (Address_in (11 downto 6)=Y2m2)))
            or
            ((Address_in (5 downto 0)=X1p5) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y1p2) or (Address_in (11 downto 6)=Y2m1)or (Address_in (11 downto 6)=Y2m2)))
            or
            ((Address_in (5 downto 0)=X2m5) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y1p2) or (Address_in (11 downto 6)=Y2m1)or (Address_in (11 downto 6)=Y2m2)))
            or
            ((Address_in (5 downto 0)=X1p6) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y2m1)))
            or
            ((Address_in (5 downto 0)=X2m6) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y2m1)))
            or
            ((Address_in (5 downto 0)=X1p7) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y2m1)))
            or
            ((Address_in (5 downto 0)=X2m7) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y2m1)))              
            )
            then
             DATA_out <=  (others => '0');
            end if;
    
    
    end if;  
    if (round = "11") then
        
        if(     ((Address_in (5 downto 0)=X1p1) and (((Address_in (11 downto 6)>=Y1p1) and (Address_in (11 downto 6)<=Y1p11)) or  ((Address_in (11 downto 6)<=Y2m1) and (Address_in (11 downto 6)>=Y2m11))))
                or
                ((Address_in (5 downto 0)=X2m1) and (((Address_in (11 downto 6)>=Y1p1) and (Address_in (11 downto 6)<=Y1p11)) or  ((Address_in (11 downto 6)<=Y2m1) and (Address_in (11 downto 6)>=Y2m11))))
                or
                ((Address_in (5 downto 0)=X1p2) and (((Address_in (11 downto 6)>=Y1p1) and (Address_in (11 downto 6)<=Y1p8)) or  ((Address_in (11 downto 6)<=Y2m1) and (Address_in (11 downto 6)>=Y2m8))))
                or
                ((Address_in (5 downto 0)=X2m2) and (((Address_in (11 downto 6)>=Y1p1) and (Address_in (11 downto 6)<=Y1p8)) or  ((Address_in (11 downto 6)<=Y2m1) and (Address_in (11 downto 6)>=Y2m8))))
                or
                ((Address_in (5 downto 0)=X1p3) and (((Address_in (11 downto 6)>=Y1p1) and (Address_in (11 downto 6)<=Y1p6)) or  ((Address_in (11 downto 6)<=Y2m1) and (Address_in (11 downto 6)>=Y2m6))))
                or
                ((Address_in (5 downto 0)=X2m3) and (((Address_in (11 downto 6)>=Y1p1) and (Address_in (11 downto 6)<=Y1p6)) or  ((Address_in (11 downto 6)<=Y2m1) and (Address_in (11 downto 6)>=Y2m6))))
                or
                ((Address_in (5 downto 0)=X1p4) and (((Address_in (11 downto 6)>=Y1p1) and (Address_in (11 downto 6)<=Y1p4)) or  ((Address_in (11 downto 6)<=Y2m1) and (Address_in (11 downto 6)>=Y2m4))))
                or
                ((Address_in (5 downto 0)=X2m4) and (((Address_in (11 downto 6)>=Y1p1) and (Address_in (11 downto 6)<=Y1p4)) or  ((Address_in (11 downto 6)<=Y2m1) and (Address_in (11 downto 6)>=Y2m4))))
                or
                ((Address_in (5 downto 0)=X1p5) and (((Address_in (11 downto 6)>=Y1p1) and (Address_in (11 downto 6)<=Y1p3)) or  ((Address_in (11 downto 6)<=Y2m1) and (Address_in (11 downto 6)>=Y2m3))))
                or                            
                ((Address_in (5 downto 0)=X2m5) and (((Address_in (11 downto 6)>=Y1p1) and (Address_in (11 downto 6)<=Y1p3)) or  ((Address_in (11 downto 6)<=Y2m1) and (Address_in (11 downto 6)>=Y2m3))))
                or
                ((Address_in (5 downto 0)=X1p6) and (((Address_in (11 downto 6)>=Y1p1) and (Address_in (11 downto 6)<=Y1p3)) or  ((Address_in (11 downto 6)<=Y2m1) and (Address_in (11 downto 6)>=Y2m3))))
                or                            
                ((Address_in (5 downto 0)=X2m6) and (((Address_in (11 downto 6)>=Y1p1) and (Address_in (11 downto 6)<=Y1p3)) or  ((Address_in (11 downto 6)<=Y2m1) and (Address_in (11 downto 6)>=Y2m3))))
                or
                ((Address_in (5 downto 0)=X1p7) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y1p2) or (Address_in (11 downto 6)=Y2m1)or (Address_in (11 downto 6)=Y2m2)))
                or
                ((Address_in (5 downto 0)=X2m7) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y1p2) or (Address_in (11 downto 6)=Y2m1)or (Address_in (11 downto 6)=Y2m2)))
                or
                ((Address_in (5 downto 0)=X1p8) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y1p2) or (Address_in (11 downto 6)=Y2m1)or (Address_in (11 downto 6)=Y2m2)))
                or
                ((Address_in (5 downto 0)=X2m8) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y1p2) or (Address_in (11 downto 6)=Y2m1)or (Address_in (11 downto 6)=Y2m2)))
                or
                ((Address_in (5 downto 0)=X1p9) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y2m1)))
                or                           
                ((Address_in (5 downto 0)=X2m9) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y2m1)))   
                or
                ((Address_in (5 downto 0)=X1p10) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y2m1)))
                or
                ((Address_in (5 downto 0)=X2m10) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y2m1)))   
                or
                ((Address_in (5 downto 0)=X1p11) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y2m1)))
                or
                ((Address_in (5 downto 0)=X2m11) and ((Address_in (11 downto 6)=Y1p1) or (Address_in (11 downto 6)=Y2m1)))                
                )
                then
                 DATA_out <=  (others => '0');
                end if;
        
        
        end if;      
     
     
    
        
       
  end if;
  end if;
end if;

end process;

end Behavioral;
