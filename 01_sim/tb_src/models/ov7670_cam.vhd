-------------------------------------------------------------------------------
-- Title       : OV7670 Camera Model
-- Project     : FPGA_PiXOR
-------------------------------------------------------------------------------
-- File        : ov7670_cam.vhd
-- Author      : J. I. Montes
-- Created     : [2025-11-17]
-- Last Update : [2025-11-17]
-- Platform    : Microsemi Igloo2 M2GL010T-FG484
-- Description : VHDL simulation model of the OV7670 camera
--
-- Dependencies: None
--
-- Revision History:
--   Date        Author        Description
--   2025-11-17  J. I. Montes  Initial version
-------------------------------------------------------------------------------
-- License/Disclaimer
-- This code may be adapted or shared as long as appropriate credit is given
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ov7670_cam is
  port (
    I_CAM_RST_N :  in std_logic;
    I_CAM_XCLK  :  in std_logic;

    O_CAM_DATA  : out std_logic_vector(7 downto 0);
    O_CAM_PCLK  : out std_logic;
    O_CAM_VSYNC : out std_logic;
    O_CAM_HREF  : out std_logic
  );
end entity;

architecture rtl of ov7670_cam is
  ------------
  -- Constants
  ------------
  constant c_total_line  : integer := 510;
  constant c_active_line : integer := 480;
  constant c_byte_pixel  : integer :=   2; -- in RGB there is 2 bytes per pixel
  constant c_tp_per_line : integer := 784;
  constant c_active_tp   : integer := 640;
  constant c_vsync_hi    : integer :=   3; -- vsync is hi for 3 lines
  constant c_vsync_blnk1 : integer :=  17; -- vsync goes lo for 17 lines before actual "active"
  constant c_vsync_blnk2 : integer :=  10; -- vsync is lo for 10 lines after all "active"

  ------------
  -- Signals
  ------------
  signal s_tp_cnt        : integer range 0 to ((c_tp_per_line * c_byte_pixel) - 1);
  signal s_line_cnt      : integer range 0 to (c_total_line - 1);
  signal s_vsync         : std_logic;
  signal s_href          : std_logic;

begin
  -- from datasheet
  -- Tp = Tpclk (Raw) or 2 * Tpclk (RGB/YUV)
  -- Tline = 784 * Tp
  -- vsync hi for 3 * Tline, lo for 507 * Tline
  -- href starts after once vsync is lo for 17 * Tline
  -- href hi for 640 * Tp, lo for 144 * Tp
  -- href active for 480 * Tline
  -- data is valid when href hi

  proc_pix_cnt : process(I_CAM_RST_N, I_CAM_XCLK)
  begin
    if(I_CAM_RST_N = '0') then
      s_tp_cnt   <= 0;
    elsif(rising_edge(I_CAM_XCLK))then
      -- check to see if the cnt should reset
      if(s_tp_cnt = (c_tp_per_line * c_byte_pixel) - 1) then
        s_tp_cnt <= 0;
      else
        s_tp_cnt <= s_tp_cnt + 1;
      end if;
    end if;
  end process;

  proc_line_cnt : process(I_CAM_RST_N, I_CAM_XCLK)
  begin
    if(I_CAM_RST_N = '0') then
      s_line_cnt   <= 0;
    elsif(rising_edge(I_CAM_XCLK)) then
      -- check to see if it should reset
      if(s_line_cnt = (c_total_line - 1) and s_tp_cnt = (c_tp_per_line * c_byte_pixel) - 1) then
        s_line_cnt <= 0;
      -- only increment after 784 Tp have came in
      elsif(s_tp_cnt = (c_tp_per_line * c_byte_pixel) - 1) then
        s_line_cnt <= s_line_cnt + 1;
      end if;
    end if;
  end process;

  proc_vsync : process(I_CAM_RST_N, I_CAM_XCLK)
  begin
    if(I_CAM_RST_N = '0') then
      s_vsync   <= '0';
    elsif(rising_edge(I_CAM_XCLK)) then
      -- vsync is high for the first 3 lines then it is lo for 507 lines
      if(s_line_cnt < c_vsync_hi) then
        s_vsync <= '1';
      else
        s_vsync <= '0';
      end if;
    end if;
  end process;

  proc_href : process(I_CAM_RST_N, I_CAM_XCLK)
  begin
    if(I_CAM_RST_N = '0') then
      s_href <= '0';
    elsif(rising_edge(I_CAM_XCLK)) then
      -- href will only be actively toggling when the line count is between 20 and 500
      if(s_line_cnt >= (c_vsync_hi + c_vsync_blnk1) and s_line_cnt <= (c_total_line - c_vsync_blnk2)) then
        -- TODO: Add proper logic here. for now would like to verify
        s_href <= '1';
      else
        s_href <= '0';
      end if;
    end if;
  end process;

  O_CAM_PCLK  <= I_CAM_XCLK when I_CAM_RST_N = '1' else '0';
  O_CAM_DATA  <= (others => '0');
  O_CAM_HREF  <= s_href;
  O_CAM_VSYNC <= s_vsync;

end architecture;