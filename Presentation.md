## DEO-Nano SoC: What is it?

- User manual
  - I wish I had read it all...
- FPGA matrix and Hard Processor System (HPS)
  - 2x high speed buses (on in each direction)
  - 1x low speed bidirectional bus
- What are peripherals?
- HPS peripherals
  - Led, button, G-sensor
  - Usb, uart, ram, ethernet, sd card
- FPGA matrix peripherals
  - Lots of GPIO pins
  - Leds and buttons
  - Clocks
  - A/D converter
- DEO-Nano SoC System Builder
  - Never took the time to look into it

## Getting started
- Embedded Linux beginners guide (RocketBoards)
  - Starts with a built system
  - Nice to follow steps
  - Very educational with regards to embedded Linux
  - Boot process
  - Linux device three
  - User space application
  - Kernel driver
  - Busybox GNU tools
  - No support for ethernet card
- Linux on ARM (for DEO-Nano)
  - Gives us a full Debian tool chain
  - Magically, the ethernet card works
  - By combining the two guides I was able to get where I wanted.
- Quartus prime
  - Compiles all the auto generated code
    - including the custom component used in the guide
  - Compiling takes about seven minutes (then I had to restart)
    - Able to convert to a file that can be loaded by u-boot
  - Wanted to run VHDL, not System Verilog
  - Was able to flash directly onto the FPGA

## Creating something in VHDL
- VHDL
  - custom\_leds.v
  - GHDL simulation
  - Wave form viewer
- Create a simple timer peripheral
  - Based on the Nordic timers
  - Both a stop watch and countdown timer
  - Commands: Start, stop, reset, capture
  - Compare registers and events
  - Controlled either by ram read/write or button presses
  - Events routed to led(s)

## Experiences with VHDL
- Lets look at the code
- Wire vs variable
  <!---
    State of a wire: 
  -->
- Type system
- Everything happens in parallel
- Something always happens
- Very often end up in finite state machines
- Just smaller primitives

## Use cases
- Digital signal processing (duh...!)
- Filters, Fourier transforms
- Data preprocessing (down sampling, ...)
- Understanding Digital Signal Processing by Richard G. Lyons
