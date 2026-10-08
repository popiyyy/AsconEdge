#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <unistd.h>
#include <string.h>
#include "asconedge_driver.h"

static volatile uint8_t *ascon_base = NULL;
static int fd = -1;

int asconedge_init(uint32_t base_address) {
    fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd == -1) return -1;
    
    ascon_base = (volatile uint8_t *)mmap(NULL, 4096, PROT_READ | PROT_WRITE, MAP_SHARED, fd, base_address);
    if (ascon_base == MAP_FAILED) return -1;
    
    return 0;
}

void asconedge_close(void) {
    if (ascon_base) munmap((void*)ascon_base, 4096);
    if (fd != -1) close(fd);
}

static inline void write_reg32(uint32_t offset, uint32_t val) {
    *(volatile uint32_t *)(ascon_base + offset) = val;
}

static inline uint32_t read_reg32(uint32_t offset) {
    return *(volatile uint32_t *)(ascon_base + offset);
}

bool asconedge_set_key(const uint8_t *key_16bytes) {
    for (int i = 0; i < 4; i++) {
        uint32_t word = ((uint32_t*)key_16bytes)[i];
        write_reg32(ASCONEDGE_KEY_REG + (i*4), word);
    }
    return true;
}

bool asconedge_set_nonce(const uint8_t *nonce_16bytes) {
    for (int i = 0; i < 4; i++) {
        uint32_t word = ((uint32_t*)nonce_16bytes)[i];
        write_reg32(ASCONEDGE_NONCE_REG + (i*4), word);
    }
    return true;
}

bool asconedge_process_block(const uint8_t *data_in, uint8_t *data_out, uint32_t len, bool is_decrypt) {
    for (uint32_t i = 0; i < (len+3)/4; i++) {
        write_reg32(ASCONEDGE_DATA_IN + (i*4), ((uint32_t*)data_in)[i]);
    }
    
    uint32_t ctrl = CTRL_START | (is_decrypt ? CTRL_MODE_DECRYPT : 0);
    write_reg32(ASCONEDGE_CTRL_REG, ctrl);
    
    uint32_t status;
    do {
        status = read_reg32(ASCONEDGE_STATUS_REG);
    } while (status & STATUS_BUSY);
    
    if (status & STATUS_NONCE_ERR) {
        printf("ERROR: Nonce Reuse Detected!\n");
        return false;
    }
    if (is_decrypt && (status & STATUS_AUTH_FAIL)) {
        printf("ERROR: Authentication Failed! Data dropped.\n");
        return false;
    }
    
    if (data_out != NULL) {
        for (uint32_t i = 0; i < (len+3)/4; i++) {
            ((uint32_t*)data_out)[i] = read_reg32(ASCONEDGE_DATA_OUT + (i*4));
        }
    }
    return true;
}
