LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY mux2x1 IS
	GENERIC(N: INTEGER := 4);
	PORT (a, b: IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
		  sel: IN STD_LOGIC;
		  Y : OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0));
	END mux2x1;
	
ARCHITECTURE comportamento OF mux2x1 IS
BEGIN
	WITH sel SELECT
	Y <=
		a WHEN '0',
		b WHEN '1',
		(Others=>'0') WHEN OTHERS;
END comportamento;