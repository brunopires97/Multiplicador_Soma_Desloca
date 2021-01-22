LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY PCPO IS
	PORT (clk,RES,start: IN STD_LOGIC; 
			A,B: IN STD_LOGIC_VECTOR(3 DOWNTO 0);
			carry: OUT STD_LOGIC;
			R: OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
END PCPO;

ARCHITECTURE arq OF PCPO IS

COMPONENT PO
	PORT (clk,loadAR,loadBR,loadACC,loadACC_2,mux,sel,reset: IN STD_LOGIC;
		  A,B: IN STD_LOGIC_VECTOR (3 DOWNTO 0); 
		  carry,carry_2,Q_0: OUT STD_LOGIC;
		  R: OUT STD_LOGIC_VECTOR (7 DOWNTO 0));     
END COMPONENT;

COMPONENT FSM
	PORT (clk,RES,start,Q_0,carry_2: IN STD_LOGIC; 
			reset,loadAR,loadBR,loadACC,loadACC_2,sel,mux: OUT STD_LOGIC);
END COMPONENT;

SIGNAL loadAR,loadBR,loadACC,loadACC_2,mux,sel,reset,Q_0,carry_2: STD_LOGIC;

BEGIN
	maquina: FSM PORT MAP(clk,RES,start,Q_0,carry_2,reset,loadAR,loadBR,loadACC,loadACC_2,sel,mux);
	
	operativo: PO PORT MAP(clk,loadAR,loadBR,loadACC,loadACC_2,mux,sel,reset,A,B,carry,carry_2,Q_0,R);
END arq;