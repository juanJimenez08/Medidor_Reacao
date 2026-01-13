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
            rtempo      : out std_logic_vector(15 downto 0)
        );
    end component;

    -- Sinais de Simulacao
    signal clk_tb   : std_logic := '0';
    signal rst_tb   : std_logic := '0';
    signal B_tb     : std_logic := '0';
    signal len_tb   : std_logic;
    signal lento_tb : std_logic;
    signal rtempo_tb: std_logic_vector(15 downto 0);

    constant CLK_PERIOD : time := 400 us;

begin

    -- Instancia do Circuito Principal
    UUT: medidor_reacao_top port map (
        clk => clk_tb, rst => rst_tb, B => B_tb, 
        len => len_tb, lento => lento_tb, rtempo => rtempo_tb
    );

    -- Geracao de Clock
    process
    begin
        clk_tb <= '0'; wait for CLK_PERIOD/2;
        clk_tb <= '1'; wait for CLK_PERIOD/2;
    end process;

    -- Le o arquivo entradas.txt
    process
        file arquivo_entradas : text open read_mode is "C:/Users/juane/OneDrive/Documentos/QUARTUS/MEDIDOR/entradas.txt";
        variable linha_leitura : line;
        variable var_rst, var_B : std_logic;
        variable var_tempo_ms : integer;
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
                read(linha_leitura, var_tempo_ms);

                -- Conversao de tempo (ms) para ciclos de clock
                var_ciclos := (var_tempo_ms * 5) / 2; 
                if var_ciclos < 1 then var_ciclos := 1; end if;

                wait until falling_edge(clk_tb);
                rst_tb <= var_rst;
                B_tb   <= var_B;

                for i in 1 to var_ciclos loop
                    wait until rising_edge(clk_tb);
                end loop;
            end if;
        end loop;
        file_close(arquivo_entradas);
        -- O fim da simulação agora é controlado pelo timeout do Logger
        wait;
    end process;


    process
        file arquivo_log : text open write_mode is "C:/Users/juane/OneDrive/Documentos/QUARTUS/MEDIDOR/log_ondas.csv";
        variable linha_escrita : line;
        
        -- Variaveis para detectar mudanca
        variable v_rst_prev, v_B_prev : std_logic := 'U';
        variable v_len_prev, v_lento_prev : std_logic := 'U';
        variable v_rtempo_prev : std_logic_vector(15 downto 0) := (others => 'U'); -- AGORA 16 BITS
        
        variable tempo_ms : integer;
        variable ciclos_raw : integer;
        variable rtempo_segundos : real; 
        
        -- Constante do periodo do clock em Segundos 
        constant PERIODO_S : real := 0.0004;
        
    begin
        -- Cabeçalho do CSV
        write(linha_escrita, string'("Time_ms,RST,B,Len,Lento,RTempo_s"));
        writeline(arquivo_log, linha_escrita);

        while true loop
            wait until falling_edge(clk_tb);

            if (rst_tb /= v_rst_prev) or (B_tb /= v_B_prev) or
               (len_tb /= v_len_prev) or (lento_tb /= v_lento_prev) or
               (rtempo_tb /= v_rtempo_prev) then
                
                tempo_ms := now / 1 ms;

                -- Escreve colunas padrao
                write(linha_escrita, tempo_ms);
                write(linha_escrita, string'(","));
                write(linha_escrita, rst_tb);
                write(linha_escrita, string'(","));
                write(linha_escrita, B_tb);
                write(linha_escrita, string'(","));
                write(linha_escrita, len_tb);
                write(linha_escrita, string'(","));
                write(linha_escrita, lento_tb);
                write(linha_escrita, string'(","));
                
                
                -- 1. conversao
                ciclos_raw := to_integer(unsigned(rtempo_tb));
                
                -- 2. Multiplica pelo período do clock
                rtempo_segundos := real(ciclos_raw) * PERIODO_S;
                
                -- Escrita no csv
                write(linha_escrita, rtempo_segundos, right, 0, 4);
                
                writeline(arquivo_log, linha_escrita);

                -- Atualiza memoria
                v_rst_prev := rst_tb; v_B_prev := B_tb;
                v_len_prev := len_tb; v_lento_prev := lento_tb;
                v_rtempo_prev := rtempo_tb;
            end if;
            
            if (now > 800 sec) then report "Timeout" severity failure; end if;
        end loop;
    end process;

end Behavioral;