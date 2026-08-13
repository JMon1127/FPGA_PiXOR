-------------------------------------------------------------------------------
-- Title       : OV5640 Model
-------------------------------------------------------------------------------
-- File        : ov5640_cam.vhd
-- Author      : J. I. Montes
-- Created     : [2026-08-01]
-- Last Update : [2026-08-01]
-- Platform    : N/A
-- Description : OV5640 model
--
-- Dependencies:
--
-- Revision History:
--   Date        Author        Description
--   2026-08-01  J. I. Montes  Initial version
-------------------------------------------------------------------------------
-- License/Disclaimer
-- This code may be adapted or shared as long as appropriate credit is given
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ov5640_cam is
    port (
        I_CAM_RSTN  :  in std_logic;
        I_CAM_XCLK  :  in std_logic; -- external 24MHz clock
        O_CAM_PCLK  :  in std_logic; -- pixel clock

        O_CAM_VSYNC : out std_logic; -- new frame
        O_CAM_HREF  : out std_logic; -- new row
        O_CAM_DATA  : out std_logic_vector(7 downto 0)
    );
end entity;

architecture rtl of ov5640_cam is

  constant c_pclk_prd : time := 1 sec / 96000000;
  constant c_xclk_max : integer := 500;

  signal s_xclk_lockd : std_logic;
  signal s_xclk_cnt   : unsigned(31 downto 0);
  signal s_pclk       : std_logic;
  signal s_row_cnt    : unsigned(31 downto 0);
  signal s_col_cnt    : unsigned(31 downto 0);

begin

  ----------------------------------------------------------------------
  -- pclk generation, per datasheet 1080p DVP mode pixel clock is 96MHz
  ----------------------------------------------------------------------
  -- start with sampling the input xclk. once we get 500 stable clocks we can indicate lock
  proc_lock_xclk : process (I_CAM_XCLK, I_CAM_RSTN)
  begin
    if (I_CAM_RSTN = '0') then
      s_xclk_lockd <= '0';
      s_xclk_cnt   <= (others => '0');
    elsif(rising_edge(I_CAM_XCLK)) then
      -- increment counter
      s_xclk_cnt <= s_xclk_cnt + 1;

      -- once the count hits 500 keep the counter cleared and indicate a lock
      if (s_xclk_cnt = c_xclk_max - 1) then
        s_xclk_cnt   <= (others => '0');
        s_xclk_lockd <= '1';
      end if;
    end if;
  end process proc_lock_xclk;

  proc_gen_pclk : process
  begin
    s_pclk <= '0';

    wait until s_xclk_lockd = '1';

    loop
      wait for c_pclk_prd / 2;
      s_pclk <= not s_pclk;
    end loop;
  end process;

  -- process to track rows

  -- process to track columns

  -- process to drive vsync

  -- process to drive href

  -- process to drive data

end architecture;