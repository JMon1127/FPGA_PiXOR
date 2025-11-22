-------------------------------------------------------------------------------
-- Title       : PiXOR FPGA Testbench
-- Project     : FPGA_PiXOR
-------------------------------------------------------------------------------
-- File        : tb_top.vhd
-- Author      : J. I. Montes
-- Created     : [2025-11-21]
-- Last Update : [2025-11-21]
-- Platform    : Microsemi Igloo2 M2GL010T-FG484
-- Description : VHDL simulation model of the OV7670 camera
--
-- Dependencies: None
--
-- Revision History:
--   Date        Author        Description
--   2025-11-21  J. I. Montes  Initial version
-------------------------------------------------------------------------------
-- License/Disclaimer
-- This code may be adapted or shared as long as appropriate credit is given
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_top is
end tb_top;

architecture behavioral of tb_top is
  ------------
  -- Signals
  ------------
  signal s_cam_rst_n : std_logic := '0';
  signal s_cam_xclk  : std_logic := '0';
  signal s_cam_data  : std_logic_vector(7 downto 0);
  signal s_cam_vsync : std_logic;
  signal s_cam_href  : std_logic;
  signal s_cam_pclk  : std_logic;

begin
  -- generate a 50MHz clock to drive the ref clk input to the DUT
  proc_tb_clkgen : process
  begin
    wait for 10 ns;
    s_cam_xclk <= not s_cam_xclk;
  end process proc_tb_clkgen;

  -- wait for clock to be stable and release DUT from RST
  proc_tb_rst : process
  begin
    wait for 400 ns; -- after 20 clock cycles release the DUT out of reset
    s_cam_rst_n <= '1';
  end process proc_tb_rst;

  -- OV7670 camera model
  cam_model : entity work.ov7670_cam
  port map (
    I_CAM_RST_N => s_cam_rst_n,
    I_CAM_XCLK  => s_cam_xclk,

    O_CAM_DATA  => s_cam_data,
    O_CAM_PCLK  => s_cam_pclk,
    O_CAM_VSYNC => s_cam_vsync,
    O_CAM_HREF  => s_cam_href
  );

end behavioral;