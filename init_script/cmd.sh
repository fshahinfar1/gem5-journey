
SYSFILES="../system-files"
# TODO: take arguments for selecting environment stack
DISKIMG="ubuntu-test.img"
VMLINUX="x86_64-vmlinux-4.10.0"

# DISKIMG="x86root.img"
# VMLINUX="x86_64-vmlinux-2.6.22.9"

# TODO start telnet client automatically
# TODO use BOOTOPTS
BOOTOPTS="\"earlyprintk=ttyS0 console=ttyS0 lpj=7999923 root=/dev/hda2\""
echo $BOOTOPTS

LOGFILE="cmd.log"

sudo echo "Thanks."

sudo \
./build/X86/gem5.opt \
./configs/kvm_config/runkvm.py \
--kernel $SYSFILES/binaries/$VMLINUX \
--disk-image $SYSFILES/disks/$DISKIMG \
--mem-size 3GB \
--script ./scripts/run_test 2>&1 | tee $LOGFILE
# 1>simulator.log 2>&1 \
# --command-line $BOOTOPTS

#pid=$!

# sleep 3
# telnet 127.0.0.1 3456
#  wait $pid
