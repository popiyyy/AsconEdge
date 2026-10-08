library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ascon_round is
    Port (
        state_in    : in  std_logic_vector(319 downto 0);
        round_const : in  std_logic_vector(7 downto 0);
        state_out   : out std_logic_vector(319 downto 0)
    );
end ascon_round;

architecture combinational of ascon_round is

    function ror64(x: std_logic_vector(63 downto 0); n: integer) return std_logic_vector is
    begin
        return x(n-1 downto 0) & x(63 downto n);
    end function;

    signal x0, x1, x2, x3, x4 : std_logic_vector(63 downto 0);
    signal t0, t1, t2, t3, t4 : std_logic_vector(63 downto 0);
    
    signal ac_x2 : std_logic_vector(63 downto 0);
    
    signal s_x0, s_x1, s_x2, s_x3, s_x4 : std_logic_vector(63 downto 0);

begin

    x0 <= state_in(319 downto 256);
    x1 <= state_in(255 downto 192);
    x2 <= state_in(191 downto 128);
    x3 <= state_in(127 downto 64);
    x4 <= state_in(63 downto 0);
    ac_x2 <= x2(63 downto 8) & (x2(7 downto 0) xor round_const);
    t0 <= x0 xor x4;
    t4 <= x4 xor x3;
    t2 <= ac_x2 xor x1;

    s_x0 <= t0 xor (not x1 and t2);
    s_x1 <= x1 xor (not t2 and x3);
    s_x2 <= t2 xor (not x3 and t4);
    s_x3 <= x3 xor (not t4 and t0);
    s_x4 <= t4 xor (not t0 and x1);
    
    t1 <= s_x1 xor s_x0;
    t3 <= s_x3 xor s_x2;
    s_x0 <= s_x0 xor s_x4;
    s_x2 <= not s_x2;
    
    state_out(319 downto 256) <= s_x0 xor ror64(s_x0, 19) xor ror64(s_x0, 28);
    state_out(255 downto 192) <= t1   xor ror64(t1, 61)   xor ror64(t1, 39);
    state_out(191 downto 128) <= s_x2 xor ror64(s_x2, 1)  xor ror64(s_x2, 6);
    state_out(127 downto 64)  <= t3   xor ror64(t3, 10)   xor ror64(t3, 17);
    state_out(63 downto 0)    <= s_x4 xor ror64(s_x4, 7)  xor ror64(s_x4, 41);

end combinational;
