'''
Created on Jun 4, 2021

@author: mballance
'''

import cocotb
import pybfms

class ClustervTestBase(object):
    
    def __init__(self):
        self.mgmt_bfm = None
        pass
    
    async def init(self):
        await pybfms.init()
        self.mgmt_bfm = pybfms.find_bfm(".*u_mgmt_bfm")
        print("mgmt_bfm=" + str(self.mgmt_bfm))
        
        for bfm in pybfms.get_bfms():
            print("bfm: " + str(bfm))
        
        pass
    
    async def run(self):
        await cocotb.triggers.Timer(1, 'us')
        pass

@cocotb.test()
async def entry(dut):
    t = ClustervTestBase()
    await t.init()
    await t.run()
    

    