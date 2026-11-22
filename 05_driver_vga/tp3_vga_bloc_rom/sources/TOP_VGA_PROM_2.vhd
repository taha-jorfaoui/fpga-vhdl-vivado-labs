library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Top-level du TP VGA Block ROM (figure 7) :
-- CLKDIV -> VGA640x480 -> VGA_PROM_2 <-> sprite_rom (IP Block Memory Generator)
entity TOP_VGA_PROM_2 is
    Port ( mclk : in STD_LOGIC;                        -- horloge 100 MHz de la carte
           btnr : in STD_LOGIC;                        -- reset
           sw : in STD_LOGIC_VECTOR (7 downto 0);      -- position de l'image
           hsync : out STD_LOGIC;
           vsync : out STD_LOGIC;
           red : out STD_LOGIC_VECTOR (3 downto 0);
           green : out STD_LOGIC_VECTOR (3 downto 0);
           blue : out STD_LOGIC_VECTOR (3 downto 0));
end TOP_VGA_PROM_2;

architecture Behavioral of TOP_VGA_PROM_2 is

component div_clk
    Port ( RST : in STD_LOGIC;
           CLK : in STD_LOGIC;
           CLK25 : out STD_LOGIC);
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

-- IP Xilinx Block Memory Generator : Single Port ROM 38400 x 8 bits,
-- initialisee par COE240x160.coe, "Always Enabled", sans registre de sortie
component sprite_rom
    Port ( clka : in STD_LOGIC;
           addra : in STD_LOGIC_VECTOR (15 downto 0);
           douta : out STD_LOGIC_VECTOR (7 downto 0));
end component;

component VGA_PROM_2
    Port ( hc : in STD_LOGIC_VECTOR (9 downto 0);
           vc : in STD_LOGIC_VECTOR (9 downto 0);
           vidon : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR (7 downto 0);
           M : in STD_LOGIC_VECTOR (7 downto 0);
           rom_addr16 : out STD_LOGIC_VECTOR (15 downto 0);
           red : out STD_LOGIC_VECTOR (3 downto 0);
           green : out STD_LOGIC_VECTOR (3 downto 0);
           blue : out STD_LOGIC_VECTOR (3 downto 0));
end component;

-- signaux d'interconnexion
signal clk25_s : STD_LOGIC;
signal hc_s, vc_s : STD_LOGIC_VECTOR (9 downto 0);
signal vidon_s : STD_LOGIC;
signal rom_addr16_s : STD_LOGIC_VECTOR (15 downto 0);
signal M_s : STD_LOGIC_VECTOR (7 downto 0);

begin

U1 : div_clk    port map (RST => btnr, CLK => mclk, CLK25 => clk25_s);

U2 : VGA640x480 port map (rst => btnr, clk25 => clk25_s,
                          hsync => hsync, vsync => vsync,
                          hc => hc_s, vc => vc_s, vidon => vidon_s);

U3 : VGA_PROM_2 port map (hc => hc_s, vc => vc_s, vidon => vidon_s, sw => sw,
                          M => M_s, rom_addr16 => rom_addr16_s,
                          red => red, green => green, blue => blue);

-- la ROM est cadencee par l'horloge pixel : 1 pixel = 1 lecture
U4 : sprite_rom port map (clka => clk25_s, addra => rom_addr16_s, douta => M_s);

end Behavioral;
