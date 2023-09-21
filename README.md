# Media Presenter SoC on Cortex-M0

The project uses Arm Cortex-M0 assembly on VGA peripheral to present series of images and text on monitor connected to Nexys-A7 FPGA board.
To accomplish the task, I defined a custom data format to embed a series of images and texts in memory. I also wrote a Python script that can convert any online images and user text into this embedding. On the FPGA board, I wrote an assembly program to recognize this data format and also send the it to display and text regions of VGA peripheral.

## Peripherals
![image](https://github.com/bhavinpt/media-presenter-soc/assets/117598876/2222749b-7226-47b6-9987-17745a919b7b)

I interfaced an on chip data and program memory, along with external VGA peripheral with Arm-Cortex M0 as shown above.
I also specified the memory-maps for these peripherals. Although it can support a maximum of 16 MB data memory with this mapping, it was still good enough to hold multiple images and text information as the resolution of VGA monitor is only 120*140 pixels.

## Custom Data Format

![image](https://github.com/bhavinpt/media-presenter-soc/assets/117598876/a8828ed6-11f9-475a-80c6-7481a104268d)

The type field indicates whether the element represents an image or text. 
Last field indicates if there are more elements following.
Length is the number of bytes in text/image.
Data represents the characters/pixels for text/image.

![image](https://github.com/bhavinpt/media-presenter-soc/assets/117598876/e67c3815-2d7d-4de1-805c-30fbd620014e)

Multiple such elements stored consecutively are used to represent a series of images and texts. The last element has Last=0 to tell the assembly program that there are no further text/image.

## Generating Images and Texts in Custom Data Format

This Python notebook was written to embed any online or user defined images/texts in a hex file that was loaded on FPGA data memory block.

https://colab.research.google.com/drive/16vjcf-E1ifKRv7o2Hb1trw8ivz6vjTBS?usp=sharing

Find the sample output in this repo.

## Program Logic

![image](https://github.com/bhavinpt/media-presenter-soc/assets/117598876/c61a79ac-6e65-4d91-998f-7fac1e7d53e3)

## Results
![image](https://github.com/bhavinpt/media-presenter-soc/assets/117598876/4b632751-d2ad-465b-92f9-7e6bfa0772b5)


https://github.com/bhavinpt/media-presenter-soc/assets/117598876/6b30c6f7-43f9-4b2d-9480-e7b6230bee16


