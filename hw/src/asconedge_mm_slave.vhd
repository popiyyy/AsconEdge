library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity asconedge_mm_slave is
    Port (
        clk       : in std_logic;
        reset_n   : in std_logic;
        
        address   : in std_logic_vector(7 downto 0);
        write     : in std_logic;
        writedata : in std_logic_vector(31 downto 0);
        read      : in std_logic;
        readdata  : out std_logic_vector(31 downto 0);
        
        core_start  : out std_logic;
        core_mode   : out std_logic; 
        core_busy   : in std_logic;
        core_done   : in std_logic;
        auth_fail   : in std_logic;
        nonce_err   : in std_logic
    );
end asconedge_mm_slave;

architecture rtl of asconedge_mm_slave is

    signal ctrl_reg   : std_logic_vector(31 downto 0) := (others => '0');
    signal status_reg : std_logic_vector(31 downto 0) := (others => '0');
begin
    
    status_reg(0) <= core_busy;
    status_reg(1) <= core_done;
    status_reg(2) <= auth_fail;
    status_reg(3) <= nonce_err;
    status_reg(31 downto 4) <= (others => '0');
    
    core_start <= ctrl_reg(0);
    core_mode  <= ctrl_reg(1);

    process(clk, reset_n)
    begin
        if reset_n = '0' then
            ctrl_reg <= (others => '0');
        elsif rising_edge(clk) then
            if write = '1' then
                case address is
                    when x"00" => ctrl_reg <= writedata;
                    when others => null;
                end case;
            end if;
            
            if read = '1' then
                case address is
                    when x"00" => readdata <= ctrl_reg;
                    when x"04" => readdata <= status_reg;
                    when others => readdata <= (others => '0');
                end case;
            end if;
            
            if ctrl_reg(0) = '1' and core_busy = '1' then
                ctrl_reg(0) <= '0';
            end if;
        end if;
    end process;
end rtl;
