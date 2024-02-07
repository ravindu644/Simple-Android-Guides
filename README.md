# 🧱 01. How to Unpack your Super.img..?

**Requirements** : WSL, `simg2img`, [lpunpack](https://raw.githubusercontent.com/ravindu644/Scamsung/Samsung/bin/lpunpack), [lpmake](https://raw.githubusercontent.com/ravindu644/Scamsung/Samsung/bin/lpmake).

## 01. Setup WSL and Install simg2img using this command :

```
sudo apt update && sudo apt install simg2img
```

## 02. Change the working directory to your super.img's location.
```
cd /path/to/super
```
## 03. Convert the Sparse super.img to a RAW image.

```
simg2img super.img super.img.raw
```
## 04. Extract the partitions inside the super.img using this command :

```
./lpunpack super.img.raw
```

### Done ✔️

<hr>

# 🧱 02. How to Repack your super.img..?

To repack your super.img file, which is crucial for ROM developers, follow these steps:

## Step 1: Determine the Super Partition Size.

First, find out the exact size of your super partition in bytes using the following command:

```
adb shell
su
blockdev --getsize64 /dev/block/by-name/super
```

*Take note of this value.

## Step 2: Fix Errors and Shrink Partitions to its minimum value.

After modifying the child partitions inside the super.img, you'll need to fix errors and shrink the partitions to their minimum size. Execute these commands:

```
e2fsck -yf system.img
resize2fs -M system.img

e2fsck -yf vendor.img
resize2fs -M vendor.img

e2fsck -yf product.img
resize2fs -M product.img

e2fsck -yf odm.img
resize2fs -M odm.img
```

## Step 3: Measure Child Partition Sizes.

Use the following command to measure the sizes of the child partitions needed to repack the super.img :

```
stat -c '%n %s' *.img
```

## Step 4: Repack the Super.img.

Finally, repack the super.img using this command:

Notes : 

- Remove `--sparse` to create a TWRP flashable super.img. Otherwise, you can flash a sparse super with Odin or fastboot.

- `--device super` represents your device's super partition size in bytes.

- `--group main` is the sum of system, vendor, product, and odm partition sizes in bytes. 

- You can calculate this using a calculator.

- Adjust the partition sizes according to their actual sizes obtained from the `stat -c '%n %s' *.img` command in bytes.

Example Command :

```
./lpmake --metadata-size 65536 --super-name super --metadata-slots 1 --device super:6382682112 --group main:4293513600 --partition system:readonly:1577095168:main --image system=./system.img --partition vendor:readonly:342155264:main --image vendor=./vendor.img --partition odm:readonly:643456:main --image odm=./odm.img --sparse --output ./super.img
```

Credits :

https://forum.xda-developers.com/t/editing-system-img-inside-super-img-and-flashing-our-modifications.4196625/

https://blog.senyuuri.info/posts/2022-04-27-patching-android-super-images/

Copyright [@Ravindu_Deshan ](https://t.me/Ravindu_Deshan)\ [@SamsungTweaks](https://t.me/SamsungTweaks)
