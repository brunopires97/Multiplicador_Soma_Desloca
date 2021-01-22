LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY FA IS
	PORT(a, b, ci: IN STD_LOGIC;
	     s, co: OUT STD_LOGIC);
END FA;

ARCHITECTURE architectural OF FA IS
BEGIN
	co <= (a AND b) OR (a AND ci) OR (b AND ci);
	s <= a XOR b XOR ci;
END architectural;