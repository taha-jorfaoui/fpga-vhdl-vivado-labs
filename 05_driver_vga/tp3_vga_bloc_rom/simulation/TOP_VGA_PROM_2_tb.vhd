library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Test final : 1 image avec sw = 0 (image en haut a gauche),
-- puis 1 image avec sw = "00100011" (ligne 2 -> 40 lignes plus bas, colonne 3 -> 75 pixels a droite)
-- Simulation : run 35 ms
entity TOP_VGA_PROM_2_tb is
end TOP_VGA_PROM_2_tb;

architecture Behavioral of TOP_VGA_PROM_2_tb is

component TOP_VGA_PROM_2
    Port ( mclk : in STD_LOGIC;
           btnr : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR (7 downto 0);
           hsync : out STD_LOGIC;
           vsync : out STD_LOGIC;
           red : out STD_LOGIC_VECTOR (3 downto 0);
           green : out STD_LOGIC_VECTOR (3 downto 0);
           blue : out STD_LOGIC_VECTOR (3 downto 0));
end component;

signal mclk : STD_LOGIC := '0';
signal btnr : STD_LOGIC := '1';
signal sw : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
signal hsync, vsync : STD_LOGIC;
signal red, green, blue : STD_LOGIC_VECTOR (3 downto 0);

begin
uut : TOP_VGA_PROM_2 port map (mclk => mclk, btnr => btnr, sw => sw,
                               hsync => hsync, vsync => vsync,
                               red => red, green => green, blue => blue);

mclk <= not mclk after 5 ns;   -- 100 MHz

stim : process
begin
    btnr <= '1';
    sw <= "00000000";
    wait for 100 ns;
    btnr <= '0';
    wait for 17 ms;            -- premiere image : en haut a gauche
    sw <= "00100011";          -- deuxieme image : deplacee
    wait;
end process;

end Behavioral;
