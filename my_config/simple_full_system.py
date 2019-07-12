"""
Article linke: http://learning.gem5.org/book/part5/fs_config.html
"""

import x86
from m5.objects import *
from caches import *

class MySystem(LinuxX86System):
    def __init__(self, opts):
        super(MySystem, self).__init__()
        self._opts = opts
        self.clk_domain = SrcClockDomain()
        self.clk_domain.clock = '3GHz'
        self.clk_domain.voltage_domain = VoltageDomain()

        mem_size = '3GB'
        self.mem_ranges = [AddrRange(mem_size),
                           AddrRange(0xC0000000, size=0x100000), # For I/0
                           ]
        self.membus = SystemXBar()
        self.membus.badaddr_responder = BadAddr()
        self.membus.default = self.membus.badaddr_responder.pio

        self.system_port = self.membus.slave
        x86.init_fs(self, self.membus)
        
        self.kernel = '/home/hawk/Workplace/Github/gem5-system/binaries/x86_64-vmlinux-5.2'

        boot_options = ['earlyprintk=ttyS0', 'console=ttyS0', 'lpj=7999923',
                        'root=/dev/hda1']
        self.boot_osflags = ' '.join(boot_options)
        
        self.setDiskImage('/home/hawk/Workplace/Github/gem5-system/disks/x86root.img')

        self.createCPU()

        self.createCacheHierarchy()

        self.createMemoryControllers()

        self.setupInterrupts()
        
    def setDiskImage(self, img_path):
        """ Set the disk image
            @param img_path path on the host to the image file for the disk
        """
        disk0 = CowDisk(img_path)
        self.pc.south_bridge.ide.disks = [disk0]

    def createCPU(self):
        """ Create a CPU for the system """
        self.cpu = AtomicSimpleCPU()
        self.mem_mode = 'atomic'
        self.cpu.createThreads()

    def createCacheHierarchy(self):
        """ Create a simple cache heirarchy with the caches from part1 """

        # Create an L1 instruction and data caches and an MMU cache
        # The MMU cache caches accesses from the inst and data TLBs
        self.cpu.icache = L1ICache()
        self.cpu.dcache = L1DCache()

        # Connect the instruction, data, and MMU caches to the CPU
        self.cpu.icache.connectCPU(self.cpu)
        self.cpu.dcache.connectCPU(self.cpu)

        # Hook the CPU ports up to the membus
        self.cpu.icache.connectBus(self.membus)
        self.cpu.dcache.connectBus(self.membus)

        # Connect the CPU TLBs directly to the mem.
        self.cpu.itb.walker.port = self.membus.slave
        self.cpu.dtb.walker.port = self.membus.slave

    def createMemoryControllers(self):
        """ Create the memory controller for the system """
        self.mem_cntrl = DDR3_1600_8x8(range = self.mem_ranges[0],
                                       port = self.membus.master)
    def setupInterrupts(self):
        """ Create the interrupt controller for the CPU """
        self.cpu.createInterruptController()
        self.cpu.interrupts[0].pio = self.membus.master
        self.cpu.interrupts[0].int_master = self.membus.slave
        self.cpu.interrupts[0].int_slave = self.membus.master

    
class CowDisk(IdeDisk):
    """ Wrapper class around IdeDisk to make a simple copy-on-write disk
        for gem5. Creates an IDE disk with a COW read/write disk image.
        Any data written to the disk in gem5 is saved as a COW layer and
        thrown away on the simulator exit.
    """

    def __init__(self, filename):
        """ Initialize the disk with a path to the image file.
            @param filename path to the image file to use for the disk.
        """
        super(CowDisk, self).__init__()
        self.driveID = 'master'
        self.image = CowDiskImage(child=RawDiskImage(read_only=True),
                                  read_only=False)
        self.image.child.image_file = filename

