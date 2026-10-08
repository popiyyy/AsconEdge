library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity ascon_permutation is
    generic (
        ROUNDS_PER_CYCLE : integer := 1
    );
    Port (
        clk         : in  std_logic;
        reset_n     : in  std_logic;
        start       : in  std_logic;
        is_p12      : in  std_logic;
        state_in    : in  std_logic_vector(319 downto 0);
        
        state_out   : out std_logic_vector(319 downto 0);
        done        : out std_logic
    );
end ascon_permutation;

architecture rtl of ascon_permutation is

    component ascon_round
        Port (
            state_in    : in  std_logic_vector(319 downto 0);
            round_const : in  std_logic_vector(7 downto 0);
            state_out   : out std_logic_vector(319 downto 0)
        );
    end component;

    signal current_state : std_logic_vector(319 downto 0);
    signal next_state    : std_logic_vector(319 downto 0);
    
    signal round_idx     : integer range 0 to 15;
    signal round_const   : std_logic_vector(7 downto 0);
    signal busy          : std_logic;

    type const_array is array (0 to 11) of std_logic_vector(7 downto 0);
    constant ASCON_CONSTANTS : const_array := (
        x"f0", x"e1", x"d2", x"c3", x"b4", x"a5", 
        x"96", x"87", x"78", x"69", x"5a", x"4b"
    );

begin

    round_inst: ascon_round port map (
        state_in    => current_state,
        round_const => round_const,
        state_out   => next_state
    );

    process(clk, reset_n)
    begin
        if reset_n = '0' then
            busy <= '0';
            done <= '0';
            round_idx <= 0;
            current_state <= (others => '0');
        elsif rising_edge(clk) then
            done <= '0';
            
            if start = '1' and busy = '0' then
                busy <= '1';
                current_state <= state_in;
                if is_p12 = '1' then
                    round_idx <= 0;
                else
                    round_idx <= 4;
                end if;
            elsif busy = '1' then
                current_state <= next_state;
                round_idx <= round_idx + 1;
                
                if round_idx = 11 then
                    busy <= '0';
                    done <= '1';
                end if;
            end if;
        end if;
    end process;

    round_const <= ASCON_CONSTANTS(round_idx) when round_idx <= 11 else x"00";
    state_out <= current_state;

end rtl;
