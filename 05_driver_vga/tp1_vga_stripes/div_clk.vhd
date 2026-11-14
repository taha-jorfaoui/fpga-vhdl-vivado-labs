library IEEE; 
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.All;
use IEEE.std_logic_unsigned.All;
entity div_clk is
    Port ( RST : in STD_LOGIC;
           clk : in STD_LOGIC; 
           clk25 : out STD_LOGIC);
end div_clk;

architecture Behavioral of div_clk is
signal count :std_logic_vector(1 downto 0):="00";
begin
gen_clk25: process (clk,RST)
begin
if RST ='1' then count<="00";
elsif rising_edge(clk) then count <= count + 1;
end if;
end process;
clk25 <= count(1);
end Behavioral;