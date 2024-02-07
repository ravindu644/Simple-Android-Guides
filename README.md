## Flashing / Dumping your Android partitions with root and termux.

Example command :

```
dd if=/dev/block/by-name/partition_name of=/sdcard/partition_name.img
```

Explaination :

**dd:** `dd` stands for "data duplicator." It's a command-line utility used for copying and converting data. It's commonly used in Unix-like operating systems, including Linux and Android.

`if=/dev/block/by-name/partition_name`: Here, `if` stands for "input file." This part of the command specifies the source of the data to be copied. In this case, it's specifying the input file as a specific partition on the Android device. `/dev/block/by-name/` is the directory where the partitions of the Android device are stored, and `partition_name` is the name of the partition you want to copy.

`of=/sdcard/partition_name.img`: Here, `of` stands for "output file." This part of the command specifies the destination where the copied data will be saved. `/sdcard/` is typically the directory where the user's files are stored on an Android device, and `partition_name.img` is the name of the file that will be created to store the copied data. The .img extension is commonly used for disk image files.

### So, when you run this command on an Android device:

```
dd if=/dev/block/by-name/partition_name of=/sdcard/partition_name.img
```

<hr>

It will read the contents of the specified partition (partition_name) from the device's storage and save it as a disk image file (partition_name.img) in the /sdcard/ directory, which is usually accessible to the user.

To dump any partition you like from an Android device using this command:

**01.** First, you need to identify the name of the partition you want to dump. You can do this by checking the `/dev/block/by-name/` directory on your Android device. Common partitions include `boot`, `system`, `recovery`, `super`, etc.

**02.** Once you know the name of the partition you want to dump, replace `partition_name` in the command with the actual name of the partition. For example, if you want to dump the `boot` partition, the command would look like this:

```
dd if=/dev/block/by-name/boot of=/sdcard/boot.img
```
**03.** After replacing `partition_name` with the actual partition name, run the command in a termux or using adb (Android Debug Bridge) on your Android device. Make sure you have appropriate permissions to access the partition you're trying to dump.

**04.** Once the command completes, you'll find the dumped partition as a disk image file (partition_name.img) in the /sdcard/ directory of your Android device. You can then transfer this file to your computer or another device for further analysis or backup.

<hr>

## You can use this reverse to flash a .img file to a partition too ☺️.

**Example :**
```
dd if=/sdcard/boot.img of=/dev/block/by-name/boot
```
