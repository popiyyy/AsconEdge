library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tag_verify_zeroize is
    Port (
        clk          : in std_logic;
        reset_n      : in std_logic;
        
        computed_tag : in std_logic_vector(127 downto 0);
        received_tag : in std_logic_vector(127 downto 0);
        verify_req   : in std_logic;
        
        tag_match    : out std_logic;
        auth_fail    : out std_logic
    );
end tag_verify_zeroize;

architecture rtl of tag_verify_zeroize is
begin
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            tag_match <= '0';
            auth_fail <= '0';
        elsif rising_edge(clk) then
            tag_match <= '0';
            auth_fail <= '0';
            
            if verify_req = '1' then
                if computed_tag = received_tag then
                    tag_match <= '1';
                else
                    auth_fail <= '1';
                end if;
            end if;
        end if;
    end process;
end rtl;
