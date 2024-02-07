Copyrights and Written by [@Ravindu_Deshan](https://t.me/Ravindu_Deshan) (find me on telegram)

## ! PLEASE NOTE THAT, IN EXYNOS DEVICES WE NEED TO COMPILE A CUSTOM KERNEL BY DISABLING SAMSUNG RKP and DEFEX with SELINUX FORCE PERMISSIVE TO BOOT THE TWRP. IN MY CASE IT IS REQUIRED, ELSE NO BOOT !

#### ❗ Notes : Before continue, install wsl, crb kitchen and enable file extensions in windows explorer..! (requires pc)
<hr>

01. Make a basic TWRP device tree using "[twrpdtgen by seaubuntu](https://github.com/twrpdtgen/twrpdtgen)". Please read its instructions to make a Device tree.

02. delete all the .sh files and delete the android.bp and readme file.

03. Open omini_devicename.mk and delete `$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)` line.

04. then change the first line `$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)` to `$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)`.

05. change `vendor/omni/config/common.mk` to `vendor/twrp/config/common.mk` and change `PRODUCT_MODEL := ` 's value by filling your Device name like "Galaxy M21"

06 now delete all the line below `PRODUCT_GMS_CLIENTID_BASE` and save the file.

07. open recovery > root and delete the files named "dsms".

08. now create a folder named in recovery > root folder named "system". Open the newly created "system" folder again and create a new folder named "etc".

09. Now go back to the root derectory of your device tree.

10. open prebuilt folder and delete the files end with .img.

11. Now extract your stock recovery.img using crb kitchen and open the extracted directory.

12. now open split_image folder and copy these two files named "recovery.img-dtbo" , "recovery.img-dtb" and paste them to the prebuilt folder in your device tree.

13. Now remove the "recovery.img-" part from both of the copied files and after doing it the files in the prebuilt folder must be looks like this.
		- dtb
		- dtbo
		- Kernel
14. rename Kernel to Image. after that files in the prebuilt folder looks like this.
		- dtb
		- dtbo
		- Image
15. now rename the dtb file to "dtb.dtb" and create a new folder named "dtb" and move the "dtb.dtb" file to dtb folder.

16. Now open recovery.fstab in the root dir of your device tree.then we are going to modify it.

i. remove "system_ext" and "vendor_dlkm" lines if you haven't a seperated partitions for them. In my case I don't have so I'm removing them.
ii. remove the line contains "sdcard"
iii. delete "vendor_boot" line also
iv. remove the "_system" from "vbmeta_system" line and the final result will like this "/vbmeta emmc /dev/block/by-name/vbmeta flags=display=vbmeta"
v. Add ";backup=1;flashimg" for the partitions you would like to backup and flash
vi. add ";wipeingui" to the partitions, which you would like to wipe

vii. remove the "logical" flag from system,vendor,product,odm lines and change the mountpoint of system to system_root. then add ;backup=1;flashimg;wipeingui to 4 of them.
viii. change the path of the system to /dev/block/mapper/system and apply it also for the 4 lines (system,vendor,product,odm)
ix. The final result will be like this..

```

	/system_root        ext4      /dev/block/mapper/system              flags=display="System Image";wipeingui;backup=1;flashimg;
	/vendor             ext4      /dev/block/mapper/vendor              flags=display="Vendor Image";wipeingui;backup=1;flashimg;
	/product            ext4      /dev/block/mapper/product             flags=display="Product Image";;wipeingui;backup=1;flashimg;
	/odm                ext4      /dev/block/mapper/odm                 flags=display="ODM Image";wipeingui;backup=1;flashimg;
```

x. add these lines to bottom of the fstab file if you want to mount your external sd and usb otg.

```
/external_sd    vfat    /dev/block/mmcblk0p1 /dev/block/mmcblk0 flags=display="External SD Card";storage;wipeingui;removable;
/usb-otg        vfat    /dev/block/sdf1 /dev/block/sdf          flags=display="USB OTG";storage;wipeingui;removable;
```

now we are done editing the fstab file. please note if you don't have a super partition, you don't have to make a copy of system,vendor etc line and only add the features like ";flashimg;backup=1;wipeingui"

17. now save your modified recovery.fstab file. now make a copy of your fstab file and paste it and you will see the copy now. simple rename the copied recovery.fstab to "twrp.flags" and move both of "recovery.fstab" and "twrp.flags" to your recovery/root/system/etc folder.

18. now we have to install sdk platform tools in your pc and this android app for your android device 

here are the links

i. sdk platform tools : https://developer.android.com/studio/releases/platform-tools
ii. app link : https://play.google.com/store/apps/details?id=ru.andr7e.deviceinfohw&hl=en&gl=US

19. after extracing the downloaded platform tools zip, open up the extracted direcory and open your command prompt there.
20. enable usb debugging in your device and type "adb devices" in the cmd and authorize your pc in ur mobile.
21. then type "adb shell" and type "getprop ro.product.board" and copy its value to a new text file and make your you can identify it like wtf is that.

22. now open device info hw app and move to soc tab and look the value for "familiy". for me there are two values and copy them into our text file. in my case it is Cortex-A73 and Cortex-A53 and it defines the name of our clusters and put them into your text file with lowercase letters like this "cortex-a73". If you found only one value, that means you have 2 clusters with the same name.

23. also copy the value for Vendor and Manufacturer,brand and board in the system tab to the text file and In my case both of these have same values "samsung"
24. copy the value for gpu in the soc tab and in my case it is Mali-G72 MP3 and you have to paste it in ur text file like this "mali-g72"

finally our new text file will look like this (in my case) :

```
	familiy : cortex-a73 , cortex-a53
	ro.product.board = exynos9611
	Vendor = samsung
	Manufacturer = samsung
	board = exynos9611
	gpu = mali-g72
```

25. Now open your boardconfig.mk file which is in the root directory of twrp device tree.

i. find this item "TARGET_CPU_VARIANT" and replace its value with your first cpu cluster's value. In my case it is "cortex-a73"
ii. find this item "TARGET_2ND_CPU_VARIANT" and replace its value with your second cpu cluster's value. In my case it is "cortex-a53"
iii. replce the value for "TARGET_2ND_ARCH_VARIANT" with "armv8-a" ( if you have only one cluster, replace it using this value )
iv. Now delete these items "TARGET_CPU_VARIANT_RUNTIME" and "TARGET_2ND_CPU_VARIANT_RUNTIME"
v. add these lins to below the "TARGET_2ND_CPU_VARIANT"

```
	BOARD_VENDOR := samsung #value for Vendor
	TARGET_SOC := exynos9611 #value for ro.product.board
	TARGET_BOOTLOADER_BOARD_NAME := exynos9611 #value for board or cpu I'm not sure because all of the values for me are same lmao
	TARGET_BOARD_PLATFORM := exynos9611 #value for ro.product.board
	TARGET_BOARD_PLATFORM_GPU := mali-g72 #value for gpu
```

	( also check for duplicated lines and delete them elso it will crash the twrp building process )

vi. remove "TARGET_NO_BOOTLOADER := true"

vii. now lets begin the craziest part. remove all of these lines now..

DEXPREOPT_GENERATE_APEX_IMAGE
TARGET_SCREEN_DENSITY
BOARD_FLASH_BLOCK_SIZE
BOARD_RAMDISK_OFFSET
BOARD_BOOTIMG_HEADER_VERSION
BOARD_KERNEL_TAGS_OFFSET
BOARD_MKBOOTIMG_ARGS (if you found multiple values for it, delete them too)
BOARD_KERNEL_SEPARATED_DTBO
TARGET_KERNEL_CONFIG
TARGET_KERNEL_SOURCE

viii. and remove all the values below from "# Kernel - prebuilt" to "endif"

ix. now add these values below "BOARD_INCLUDE_DTB_IN_BOOTIMG"

BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilt/dtbo
BOARD_PREBUILT_DTBIMAGE_DIR := $(DEVICE_PATH)/prebuilt/dtb
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image

x. now lets jump to "BOARD_KERNEL_CMDLINE" line and it's value must be like this (you don't need to edit is if you have androidboot.hardware already) - androidboot.hardware= ( your TARGET_SOC )

