library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity medidor_reacao_top is
    port (
        clk, rst, B : in  std_logic;
        len, lento  : out std_logic;
        rtempo      : out std_logic_vector(11 downto 0)
    );
end medidor_reacao_top;

architecture Structural of medidor_reacao_top is

    -- Sinais internos 
    signal s_clr     : std_logic; -- Fio do Clear
    signal s_inc     : std_logic; -- Fio do Incremento
    signal s_ld      : std_logic; -- Fio do Load (Registrador)
    signal s_f10     : std_logic; -- Fio do Status "Acabou os 10s"
    signal s_f2      : std_logic; -- Fio do Status "Acabou os 2s"

begin

    -- 1. Instancia da BC
    
    U_BC: entity work.bloco_controle
        port map (
            clk       => clk, 
            rst       => rst, 
            B         => B,
            -- Entradas de Status vindas do BO
            fim_10s   => s_f10, 
            fim_2s    => s_f2,
            -- Saídas de Controle para o mundo externo
            len       => len, 
            lento     => lento,
            -- Saídas de Controle para o BO
            clr_cont  => s_clr, 
            inc_cont  => s_inc, 
            ld_rtempo => s_ld
        );

    -- 2. Instancia BO
    U_BO: entity work.bloco_operacional
        port map (
            clk        => clk,
            -- Entradas de Controle vindas do BC
            clr_cont   => s_clr, 
            inc_cont   => s_inc, 
            ld_rtempo  => s_ld,
            -- Saídas de Status para o BC
            fim_10s    => s_f10, 
            fim_2s     => s_f2,
            -- Saída de Dados para o mundo externo
            rtempo_out => rtempo
        );

end Structural;