-------------------------------------------------------------------------------
-- Title       : Generic Testbench PLL
-------------------------------------------------------------------------------
-- File        : tb_pll.vhd
-- Author      : J. I. Montes
-- Created     : [2026-08-02]
-- Last Update : [2026-08-02]
-- Platform    : N/A
-- Description : Generic PLL for testbench use. Should not target real hardware
--
-- Dependencies:
--
-- Revision History:
--   Date        Author        Description
--   2026-08-02  J. I. Montes  Initial version
-------------------------------------------------------------------------------
-- License/Disclaimer
-- This code may be adapted or shared as long as appropriate credit is given
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_pll is
  generic (
    MULTIPLIER : positive := 5;
    DIVIDER    : positive := 2;
    LOCK_DLY   : time     := 100 ns
  );
  port (
    I_REF_CLK  :  in std_logic;
    I_RSTN     :  in std_logic;

    O_CLK      : out std_logic;
    O_PLL_LOCK : out std_logic
  );
end entity;

architecture behavorial of tb_pll is

  signal s_ref_clk_prd : time := 0 ns;
  signal s_out_clk_prd : time := 0 ns;
  signal s_timeout     : time := 0 ns;
  signal s_last_edge   : time := 0 ns;
  signal s_prd_valid   : std_logic;
  signal s_toggle_time : std_logic;

begin

  -- start with deriving the input clock period
  proc_in_prd : process (I_RSTN, I_REF_CLK)
    variable v_t1, v_t2 : time;
  begin
    if(I_RSTN = '0') then
      s_prd_valid   <= '0';
      s_toggle_time <= '0';
    elsif(rising_edge(I_REF_CLK)) then
      s_toggle_time <= not s_toggle_time;

      if(s_prd_valid /= '1') then
        if(s_toggle_time = '0') then
          v_t1 := now;
        else
          s_ref_clk_prd <=  now - v_t1;
          s_timeout     <= (now - v_t1) * 3;
          s_out_clk_prd <= (now - v_t1) * DIVIDER / MULTIPLIER;
          s_prd_valid   <= '1';
        end if;
      end if;
    end if;
  end process;

  -- process to unlock PLL if input stops
  proc_wdg : process (I_RSTN, I_REF_CLK)
  begin
  end process;

end architecture;