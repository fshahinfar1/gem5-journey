# Setup GEM5 Full System Simulation With ASCYLIB
1. `qemu-img create <img name>.img <size e.g. 8G>`

2. Boot and install ubuntu:
`qemu-system-x86_64 -hda <disk img> -cdrom <installation img> -boot d -enable-kvm -m 4096`

3. Make m5:
```
cd <gem5>/util/m5
make -f Makefile.x86
```

4. Mount disk image:
```
fdisk -lu <disk img>
mkdir mnt/
sudo mount -o loop,offset=$[offset*512] <disk img> mnt/
```

5. Copy m5 binary to:
```
/sbin/
```

6. Create a link from `/sbin/gem5` to `/sbin/m5`.
```
ln -s /sbin/m5 /sbin/gem5
```

7. Create a file at `/lib/systemd/system/gem5.service`.
(file content is [here](./init_script/gem5.service))

8. Create a file at `/sbin/initgem5`.
(file content is [here](./init_script/initgem5))

9. Boot the image and enable the `gem5.service`.
```
qemu-system-x86_64 -hda <img> -enable-kvm -m 4096
systemctl enable gem5
```

10. Clone ASCYLIB.
```
git clone https://github.com/LPD-EPFL/ASCYLIB
``` 

11. Make ASCYLIB.
```
make bst_aravind
make bst_howley
make lfsl_fraser
make htjava
```

12. Add run scripts for running tests.

13. Enable auto login
```
systemctl edit serial-getty@ttyS0
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --keep-baud 115200,38400,9600 %I $TERM
```

14. Shutdown qemu and write script for running tests.

15. Add script for starting gem5.

16. Run script 

17. Connect with telnet
```
telnet 127.0.0.1 3456
```

