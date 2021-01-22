LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY RCA_Nbits IS

GENERIC(N: INTEGER := 8);
PORT (A, B: IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
		Cin: IN STD_LOGIC;
		Soma: OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0);
		Cout: OUT STD_LOGIC);
END RCA_Nbits;

ARCHITECTURE architectural OF RCA_Nbits IS
SIGNAL c: STD_LOGIC_VECTOR(0 TO N-2);

COMPONENT FA
	PORT(a, b, ci: IN STD_LOGIC;
	     s, co: OUT STD_LOGIC);
END COMPONENT;

BEGIN
	Soma0: FA PORT MAP (A(0), B(0), Cin, Soma(0),c(0));
	
	Somas: FOR i IN 1 TO N-2 GENERATE
		FullAdders: FA PORT MAP (A(i), B(i), c(i-1),Soma(i), c(i));
	END GENERATE;
	
	SomaEnd: FA PORT MAP (A(N-1), B(N-1), c(N-2), Soma(N-1), Cout);
END architectural;