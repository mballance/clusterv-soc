# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

set script_dir [file dirname [file normalize [info script]]]
source $::env(SYNTH_DIR)/../../../caravel/openlane/user_project_wrapper_empty/fixed_wrapper_cfgs.tcl

set ::env(DESIGN_NAME) user_project_wrapper

set ::env(FP_PDN_CHECK_NODES) 0

# set ::env(PDN_CFG) $script_dir/pdn.tcl

set ::env(GLB_RT_OBS) "met1 0 0 $::env(DIE_AREA),\
					   met2 0 0 $::env(DIE_AREA),\
					   met3 0 0 $::env(DIE_AREA),\
					   met4 0 0 $::env(DIE_AREA),\
					   met5 0 0 $::env(DIE_AREA)"

set ::env(CLOCK_PORT) "wb_clk_i"
#set ::env(CLOCK_NET) "mprj.clk"

set ::env(CLOCK_PERIOD) "10"

set ::env(PL_OPENPHYSYN_OPTIMIZATIONS) 0
set ::env(DIODE_INSERTION_STRATEGY) 0

set ::env(MAGIC_WRITE_FULL_LEF) 1

#set ::env(VERILOG_FILES) "\
#	$script_dir/../../verilog/rtl/defines.v \
#	$script_dir/../../verilog/rtl/__user_project_wrapper.v"

# save some time
set ::env(RUN_KLAYOUT_XOR) 0
set ::env(RUN_KLAYOUT_DRC) 0

# magic drc checking on the sram block shows millions of false errors
set ::env(MAGIC_DRC_USE_GDS) 0

#set ::env(PL_RANDOM_GLB_PLACEMENT) 1
#set ::env(MACRO_PLACEMENT_CFG) $::env(SYNTH_DIR)/macro.cfg
#set ::env(CLOCK_TREE_SYNTH) 0
set ::env(ROUTING_CORES) 10
#set ::env(PL_TARGET_DENSITY)     0.01

