#ifndef ASCONEDGE_DRIVER_H
#define ASCONEDGE_DRIVER_H

#include <stdint.h>
#include <stdbool.h>

#define ASCONEDGE_CTRL_REG    0x00
#define ASCONEDGE_STATUS_REG  0x04
#define ASCONEDGE_KEY_REG     0x10
#define ASCONEDGE_NONCE_REG   0x20
#define ASCONEDGE_DATA_IN     0x30
#define ASCONEDGE_DATA_OUT    0x50


#define STATUS_BUSY       (1 << 0)
#define STATUS_DONE       (1 << 1)
#define STATUS_AUTH_FAIL  (1 << 2)
#define STATUS_NONCE_ERR  (1 << 3)

#define CTRL_START        (1 << 0)
#define CTRL_MODE_DECRYPT (1 << 1) 

int asconedge_init(uint32_t base_address);
void asconedge_close(void);

bool asconedge_set_key(const uint8_t *key_16bytes);
bool asconedge_set_nonce(const uint8_t *nonce_16bytes);
bool asconedge_process_block(const uint8_t *data_in, uint8_t *data_out, uint32_t len, bool is_decrypt);

#endif
