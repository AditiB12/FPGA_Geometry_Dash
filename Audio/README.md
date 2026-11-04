***To Generate Audio:***
1. Replicate block design from Lab 6.1 (Add Microblaze, AXI GPIO, UART). Create an HDL wrapper of the block design.
2. Create top_level and have speaker right and left as outputs of the top_level and instantiate all other modules within the top_level.
3. Add the following modules to Vivado: pwm_audio, audio_clk_gen, and rom_audio. Below is a quick description on what each module does. 

-> pwm_audio
This module implements an 8-bit pulse PWM audio signal generator. The duty-cycle of the PWM is determined by the audio_sample, we want to create a PWM
signal whose average voltage matches the input sample value. The duty-cycle is used to represent audio of the audio sample. 

-> audio_clk_gen
The audio_clk_gen module generates a timing "tick" signal at a lower frequency (44.1 kHz) from a higher-frequency system clock (e.g., 100 MHz). 
This is typically used in audio systems to control when to output the next audio sample. The DIV parameter sets how many clock cycles should pass before
one tick pulse. A counter is used to set tick high every 2268 cycles. The tick frequency is 44.1 kHz. Since 100 MHz / 2268 = 44.1 kHZ. This module is
mainly used to trigger the output of the next audio sample to feed to the pwm_audio module. 

-> rom_audio
The ROM is loaded with data from a audio.mem file in hex format. Audio_mem should contain one 8-bit value per line, representing audio waveform amplitude at each sample time.
Advances the audio sample at every tick and loop at reset. 

-> Quick Overview:
The audio_clk_gen basically generates a tick every 44.1 kHz. The rom_audio outputs samples on every tick. The pwm_audio takes those samples and outputs them as a PWM signal to a speaker. 

4. Create BRAM IP. To create the .wav file, use Audacity to record momo, 8-bit, unsigned audio. Then, export as a .WAV file. Use python script to turn .WAV file into a .COE file. 


*** Right now, we can using the FPGA's BRAM to play audio. If we want to use an SD card for longer audio follow these steps: ***
1. Replicate block design from lab 6.1. 
2. Use Audacity to export a 8-bit, unsigned, momo .WAV file. 
3. Use HxD to convert .WAV analog data into hex. Put decrypted hex data into SD card.
4. Initialize SD card in Vivado. You need to have a file for SD card initialization and another file for SD memory card interface. 
5. Use FIFO as a buffer that reads data at a rate of 44.1 kHz since PWM reads slower than SD card writes. Have multiple cycles per sample for clean audio. 
6. Create custom PWM IP to read from SD card. The PWM IP will ensure that we have a duty-cycle controlled PWM module. Use AXI protocol for IP communication.
7. Initialize everything in top_level so the FPGA DAC can recieve PWM signals and output audio. 
