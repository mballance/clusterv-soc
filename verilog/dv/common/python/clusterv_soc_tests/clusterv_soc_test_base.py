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
        
        for core_bfm in pybfms.find_bfms(".*", RiscvDebugBfm):
            pass

        # Specify the boot address
        # TODO: should be controlled by plusarg?
        self.resvec_bfm.set_gpio_out(0x80000000)
        
        pass
    
    async def run(self):
        await cocotb.triggers.Timer(10, 'us')
        pass

@cocotb.test()
async def entry(dut):
    t = ClustervSocTestBase()
    await t.init()
    await t.run()
    

    