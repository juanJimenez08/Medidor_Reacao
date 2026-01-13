library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port ( 
        A         : in  STD_LOGIC_VECTOR (15 downto 0);
        B         : in  STD_LOGIC_VECTOR (15 downto 0);
        Sel       : in  STD_LOGIC_VECTOR (3 downto 0); 
        Resultado : out STD_LOGIC_VECTOR (15 downto 0);
        C         : out STD_LOGIC;
        O         : out STD_LOGIC
    );
end ALU;

architecture Behavioral of ALU is
begin
    process(A, B, Sel)
        variable A_uns, B_uns : unsigned(16 downto 0);
        variable Res_v        : unsigned(16 downto 0);
    begin
        -- 1. Prepara as entradas 
        A_uns := unsigned('0' & A);
        B_uns := unsigned('0' & B);
        
        -- Valores padrao
        Res_v := (others => '0');
        C <= '0';
        O <= '0';

        -- 2. Seleção das Operacoes
        case Sel is
            when "0000" => -- SOMA
                Res_v := A_uns + B_uns;
                C <= Res_v(16); -- Bit 17 é o Carry

            when "0001" => -- SUBTRACAO
                Res_v := A_uns - B_uns;
                C <= Res_v(16);

            when "0010" => -- AND
                Res_v(15 downto 0) := unsigned(A and B);

            when "0011" => -- OR
                Res_v(15 downto 0) := unsigned(A or B);

            when "0100" => -- NOT
                Res_v(15 downto 0) := unsigned(not A);

            when "0101" => -- SHIFT LEFT
                Res_v(15 downto 0) := unsigned(A(14 downto 0) & '0');
                C <= A(15);

            when "0110" => -- SHIFT RIGHT
                Res_v(15 downto 0) := unsigned('0' & A(15 downto 1));
                C <= A(0);

            when "0111" => -- INCREMENTO 
                Res_v := A_uns + 1;
                C <= Res_v(16);

            when "1000" => -- DECREMENTO
                Res_v := A_uns - 1;
                C <= Res_v(16);

            when others => 
                Res_v := (others => '0');
        end case;

        -- 3. Saida do Resultado (16 bits)
        Resultado <= std_logic_vector(Res_v(15 downto 0));

    end process;
end Behavioral;