library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Top-level : CLKDIV -> VGA640x480 -> VGA_STRIPES
entity TOP_VGA_SPRITES is
    Port ( mclk : in STD_LOGIC;                        -- horloge 100 MHz de la carte
           btnr : in STD_LOGIC;                        -- bouton reset (btnR)
           hsync : out STD_LOGIC;
           vsync : out STD_LOGIC;
           red : out STD_LOGIC_VECTOR (3 downto 0);
           green : out STD_LOGIC_VECTOR (3 downto 0);
           blue : out STD_LOGIC_VECTOR (3 downto 0));
end TOP_VGA_SPRITES;

architecture Behavioral of TOP_VGA_SPRITES is

component div_clk
    Port ( RST : in STD_LOGIC;
           clk : in STD_LOGIC;
           clk25 : out STD_LOGIC);
end component;

component VGA640x480
    Port ( rst : in STD_LOGIC;
           clk25 : in STD_LOGIC;
           hsync : out STD_LOGIC;
           vsync : out STD_LOGIC;
           hc : out STD_LOGIC_VECTOR (9 downto 0);
           vc : out STD_LOGIC_VECTOR (9 downto 0);
           vidon : out STD_LOGIC);
end component;

component VGA_STRIPES
    Port ( hc : in STD_LOGIC_VECTOR (9 downto 0);
           vc : in STD_LOGIC_VECTOR (9 downto 0);
           vidon : in STD_LOGIC;
           red : out STD_LOGIC_VECTOR (3 downto 0);
           green : out STD_LOGIC_VECTOR (3 downto 0);
           blue : out STD_LOGIC_VECTOR (3 downto 0));
end component;

-- signaux d'interconnexion
signal clk25_s : STD_LOGIC;
signal hc_s, vc_s : STD_LOGIC_VECTOR (9 downto 0);
signal vidon_s : STD_LOGIC;

begin

U1 : div_clk     port map (RST => btnr, clk => mclk, clk25 => clk25_s);

U2 : VGA640x480  port map (rst => btnr, clk25 => clk25_s,
                           hsync => hsync, vsync => vsync,
                           hc => hc_s, vc => vc_s, vidon => vidon_s);

U3 : VGA_STRIPES port map (hc => hc_s, vc => vc_s, vidon => vidon_s,
                           red => red, green => green, blue => blue);

end Behavioral;
