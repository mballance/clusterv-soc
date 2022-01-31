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
            await self.mgmt_bfm.write(0x12000000+4*i, 0x55+i, 0xF)
        for i in range(10):
            data = await self.mgmt_bfm.read(0x12000000+4*i)
            print("data: 0x%08x" % data)
        pass
    
@cocotb.test()
async def entry(dut):
    t = UserProjectWrapperTestBase()
    await t.init()
    await t.run()
    