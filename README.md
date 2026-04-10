# Description

I’ve been obsessed with the idea of building my own 8 bit computer for a long time now. I find old computers very interesting. The processors used in such systems have relatively simple architecture and are easy to handle at home.

# Status

Work in progress

# Disclaimer

This project is educational but can be useful for all the others who want to build a homebrew 8 bit computer.

Working with electronics can be dangerous!

# Current stage

- Working on hardware design

- Working on firmware

- Working on memory organization

# Hardware

Hardware layout:

1. Power supply

2. CPU

3. MMU

4. IOU

## CPU

This project uses `Z80` as the CPU. This processor is widely available and cheap.

### Memory organization and control

Memory layout:

- `FFFF` - undefined 

- `2000` - undefined

- `1FFF` - ROM

- `...`

- `0000` - ROM

# Firmware

There is no OS and no GUI. The computer has only text output. This makes coding much easier.

The monitor program is written in Z80 assembly. This project uses `z80asm` to compile the code.

# References

