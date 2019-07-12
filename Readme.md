# Gem5 journey

## Building gem5

1. Follow the guid in the [website](http://gem5.org/Introduction).
```
scons build/ARM/gem5.opt -j4
```

2. If protobuf_min_version error then edit SConstruct in the root of gem5 directory.
At line 390, append to the list '-Wno-error=undef'.

## Running a full system simulation

### Run the default images and kernel

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
./build/X86/gem.opt ./configs/examples/fs.py --disk-image=test.img --kernel=x86_64-vmlinux-4.8.13
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


**Kernel Config:**

1. It looks like gem5 wants Retpoline enabled

