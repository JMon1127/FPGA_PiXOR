-------------------------------------------------------------------------------
-- Title       : OV7670 Frame Grabber
-- Project     : FPGA_PiXOR
-------------------------------------------------------------------------------
-- File        : ov7670_fg.vhd
-- Author      : J. I. Montes
-- Created     : [2025-12-06]
-- Last Update : [2025-12-06]
-- Platform    : Microsemi Igloo2 M2GL010T-FG484
-- Description : VHDL frame grabber model for the OV7670 camera
--
-- Dependencies: None
--
-- Revision History:
--   Date        Author        Description
--   2025-12-06  J. I. Montes  Initial version
-------------------------------------------------------------------------------
-- License/Disclaimer
-- This code may be adapted or shared as long as appropriate credit is given
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ov7670_fg is
  port (
    I_RST_N    : in std_logic;
    I_PCLK     : in std_logic;
    I_HREF     : in std_logic;
    I_VSYNC    : in std_logic;
    I_CAM_DATA : in std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of ov7670_fg is

  ------------
  -- Constants
  ------------
  constant c_num_cols       : integer := 640;
  constant c_num_rows       : integer := 480;
  constant c_bits_per_pixel : integer :=  16; -- 2 bytes per pixel in RGB mode
  constant c_total_pixels   : integer := c_num_cols * c_num_rows;

  ------------
  -- Types
  ------------
  type t_frame_buff_arry is array (0 to c_total_pixels - 1) of std_logic_vector(c_bits_per_pixel - 1 downto 0);
  type t_cap_state is ( idle_vsync,
                        idle_href,
                        data_cap
                      );

  ------------
  -- Signals
  ------------
  signal s_frame_buff       : t_frame_buff_arry;
  signal sm_data_cap        : t_cap_state;
begin

  proc_framegrab : process(I_RST_N, I_PCLK)
  begin
    if(I_RST_N = '0') then
      sm_data_cap <= idle_vsync;
    elsif(rising_edge(I_PCLK)) then
      case
    end if;
  end process;
end architecture;