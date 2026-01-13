library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bloco_operacional is
    port (
        clk             : in  std_logic;
        clr_cont        : in  std_logic;
        inc_cont        : in  std_logic;
        ld_rtempo       : in  std_logic;
        fim_10s         : out std_logic;
        fim_2s          : out std_logic;
        rtempo_out      : out std_logic_vector(11 downto 0)
    );
end bloco_operacional;

architecture RTL of bloco_operacional is

    -- Declaração do componente ALU (deve ser igual à Entity da ALU)
    component ALU is
        Port ( 
            A, B      : in  STD_LOGIC_VECTOR (15 downto 0);
            Sel       : in  STD_LOGIC_VECTOR (3 downto 0); 
            Resultado : out STD_LOGIC_VECTOR (15 downto 0);
            C, O      : out STD_LOGIC
        );
    end component;

    signal contador_reg : std_logic_vector(15 downto 0) := (others => '0');
    signal alu_result   : std_logic_vector(15 downto 0);
    
    -- Constantes
    constant OP_INC : std_logic_vector(3 downto 0) := "0111"; -- Código para Incremento
    constant ZERO_16 : std_logic_vector(15 downto 0) := (others => '0');

begin

    -- Instanciação da ALU
    U_ALU: ALU port map (
        A => contador_reg,    -- Entra o valor atual do contador
        B => ZERO_16,         -- B não importa no incremento
        Sel => OP_INC,        -- Operação 0111 (Incremento)
        Resultado => alu_result, -- Sai (Valor + 1)
        C => open, 
        O => open
    );

    -- Processo do Registrador do Contador
    process(clk)
    begin
        if rising_edge(clk) then
            if clr_cont = '1' then
                contador_reg <= (others => '0'); -- Zera o registrador
            elsif inc_cont = '1' then
                contador_reg <= alu_result;      -- Atualiza com valor da ALU
            end if;
            
            -- Registrador de Saída (RTEMPO)
            if ld_rtempo = '1' then
                -- Pega os 12 bits menos significativos
                rtempo_out <= contador_reg(11 downto 0);
            end if;
        end if;
    end process;

    -- Comparadores (Status para o BC)
    -- Clock 2.5 kHz -> Periodo 0.4ms
    -- 10 segundos = 10 / 0.0004 = 25000 pulsos
    fim_10s <= '1' when unsigned(contador_reg) >= 25000 else '0';
    
    -- 2 segundos = 2 / 0.0004 = 5000 pulsos
    fim_2s  <= '1' when unsigned(contador_reg) >= 5000 else '0';

end RTL;