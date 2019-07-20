# Gem5 journey

## Building gem5

1. Follow the guide in the [website](http://gem5.org/Introduction).
```
scons build/ARM/gem5.opt -j4
```

2. If protobuf_min_version error then edit SConstruct in the root of gem5 directory.
At line 390, append to the list '-Wno-error=undef'.

## Running a full system simulation

### Run the default image and kernel

1. Download the provided kernel and image from [link](http://gem5.org/Download).

2. Extract the download archive and add a path to the directory. (export M5_PATH or
edit the "\<gem5 dir\>/configs/common/SysPaths.py" -> line 53, append path to the list.)

3. Create a dummy image named linux-bigswap2.img in the **disks** folder of the $M5_PATH.
```
dd if=/dev/zero of=./binaries/linux-bigswap2.img count=1 bs=16k
```
Check this [link](https://stackoverflow.com/questions/56319473/gem-5-ioerror-cant-find-a-path-to-system-files-full-system-x86-simulation-set).

4. Use the default fs.py config for running a simulation.
Run gem5 simulator: 
```
./build/X86/gem.opt ./configs/examples/fs.py --disk-image=x86Linux --kernel=x86_64-vmlinux-2.6.22.9
```
>Also please note that with correct kernel config it is possible to use the base old image with the new kernel.

5. Then connect to the simulator using telnet.
```
telnet 127.0.0.1 <port>
```

### Run a custom kernel and image [Not yet achieved]

These steps has been taken for running a full system simulation but
I haven't yet got there.

1. Read the blog post [here](http://www.lowepower.com/jason/setting-up-gem5-full-system.html).

2. Download kernel version 4.8.13

3. Download config file linked to in the post.

4. Build the kernel with that config file.
```
cp config ./kernel directory/.config
cd ./kernel directory/
make oldconfig
make -j9
```

5. Copy vmlinux file (built kernel) to $M5_PATH/binaries

6. Run simulation.
```
./build/X86/gem5.opt ./configs/examples/fs.py --disk-image=test.img --kernel=x86_64-vmlinux-4.8.13
```

7. After some time, just after running init process of kerenl, the simulation ends.
There is an error with TLB I guess. It might be because of system configuration.
Check error logs at [here](./tlb_assertion_error).

8. Read post [here](http://learning.gem5.org/book/part5/fs_config.html)
for creating a system configuration.
After following the tutorial I get the following error:
```
AttributeError: object 'MySystem' has no attribute 'mmubus'
  (C++ object is not yet constructed, so wrapped C++ methods are unavailable.)
```

9. The issue was solved there was some typing errors in the toturials code.
(I opened an issue for them).
System config is available [here](./my_config).
```
./build/X86/gem5.opt ./configs/my_config/run.py
```

10. Follow this [link](http://www.lowepower.com/jason/setting-up-gem5-full-system.html)
to create an image file. Ubuntu Server version 18.04.2 was used.
I have Tried to run simulation with ubuntu image and kernel 4.8.13 on my_config system
but it was stoped by kernel panic.
Logs for the error is available [here](./kernel-panic/).
(Check create disk image section)

11. Check [this](https://askubuntu.com/questions/41930/kernel-panic-not-syncing-vfs-unable-to-mount-root-fs-on-unknown-block0-0) post for solving the issue.
And this [post](https://wiki.gentoo.org/wiki/Knowledge_Base:Unable_to_mount_root_fs).

12. In my_config/simple_full_system.py, boot_options, change `root=/dev/hda1` to `root=/dev/hda2`. 
A new kernel panic message. check [here](./kernel-panic-2).

13. Stuck, but this [repository](https://github.com/cirosantilli/linux-kernel-module-cheat/tree/6aa2f783a8a18589ae66e85f781f86b08abb3397#gem5-system-parameters) looks promising.

## Useful tips
### Create a disk image
This part is obtained from this [post](http://www.lowepower.com/jason/setting-up-gem5-full-system.html)
writen by Jason Lowe-Power.

Dependencies: qemu

1. Create an empty disk image
```
qemu-img create ubuntu-test.img 8G
```

2. Boot the installation image and install it on the disk image.
```
qemu-system-x86_64 -hda \<path to ubuntu-test.img\> -cdrom \<path to installation image\> -m 1024 -enable-kvm -boot d
```

3. Boot from disk and add data, programs, ...
```
qemu-system-x86_64 -hda \<path to ubuntu-test.img\> -m 1024 -enable-kvm
```

4. Setup init script:
* build m5 
```
cd util/m5
make -f Makefile.x86
```
* mount image file system (check out mounting image file system)
* copy m5 binary to /sbin
* create a link from `/sbin/gem5` to `/sbin/m5`
```
ln -s /sbin/m5 /sbin/gem5
```
* create a file at `/lib/systemd/system/gem5.service`
(file content is [here](./init_script/gem5.service))
* create a file at `/sbin/initgem5`
(file content is [here](./init_script/initgem5))
* boot the image and enable the gem5.service
```
systemctl enable gem5.service
```

### Mounting image file system
For copying files from host to guest file-system, you can mount the image.
(Read this [post](https://www.cnx-software.com/2011/09/29/how-to-transfer-files-between-host-and-qemu/).)

1. First find the partition's offset with command below
```
fdisk -lu ubuntu-test.img
```

2. Mount the partition
(4096 start of file system offset, 512 block size)
```
sudo mount -o loop,offset=$[4096*512] ubuntu-test.img mnt/
```

3. Copy files and ...

### Config image for auto login

Check the post [here](https://unix.stackexchange.com/questions/297252/how-do-you-configure-autologin-in-debian-jessie).

1. Use command below
```
systemctl edit serial-getty@ttyS0
```

2. Add lines below
```
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --keep-baud 115200,38400,9600 %I $TERM
```

### How does gem5 pass scripts to guest

1. Using `system.readfile` attribute defined at `System.py` a pointer 
to a script can be send to guest.

2. guest can use `m5` binary for accessing the file using command:
`m5 readfile`

* Note: take a look at [here](https://stackoverflow.com/questions/49516399/how-to-use-m5-readfile-and-m5-execfile-in-gem5/49538051).
