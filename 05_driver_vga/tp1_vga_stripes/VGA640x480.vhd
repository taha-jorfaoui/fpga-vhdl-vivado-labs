library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity VGA640x480 is
    Port ( rst : in STD_LOGIC;
           clk25 : in STD_LOGIC;
           hsync : out STD_LOGIC;
           vsync : out STD_LOGIC;
           hc : out STD_LOGIC_VECTOR (9 downto 0);
           vc : out STD_LOGIC_VECTOR (9 downto 0);
           vidon : out STD_LOGIC);
end VGA640x480;

architecture Behavioral of VGA640x480 is

constant hpixels: std_logic_vector(9 downto 0) :="1100100000"; -- nombre de px sur une ligne = 800
constant vlines: std_logic_vector(9 downto 0) :="1000001001"; -- nombre (total) de ligne horizontale 521
constant hbp: std_logic_vector(9 downto 0) :="0010010000"; -- horizontal back porch = 128 + 16 = 144 (ou 96 + 48)
constant hfp: std_logic_vector(9 downto 0) :="1100010000"; -- horizontal front porch = 128 + 16 + 640 = 784
constant vbp: std_logic_vector(9 downto 0) :="0000011111"; -- vertical back porch = 2 + 29 = 31
constant vfp: std_logic_vector(9 downto 0) :="0111111111"; -- vertical front porch = 2 + 29 + 480 + 10 = 511

signal hcs : std_logic_vector(9 downto 0); -- :="0000000000" ; -- compteur horizontal / vertical
signal vcs: std_logic_vector(9 downto 0) ;-- :="0000000000" ; -- compteur horizontal / vertical
signal vsenable: std_logic := '0'; -- enable pour le compteur vertical

begin

-- Compteur pour le signal de synchro horizontale hcs
process(clk25, rst)
begin
if rst='1' then hcs <= "0000000000"; -- ou if rst='1' then hcs <= (other => '0');
elsif rising_edge(clk25) then
        if hcs = (hpixels - 1) then
           hcs <= "0000000000";
           vsenable <='1';
        else
           hcs <= (hcs + 1) ;
           vsenable <='0';
        end if;
end if;
end process;

-- Compteur pour le signal de synchro virticale vcs
process(clk25, rst)
begin
if rst='1' then vcs <= "0000000000";
elsif rising_edge(clk25) then
        if vsenable='1' then
                if vcs =(vlines - 1) then
                  vcs <= "0000000000";
                else
                  vcs <=vcs + 1;
                end if;
        end if;
end if;
end process;

-- Génération des signaux de sortie
hsync <= '0' when hcs < 96 else '1';
vsync <= '0' when vcs < 2 else '1';

vidon <= '1' when ((hcs>=hbp) and (hcs<hfp) and (vcs>=vbp) and (vcs<vfp)) else '0';
hc <= hcs;
vc <= vcs;

end Behavioral;
