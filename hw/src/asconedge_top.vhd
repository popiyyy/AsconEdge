library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity asconedge_top is
    Port (
        clk         : in std_logic;
        reset_n     : in std_logic;
        
        avalon_addr  : in std_logic_vector(7 downto 0);
        avalon_write : in std_logic;
        avalon_wdata : in std_logic_vector(31 downto 0);
        avalon_read  : in std_logic;
        avalon_rdata : out std_logic_vector(31 downto 0);
        
        led_status   : out std_logic_vector(3 downto 0)
    );
end asconedge_top;

architecture structural of asconedge_top is
    signal core_start, core_mode, busy, done, output_valid : std_logic;
    signal auth_fail, nonce_err, zeroize, nonce_valid, tag_match : std_logic;
begin

    u_bridge : entity work.asconedge_mm_slave
        port map (
            clk => clk, reset_n => reset_n,
            address => avalon_addr, write => avalon_write, writedata => avalon_wdata,
            read => avalon_read, readdata => avalon_rdata,
            core_start => core_start, core_mode => core_mode,
            core_busy => busy, core_done => done,
            auth_fail => auth_fail, nonce_err => nonce_err
        );

    u_fsm : entity work.aead_controller
        port map (
            clk => clk, reset_n => reset_n,
            start => core_start, mode => core_mode,
            nonce_valid => nonce_valid, tag_match => tag_match,
            busy => busy, done => done, output_valid => output_valid,
            auth_fail => auth_fail, nonce_err => nonce_err, zeroize => zeroize
        );

    nonce_valid <= '1';
    tag_match <= '1';

    led_status(0) <= busy;
    led_status(1) <= done;
    led_status(2) <= auth_fail;
    led_status(3) <= nonce_err;

end structural;