eg : androidboot.hardware=exynos9611

xi. Now add this line "BOARD_MKBOOTIMG_ARGS := " and its value must be like this (in my case) "--kernel_offset 0x00008000 --ramdisk_offset 0x01000000 --tags_offset 0x00000100 --header_version 2 --board SRPSG30B004RU"

you can find the values for kernel_offset, ramdisk_offset, tags_offset, header_version and board from the extracted boot image's split_image folder and open the files with their names with notepad and copy and paste their correct values.

after setting up all the kernel things, the final output must be like this (in my case) :

```
	# Kernel
	BOARD_KERNEL_BASE := 0x10000000
	BOARD_KERNEL_PAGESIZE := 2048
	TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image
	BOARD_KERNEL_CMDLINE := androidboot.hardware=exynos9611
	BOARD_MKBOOTIMG_ARGS := --kernel_offset 0x00008000 --ramdisk_offset 0x01000000 --tags_offset 0x00000100 --header_version 2 --board SRPSG30B004RU
	BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilt/dtbo
	BOARD_PREBUILT_DTBIMAGE_DIR := $(DEVICE_PATH)/prebuilt/dtb
	BOARD_INCLUDE_DTB_IN_BOOTIMG := true
	BOARD_KERNEL_IMAGE_NAME := Image
```

now we finished the hard part and lets change the other things too..!


26. Now extract the recovery.img and boot.img from your device's firmware file (if it compressed with lz4, decompress it too). If you lazy to download the firmware file for your device and you are rooted, you can type these simple commands in the adb shell to dump them from your system

