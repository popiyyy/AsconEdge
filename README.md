# AsconEdge: Akselerator Perangkat Keras untuk Ascon-AEAD128

## Abstrak
AsconEdge adalah koprosesor kriptografi yang diakselerasi perangkat keras dan dirancang untuk komunikasi edge yang aman. Koprosesor ini mengimplementasikan algoritma Ascon-AEAD128 langsung di dalam fabrik FPGA, memindahkan beban operasi kriptografi dari CPU utama (HPS). Pendekatan *Hardware/Software Co-Design* (Desain Bersama Perangkat Keras/Perangkat Lunak) ini meminimalkan pemanfaatan CPU sekaligus memberikan jaminan keamanan tingkat perangkat keras terhadap ancaman fisik dan logis di lingkungan komputasi edge.

## Arsitektur
Sistem ini dipartisi menjadi dua domain utama:
- **Control Plane (HPS / SW):** ARM Cortex-A9 yang menjalankan Linux embedded. Bertanggung jawab atas logika aplikasi, manajemen sesi, dan antarmuka jaringan.
- **Data Plane (FPGA / HW):** Custom VHDL RTL yang mengimplementasikan datapath Ascon-AEAD128 dan FSM Fail-Closed. Beroperasi melalui jembatan Avalon Memory-Mapped HPS-ke-FPGA yang ringan.

## Fitur Keamanan Perangkat Keras
Implementasi RTL menggabungkan batasan keamanan yang ketat:
1. **Authenticated Release:** Cyphertext ditahan dalam buffer karantina perangkat keras yang terisolasi selama dekripsi. Plaintext hanya diekspos ke bus memori jika verifikasi tag autentikasi berhasil.
2. **Strict Monotonic Nonce Guard:** Sebuah komparator fisik menolak nilai nonce yang berulang atau berkurang pada tingkat perangkat keras, menetralkan serangan replay (replay attacks).
3. **Zeroization:** Mesin status (state machine) bertransisi ke status `ZEROIZE` saat terjadi kegagalan autentikasi, deteksi status ilegal, atau operasi selesai, yang akan menghapus kunci internal dan buffer sensitif untuk mencegah pembacaan ulang memori (memory readback).
4. **Constant-Cycle Operations:** Verifikasi tag dieksekusi dalam jumlah siklus yang deterministik dan konstan untuk memitigasi serangan timing oracle (timing oracle attacks).

## Struktur Repositori

```text
AsconEdge/
├── hw/                               # Sumber RTL Perangkat Keras (FPGA Fabric)
│   ├── src/
│   │   ├── asconedge_top.vhd         # Entitas Integrasi Top-level
│   │   ├── asconedge_mm_slave.vhd    # Antarmuka Jembatan Avalon-MM
│   │   ├── aead_controller.vhd       # FSM Fail-Closed Pusat
│   │   ├── ascon_permutation.vhd     # Pengontrol Permutasi P12/P8
│   │   ├── ascon_round.vhd           # Logika Kombinasional Inti (S-Box, Difusi)
│   │   ├── nonce_policy_guard.vhd    # Modul Pencegahan Serangan Replay
│   │   ├── packet_buffer.vhd         # Buffer Karantina
│   │   └── tag_verify_zeroize.vhd    # Komparator Tag dan Penghapus Status
│   └── tb/
│       └── asconedge_tb.vhd          # VHDL Testbench
├── sw/                               # Sumber C/C++ Perangkat Lunak (HPS ARM)
│   ├── asconedge_driver.h            # Peta Memori dan Definisi API Driver
│   ├── asconedge_driver.c            # Driver Perangkat Keras Berbasis Mmap
│   └── main.c                        # Aplikasi Demonstrasi
└── README.md
```

## Instruksi Build dan Deployment

### Prasyarat
- Intel Quartus Prime Standard/Lite Edition (untuk Sintesis RTL)
- Board Support Package Terasic DE10-Nano
- Toolchain GCC untuk ARM (misalnya, `arm-linux-gnueabihf-gcc`)

### 1. Sintesis Perangkat Keras (RTL ke Bitstream)
1. Inisialisasi proyek baru di Intel Quartus Prime dengan menargetkan perangkat Intel Cyclone V pada DE10-Nano.
2. Buka **Platform Designer (Qsys)** dan buat instansiasi modul `hw/src/` sebagai komponen IP kustom yang dilampirkan ke `hps_0_h2f_lw_axi_master` (Lightweight HPS-to-FPGA Bridge).
3. Petakan alamat basis memori sesuai dengan spesifikasi di `sw/asconedge_driver.h`.
4. Jalankan Synthesis, Fitter, dan buat file pemrograman (`.sof` / `.rbf`).
5. Program fabrik FPGA.

### 2. Kompilasi Perangkat Lunak (HPS)
Kompilasi driver dan aplikasi pada lingkungan Linux target (atau melalui cross-compilation):

```bash
cd sw
gcc -O2 -Wall -Wextra main.c asconedge_driver.c -o asconedge_demo
```

### 3. Eksekusi
Aplikasi ini memerlukan akses memori mapped I/O (`/dev/mem`) untuk berkomunikasi dengan jembatan FPGA. Hak akses root diperlukan.

```bash
sudo ./asconedge_demo
```
Program ini akan menginisialisasi perangkat keras, mengonfigurasi kunci kriptografi dan nonce, memproses payload pengujian, dan memvalidasi mekanisme authenticated release perangkat keras.
