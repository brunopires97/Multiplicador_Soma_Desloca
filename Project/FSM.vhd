LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY FSM is
	PORT (clk,RES,start,Q_0,carry_2: IN STD_LOGIC; 
			reset,loadAR,loadBR,loadACC,loadACC_2,sel,mux: OUT STD_LOGIC);
END FSM;

ARCHITECTURE arq OF FSM IS

TYPE tipoestado IS
	(inicio,registra,compara,igual_0,igual_1,desloca,fim);
SIGNAL estadoAtual,proximoEstado: tipoestado;

BEGIN

	registradorEstado: PROCESS(clk,RES)
	BEGIN
		IF(RES = '1') THEN
			estadoAtual <= inicio;
		ELSIF(clk = '1' AND clk'EVENT) THEN
			estadoAtual <= proximoEstado;
		END IF;
	END PROCESS;
	
	logica: PROCESS(estadoAtual,start,Q_0,carry_2)
	BEGIN
		CASE estadoAtual IS
			WHEN inicio =>
				reset <= '1';
				loadAR <= '0';
				loadBR <= '0';
				loadACC <= '0';
				loadACC_2 <= '0';
				sel <= '0';
				mux <= '0';
				IF(start = '1') THEN
					proximoEstado <= registra;
				ELSE	
					proximoEstado <= inicio;
				END IF;
			WHEN registra =>
				reset <= '0';
				loadAR <= '1';
				loadBR <= '1';
				loadACC <= '1';
				loadACC_2 <= '1';
				sel <= '0';
				mux <= '0';	
						
				proximoEstado <= compara;
			WHEN compara =>
				reset <= '0';
				loadAR <= '0';
				loadBR <= '0';
				loadACC <= '1';
				loadACC_2 <= '1';
				sel <= '0';
				mux <= '0';
				
				IF(Q_0 = '1') THEN
					proximoEstado <= igual_1;
				ELSE
					proximoEstado <= igual_0;
				END IF;
			WHEN igual_1 =>
				reset <= '0';
				loadAR <= '0';
				loadBR <= '0';
				loadACC <= '1';
				loadACC_2 <= '1';
				sel <= '0';
				mux <= '1';
				
				proximoEstado <= desloca;
			WHEN igual_0 =>
				reset <= '0';
				loadAR <= '0';
				loadBR <= '0';
				loadACC <= '1';
				loadACC_2 <= '1';
				sel <= '0';
				mux <= '0';
				
				proximoEstado <= desloca;
			WHEN desloca =>
				reset <= '0';
				loadAR <= '0';
				loadBR <= '0';
				loadACC <= '1';
				loadACC_2 <= '1';
				sel <= '1';
				mux <= '0';
				
				IF(carry_2 = '1') THEN
					proximoEstado <= fim;
				ELSE
					proximoEstado <= compara;
				END IF;
			WHEN fim =>
				reset <= '0';
				loadAR <= '0';
				loadBR <= '0';
				loadACC <= '1';
				loadACC_2 <= '0';
				sel <= '1';
				mux <= '0';
		END CASE;
	END PROCESS;
	
END arq;