so I am dumping them now lemme give its command :
```

	cp /dev/block/by-name/recovery /sdcard/recovery.img
	cp /dev/block/by-name/boot /sdcard/boot.img
	cp /dev/block/by-name/dtbo /sdcard/dtbo.img
```

26. after dumping them, copy them to a new folder in your windows pc and open the linux shell there by typing "wsl" in the address bar.

27. So we are going to find their values in bytes using this command :
	
	`stat -c '%n %s' *.img`

and copy their values to our text file which is opened in the notepad.

28. then go back to boardconfig.mk again and replce the value for "BOARD_BOOTIMAGE_PARTITION_SIZE" with your boot.img's value

again replce the value for "BOARD_RECOVERYIMAGE_PARTITION_SIZE" with your recovery.img's value

29. now add this line and replace its value with your dtbo.img's value

	BOARD_DTBOIMG_PARTITION_SIZE       :=  #value_of_your_dtbo.img

30. jump to "BOARD_SAMSUNG_DYNAMIC_PARTITIONS_PARTITION_LIST" line and remove "system_ext and "vendor_dlkm" if you don't have it. in my case I don't have neither "system_ext" nor "vendor_dlkm" partitiond.So I removed them

31. Now replace the value for "BOARD_SUPER_PARTITION_SIZE" and "BOARD_SAMSUNG_DYNAMIC_PARTITIONS_SIZE" with your super partition's size in bytes. You can know it by this simple adb shell command :

	su
	blockdev --getsize64 /dev/block/by-name/super

32. now set the "BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS" 's flag value, "BOARD_AVB_RECOVERY_ROLLBACK_INDEX" and "BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION" to 0

33. remove these shit lines :

	# Hack: prevent anti rollback
	PLATFORM_SECURITY_PATCH := 2099-12-31
	VENDOR_SECURITY_PATCH := 2099-12-31
	PLATFORM_VERSION := 16.1.0

	also remove twrp configuration values

34. Let's configure twrp's values

	TW_THEME := portrait_hdpi
	RECOVERY_SDCARD_ON_DATA := true
	TARGET_RECOVERY_PIXEL_FORMAT := "ABGR_8888"
	TW_BRIGHTNESS_PATH := "/sys/class/backlight/panel/brightness"
	TW_MAX_BRIGHTNESS := 365
	TW_DEFAULT_BRIGHTNESS := 219
	TW_Y_OFFSET := 84
	TW_H_OFFSET := -84
	TW_HAS_DOWNLOAD_MODE := true
	TW_EXTRA_LANGUAGES := true
	TW_EXCLUDE_DEFAULT_USB_INIT := true
	TW_DEVICE_VERSION := Ravindu Deshan #use your name
	TW_USE_SAMSUNG_HAPTICS := true
	TW_NO_REBOOT_BOOTLOADER := true

We just finished editing the board config. please note that the editing process will be vary depends on your device's partition scheme and brand. So study some same chipset device's device trees from github and see the commits of them.

Save the boardconfig.mk file by pressing ctrl + s

35. Now we need to enable mtp. So study other same chipset device trees and find the file named "init.recovery.usb.rc" which is located in  recovery/root and copy its content and make your own file in recovery/root by pasting the copied value

36. Our twrp device tree is perfect right now and only thing we need to do is compile it from the source.

- COMPILATION GUIDE -

1. Make a github or gitlab account and create a new emplty repository named "gitpod" or somewhat
2. sign up for https://gitpod.io/ with gitlab or github
3. Now click new workspace and choose your empty repo and choose the "large" class.
4. one it finished, you can see the folders and files in the left side panel (it is empty) and you can see our linux terminal in the bottom.
5. now type this command to install "rsync"
```
 sudo apt update && sudo apt install rsync -y
```

6. type these commands to install the google repo as well

```
mkdir ~/bin
PATH=~/bin:$PATH
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
```

7. Now we are going to clone the twrp official source code and I'm going to clone the "twrp-11" and you can it in the "-b" flag

```
repo init --depth=1 --no-repo-verify -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-11 -g default,-mips,-darwin,-notdefault
```

In my case twrp-12.1 isn't booted so I choosed twrp-11. you can try both xD

8. after that type this command to start the cloning processS

```
repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8
```

9. After it finished type this command to set up the environment variables.

```
  . build/envsetup.sh
```   

11. now upload the entire folder of your device tree which is in your twrpdtgen's output to the "device" folder.

12. after it finished you can see inside of the "device" folder and it must be look like this

	samsung/m21 #in my case

13. now type this command to choose your device and only use the number for "-eng" .

	lunch

14. Now let's start building our twrp by this command

	make recoveryimage

15. the building process will take 15 to 25 minutes so grab a coffee xD

16. After build process done, the terminal shows the output dir of your recovery.img and just navigate it using the left side panel of gitpot and download it to your local pc and flash it using fasboot or odin by making a tar file using 7zip

Good luck homies !

This A to Z fooking tutorial is written by Ravindu Deshan who is a 20yo (in 2024) boy from Sri Lanka and copying my content as yours is prohibited; if you did that, you are g*y
