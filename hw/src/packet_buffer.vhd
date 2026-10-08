library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity packet_buffer is
    Port (
        clk          : in std_logic;
        reset_n      : in std_logic;
        
        data_in      : in std_logic_vector(31 downto 0);
        write_en     : in std_logic;
        
        data_out     : out std_logic_vector(31 downto 0);
        
        output_valid : in std_logic; 
        zeroize      : in std_logic  
    );
end packet_buffer;

architecture rtl of packet_buffer is
    signal quarantine_reg : std_logic_vector(31 downto 0);
begin
    process(clk, reset_n)
    begin
        if reset_n = '0' then
            quarantine_reg <= (others => '0');
            data_out <= (others => '0');
        elsif rising_edge(clk) then
            if zeroize = '1' then
                quarantine_reg <= (others => '0');
                data_out <= (others => '0');
            else
                if write_en = '1' then
                    quarantine_reg <= data_in;
                end if;
                
                if output_valid = '1' then
                    data_out <= quarantine_reg;
                else
                    data_out <= (others => '0');
                end if;
            end if;
        end if;
    end process;
end rtl;
