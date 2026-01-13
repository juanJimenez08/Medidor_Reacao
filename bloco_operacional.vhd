library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bloco_operacional is
    port (
        clk             : in  std_logic;
        clr_cont        : in  std_logic;
        inc_cont        : in  std_logic;
        ld_rtempo       : in  std_logic; 
        f_10s         : out std_logic;
        f_2s          : out std_logic;
        rtempo_out      : out std_logic_vector(15 downto 0)
    );
end bloco_operacional;

architecture RTL of bloco_operacional is

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
    constant OP_INC : std_logic_vector(3 downto 0) := "0111"; 
    constant ZERO_16 : std_logic_vector(15 downto 0) := (others => '0');

begin

    
    U_ALU: ALU port map (
        A => contador_reg, B => ZERO_16, Sel => OP_INC,        
        Resultado => alu_result, C => open, O => open
    );

    process(clk)
    begin
        if rising_edge(clk) then
            if clr_cont = '1' then
                contador_reg <= (others => '0');
                
            elsif inc_cont = '1' then
                
                contador_reg <= alu_result; 
            end if;
            
           
            
        end if;
    end process;

    
    rtempo_out <= std_logic_vector(contador_reg(15 downto 0));
	 
	 

   
    f_2s  <= '1' when unsigned(contador_reg) >= 5000 else '0';
    f_10s <= '1' when unsigned(contador_reg) >= 25000 else '0';

end RTL;