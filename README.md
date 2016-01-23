### DealOS

To test out this operating system, first install qemu and nasm. Then run

`nasm DealOS -o DealOS.bin DealOS.asm`

to assemble it. To run DealOS, we invoke the qemu i386 emulator with DealOS.bin as a virtual hard drive:

`qemu -hda DealOS.bin`

So far the following operating system functions are implemented:
* Print friendly welcome message.

Todo:
* Run DOS MZ format executable files.
