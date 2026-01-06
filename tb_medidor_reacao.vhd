library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_medidor_reacao is
end tb_medidor_reacao;

architecture Behavioral of tb_medidor_reacao is

    component medidor_reacao_top
        port (
            clk, rst, B : in  std_logic;
            len, lento  : out std_logic;
            rtempo      : out std_logic_vector(11 downto 0)
        );
    end component;

    signal clk_tb   : std_logic := '0';
    signal rst_tb   : std_logic := '0';
    signal B_tb     : std_logic := '0';
    signal len_tb   : std_logic;
    signal lento_tb : std_logic;
    signal rtempo_tb: std_logic_vector(11 downto 0);

    constant CLK_PERIOD : time := 400 us;

begin

    UUT: medidor_reacao_top port map (
        clk => clk_tb, rst => rst_tb, B => B_tb, 
        len => len_tb, lento => lento_tb, rtempo => rtempo_tb
    );

    -- Gerador de Clock
    process
    begin
        clk_tb <= '0'; wait for CLK_PERIOD/2;
        clk_tb <= '1'; wait for CLK_PERIOD/2;
    end process;

    ---------------------------------------------------------------------------
    -- PROCESSO 1: ESTIMULADOR (Lê do seu arquivo específico e para no final)
    ---------------------------------------------------------------------------
    process
        -- Usei barras normais (/) para garantir compatibilidade
        file arquivo_entradas : text open read_mode is "C:/Users/juane/OneDrive/Documentos/QUARTUS/MEDIDOR/entradas.txt";
        variable linha_leitura : line;
        variable var_rst, var_B : std_logic;
        variable var_ciclos : integer;
        variable espaco : character;
    begin
        wait for 100 ns;

        while not endfile(arquivo_entradas) loop
            readline(arquivo_entradas, linha_leitura);
            
            if linha_leitura'length > 0 then
                read(linha_leitura, var_rst);
                read(linha_leitura, espaco);
                read(linha_leitura, var_B);
                read(linha_leitura, espaco);
                read(linha_leitura, var_ciclos);

                wait until falling_edge(clk_tb);
                rst_tb <= var_rst;
                B_tb   <= var_B;

                for i in 1 to var_ciclos loop
                    wait until rising_edge(clk_tb);
                end loop;
            end if;
        end loop;
        
        file_close(arquivo_entradas);
        
        -- COMANDO PARA PARAR A SIMULAÇÃO AUTOMATICAMENTE
        report "FIM DO ARQUIVO DE TESTE. PARANDO SIMULACAO." severity note;
        assert false report "Simulacao Concluida com Sucesso!" severity failure;
        
        wait;
    end process;

    ---------------------------------------------------------------------------
    -- PROCESSO 2: MONITOR (Grava na mesma pasta do projeto)
    ---------------------------------------------------------------------------
    process
        file arquivo_saidas : text open write_mode is "C:/Users/juane/OneDrive/Documentos/QUARTUS/MEDIDOR/saidas.txt";
        variable linha_escrita : line;
        
        variable v_len_prev   : std_logic := 'U';
        variable v_lento_prev : std_logic := 'U';
        variable v_rtempo_prev: std_logic_vector(11 downto 0) := (others => 'U');
    begin
        write(linha_escrita, string'("Tempo(ms) | Len | Lento | RTempo (Dec)"));
        writeline(arquivo_saidas, linha_escrita);

        while true loop
            wait until falling_edge(clk_tb);

            -- Grava apenas se houver mudança nas saídas
            if (len_tb /= v_len_prev) or 
               (lento_tb /= v_lento_prev) or 
               (rtempo_tb /= v_rtempo_prev) then
                
                write(linha_escrita, time'image(now));
                write(linha_escrita, string'(" |  "));
                write(linha_escrita, len_tb);
                write(linha_escrita, string'("  |   "));
                write(linha_escrita, lento_tb);
                write(linha_escrita, string'("   |      "));
                write(linha_escrita, to_integer(unsigned(rtempo_tb)));
                
                writeline(arquivo_saidas, linha_escrita);

                v_len_prev := len_tb;
                v_lento_prev := lento_tb;
                v_rtempo_prev := rtempo_tb;
            end if;
        end loop;
    end process;

end Behavioral;