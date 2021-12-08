# Linux On TE0802

This article would explain all the steps necessary to install petalinux on Xilinx Trenz TE0802 FPGA board. 

**Required Hardware:**
- Trenz TE0802 FPGA Board
- Micro SD Card (8GB or more)
- Micro SD Card Reader 

**Required Software Tools:**
- Xilinx Vivado 
- Xilinx Petalinux Tools

I am using the development tools provided by Xilinx. All the tools are **v2021.1**, If you have a different version you need your self to adjust to the changes accordingly. After installing the tools it is important to export Vivado as well as Petalinux tool  environment variables. If you havn't done so, go ahead and run the following two commands. Also note that for the users who are working on ubuntu linux, those users have to change their current linux shell to bash

```
 // Changing to bash
 chsh -s /bin/bash username
```

Exporting environment variables:

```
 source <vivado installation dir>/settings64.sh
 source <petalinux installation dir>/settings.sh
```



As we have setup the vivado and petalinux environment now it is a good time to have a look at our hardware design. In the block design I have initialized zynq mpsoc ip and two axi gpios. The block design can be seen the the figure below. 
![Block Design](/images/block_diagram.png)

In order to create petalinux project, you need to have the exported hardware file with and extension of `.xsa`. There are two ways from here, 
1. Generate the xsa file from scratch 
2. use the pre-exported hardware from this respository "exported_hardware.xsa".
 
If you want to start from scratch, go ahead and generate a hardware design in vivado similar to the one shown in the above figure. The next step is to generate bitstream, so go ahead and click on the Generate Bitstream button. As the bitstream has been generated successfully, export the hardware by clicking on the File button in the top menu > go to Export > click on Export Hardware. And dont forget to include the bitstream with the exported hardware.

# Building Petalinux 
Note if the following commands appear as unknown in your linux, there was probably something wrong while exporting the petalinux environment.

In order to build petalinux there are a certain number of steps that you have to go through.

petalinux-create > petalinux-config > petalinux-build > petalinux-package


The first step is to create a petalinux project. the only important parameter here in creating a petalinux project is the project template. I have selected zynqMP because TE0802 is an ultrascale+ mpsoc. This could be done by executing the following command:
```
  petalinux-create --type project --template zynqMP --name my_linux
```

Next, moving towards configuring the petalinux. Here you have to specify the hardware design (which you have generated yourself or selected it from this repo). You can do it by running the command below. After running it, a configuration window will open up. The only change that you need to do in the config window is to change the location of Root filesystem to the SD card. Initially the Root file system is set to boot from INITRD (which boots the filesystem form the RAM). As you are in the config window, you can make this change by going to **Image Packaging Configuration**, then go to Root filesystem type and change it to `SD/eMMC/QSPI/SATA/USB`. 
```
 petalinux-config --get-hw-description <path to .xsa file>
```

If you want to add pre-provided packages to your petalinux, you can do it by running the config command as shown below. Another configuration window will open up. There, you can choose your desired packages.
```
 petalinux-config -c rootfs
```


As we are done with the configuration, now it is a good time to insert the device tree of TE0802 to the project. The device tree is located in the file "system-users.dtsi" in this repo. You can copy it to the petalinux project in the following foler:
```
 ./project-spec/meta-user/recipes-bsp/device-tree/files/
```

This covers every configuration that we want to in our project. Now it is a good time to build the petalinx. Use the following commad to build the project:
```
petalinux-build
```

It would take a few minutes to build the project as it downloads packages, including the kernel, from the online repositories.
As soon as it is done, we are ready to package our linux. So go ahead and run the following command:
``` 
 cd ./images/linux
 petalinux-package --boot --fsbl ./zynqmp_fsbl.elf --fpga ./system.bit --dtb system.dtb --u-boot --force
```

# Configuring the Board to boot from the sd card
In order for the operating system to be booted properly, the jumper configuration needs to be changed from JTAG to SD. It can be done by changing the jumper configuration. According to the Trenz TE0802 documentation, in order to boot from the sd card, you have to change the jumpers to:

![Jumper Setup. Photo Courtesy Whitney Knitter:https://hackster.imgix.net/uploads/attachments/1335445/sd_boot_mode_QK2dgwhbfK.png?auto=compress%2Cformat&w=740&h=555&fit=max ](/images/jumper_setup.png) 
*Photo Courtesy Whitney Knitter*

# SD card partition
The SD card should be partitioned into two different partitions. 
1. FAT32 (1GB), 
2. ext4(4GB+)

In order to partiton the SD card, there is an amazing guide by Xilinx. You can have a look at it by clicking here: [Formatting SD Card](https://xilinx-wiki.atlassian.net/wiki/pages/viewpage.action?pageId=724009318&navigatingVersions=true)

# Copy the files to the SD Card
After partitioning, you have to copy the boot files and the root filessytem to the sd card appropriately.

1. Automated copyign:
You can copy the all the files automatically to the sd card. you can do this by copying load_sd_card.sh to '<petalinux project>/images/linux' and executing it. 
**Warning:** Change your sd card device id from 'sdb1' to your sd card id.

2. Manual copying 

2.1 Copy to FAT32 partition
```
<petalinux project>/images/linux/BOOT.BIN
<petalinux project>/images/linux/boot.scr
<petalinux project>/images/linux/image.ub
<petalinux project>/images/linux/system.dtb
```
2.2 Copy to EXT4 partition
extract the rootfs tar to EXT4 file
```
<petalinux project>/images/linux/rootfs.tar.gz
```
2.3 Run the `sync` command to synchronize all the files on the sd card 
2.4 Unmount the sd card

# Booting the linux
Insert your sd card and insert it into the FPGA board. Connect your board to your pc with a micro usb cable. You can also connect an ethernet cable (optional). Finally plug in the power adapter to turn on the board.
Now, go to your pc, open up a terminal and type the following command to connect to your FPGA board via UART.

```
 sudo screen /dev/ttyUSB1 115200 
``` 

![Booted Petalinux](/images/booted_petalinux.png)

So go ahead and play around with your linux and have fun 
