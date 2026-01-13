library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity bloco_controle is
    port (
        clk, rst, B      : in  std_logic;
        f_10s, f_2s  : in  std_logic; -- Sinais vindos do BO
        len, lento       : out std_logic; -- Saídas externas
        clr_cont, inc_cont, ld_rtempo : out std_logic -- Comandos para o BO
    );
end bloco_controle;

architecture Behavioral of bloco_controle is
    -- Estados 
    type state_type is (IDLE, WAIT_10S, REACTION, DISPLAY, TIMEOUT);
    signal state, next_state : state_type;
begin

    -- Processo Sequencial 
    process(clk, rst)
    begin
        if rst = '1' then
            state <= IDLE;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    -- Processo Combinacional 
    process(state, B, f_10s, f_2s)
    begin
    
        len <= '0'; 
        lento <= '0'; 
        clr_cont <= '0'; 
        inc_cont <= '0'; 
        ld_rtempo <= '0';
        next_state <= state; 

        case state is
            when IDLE =>
                clr_cont <= '1'; -- Zera tudo ao iniciar
                next_state <= WAIT_10S;

            when WAIT_10S =>
                if f_10s = '1' then
                    clr_cont <= '1'; 
                    next_state <= REACTION;
                else 
                    inc_cont <= '1'; 
                    next_state <= WAIT_10S;
                end if;

            when REACTION =>
                len <= '1'; 
                if B = '1' then 
                    
                    ld_rtempo <= '1'; 
                    next_state <= DISPLAY;
                elsif f_2s = '1' then 
                    -- Estourou o tempo 
                    ld_rtempo <= '1'; 
                    next_state <= TIMEOUT;
                else
                    inc_cont <= '1'; 
                    next_state <= REACTION;
                end if;

            when DISPLAY =>
                len <= '0'; 
                next_state <= DISPLAY;

            when TIMEOUT =>
                lento <= '1'; 
                next_state <= TIMEOUT;
        end case;
    end process;
end Behavioral;