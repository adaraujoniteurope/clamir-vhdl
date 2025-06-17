--<insert: c:\hw\releaseduld\headers\meta_harden.head>
-- -----------------------------------------------------------------------------
--
-- module:    debouncer
-- project:   wave_gen
-- company:   xilinx, inc.
-- author:    wk, aw
-- 
-- comment:
--   simple switch debouncer. filters out any transition that lasts less than
--   filter clocks long
-- 
-- known issues:
-- status           id     found     description                      by fixed date  by    comment
-- 
-- version history:
--   version    date    author     description
--    11.1-001 20 apr 2009 wk       first version for 11.1          
-- 
-- ---------------------------------------------------------------------------
-- 
-- disclaimer:
--   disclaimer: limited warranty and disclamer. these designs  are
--   provided to you as is . xilinx and its licensors make, and  you
--   receive no warranties or conditions, express,  implied,
--   statutory or otherwise, and xilinx specifically disclaims  any
--   implied warranties of merchantability, non-infringement,  or
--   fitness for a particular purpose. xilinx does not warrant  that
--   the functions contained in these designs will meet  your
--   requirements, or that the operation of these designs will  be
--   uninterrupted or error free, or that defects in the  designs
--   will be corrected. furthermore, xilinx does not warrant  or
--   make any representations regarding use or the results of  the
--   use of the designs in terms of correctness,  accuracy,
--   reliability, or  otherwise.
--   
-- limitation of liability. in no event will xilinx or  its
--   licensors be liable for any loss of data, lost profits,  cost
--   or procurement of substitute goods or services, or for  any
--   special, incidental, consequential, or indirect  damages
--   arising from the use or operation of the designs  or
--   accompanying documentation, however caused and on any  theory
--   of liability. this limitation will apply even if  xilinx
--   has been advised of the possibility of such damage.  this
--   limitation shall apply not-withstanding the failure of  the
--   essential purpose of any limited remedies  herein.
--   
-- copyright � 2002, 2008, 2009 xilinx,  inc.
--   all rights reserved
-- 
-- -----------------------------------------------------------------------------
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity meta_harden is
    port ( clk_dst          : in  std_logic;
            rstn_dst         : in  std_logic;
           signal_src       : in  std_logic;
           signal_dst       : out std_logic);
end meta_harden;


architecture behavioral of meta_harden is
       signal signal_meta : std_logic := '0';    -- this signal is more likely to be meta-stable
    begin

       -- behaviorally coded meta-hardener
       gethard: process (clk_dst)             
          begin
             if rising_edge(clk_dst) then        -- detect synchronous events
                if (rstn_dst = '1') then          -- if reset is asserted
                   signal_meta <= '0';           -- clear the output of the first flip-flop
                   signal_dst  <= '0';           -- clear the output of the second and final flip-flop
                else                             -- do non-reset activities
                   signal_meta <= signal_src;    -- capture the arriving signal - higher probability of being meta-stable
                   signal_dst  <= signal_meta;   -- resample the potentially meta-stable signal, lowering the probability of meta-stability
                end if;                          -- end of reset/non-reset activities
             end if;                             -- end of synchronous event check
          end process gethard;

    end behavioral;

