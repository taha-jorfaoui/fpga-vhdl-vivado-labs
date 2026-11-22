library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Affichage d'une image 240 x 160 lue dans la Block ROM (IP sprite_rom)
--   M          : octet lu dans la ROM, format [R2 R1 R0 G2 G1 G0 B1 B0]
--   rom_addr16 : adresse du pixel dans la ROM = ypix * 240 + xpix
-- sw = "00000000" : image en haut a gauche de la zone visible
-- sw(3 downto 0) : colonne de l'image, pas de 25 pixels  (0 a 375)
-- sw(7 downto 4) : ligne de l'image,   pas de 20 lignes  (0 a 300)
--   -> l'image (240 x 160) reste toujours entierement dans l'ecran 640 x 480
entity VGA_PROM_2 is
    Port ( hc : in STD_LOGIC_VECTOR (9 downto 0);
           vc : in STD_LOGIC_VECTOR (9 downto 0);
           vidon : in STD_LOGIC;
           sw : in STD_LOGIC_VECTOR (7 downto 0);
           M : in STD_LOGIC_VECTOR (7 downto 0);
           rom_addr16 : out STD_LOGIC_VECTOR (15 downto 0);
           red : out STD_LOGIC_VECTOR (3 downto 0);
           green : out STD_LOGIC_VECTOR (3 downto 0);
           blue : out STD_LOGIC_VECTOR (3 downto 0));
end VGA_PROM_2;

architecture Behavioral of VGA_PROM_2 is

-- debut de la zone visible (memes valeurs que dans VGA640x480)
constant hbp : std_logic_vector(9 downto 0) := "0010010000"; -- 144
constant vbp : std_logic_vector(9 downto 0) := "0000011111"; -- 31
-- dimensions de l'image
constant w : integer := 240;
constant h : integer := 160;

signal xoff, yoff : std_logic_vector(9 downto 0);  -- position de l'image (coin haut gauche)
signal xpix, ypix : std_logic_vector(9 downto 0);  -- coordonnees pixel dans l'image
signal spriteon : std_logic;

begin

-- position reglee par les switches (0 si tous les switches sont en bas)
xoff <= sw(3 downto 0) * conv_std_logic_vector(25, 6);
yoff <= sw(7 downto 4) * conv_std_logic_vector(20, 6);

-- Coordonnees pixel dans l'image (fonctions de hc/hbp et vc/vbp)
-- ypix : ligne du pixel courant (0 a h-1).
-- xpix : colonne du pixel SUIVANT (hc - hbp, au lieu de hc - hbp - 1).
--   La Block ROM est synchrone (sortie sans registre, "Primitives Output Register"
--   decoche) : la donnee de l'adresse presentee a un front de clk25 n'apparait qu'apres
--   ce front, c'est-a-dire quand hc a deja avance d'un pixel. Adresser le pixel suivant
--   compense exactement cette latence : M correspond au pixel affiche.
xpix <= hc - hbp - xoff;
ypix <= vc - vbp - yoff - 1;

-- spriteon = 1 si hbp+1 <= hc <= hbp+w et vbp+1 <= vc <= vbp+h (decales de xoff, yoff)
spriteon <= '1' when ((hc > hbp + xoff) and (hc <= hbp + xoff + w)
                 and  (vc > vbp + yoff) and (vc <= vbp + yoff + h)) else '0';

-- Calcul de l'adresse : rom_addr16 = ypix * 240 + xpix
--   ypix * 240 = ypix * (128 + 64 + 32 + 16) : que des decalages et des additions
--   Hors de l'image (xpix >= w ou ypix >= h, y compris les valeurs "negatives" qui
--   bouclent sur 10 bits) l'adresse est forcee a 0 : elle ne sort jamais de la ROM.
process(xpix, ypix)
variable y16, x16, a : std_logic_vector(15 downto 0);
begin
    y16 := "000000" & ypix;
    x16 := "000000" & xpix;
    if (xpix < w) and (ypix < h) then
        a := (y16(8 downto 0) & "0000000")     -- ypix * 128
           + (y16(9 downto 0) & "000000")      -- ypix * 64
           + (y16(10 downto 0) & "00000")      -- ypix * 32
           + (y16(11 downto 0) & "0000")       -- ypix * 16
           + x16;
        rom_addr16 <= a;
    else
        rom_addr16 <= (others => '0');
    end if;
end process;

-- Couleurs : l'octet M est au format RRRGGGBB. Chaque composante est etendue sur
-- 4 bits (sortie VGA de la Basys 3) en recopiant ses bits de poids fort, de sorte que
-- "000" -> "0000" et "111" -> "1111" (le blanc reste blanc).
process(spriteon, vidon, M)
begin
    if spriteon = '1' and vidon = '1' then
        red   <= M(7 downto 5) & M(7);
        green <= M(4 downto 2) & M(4);
        blue  <= M(1 downto 0) & M(1 downto 0);
    else                              -- hors de l'image : noir
        red   <= "0000";
        green <= "0000";
        blue  <= "0000";
    end if;
end process;

end Behavioral;
