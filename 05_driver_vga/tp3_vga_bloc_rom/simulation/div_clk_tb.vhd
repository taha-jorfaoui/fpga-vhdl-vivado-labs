----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.09.2026 11:56:07
-- Design Name: 
-- Module Name: div_clk_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity div_clk_tb is
--  Port ( );
end div_clk_tb;

architecture Behavioral of div_clk_tb is
component div_clk
    port(RST: in std_logic;
    CLK : in std_logic;
    CLK25 : out std_logic);
 end component;
 signal RST,CLK25: std_logic;
 signal CLK :std_logic:='1';
 
begin
CLK25_test: div_clk port map (RST, CLK, CLK25);

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




