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
  constant c_num_cols        : integer := 640;
  constant c_num_rows        : integer := 480;
  constant c_bytes_per_pixel : integer :=   2;
  constant c_bits_per_pixel  : integer := c_bytes_per_pixel * 8;              -- 2 bytes per pixel in RGB mode
  constant c_total_pixels    : integer :=     c_num_cols * c_num_rows;
  constant c_total_col_bytes : integer :=     c_num_cols * c_bytes_per_pixel; -- number of column in bytes
  constant c_total_row_bytes : integer :=     c_num_rows * c_bytes_per_pixel; -- number of rows in bytes
  constant c_total_bytes     : integer := c_total_pixels * c_bytes_per_pixel; -- total number of bytes

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

  signal s_vsync_prev       : std_logic;
  signal s_href_prev        : std_logic;
  signal s_row_cnt          : integer range 0 to (c_num_rows - 1);
  signal s_col_cnt          : integer range 0 to (c_num_cols - 1);

begin

  -- TODO: these counters may be wrong since im not accounting for the pixels being two bytes hence taking two clocks
  proc_col_cnt : process(I_RST_N, I_PCLK)
  begin
    if(I_RST_N = '0') then
      s_col_cnt     <= 0;
    elsif(rising_edge(I_PCLK)) then
      -- will only be counting columns when href is hi
      if(I_HREF = '1') then
        if(s_col_cnt = c_num_cols - 1) then
          s_col_cnt <= 0;
        else
          s_col_cnt <= s_col_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  proc_row_cnt : process(I_RST_N, I_PCLK)
  begin
    if(I_RST_N = '0') then
      s_row_cnt   <= 0;
    elsif(rising_edge(I_PCLK)) then
      if((s_row_cnt = c_num_rows - 1) and (s_col_cnt = c_num_cols - 1)) then
        s_row_cnt <= 0;
      elsif(s_col_cnt = c_num_cols - 1) then
        s_row_cnt <= s_row_cnt + 1;
      end if;
    end if;
  end process;

  proc_framegrab : process(I_RST_N, I_PCLK)
  begin
    if(I_RST_N = '0') then
      sm_data_cap       <= idle_vsync;
    elsif(rising_edge(I_PCLK)) then
      case sm_data_cap is
        -- state to wait for vsync
        when idle_vsync =>
          -- sample vsync for rising edge detect
          s_vsync_prev  <= I_VSYNC;

          if(s_vsync_prev = '0' and I_VSYNC = '1') then
            sm_data_cap <= idle_href;
          end if;
        when idle_href  =>
          -- sample href for rising edge detect
          s_href_prev   <= I_HREF;

          if(s_href_prev = '0' and I_HREF = '1') then
            -- TODO: there should already be valid data here so need to capture here.
            -- also have to keep in mind that most significant byte comes first and then the LSB

            sm_data_cap <= data_cap;
          end if;
        when data_cap   =>
      end case;
    end if;
  end process;
end architecture;