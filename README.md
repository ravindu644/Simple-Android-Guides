# TWRP Device Tree and Compilation Guide

**Copyright and Written by [@Ravindu_Deshan](https://t.me/Ravindu_Deshan) (find me on telegram)**

## ⚠️ PLEASE NOTE: EXYNOS DEVICES REQUIRE A CUSTOM KERNEL

In Exynos devices, it is necessary to compile a custom kernel with Samsung RKP and DEFEX disabled, along with SELINUX set to FORCE PERMISSIVE, to successfully boot TWRP. This step is required in my case; otherwise, the device will not boot.

#### ❗ Notes: Before continuing, ensure you have installed WSL, CRB Kitchen, and enabled file extensions in Windows Explorer (PC required).

***

### Part 1: Device Tree Preparation

1.  **Generate a Basic Device Tree:** Use the **twrpdtgen by seaubuntu** tool to create a basic TWRP device tree.
    *   [twrpdtgen by seaubuntu](https://github.com/twrpdtgen/twrpdtgen)
    *   Read its instructions carefully to generate the device tree.

2.  **Clean Up:** Delete all `.sh` files, `android.bp`, and `readme` files from the generated device tree.

3.  **Modify `omni_devicename.mk`:**
    *   Delete the line: `$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base_telephony.mk)`
    *   Change the first line: `$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)` to `$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)`.

4.  **Update Common Config:**
    *   Change `vendor/omni/config/common.mk` to `vendor/twrp/config/common.mk`.
    *   Change `PRODUCT_MODEL :=`'s value to your device name (e.g., `"Galaxy M21"`).

5.  **Clean Up `omni_devicename.mk` (Cont.):** Delete all lines below `PRODUCT_GMS_CLIENTID_BASE` and save the file.

6.  **Clean Recovery Root:** Open `recovery/root` and delete the files named `dsms`.

7.  **Create System and Etc Folders:**
    *   In the `recovery/root` folder, create a new folder named `system`.
    *   Inside the newly created `system` folder, create a new folder named `etc`.

8.  **Return to Root:** Go back to the root directory of your device tree.

9.  **Clean Prebuilt:** Open the `prebuilt` folder and delete any files ending with `.img`.

10. **Extract Stock Recovery:**
    *   Extract your stock `recovery.img` using CRB Kitchen.
    *   Open the extracted directory.

11. **Copy DTB/DTBO:**
    *   Navigate to the `split_image` folder within the extracted directory.
    *   Copy these two files: `recovery.img-dtbo` and `recovery.img-dtb`.
    *   Paste them into the `prebuilt` folder in your device tree.

12. **Rename Prebuilt Files:**
    *   Remove the `recovery.img-` prefix from both copied files.
    *   The files in the `prebuilt` folder should now look like this:
        *   `dtb`
        *   `dtbo`
        *   `Kernel`
    *   Rename `Kernel` to `Image`.
    *   The files in `prebuilt` should now be:
        *   `dtb`
        *   `dtbo`
        *   `Image`

13. **Organize DTB:**
    *   Rename the `dtb` file to `dtb.dtb`.
    *   Create a new folder named `dtb`.
    *   Move the `dtb.dtb` file into the `dtb` folder.

14. **Modify `recovery.fstab`:**
    *   Open `recovery.fstab` in the root directory of your device tree.

    | Modification Step | Description |
    | :--- | :--- |
    | **i.** | Remove `system_ext` and `vendor_dlkm` lines if you do not have separate partitions for them. (I remove them in my case.) |
    | **ii.** | Remove the line containing `sdcard`. |
    | **iii.** | Delete the `vendor_boot` line. |
    | **iv.** | Remove `_system` from the `vbmeta_system` line. The final result should look like: `/vbmeta emmc /dev/block/by-name/vbmeta flags=display=vbmeta` |
    | **v.** | Add `;backup=1;flashimg` to partitions you want to be able to backup and flash. |
    | **vi.** | Add `;wipeingui` to partitions you want to be able to wipe. |
    | **vii.** | For `system`, `vendor`, `product`, and `odm` lines: remove the `logical` flag, change the mountpoint of `system` to `system_root`, and add `;backup=1;flashimg;wipeingui` to all four. |
    | **viii.** | Change the path of the `system` line (and apply to `vendor`, `product`, `odm`) to `/dev/block/mapper/system`. |
    | **ix.** | **Final Result for Dynamic Partitions:** |

    ```fstab
    /system_root        ext4      /dev/block/mapper/system              flags=display="System Image";wipeingui;backup=1;flashimg;
    /vendor             ext4      /dev/block/mapper/vendor              flags=display="Vendor Image";wipeingui;backup=1;flashimg;
    /product            ext4      /dev/block/mapper/product             flags=display="Product Image";;wipeingui;backup=1;flashimg;
    /odm                ext4      /dev/block/mapper/odm                 flags=display="ODM Image";wipeingui;backup=1;flashimg;
    ```

    *   *Note: If you do not have a super partition, do not use the mapper path; only add features like `;flashimg;backup=1;wipeingui` to the original partition lines.*

    | Modification Step | Description |
    | :--- | :--- |
    | **x.** | Add these lines to the bottom for external SD and USB OTG mounting: |

    ```fstab
    /external_sd    vfat    /dev/block/mmcblk0p1 /dev/block/mmcblk0 flags=display="External SD Card";storage;wipeingui;removable;
    /usb-otg        vfat    /dev/block/sdf1 /dev/block/sdf          flags=display="USB OTG";storage;wipeingui;removable;
    ```

15. **Create `twrp.flags`:**
    *   Save your modified `recovery.fstab` file.
    *   Make a copy of `recovery.fstab` and rename the copy to `twrp.flags`.
    *   Move both `recovery.fstab` and `twrp.flags` to your `recovery/root/system/etc` folder.

***

### Part 2: Device and Kernel Information Gathering

16. **Install Tools:**
    *   Install **SDK Platform Tools** on your PC: [i. sdk platform tools](https://developer.android.com/studio/releases/platform-tools)
    *   Install **Device Info HW** on your Android device: [ii. app link](https://play.google.com/store/apps/details?id=ru.andr7e.deviceinfohw&hl=en&gl=US)

17. **Collect Device Information:**
    *   Extract the downloaded platform tools zip.
    *   Open a Command Prompt in the extracted directory.
    *   **Enable USB debugging** on your device and connect it to your PC.
    *   Type `adb devices` and authorize your PC on your mobile device.
    *   Type `adb shell` and then `getprop ro.product.board`. Copy its value to a new text file.

18. **Collect SOC/CPU/GPU Information:**
    *   Open the Device Info HW app and go to the **SOC tab**.
    *   Find the value for **"family"**. If there are two values (e.g., Cortex-A73 and Cortex-A53), copy both.
    *   Put them in your text file in **lowercase** (e.g., `"cortex-a73"`, `"cortex-a53"`). If only one value is found, you have two clusters with the same name.
    *   Copy the value for **"GPU"** (e.g., Mali-G72 MP3) to your text file, formatted like `"mali-g72"`.

19. **Collect System Information:**
    *   Go to the **System tab** in the Device Info HW app.
    *   Copy the values for **"Vendor"**, **"Manufacturer"**, **"Brand"**, and **"Board"** to your text file. (In my case, both Vendor and Manufacturer are "samsung".)

    **Example Text File (in my case):**
    ```
    familiy : cortex-a73 , cortex-a53
    ro.product.board = exynos9611
    Vendor = samsung
    Manufacturer = samsung
    board = exynos9611
    gpu = mali-g72
    ```

***

### Part 3: Modifying `BoardConfig.mk`

20. **Open `BoardConfig.mk`:** Open the file in the root directory of your TWRP device tree.

21. **CPU Configuration:**
    *   Find `TARGET_CPU_VARIANT` and replace its value with your **first CPU cluster's value** (e.g., `"cortex-a73"`).
    *   Find `TARGET_2ND_CPU_VARIANT` and replace its value with your **second CPU cluster's value** (e.g., `"cortex-a53"`).
    *   Replace the value for `TARGET_2ND_ARCH_VARIANT` with `"armv8-a"`. (Use this if you only have one cluster as well.)
    *   Delete the items `TARGET_CPU_VARIANT_RUNTIME` and `TARGET_2ND_CPU_VARIANT_RUNTIME`.

22. **Add SOC and Platform Variables:** Add these lines below `TARGET_2ND_CPU_VARIANT`:
    ```makefile
    BOARD_VENDOR := samsung               #value for Vendor
    TARGET_SOC := exynos9611              #value for ro.product.board
    TARGET_BOOTLOADER_BOARD_NAME := exynos9611 #value for board or cpu
    TARGET_BOARD_PLATFORM := exynos9611   #value for ro.product.board
    TARGET_BOARD_PLATFORM_GPU := mali-g72 #value for gpu
    ```
    *   *Check for and delete any duplicated lines.*

23. **Cleanup:**
    *   Remove `TARGET_NO_BOOTLOADER := true`.
    *   Remove all of these lines:
        *   `DEXPREOPT_GENERATE_APEX_IMAGE`
        *   `TARGET_SCREEN_DENSITY`
        *   `BOARD_FLASH_BLOCK_SIZE`
        *   `BOARD_RAMDISK_OFFSET`
        *   `BOARD_BOOTIMG_HEADER_VERSION`
        *   `BOARD_KERNEL_TAGS_OFFSET`
        *   `BOARD_MKBOOTIMG_ARGS` (delete multiple values if found)
        *   `BOARD_KERNEL_SEPARATED_DTBO`
        *   `TARGET_KERNEL_CONFIG`
        *   `TARGET_KERNEL_SOURCE`
    *   Remove all values below `"# Kernel - prebuilt"` to `endif`.

24. **Add Prebuilt Kernel Variables:** Add these lines below `BOARD_INCLUDE_DTB_IN_BOOTIMG`:
    ```makefile
    BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilt/dtbo
    BOARD_PREBUILT_DTBIMAGE_DIR := $(DEVICE_PATH)/prebuilt/dtb
    TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/prebuilt/Image
    ```

25. **Kernel Command Line:**
    *   Find `BOARD_KERNEL_CMDLINE`. Its value must include `androidboot.hardware=` followed by your `TARGET_SOC` value (e.g., `androidboot.hardware=exynos9611`). (You don't need to edit it if `androidboot.hardware` is already present.)

26. **MKBOOTIMG Args:**
    *   Add this line and replace its value with the correct offsets and versions:
        ```makefile
        BOARD_MKBOOTIMG_ARGS := #value
        ```
    *   **To find the value:** Extract your **boot image** using CRB Kitchen. Open the files in the `split_image` folder (e.g., `boot.img-kernel_offset`, `boot.img-ramdisk_offset`, etc.) with a text editor like Notepad and copy the values for:
        *   `--kernel_offset`
        *   `--ramdisk_offset`
        *   `--tags_offset`
        *   `--header_version`
        *   `--board`
    *   **Example Value (in my case):** `--kernel_offset 0x00008000 --ramdisk_offset 0x01000000 --tags_offset 0x00000100 --header_version 2 --board SRPSG30B004RU`

    **Final Kernel Block Example (in my case):**
    ```makefile
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

27. **Dump Image Sizes:**
    *   Extract `recovery.img` and `boot.img` from your device's firmware file (decompress if necessary). *If you are rooted, you can dump them using ADB Shell:*
        ```bash
        cp /dev/block/by-name/recovery /sdcard/recovery.img
        cp /dev/block/by-name/boot /sdcard/boot.img
        cp /dev/block/by-name/dtbo /sdcard/dtbo.img
        ```
    *   Copy these `.img` files to a new folder on your PC.
    *   Open the Linux shell (WSL) in that folder by typing `wsl` in the address bar.
    *   Find their sizes in bytes using this command:
        ```bash
        stat -c '%n %s' *.img
        ```
    *   Copy the output (the byte sizes) to your text file.

28. **Update Image Sizes:**
    *   In `BoardConfig.mk`, replace the value for `BOARD_BOOTIMAGE_PARTITION_SIZE` with your `boot.img`'s size (in bytes).
    *   Replace the value for `BOARD_RECOVERYIMAGE_PARTITION_SIZE` with your `recovery.img`'s size (in bytes).
    *   Add this line and replace its value with your `dtbo.img`'s size (in bytes):
        ```makefile
        BOARD_DTBOIMG_PARTITION_SIZE := #value_of_your_dtbo.img
        ```

29. **Dynamic Partitions:**
    *   Find `BOARD_SAMSUNG_DYNAMIC_PARTITIONS_PARTITION_LIST`.
    *   Remove `system_ext` and `vendor_dlkm` if they do not exist on your device.

30. **Super Partition Size:**
    *   Replace the values for `BOARD_SUPER_PARTITION_SIZE` and `BOARD_SAMSUNG_DYNAMIC_PARTITIONS_SIZE` with your super partition's size in bytes.
    *   *To find the size, use ADB Shell (requires root):*
        ```bash
        su
        blockdev --getsize64 /dev/block/by-name/super
        ```

31. **AVB Settings:**
    *   Set `BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS`'s flag value, `BOARD_AVB_RECOVERY_ROLLBACK_INDEX`, and `BOARD_AVB_RECOVERY_ROLLBACK_INDEX_LOCATION` to `0`.

32. **Remove Unwanted Lines:**
    *   Remove these lines (anti-rollback/platform info hacks):
        ```makefile
        # Hack: prevent anti rollback
        PLATFORM_SECURITY_PATCH := 2099-12-31
        VENDOR_SECURITY_PATCH := 2099-12-31
        PLATFORM_VERSION := 16.1.0
        ```
    *   Also remove any default TWRP configuration values if present.

33. **TWRP Configuration:** Add or update these TWRP-specific values:
    ```makefile
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
    ```
    *   ***Note:*** *The editing process may vary based on your device's partition scheme and brand. Study similar-chipset device trees on GitHub and their commit history for reference.*

34. **Save** `BoardConfig.mk` (`Ctrl + S`).

35. **Enable MTP:**
    *   Find the `init.recovery.usb.rc` file from another device tree with the same chipset (located in `recovery/root`).
    *   Copy its content.
    *   Create your own `init.recovery.usb.rc` file in your device tree's `recovery/root` folder and paste the copied content.

***

### Part 4: TWRP Compilation Guide (Using Gitpod)

1.  **Set up Git Repository:** Create an empty repository named `gitpod` (or similar) on GitHub or GitLab.
2.  **Sign up for Gitpod:** Sign up at [https://gitpod.io/](https://gitpod.io/) using your GitLab or GitHub account.
3.  **Create Workspace:** Click "New Workspace," choose your empty repository, and select the **"large"** class.
4.  **Install `rsync`:** Once the workspace loads, run this command in the terminal:
    ```bash
    sudo apt update && sudo apt install rsync -y
    ```
5.  **Install Google Repo:** Run these commands:
    ```bash
    mkdir ~/bin
    PATH=~/bin:$PATH
    curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
    chmod a+x ~/bin/repo
    ```
6.  **Clone TWRP Source:** Clone the official TWRP source code. I am using `twrp-11` as `twrp-12.1` did not boot in my case.
    ```bash
    repo init --depth=1 --no-repo-verify -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-11 -g default,-mips,-darwin,-notdefault
    ```
7.  **Sync Source Code:** Run this command to start the cloning process:
    ```bash
    repo sync -c --no-clone-bundle --no-tags --optimized-fetch --prune --force-sync -j8
    ```
8.  **Set up Environment:** After syncing finishes, set up the environment variables:
    ```bash
    . build/envsetup.sh
    ```
9.  **Upload Device Tree:** Upload the entire folder of your device tree (the output of `twrpdtgen`) into the **`device`** folder of the workspace.
    *   It should look like `device/samsung/m21` (in my case).
10. **Choose Device:** Type `lunch` and select your device by typing the corresponding number (e.g., the number for `devicename-eng`).
11. **Start Building:** Begin compiling TWRP:
    ```bash
    make recoveryimage
    ```
12. **Download Image:** The build process will take 15 to 25 minutes. After it is complete, the terminal will show the output directory of your `recovery.img`. Navigate to it using the left-side panel in Gitpod, download the file to your local PC, and flash it using fastboot or Odin (by making a `.tar` file using 7-Zip).

Good luck homies!

This A-to-Z tutorial is written by Ravindu Deshan, a 20-year-old (in 2024) boy from Sri Lanka. Copying my content as your own is prohibited; if you do, you are g*y.
