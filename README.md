# ECE532-Project
Key design files and additional documentation concerning the ECE532 design project for Group 7.

HW Modules Folder
  - GreenLocator.v
    - Module to locate the green target in the group video frame
  - frame_buffer_interface.v
    - Module that provides the interface between Microblaze and the Green Locator module
  - pmod_gpio_interface.v
    - Module to send selfie image pixel data received via PMOD headers to BRAM
  - downscale_gpio_interface.v
    - Working but unused selfie image downscaling module
  - NexysVideo_Master.xdc
    - Nexys Video FPGA constraints file
  - Tests Folder
    - GreenLocator_tb.v
    - frame_buffer_interface_tb.v
    
Microblaze SW Folder
  - video_demo.c
    - Microblaze software needed to run the working demonstration
  - video_demo.h
  
RaspberryPi Folder
  - selfieserver_pil2.py
    - Software run on the Raspberry Pi that receives a selfie image via wifi from an Android phone and then sends it to the FPGA
    
Test Modules Folder
  - Miscellaneous software and hardware tests for varying hardware configurations
    - button_debouncer.v
    - frame_buffer_trigger.v
    - frame_buffer_trigger_tb.v
    - green_locator_trigger.v
    - green_locator_trigger_tb.v
    - interrupt_test.v
    - interrupt_test_tb.v
  
project_build Folder
  - This folder contains the comprehensive set of files needed to build the project in Vivado

  
  
