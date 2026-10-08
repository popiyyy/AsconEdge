library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity nonce_policy_guard is
    Port (
        clk         : in std_logic;
        reset_n     : in std_logic;
        new_nonce   : in std_logic_vector(127 downto 0);
        check_req   : in std_logic;
        
        nonce_valid : out std_logic;
        nonce_err   : out std_logic
    );
end nonce_policy_guard;

architecture rtl of nonce_policy_guard is
    signal last_nonce : unsigned(127 downto 0) := (others => '0');
begin
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            last_nonce <= (others => '0');
            nonce_valid <= '0';
            nonce_err <= '0';
        elsif rising_edge(clk) then
            nonce_valid <= '0';
            nonce_err <= '0';
            
            if check_req = '1' then
                if unsigned(new_nonce) > last_nonce then
                    nonce_valid <= '1';
                    last_nonce <= unsigned(new_nonce);
                else
                    nonce_err <= '1';
                end if;
            end if;
        end if;
    end process;
end rtl;
