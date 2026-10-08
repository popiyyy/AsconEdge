library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity asconedge_tb is
end asconedge_tb;

architecture behavior of asconedge_tb is
    -- 1. Deklarasi Komponen yang akan diuji (Device Under Test / DUT)
    component ascon_permutation
        Port (
            clk         : in  std_logic;
            reset_n     : in  std_logic;
            start       : in  std_logic;
            is_p12      : in  std_logic;
            state_in    : in  std_logic_vector(319 downto 0);
            state_out   : out std_logic_vector(319 downto 0);
            done        : out std_logic
        );
    end component;

    -- 2. Sinyal Simulasi (Sinyal yang dikendalikan oleh Testbench)
    signal clk         : std_logic := '0';
    signal reset_n     : std_logic := '0';
    signal start       : std_logic := '0';
    signal is_p12      : std_logic := '1';
    signal state_in    : std_logic_vector(319 downto 0) := (others => '0');
    signal state_out   : std_logic_vector(319 downto 0);
    signal done        : std_logic;

    -- Konstanta periode Clock (contoh 50 MHz = 20 ns)
    constant clk_period : time := 20 ns;

begin

    -- 3. Instansiasi DUT (Hubungkan sinyal simulasi ke pin komponen)
    DUT: ascon_permutation port map (
        clk => clk,
        reset_n => reset_n,
        start => start,
        is_p12 => is_p12,
        state_in => state_in,
        state_out => state_out,
        done => done
    );

    -- 4. Proses Pembangkit Clock (Clock Generator)
    clk_process : process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;

    -- 5. Skenario Pengujian (Stimulus Process)
    stim_proc: process
    begin
        -- Tahan Reset selama beberapa siklus
        reset_n <= '0';
        wait for 40 ns;
        reset_n <= '1';
        wait for clk_period;

        -- Uji Coba: Inisialisasi permutasi P12 dengan state awal sembarang (contoh)
        state_in(319 downto 256) <= x"0011223344556677"; -- x0
        -- (Sisa state_in bernilai nol dari default)
        
        is_p12 <= '1'; -- Mode P12 (12 round)
        start <= '1';
        wait for clk_period;
        start <= '0';

        -- Tunggu sinyal done
        wait until done = '1';
        
        -- Berikan jeda untuk melihat hasil di layar simulasi (Waveform)
        wait for 100 ns;

        -- Akhiri simulasi
        assert false report "Simulasi Selesai." severity note;
        wait;
    end process;

end behavior;
