# author: omghodasara
# acript: generate_adc_data.py
# project: Digital Down Converter (SDR)
# purpose: generates a 100MHz noisy carrier with a 500kHz message and saves as hex.

import numpy as np
import matplotlib.pyplot as plt

# parameters
fs = 100e6      # 100 MHz sample rate
fc = 10e6       # 10 MHz carrier
fm = 500e3      # 500 kHz message
noise = 0.2
N = 4096        # number of samples

# time vector
t = np.arange(N) / fs

# multiplying message and carrier, then adding random white noise
sig = (np.cos(2 * np.pi * fm * t) * np.cos(2 * np.pi * fc * t)) + (noise * np.random.randn(N))

# scaling to 16-bit signed int (-32768 to 32767)
sig = sig / np.max(np.abs(sig))
sig_int = np.round(sig * 32767).astype(int)

# writing to hex file for verilog $readmemh
# doing two's complement manually so verilog functions perfectly with negatives
with open("E:/_grind/DDC/adc_data_in.hex", 'w') as f:
    for val in sig_int:
        hex_val = (val + (1 << 16)) % (1 << 16)
        f.write(f"{hex_val:04X}\n")

print("hex file generated for vivado.")

# to check if the math worked before moving to hardware
plt.figure(figsize=(10, 5))

# time domain
plt.subplot(2, 1, 1)
plt.plot(t[:200] * 1e6, sig_int[:200])
plt.title("ADC Time Domain")

# frequency domain
plt.subplot(2, 1, 2)
fft_vals = np.abs(np.fft.fft(sig_int))
fft_freqs = np.fft.fftfreq(N, 1/fs)
plt.plot(fft_freqs[:N//2] / 1e6, fft_vals[:N//2])
plt.xlim(0, 15)
plt.title("FFT")

plt.tight_layout()
plt.show()