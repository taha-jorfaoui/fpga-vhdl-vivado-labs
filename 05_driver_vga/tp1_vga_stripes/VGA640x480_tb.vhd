library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity VGA640x480_tb is
end VGA640x480_tb;

architecture Behavioral of VGA640x480_tb is
component VGA640x480
    Port ( rst : in STD_LOGIC;
           clk25 : in STD_LOGIC;
           hsync : out STD_LOGIC;
           vsync : out STD_LOGIC;
           hc : out STD_LOGIC_VECTOR (9 downto 0);
           vc : out STD_LOGIC_VECTOR (9 downto 0);
           vidon : out STD_LOGIC);
end component;

signal rst : STD_LOGIC := '1';
signal clk25 : STD_LOGIC := '0';
signal hsync, vsync, vidon : STD_LOGIC;
signal hc, vc : STD_LOGIC_VECTOR (9 downto 0);
begin
uut : VGA640x480 port map (rst, clk25, hsync, vsync, hc, vc, vidon);

clk25 <= not clk25 after 20 ns;   -- 25 MHz

stim : process
begin
    rst <= '1';
    wait for 100 ns;
    rst <= '0';
    wait;
end process;
end Behavioral;
