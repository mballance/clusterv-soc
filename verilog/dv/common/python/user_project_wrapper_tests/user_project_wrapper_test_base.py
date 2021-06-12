'''
Created on Jun 9, 2021

@author: mballance
'''

import cocotb
import pybfms
from wishbone_bfms.wb_initiator_bfm import WbInitiatorBfm

class UserProjectWrapperTestBase(object):
    
    def __init__(self):
        self.mgmt_bfm = None
        pass
    
    async def init(self):
        await pybfms.init()
        self.mgmt_bfm : WbInitiatorBfm = pybfms.find_bfm(".*u_mgmt_bfm")
        pass
    
    async def run(self):
        for i in range(10):
            await self.mgmt_bfm.write(0x10000000+4*i, 0xffeeaa55, 0xF)
        pass
    
@cocotb.test()
async def entry(dut):
    t = UserProjectWrapperTestBase()
    await t.init()
    await t.run()
    