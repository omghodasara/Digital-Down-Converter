# author: omghodasara
# script: generate_sine_rom.py
# project: Digital Down Converter (SDR)
# purpose: generates exactly one cycle of a 16-bit sine wave for the NCO LUT.

import numpy as np

# parameters to match the verilog nco
# 10-bit address means 1024 points in the rom
depth = 1024
max_val = 32767 # 16-bit max

# generating exactly one full sine wave cycle
t = np.arange(depth)
sine = np.sin(2 * np.pi * (t / depth))

# scaling to 16-bit integers
sine_int = np.round(sine * max_val).astype(int)

# writing to hex file for vivado $readmemh
# doing two's complement again so negative numbers format right
with open("E:/_grind/DDC/sine_lut.hex", 'w') as f:
    for val in sine_int:
        hex_val = (val + (1 << 16)) % (1 << 16)
        f.write(f"{hex_val:04X}\n")

print("sine rom file generated.")