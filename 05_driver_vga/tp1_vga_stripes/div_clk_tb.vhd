library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.All;
use IEEE.std_logic_unsigned.All;

entity div_clk_tb is
--  Port ( );
end div_clk_tb;

architecture Behavioral of div_clk_tb is

component div_clk
Port ( RST : in STD_LOGIC;
           clk : in STD_LOGIC;
           clk25 : out STD_LOGIC);
end component;

signal rst,clk25:std_logic;
signal clk:std_logic :='1';

begin
clk25_test : div_clk port map (RST,clk,clk25);

tb:process
begin
RST <='1';
wait for 10 ns;
RST<='0';
wait;  
end process tb;

myclk:process
begin
clk <='0','1' after 5 ns ;
wait for 10 ns;
end process myclk;

end Behavioral;