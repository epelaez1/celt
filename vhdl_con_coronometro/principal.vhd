---------------------------------------------------
-- Principal
--
-- Interconexión de todos los módulos del proyecto 
-- Selecciona la información a mostrar  en función
-- del modo elegido.
-- 
---------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity principal is
    Port ( 
        SIN : in STD_LOGIC;
        CLK : in  STD_LOGIC;
        RESET : in  STD_LOGIC;
        START : in  STD_LOGIC;
        CRONO : in STD_LOGIC;
        SAL : OUT STD_LOGIC_VECTOR (6 downto 0);
        ACT_SEG : OUT STD_LOGIC_VECTOR (3 downto 0)
    );
end principal;

architecture a_principal of principal is

    signal reg_to_sum  : STD_LOGIC_VECTOR (39 downto 0); -- Comunica el registro de desplazamiento40 con el sumador
    signal CLK_M  : STD_LOGIC;
    --signal audio  : STD_LOGIC;
    signal sum_out : STD_LOGIC_VECTOR (5 downto 0); -- Salida del sumador que recibe el comparador
    signal GTU1 : STD_LOGIC; -- Salida sumador mayor que umbral 1
    signal LEU1 : STD_LOGIC; -- Salida sumador menor que umbral 1
    signal LEU2 : STD_LOGIC; -- Salida sumador menor que umbral 2
    signal SAND : STD_LOGIC; -- Salida del and
    signal Dat_SIN : STD_LOGIC; -- Comunica Dato (autómata) con SIN del registro de desplazamiento
    signal Capt_EN : STD_LOGIC; -- Comunica Captura (autómata) con EN del registro de desplazamiento
    signal Val_EN : STD_LOGIC; -- Comunica Validar (autómata) con EN del registro de validación
    signal reg_desp_val : STD_LOGIC_VECTOR (13 downto 0); -- Comunica el registro de desplazamiento con el r.validacion
    signal val_visual : STD_LOGIC_VECTOR (13 downto 0); -- Comunica el registro de validacion con visualización
    signal tiempo_cronometro : STD_LOGIC_VECTOR (13 downto 0):= (others=>'0');
    signal hora_senal : STD_LOGIC_VECTOR (13 downto 0):= (others=>'0');

    --component gen_signal 
    --         Port ( clk : in  STD_LOGIC;
    --           sal_dig : out  STD_LOGIC);
    --    
    --end component;



    component reg_desp40 
        Port ( 
            SIN : in STD_LOGIC; 
            CLK : in STD_LOGIC; 
            Q :  out STD_LOGIC_VECTOR (39 downto 0)
        ); 
        
    end component;

    component sumador40 
        Port ( 
            ENT : in  STD_LOGIC_VECTOR (39 downto 0);
            SAL : out  STD_LOGIC_VECTOR (5 downto 0)
        );   
    end component;

    component gen_reloj
        Port ( 
            CLK : in  STD_LOGIC;
            CLK_M : out  STD_LOGIC
        );
    end component;

    component comparador
        Port ( 
            P : in STD_LOGIC_VECTOR (5 downto 0); 
            Q : in STD_LOGIC_VECTOR (5 downto 0); 
            PGTQ : out STD_LOGIC; 
            PLEQ : out STD_LOGIC
        ); 
    end component;
    component AND_2
        Port ( 
            A : in STD_LOGIC;
            B : in STD_LOGIC;
            S : out STD_LOGIC
        ); 
    end component;
    component automata
        Port ( 
            CLK : in STD_LOGIC;
            C0 : in STD_LOGIC; 
            C1 : in STD_LOGIC; 
            DATO : out STD_LOGIC;
            CAPTUR : out STD_LOGIC;
            VALID : out STD_LOGIC
        );
    end component;

    component reg_desp 
        Port (
            SIN : in STD_LOGIC; 
            CLK : in STD_LOGIC; 
            EN : in STD_LOGIC; 
            Q : out STD_LOGIC_VECTOR (13 downto 0)
        ); 
    end component;

    component registro 
        Port (
            ENTRADA : in STD_LOGIC_VECTOR (13 downto 0);
            SALIDA : out STD_LOGIC_VECTOR (13 downto 0);
            EN : in STD_LOGIC;
            CLK : in STD_LOGIC
        );
    end component;

    component visualizacion 
        Port ( 
            CLK : in  STD_LOGIC;
            E0 : in   STD_LOGIC_VECTOR (3 downto 0);
            E1 : in   STD_LOGIC_VECTOR (3 downto 0);
            E2 : in   STD_LOGIC_VECTOR (3 downto 0);
            E3 : in   STD_LOGIC_VECTOR (3 downto 0);
            SEG7 : out  STD_LOGIC_VECTOR (6 downto 0);
            AN : out  STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;
    component cronometro 
        Port ( 
            reset : in STD_LOGIC;
            start : in STD_LOGIC;
            CLK : in  STD_LOGIC;
            minutos_decenas : out  STD_LOGIC_VECTOR (2 downto 0);
            minutos_unidades : out  STD_LOGIC_VECTOR (3 downto 0);
            segundos_decenas : out  STD_LOGIC_VECTOR (2 downto 0);
            segundos_unidades : out  STD_LOGIC_VECTOR (3 downto 0)
        );
    end component;
    begin
        -- Selecciona qué señal se debe mostrar en el display
    	PROC_SELECT_OUTPUT: process(CLK, CRONO)
    	begin
    		if CRONO = '1' then
    		  val_visual <= tiempo_cronometro;
    		else
    		  val_visual <= hora_senal;
    		end if;
    	end process;

    registro_desp40 : reg_desp40

        port map (
            SIN  =>  SIN,
            CLK  =>  CLK_M,
            Q    =>  reg_to_sum
        ); 

    cronometer : cronometro
        port map (
            reset => RESET,
            start => START,
            CLK => CLK,
            minutos_decenas => tiempo_cronometro(13 downto 11),
            minutos_unidades => tiempo_cronometro(10 downto 7),
            segundos_decenas =>  tiempo_cronometro(6 downto 4),
            segundos_unidades => tiempo_cronometro(3 downto 0)
        );
    sumador : sumador40
        port map (
      	    ENT   =>  reg_to_sum,
    	    SAL   =>  sum_out
        );

    clock40 : gen_reloj
        port map (
    	    CLK   =>  CLK,
            CLK_M =>  CLK_M
        );

    --generated_signal : gen_signal
    --
    --            port map (
    --              CLK     =>  CLK,
    --              sal_dig =>  audio
    --            );
    comparadorU1 : comparador 
        port map (
            P => sum_out,
            Q => "100010",
            PGTQ => GTU1,
            PLEQ => LEU1
        );
    comparadorU2 : comparador 
        port map (
            P => sum_out,
            Q => "100110",
            PGTQ => open,
            PLEQ => LEU2
        );
    comparador_and_2 : AND_2
        port map (
            A => GTU1,
            B => LEU2,
            S => SAND
        );
    automata_moore : automata
        port map (
            CLK => CLK_M,
            C0 => SAND,
            C1 => LEU1,
            DATO => Dat_SIN,
            CAPTUR => Capt_EN,
            VALID => Val_EN
        );
    registro_desp : reg_desp
        port map (
            SIN => Dat_SIN,
            CLK => CLK_M,
            EN => Capt_EN,
            Q => reg_desp_val
        );
    reg : registro
        port map (
            ENTRADA => reg_desp_val,
            SALIDA => hora_senal,
            EN => Val_EN,
            CLK => CLK_M
        );
    display : visualizacion
        port map (
            CLK => CLK,
            E3(2 downto 0)  => val_visual(13 downto 11),
            E3(3) => '0',
            E2  => val_visual(10 downto 7),
            E1(2 downto 0)  => val_visual(6 downto 4),
            E1(3) => '0',
            E0  => val_visual(3 downto 0),
            SEG7 => SAL, 
            AN  => ACT_SEG
        );
end a_principal;

-- Terminar visualizacion
