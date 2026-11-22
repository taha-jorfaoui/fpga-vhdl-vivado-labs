----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.09.2026 10:51:36
-- Design Name: 
-- Module Name: div_clk - Behavioral
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
use IEEE.std_logic_arith.ALL;
use IEEE.std_logic_unsigned.ALL;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity div_clk is
    Port ( RST : in STD_LOGIC;
           CLK : in STD_LOGIC;
           CLK25 : out STD_LOGIC);
end div_clk;
   
  
architecture Behavioral of div_clk is

      signal counter : std_logic_vector(1 downto 0) :="00";
      
begin
     process(CLK,RST)
     begin
          if RST= '1' then counter <= "00";
          elsif rising_edge(CLK)then counter<=counter+1;
          end if;
     end process;
          
     CLK25 <=counter(1);
          
          
          

end Behavioral;
