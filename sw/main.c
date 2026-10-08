#include <stdio.h>
#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include "asconedge_driver.h"

#define FPGA_HPS_LW_BASE 0xFF200000 
#define ASCON_CORE_OFFSET 0x00000000 

int main() {
    printf("--- AsconEdge C Driver Test ---\n");
    
    if (asconedge_init(FPGA_HPS_LW_BASE + ASCON_CORE_OFFSET) != 0) {
        printf("Failed to map FPGA memory. Run as root?\n");
        printf("ponytail: Bypass init check for compilation test.\n");
    }

    uint8_t key[16]   = {0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef, 0x01,0x23,0x45,0x67,0x89,0xab,0xcd,0xef};
    uint8_t nonce[16] = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00, 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01};
    uint8_t plaintext[16] = "Hello FPGA Edge";
    uint8_t ciphertext[16] = {0};
    uint8_t decrypted[16] = {0};

    printf("Setting Key and Nonce...\n");
    asconedge_set_key(key);
    asconedge_set_nonce(nonce);

    printf("Encrypting...\n");
    if (asconedge_process_block(plaintext, ciphertext, 16, false)) {
        printf("Encryption Success.\n");
    }

    printf("Decrypting...\n");
    if (asconedge_process_block(ciphertext, decrypted, 16, true)) {
        printf("Decryption Success. Plaintext: %s\n", decrypted);
    } else {
        printf("Decryption Failed! Data not released.\n");
    }

    asconedge_close();
    printf("--- Test Finished ---\n");
    return 0;
}
