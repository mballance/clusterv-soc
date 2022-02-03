'''
Created on Jun 4, 2021

@author: mballance
'''

import cocotb
import pybfms
from gpio_bfms.GpioBfm import GpioBfm
from wishbone_bfms.wb_initiator_bfm import WbInitiatorBfm
from riscv_debug_bfms.riscv_debug_bfm import RiscvDebugBfm
from spi_bfms.spi_memory_model import SpiMemoryModel
from elftools.elf.elffile import ELFFile
from elftools.elf.sections import SymbolTableSection

class ClustervSocTestBase(object):
    
    def __init__(self):
        self.mgmt_bfm : WbInitiatorBfm = None
        self.resvec_bfm : GpioBfm = None
        self.core_reset_bfm : GpioBfm = None
        self.spi_memio : SpiMemoryModel = None
        
        pass
    
    async def init(self):
        await pybfms.init()
        self.mgmt_bfm = pybfms.find_bfm(".*u_mgmt_bfm")
        self.resvec_bfm = pybfms.find_bfm(".*u_resvec_bfm")
        self.core_reset_bfm = pybfms.find_bfm(".*u_core_reset_bfm")
        
        spi_memio = pybfms.find_bfm(".*u_spi_memio")
        self.spi_memio = SpiMemoryModel(spi_memio, 1024*1024*4)

        # Hold the cores in reset        
        self.core_reset_bfm.set_gpio_out(1)
        await self.core_reset_bfm.propagate()
        self.core_reset_bfm.set_gpio_out(1)
        await self.core_reset_bfm.propagate()
        
        sw_image = cocotb.plusargs["sw.image"]
        boot = cocotb.plusargs["boot"]
        
        if boot == "ram":
            self.resvec_bfm.set_gpio_out(0x80000000)
        else:
            print("Setting resvec to 0x10000000")
            self.resvec_bfm.set_gpio_out(0x10000000)
        await self.resvec_bfm.propagate()
        
        for core_bfm in pybfms.find_bfms(".*", RiscvDebugBfm):
            pass
        

        # Specify the boot address
        # TODO: should be controlled by plusarg?
        
            
        await self.load_image(boot, sw_image)
            
        # Release the cores from reset
        self.core_reset_bfm.set_gpio_out(0)
        
        pass
    
    async def load_image(self, boot, sw_image):
        print("Note: loading image " + sw_image)    
        with open(sw_image, "rb") as f:
            elffile = ELFFile(f)
        
            # Find the section that contains the data we need
            section = None
            for seg in elffile.iter_segments():
                print("seg: " + hex(seg.header.p_paddr) + " " + hex(seg.header.p_vaddr)) 
                print("  p_offset: " + hex(seg.header.p_offset))
                print("  p_flags: " + hex(seg.header.p_flags))
                print("  p_filesz: " + hex(seg.header.p_filesz))
                print("  p_memsz: " + hex(seg.header.p_memsz))

                addr = seg.header.p_paddr                
                data = seg.data()
                
                if seg.header.p_flags & 0x1: # Executable data
                    if boot == "ram":
                        j = 0
                        while j < len(data):
                            word = (data[j+0] << (8*0))
                            word |= (data[j+1] << (8*1)) if j+1 < len(data) else 0
                            word |= (data[j+2] << (8*2)) if j+2 < len(data) else 0
                            word |= (data[j+3] << (8*3)) if j+3 < len(data) else 0
                            bfm_addr = 0x80000000 | (addr & 0xFFFC)
                            print("Write: 0x%08x 0x%08x" % (bfm_addr, word))
                            await self.mgmt_bfm.write(bfm_addr, word, 0xF)
                            addr += 4
                            j += 4
                    else: # Flash
                        base = (addr & 0xFFFFFF)
                        print("Loading section @ 0x%08x" % base)
                        for i,b in enumerate(data):
                            self.spi_memio.data[base+i] = b
                    
#                print("  data: " + str(seg.data()))
                
#             for i in range(elffile.num_sections()):
#                 shdr = elffile._get_section_header(i)
#                 if shdr['sh_size'] != 0 and (shdr['sh_flags'] & 0x2):
#                     section = elffile.get_section(i)
#                     data = section.data()
#                     addr = shdr['sh_addr']
#                     
#                     if boot == "ram":
#                         j = 0
#                         while j < len(data):
#                             word = (data[j+0] << (8*0))
#                             word |= (data[j+1] << (8*1)) if j+1 < len(data) else 0
#                             word |= (data[j+2] << (8*2)) if j+2 < len(data) else 0
#                             word |= (data[j+3] << (8*3)) if j+3 < len(data) else 0
#                             bfm_addr = 0x80000000 | (addr & 0xFFFC)
#                             print("Write: 0x%08x 0x%08x" % (bfm_addr, word))
#                             await self.mgmt_bfm.write(bfm_addr, word, 0xF)
#                             addr += 4
#                             j += 4
#                     else: # Flash
#                         base = (addr & 0xFFFFFF)
#                         print("Loading section @ 0x%08x" % base)
#                         for i,b in enumerate(data):
#                             self.spi_memio.data[base+i] = b
#                         
        print("Done Loading")
        
    
    async def run(self):
        await self.mgmt_bfm.write(0x10000000, 0x55aaeeff, 0xF)
#        await self.mgmt_bfm.write(0x80000000, 0x55aaeeff, 0xF)
        await self.mgmt_bfm.write(0x10000004, 0x00000000, 0xF)
        await cocotb.triggers.Timer(100, 'us')
#        await cocotb.triggers.Timer(1, 'ms')
        pass

@cocotb.test()
async def entry(dut):
    t = ClustervSocTestBase()
    await t.init()
    await t.run()
    

    