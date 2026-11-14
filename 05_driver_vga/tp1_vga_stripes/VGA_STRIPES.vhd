library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Affectation des couleurs des pixels (processus purement combinatoire)
entity VGA_STRIPES is
    Port ( hc : in STD_LOGIC_VECTOR (9 downto 0);
           vc : in STD_LOGIC_VECTOR (9 downto 0);
           vidon : in STD_LOGIC;
           red : out STD_LOGIC_VECTOR (3 downto 0);
           green : out STD_LOGIC_VECTOR (3 downto 0);
           blue : out STD_LOGIC_VECTOR (3 downto 0));
end VGA_STRIPES;

architecture Behavioral of VGA_STRIPES is
begin

process(hc, vc, vidon)
begin
    if vidon = '1' then
        red   <= vc(4) & vc(4) & vc(4) & vc(4);
        green <= not (vc(4) & vc(4) & vc(4) & vc(4));
        blue  <= "0000";
    else
        red   <= "0000";
        green <= "0000";
        blue  <= "0000";
    end if;
end process;

end Behavioral;
