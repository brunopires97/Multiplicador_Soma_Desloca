LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY RegNBits IS
	GENERIC(N: INTEGER := 8);
	PORT (D: IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
		  reset, clk, load, desl: IN STD_LOGIC;
		  Q: OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0));
END RegNBits;

ARCHITECTURE comportamento OF RegNBits IS
SIGNAL X: STD_LOGIC_VECTOR (N-1 DOWNTO 0);
BEGIN
	PROCESS(reset, clk, desl)
	BEGIN
		IF reset = '1' THEN 
			Q <= (OTHERS => '0');
		ELSIF (clk'EVENT AND clk = '1') THEN
			IF (load = '1') THEN
				IF (desl = '1') THEN
					X <= D;
					
					X(N-2 DOWNTO 0) <= X(N-1 DOWNTO 1);
					
					Q <= X;
				ELSE
					Q <= D;
				END IF;
			END IF;
		END IF;
	END PROCESS;
END comportamento;