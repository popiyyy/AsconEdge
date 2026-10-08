library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity aead_controller is
    Port (
        clk         : in std_logic;
        reset_n     : in std_logic;
        start       : in std_logic;
        mode        : in std_logic;
        nonce_valid : in std_logic;
        tag_match   : in std_logic;
        
        busy        : out std_logic;
        done        : out std_logic;
        output_valid: out std_logic;
        auth_fail   : out std_logic;
        nonce_err   : out std_logic;
        zeroize     : out std_logic  
    );
end aead_controller;

architecture fsm of aead_controller is
    type state_type is (IDLE, LOAD_INPUT, CHECK_NONCE, INIT_P12, ABSORB_AD, DOMAIN_SEP, PROCESS_PAYLOAD, FINAL_P12, VERIFY_TAG, AUTH_RELEASE, WRITE_OUTPUT, ERROR_STATE, ZEROIZE_STATE, DONE_STATE);
    signal state, next_state : state_type;
begin

    process(clk, reset_n)
    begin
        if reset_n = '0' then
            state <= IDLE;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    process(state, start, mode, nonce_valid, tag_match)
    begin
        busy <= '1'; done <= '0'; output_valid <= '0'; 
        auth_fail <= '0'; nonce_err <= '0'; zeroize <= '0';
        next_state <= state;

        case state is
            when IDLE =>
                busy <= '0';
                if start = '1' then next_state <= LOAD_INPUT; end if;
                
            when LOAD_INPUT =>
                if mode = '0' then next_state <= CHECK_NONCE; 
                else next_state <= INIT_P12; end if;          
                
            when CHECK_NONCE =>
                if nonce_valid = '1' then next_state <= INIT_P12;
                else next_state <= ERROR_STATE; nonce_err <= '1'; end if;
                
            when INIT_P12 => next_state <= ABSORB_AD;
            when ABSORB_AD => next_state <= DOMAIN_SEP;
            when DOMAIN_SEP => next_state <= PROCESS_PAYLOAD;
            when PROCESS_PAYLOAD => next_state <= FINAL_P12;
            
            when FINAL_P12 =>
                if mode = '0' then next_state <= WRITE_OUTPUT;
                else next_state <= VERIFY_TAG; end if;
                
            when VERIFY_TAG =>
                if tag_match = '1' then next_state <= AUTH_RELEASE;
                else next_state <= ERROR_STATE; auth_fail <= '1'; end if;
                
            when AUTH_RELEASE =>
                output_valid <= '1'; 
                next_state <= WRITE_OUTPUT;
                
            when WRITE_OUTPUT =>
                next_state <= ZEROIZE_STATE;
                
            when ERROR_STATE =>
                next_state <= ZEROIZE_STATE; 
                
            when ZEROIZE_STATE =>
                zeroize <= '1';
                next_state <= DONE_STATE;
                
            when DONE_STATE =>
                done <= '1';
                next_state <= IDLE;
                
            when others =>
                next_state <= ERROR_STATE;
        end case;
    end process;
end fsm;
