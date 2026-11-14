library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TOP_VGA_SPRITES_tb is
end TOP_VGA_SPRITES_tb;

architecture Behavioral of TOP_VGA_SPRITES_tb is

component TOP_VGA_SPRITES
    Port ( mclk : in STD_LOGIC;
           btnr : in STD_LOGIC;
           hsync : out STD_LOGIC;
           vsync : out STD_LOGIC;
           red : out STD_LOGIC_VECTOR (3 downto 0);
           green : out STD_LOGIC_VECTOR (3 downto 0);
           blue : out STD_LOGIC_VECTOR (3 downto 0));
end component;

signal mclk : STD_LOGIC := '0';
signal btnr : STD_LOGIC := '1';
signal hsync, vsync : STD_LOGIC;
signal red, green, blue : STD_LOGIC_VECTOR (3 downto 0);

begin
uut : TOP_VGA_SPRITES port map (mclk, btnr, hsync, vsync, red, green, blue);

mclk <= not mclk after 5 ns;   -- 100 MHz

stim : process
begin
    btnr <= '1';
    wait for 100 ns;
    btnr <= '0';
    wait;
end process;

end Behavioral;
