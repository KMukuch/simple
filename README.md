# Description

I’ve been obsessed with the idea of building my own 8 bit computer for a long time now. I find old computers very interesting. The processors used in such systems have relatively simple architecture and are easy to handle at home.

# Status

Work in progress

# Disclaimer

This project is educational but can be useful for all the others who want to build a homebrew 8 bit computer.

Working with electronics can be dangerous!

# Current stage

- Working on hardware design

- Working on tools

- Working on firmware

- Working on memory organization

# Design



# Hardware

Hardware layout:

1. Power supply

2. CPU

3. MMU

4. IOU

## CPU

This project uses `Z80` as the CPU. This processor is widely available and cheap.

### Memory organization and control

The memory is divided in two major parts:

- ROM

- RAM

Memory layout:

- `FFFF` - undefined 

- `2000` - undefined

- `1FFF` - ROM

- `...`

- `0000` - ROM

# Firmware

The system has no GUI. It has only text output, and the user interaction is controlled by the so called monitor program.

The monitor program is written in Z80 assembly. This project uses `z80asm` to compile the code and the uses `xxd`tool to convert the bin file into a C array representation:

```
z80asm file.asm -o file
```

```
xxd -i input.bin > output.h
```

# Tools

## Arduino UNO Rev3

To program and test our build Arduino UNO Rev3 is used. This MC has enough controll pins to help us program memory and test the computer units like IOU.

### VGA output

Using `VGAX`library on Arduino makes possible to make an output to a VGA monitor.

### EEPROM Programmer

This project uses the `AT28C64B` as ROM. The programmer is built by using two `74HC595` shift registers additional to the Arduino UNO [see schematics](hardware/tools/export/).

The following code writes to the EEPROM and uses the serial monitor to output messages:

```cpp
/*
  AT28C64B Programmer – /CE and /OE tied to GND
  Data D2-D9 with 220Ω series resistors for safety
  /WE on D13 with 1.5k pull-up
  Shift registers on D10(latch), D11(data), D12(clock)
*/

#define SHIFT_DATA 11
#define SHIFT_CLK 12
#define SHIFT_LATCH 10

#define EEPROM_D0 2
#define EEPROM_D1 3
#define EEPROM_D2 4
#define EEPROM_D3 5
#define EEPROM_D4 6
#define EEPROM_D5 7
#define EEPROM_D6 8
#define EEPROM_D7 9

#define WRITE_ENABLE 13

unsigned char rom[] = {
  0x31, 0xff, 0xff, 0x3e, 0x3e, 0xcd, 0x0b, 0x00, 0xcd, 0x0d, 0x00, 0xd3,
  0x01, 0x76, 0xcd, 0x0d, 0x00
};
const unsigned int rom_len = sizeof(rom);

void pulseShiftLatch() {
  digitalWrite(SHIFT_LATCH, LOW);
  digitalWrite(SHIFT_LATCH, HIGH);
  delayMicroseconds(1);
  digitalWrite(SHIFT_LATCH, LOW);
}

void setAddress(unsigned int address) {
  address &= 0x1FFF;
  shiftOut(SHIFT_DATA, SHIFT_CLK, MSBFIRST, address >> 8);
  shiftOut(SHIFT_DATA, SHIFT_CLK, MSBFIRST, address);
  pulseShiftLatch();
}

void pulseWrite() {
  digitalWrite(WRITE_ENABLE, HIGH);
  digitalWrite(WRITE_ENABLE, LOW);
  delayMicroseconds(1);
  digitalWrite(WRITE_ENABLE, HIGH);
  delay(10);
}

byte readByte(unsigned int address) {
  setAddress(address);
  for (int pin = EEPROM_D0; pin <= EEPROM_D7; pin++) pinMode(pin, INPUT);
  byte data = 0;
  for (int pin = EEPROM_D7; pin >= EEPROM_D0; pin--) data = (data << 1) | digitalRead(pin);
  return data;
}

void writeByte(unsigned int address, byte data) {
  setAddress(address);
  for (int pin = EEPROM_D0; pin <= EEPROM_D7; pin++) {
    pinMode(pin, OUTPUT);
    digitalWrite(pin, data & 0x01);
    data >>= 1;
  }
  pulseWrite();
}

void setup() {
  pinMode(SHIFT_DATA, OUTPUT);
  pinMode(SHIFT_CLK, OUTPUT);
  pinMode(SHIFT_LATCH, OUTPUT);
  pinMode(WRITE_ENABLE, OUTPUT);
  digitalWrite(WRITE_ENABLE, HIGH);

  Serial.begin(9600);
  delay(1000);
  Serial.println("AT28C64B Programmer Ready");

  // Erase first 256 bytes
  Serial.print("Erasing...");
  for (unsigned int i = 0; i < 256; i++) {
    writeByte(i, 0xFF);
    if (i % 64 == 0) Serial.print(".");
  }
  Serial.println(" Done.");

  // Write ROM
  Serial.print("Writing ROM...");
  for (unsigned int i = 0; i < rom_len; i++) {
    writeByte(i, rom[i]);
    if (i % 64 == 0) Serial.print(".");
  }
  Serial.println(" Done.");

  // Verify
  Serial.print("Verifying...");
  bool ok = true;
  for (unsigned int i = 0; i < rom_len; i++) {
    if (readByte(i) != rom[i]) { ok = false; break; }
    if (i % 64 == 0) Serial.print(".");
  }
  Serial.println(ok ? " Passed." : " Failed.");

  // Hex dump
  Serial.println("Hex dump (first 256 bytes):");
  for (unsigned int base = 0; base < 256; base += 16) {
    Serial.print(base, HEX); Serial.print(": ");
    for (unsigned int off = 0; off < 16; off++) {
      byte b = readByte(base + off);
      if (b < 0x10) Serial.print("0");
      Serial.print(b, HEX); Serial.print(" ");
    }
    Serial.println();
  }

  Serial.println("Done. You may disconnect.");
}

void loop()
{

}
```

# References

