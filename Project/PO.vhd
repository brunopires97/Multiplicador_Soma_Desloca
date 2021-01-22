LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY PO is
	PORT (clk,loadAR,loadBR,loadACC,loadACC_2,mux,sel,reset: IN STD_LOGIC;
		  A,B: IN STD_LOGIC_VECTOR (3 DOWNTO 0); 
		  carry,carry_2,Q_0: OUT STD_LOGIC;
		  R: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)); 
END PO;

ARCHITECTURE arq OF PO IS
COMPONENT mux2x1	--Multiplexador
	GENERIC(N: INTEGER := 4);
	PORT (a, b: IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
		  sel: IN STD_LOGIC;
		  Y : OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0));
END COMPONENT;

COMPONENT RegNBits	--Registrador
	GENERIC(N: INTEGER := 8);
	PORT (D: IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
		  reset, clk, load, desl: IN STD_LOGIC;
		  Q: OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0));
END COMPONENT;

COMPONENT RCA_Nbits	--Somador
	GENERIC(N: INTEGER := 8);
	PORT (A, B: IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
		  Cin: IN STD_LOGIC;
		  Soma: OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0);
		  Cout: OUT STD_LOGIC);
END COMPONENT;

SIGNAL ACC,Sacc: STD_LOGIC_VECTOR(7 DOWNTO 0);
SIGNAL muxAR,Sar,Sbr,Smux,Sacc_2,ACC_2: STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN			
	regAR: RegNBits GENERIC MAP(N => 4)
			PORT MAP(A,reset,clk,loadAR,'0',Sar); --Registra AR
			
	regBR: RegNBits GENERIC MAP(N => 4)
			PORT MAP(B,reset,clk,loadBR,'1',Sbr); --Registra BR	
			
	regACC: RegNBits GENERIC MAP(N => 8)
			PORT MAP(ACC,reset,clk,loadACC,sel,Sacc); --Registra ACC	
			
	multiplexador: mux2x1 GENERIC MAP(N => 4)
			PORT MAP(Sar,"0000",mux,Smux); --Mux 2x1	
			
	somador: RCA_Nbits GENERIC MAP(N => 8)
			PORT MAP("0000"&Smux,Sacc,'0',ACC,carry); --Somador
			
	somador_2: RCA_Nbits GENERIC MAP(N => 4)
		PORT MAP("0001",Sacc_2,'0',ACC_2,carry_2); --Somador_2

	regACC_2: RegNBits GENERIC MAP(N => 4)
			PORT MAP(ACC_2,reset,clk,loadACC_2,'0',Sacc_2); --Registra ACC_2								
		
	Q_0 <= Sbr(0);		
	R <= Sacc;
END arq;