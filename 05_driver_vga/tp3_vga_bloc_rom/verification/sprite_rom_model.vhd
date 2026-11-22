-- Modele de simulation (GHDL) de l'IP Xilinx sprite_rom : NE PAS ajouter au projet Vivado
-- (l'IP generee fournit deja son propre modele de simulation).
-- Single Port ROM 38400 x 8 bits, lecture synchrone, sortie sans registre
-- => douta = contenu de l'adresse presentee au front montant precedent (1 cycle de latence).
-- Le contenu est lu dans le fichier .coe (generic COE_FILE).
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;

entity sprite_rom is
    generic ( COE_FILE : string := "COE240x160.coe";
              DEPTH    : integer := 38400 );
    Port ( clka : in STD_LOGIC;
           addra : in STD_LOGIC_VECTOR (15 downto 0);
           douta : out STD_LOGIC_VECTOR (7 downto 0));
end sprite_rom;

architecture Model of sprite_rom is
    type mem_t is array (0 to DEPTH-1) of std_logic_vector(7 downto 0);

    impure function load_coe return mem_t is
        file f : text open read_mode is COE_FILE;
        variable l : line;
        variable m : mem_t := (others => (others => '0'));
        variable n : integer := 0;
        variable v : integer;
        variable intoken : boolean;
        variable c : character;
    begin
        while not endfile(f) loop
            readline(f, l);
            if l'length > 0 then
                if l(l'left) /= ';' and l(l'left) /= 'm' then
                    v := 0; intoken := false;
                    for i in l'range loop
                        c := l(i);
                        if (c >= '0' and c <= '9') then
                            v := v*16 + (character'pos(c) - character'pos('0')); intoken := true;
                        elsif (c >= 'A' and c <= 'F') then
                            v := v*16 + (character'pos(c) - character'pos('A') + 10); intoken := true;
                        elsif (c >= 'a' and c <= 'f') then
                            v := v*16 + (character'pos(c) - character'pos('a') + 10); intoken := true;
                        elsif (c = ',' or c = ';') then
                            if intoken and n < DEPTH then
                                m(n) := std_logic_vector(to_unsigned(v, 8)); n := n + 1;
                            end if;
                            v := 0; intoken := false;
                        end if;
                    end loop;
                    if intoken and n < DEPTH then
                        m(n) := std_logic_vector(to_unsigned(v, 8)); n := n + 1;
                    end if;
                end if;
            end if;
        end loop;
        assert n = DEPTH report "COE : " & integer'image(n) & " mots lus au lieu de " & integer'image(DEPTH) severity failure;
        return m;
    end function;

    constant mem : mem_t := load_coe;
begin
    process(clka)
    begin
        if rising_edge(clka) then
            assert to_integer(unsigned(addra)) < DEPTH
                report "ADRESSE HORS ROM : " & integer'image(to_integer(unsigned(addra))) severity error;
            if to_integer(unsigned(addra)) < DEPTH then
                douta <= mem(to_integer(unsigned(addra)));
            else
                douta <= (others => 'X');
            end if;
        end if;
    end process;
end Model;
