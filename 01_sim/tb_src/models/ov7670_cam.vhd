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

begin

  O_CAM_PCLK <= I_CAM_XCLK when I_CAM_RST_N = '1' else '0';

  -- from datasheet
  -- Tp = Tpclk (Raw) or 2 * Tpclk (RGB/YUV)
  -- Tline = 784 * Tp
  -- vsync hi for 3 * Tline, lo for 507 * Tline
  -- href starts after once vsync is lo for 17 * Tline
  -- href hi for 640 * Tp, lo for 144 * Tp
  -- href active for 480 * Tline
  -- data is valid when href hi

end architecture;