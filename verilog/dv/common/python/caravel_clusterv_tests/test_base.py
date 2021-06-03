'''
Created on May 30, 2021

@author: mballance
'''

import cocotb
from elftools.elf.elffile import ELFFile
from elftools.elf.sections import SymbolTableSection
import pybfms
from spi_bfms.spi_memory_model import SpiMemoryModel

class TestBase(object):
    
    def __init__(self):
        self.caravel_dbg_bfm = None
        self.spi_flash_bfm = None
        self.spi_flash_mem = None
        pass
    
    async def init(self):
        await pybfms.init()
        
        self.caravel_dbg_bfm = pybfms.find_bfm(".*u_caravel_core_bfm")
        self.spi_flash_bfm = pybfms.find_bfm(".*u_spiflash_bfm")
        self.spi_flash_mem = SpiMemoryModel(self.spi_flash_bfm, 0x400000)

        sw_image = cocotb.plusargs["sw.image"]

        print("Note: loading image " + sw_image)    
        with open(sw_image, "rb") as f:
            elffile = ELFFile(f)
        
            # Find the section that contains the data we need
            section = None
            for i in range(elffile.num_sections()):
                shdr = elffile._get_section_header(i)
                if shdr['sh_size'] != 0 and (shdr['sh_flags'] & 0x2):
                    section = elffile.get_section(i)
                    data = section.data()
                    addr = shdr['sh_addr']
                    j = 0
                    while j < len(data):
                        self.spi_flash_mem.data[(addr & 0x3FFFFF)] = data[j]
                        addr += 1
                        j += 1

                                
        pass
    
    async def run(self):
        await cocotb.triggers.Timer(1, "ms")
        pass
    
@cocotb.test()
async def entry(dut):
    t = TestBase()
    await t.init()
    await t.run()
    
        
    