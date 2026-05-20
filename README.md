# Digital Down Converter (DDC) in Verilog

## What is this project?
I built a Digital Down Converter (DDC) in Verilog. This is a core component used in Software Defined Radios (SDR) and digital communication systems. 

The main goal of this project is to take a high-frequency input signal from an ADC, mix it down to a lower frequency (baseband), and then lower the sampling rate so it is easier for a processor to handle.

## Why did I make this?
High-frequency RF signals are too fast for normal microprocessors to process in real-time. By processing the signal inside an FPGA first, we can downconvert and decimate the data stream down to a manageable speed. I made this to learn how hardware DSP (Digital Signal Processing) works in real FPGAs.

## How it Works (The Architecture)
The design is split into three main hardware blocks:
1. **NCO (Numerically Controlled Oscillator):** Generates a local sine/cosine wave at a specific target frequency using a phase accumulator and a Lookup Table (LUT).
2. **Digital Mixer:** Multiplies the incoming ADC signal with the local NCO sine wave. This shifts the signal down in frequency.
3. **CIC Decimation Filter:** A Cascaded Integrator-Comb filter that handles downsampling. It downsamples the signal from 100MHz to 10MHz (Decimation factor of 10) and acts as a basic low-pass filter to remove unwanted mixing products.

## Important Concepts & Formulas Used

### 1. NCO Phase Increment (Frequency Tuning Word)
To make the NCO generate an exact 10 MHz sine wave on a 100 MHz clock, I had to calculate the exact phase increment value for the 32-bit accumulator. 

**Formula:** `Phase Increment = (Desired Frequency * 2^B) / Clock Frequency`
* `Desired Frequency` = 10 MHz ($10,000,000$ Hz)
* `Clock Frequency` = 100 MHz ($100,000,000$ Hz)
* `B` (Accumulator bits) = 32 bits ($2^{32} = 4,294,967,296$)

**The Math:**
* Phase Increment = ($10,000,000$ * $4,294,967,296$) / $100,000,000$
* Phase Increment = $0.1$ * $4,294,967,296$
* Phase Increment = $429,496,729.6$

Rounding to the nearest whole number gives **`429496730`**. This is the exact decimal value I passed to `phase_inc` in my top-level testbench to lock the local oscillator at 10 MHz.

### 2. Pipelined Mixing
In the mixer module, I registered the ADC inputs and NCO inputs before multiplying them. 
* **Why?** Doing raw multiplication across random logic gates is very slow. By pipelining the inputs, Vivado can easily map this math directly into the FPGA's dedicated hardware **DSP48 slices**, which keeps the clock speed high.

### 3. Signed Math for RF Signals
All signals in an SDR are AC signals that swing above and below zero. This means they use Two's Complement signed binary. If you just multiply normal binary numbers, a small negative number like `-1` looks like a massive positive number, which completely destroys the sine wave.
* **How I handled it:** I declared my inputs and registers with the `signed` keyword (e.g., `reg signed [15:0]`). Because I did this right at the port and register declarations, Verilog automatically handles the two's complement math perfectly without needing extra type-casting in the actual logic.

### 4. CIC Bit Growth Calculation
When you add numbers together repeatedly in a CIC filter's integrator stage, the numbers get bigger. If the registers are too small, the data overflows and gets corrupted. I used the standard bit growth formula to calculate exactly how wide my registers needed to be:

**Formula:** `Bit Growth = N * log2(R)`
* `N` = Number of CIC stages = 1
* `R` = Decimation factor = 10

**The Math:**
* Growth = 1 * log2(10)
* Growth = 1 * 3.32 = 3.32 bits
* Since we can't have partial bits in hardware, we round up to **4 extra bits**.

My mixer output was 32 bits wide. To prevent overflow in the filter, I added the 4 bits of growth, meaning my CIC output register had to be exactly **36 bits wide** (32 + 4).

## Simulation Results
The project was simulated using Vivado XSIM. The testbenches verify that the NCO generates a clean sine wave and that the CIC filter correctly downsamples the mixed output signal by a factor of 10 without data clipping or overflow. (Screenshots of the analog waveforms are available in the repository).

## Future Improvements
If I have more time later, I want to add these upgrades:
* **Add an FIR Compensation Filter:** CIC filters cause a slight "droop" in the frequency response. Adding a small FIR filter after the CIC would clean up the signal.
* **Programmable Decimation:** Right now the decimation factor is hardcoded to 10. I could make it variable using a control register.

