# Multiplicador_Soma_Desloca
# Autor: Bruno Pires Lourenço


1. INTRODUÇÃO

  Esse projeto apresenta a descrição em VHDL de um multiplicador por somas com deslocamento, permitindo que o usuário insira dois valores de 8 bits que serão multiplicados através de sucessivas somas realiazadas pelos componentes, sendo que o deslocamento ocorre a cada iteração. Foram utilizados três registradores, um multiplexador e um somador. É importante mencionar que o projeto foi realizado no modelo PC-PO, ou seja, há uma parte de controle (que designa todo o processo das tarefas do projeto) e uma parte operativa (que descreve os componentes utilizados, bem como as conexões entre eles). O software utilizado foi o Quartus II, versão 13.0.1, juntamente com o ModelSim. A descrição VHDL deste multiplicador foi feito para ser aplicado em um FPGA, da família Cyclone II, dispositivo EP2C35F672C6.
  
2. O PROJETO

  Ao pensar no funcionamento do multiplicador, foi criada a FSM da figura abaixo:
  
  ![FSM](https://github.com/brunopires97/Multiplicador_Soma_Desloca/blob/main/Images/FSM.jpg?raw=true)
  
  Além disso, foram construídos os blocos de controle e operacional, como podem ser vistos nas figuras 2 e 3:
  
  ![Bloco Operativo](https://github.com/brunopires97/Multiplicador_Soma_Desloca/blob/main/Images/Bloco%20Operativo.jpg?raw=true)
  
  ![Bloco de Controle](https://github.com/brunopires97/Multiplicador_Soma_Desloca/blob/main/Images/Bloco%20de%20Controle.jpg?raw=true)
  
  Percebe-se, a partir da figura acima, que a multiplicação possui uma configuração paralela, com três registradores, um multiplexador e um somador. Em um primeiro momento, deveriam ser armazenadas as entradas A e B em seus respectivos registradores. Após, deveria haver uma análise do dígito menos significativo do multiplicador e, caso fosse 1, o multiplicando seria somado ao produto parcial. Caso fosse 0, o valor somado ao produto parcial seria 0. Depois disso, o produto parcial seria deslocado para a direita, conforme a figura abaixo:
  
  ![Multiplicação desloca-soma](https://github.com/brunopires97/Multiplicador_Soma_Desloca/blob/main/Images/Multiplica%C3%A7%C3%A3o%20desloca-soma.jpg?raw=true)

3. COMPONENTES UTILIZADOS

   - REGISTRADOR-DESLOCADOR
   
     O registrador-deslocador é o componente que armazena os dados das variáveis e faz o processo de deslocamento. Nesse projeto, foram utilizados três registradores-deslocadores genéricos de 8 bits (para armazenar as entradas A e B, e para o acumulador), mas apenas o registrador do acumulador utiliza a função de deslocamento. A descrição em VHDL do registrador pode ser observada abaixo.
       
```
       -- INÍCIO DO VHDL DO REGISTRADOR-DESLOCADOR

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

-- FIM DO VHDL DO REGISTRADOR-DESLOCADOR
```

   - FULL-ADDER
   
     O full-adder (ou somador completo) é o componente que soma três entradas (A, B e Cin) e produz duas saídas (Resultado e Cout). 
     
     ![Full-Adder](https://github.com/brunopires97/Multiplicador_Soma_Desloca/blob/main/Images/Full-Adder.jpg?raw=true)
     
     Esse componente foi utilizado na descrição do somador. O código em VHDL pode ser visto na imagem abaixo.
```
-- INÍCIO DO VHDL DO FULL-ADDER

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

-- FIM DO VHDL DO FULL-ADDER
```

   - Multiplexador 2X1
     O multiplexador 2x1 foi utilizado para fazer a escolha de somar 0, caso o dígito menos significativo fosse 0, ou o valor do multiplicando, caso o dígito menos significativo fosse 1. O código em VHDL do multiplexador pode ser visto abaixo:
 ```
 -- INÍCIO DO VHDL DO MULTIPLEXADOR

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

-- FIM DO CÓDIGO DO MULTIPLEXADOR
```

   - SOMADOR
   
     Foi utilizado um código de um somador genérico de 8 bits, como pode ser visto abaixo:
```
-- INÍCIO DO VHDL DO SOMADOR

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

-- FIM DO VHDL DO SOMADOR
```

4. O MULTIPLICADOR

   O Multiplicador foi dividido em parte operativa e parte de controle.
   - PARTE OPERATIVA
   
   A parte de operativa, responsável por descrever os componentes utilizados, bem como as conexões entre eles, pode ser vista no código abaixo:
```
-- INÍCIO DO VHDL DA PARTE OPERATIVA

LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY PO is
 
PORT (clk,loadAR,loadBR,loadACC,loadACC_2,mux,sel,reset: IN STD_LOGIC;
      A,B: IN STD_LOGIC_VECTOR (3 DOWNTO 0);  
      carry,carry_2,Q_0: OUT STD_LOGIC; 
      R: OUT STD_LOGIC_VECTOR (7 DOWNTO 0));  
END PO;

ARCHITECTURE arq OF PO IS
COMPONENT mux2x1  --Multiplexador 
      GENERIC(N: INTEGER := 4); 
      PORT (a, b: IN STD_LOGIC_VECTOR (N-1 DOWNTO 0); 
            sel: IN STD_LOGIC; 
            Y : OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0)); 
END COMPONENT;

COMPONENT RegNBits --Registrador
       GENERIC(N: INTEGER := 8);  
       PORT (D: IN STD_LOGIC_VECTOR (N-1 DOWNTO 0);
       reset, clk, load, desl: IN STD_LOGIC; 
       Q: OUT STD_LOGIC_VECTOR (N-1 DOWNTO 0)); 
END COMPONENT;

COMPONENT RCA_Nbits --Somador
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

-- FIM DO VHDL DA PARTE OPERATIVA
```

      
   Ao clicar em Netlist Viewers, depois em RTL Viewer, pôde ser observado o circuito feito a partir da descrição:
   
   ![RTL Viewer da parte operativa](https://github.com/brunopires97/Multiplicador_Soma_Desloca/blob/main/Images/RTL%20Viewer%20da%20Parte%20Operativa.jpg?raw=true)
   
   Na figura acima, ocorre a configuração dos componentes utilizados no multiplicador.
   
   - FSM
     A FSM, que é a parte de controle, responsável por controlar a parte operativa, descrevendo toda a sequência/processo do circuito, pode ser vista no código em VHDL abaixo:
     
```
-- INÍCIO DO VHDL DA FSM

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

-- FIM DO VHDL DA FSM
```

    
  Ao clicar em Netlist Viewers, depois em RTL Viewer, pôde ser observado o circuito com registrador de estados feito a partir da descrição:
  
  ![Registrador de estados](https://github.com/brunopires97/Multiplicador_Soma_Desloca/blob/main/Images/Registrador%20de%20Estados.jpg?raw=true)
  
  É importante mencionar que o registrador de estados armazena as informações das operações a serem realizadas em cada estado pela parte operativa.

   - PARTE DE CONTROLE / PARTE OPERATIVA
   
```
-- INÍCIO DO VHDL DA PARTE DE CONTROLE / PARTE OPERATIVA

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

-- FIM DO VHDL DA PARTE DE CONTROLE / PARTE OPERATIVA
```

  Ao clicar em Netlist Viewers, foi apresentada a imagem abaixo:
  
  ![Parte de Controle](https://github.com/brunopires97/Multiplicador_Soma_Desloca/blob/main/Images/Parte%20de%20Controle.jpg?raw=true)
  

5. REFERÊNCIAS
VAHID, Frank. “Sistemas Digitais: Projeto, Otimização e HDLs”. Editora Bookman, 2008.
TOCCI, R. J.; WIDMER, N. J.; MOSS, G. L. “Sistemas Digitais”. Editora Pearson, 2015.
GAJSKI, D. D. “Principles of Digital Design”. Editora Prentice-Hall, 1996.
SLIDEPLAYER. Síntese Lógica Para Componentes Programáveis - VHDL. Disponível em: <https://slideplayer.com.br/slide/4917710/>. Acesso em: 18 out. 2019.
