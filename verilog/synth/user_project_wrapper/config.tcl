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

# Base Configurations. Don't Touch
# section begin
set script_dir [file dirname [file normalize [info script]]]

source $::env(SYNTH_DIR)/../../../caravel/openlane/user_project_wrapper_empty/fixed_wrapper_cfgs.tcl

set ::env(DESIGN_NAME) user_project_wrapper
set ::env(RUN_KLAYOUT) 0

# magic drc checking on the sram block shows millions of false errors
set ::env(MAGIC_DRC_USE_GDS) 0

## Routing configurations
set ::env(GLB_RT_ADJUSTMENT) 0.38
set ::env(GLB_RT_MAXLAYER) 5

set ::env(GLB_RT_OBS) "
        met4 1313 1690 1623 2084"


#section end

# User Configurations

## Source Verilog Files
#set ::env(VERILOG_FILES) "\
#	$script_dir/../../caravel/verilog/rtl/defines.v \
#	$script_dir/../../verilog/rtl/user_project_wrapper.v"

## Clock configurations
set ::env(CLOCK_PORT) "user_clock2"
#set ::env(CLOCK_NET) "mprj.clk"

set ::env(CLOCK_PERIOD) "10"

## Internal Macros
### Macro Placement
set ::env(MACRO_PLACEMENT_CFG) $::env(SYNTH_DIR)/macro.cfg

### Black-box verilog and views
#set ::env(VERILOG_FILES_BLACKBOX) "\
#	$script_dir/../../caravel/verilog/rtl/defines.v \
#	$script_dir/../../verilog/rtl/user_proj_example.v"

#set ::env(EXTRA_LEFS) "\
#	$script_dir/../../lef/user_proj_example.lef"

#set ::env(EXTRA_GDS_FILES) "\
#	$script_dir/../../gds/user_proj_example.gds"

set ::env(GLB_RT_MAXLAYER) 5

set ::env(FP_PDN_CHECK_NODES) 0

# The following is because there are no std cells in the example wrapper project.
#set ::env(SYNTH_TOP_LEVEL) 1
#set ::env(PL_RANDOM_GLB_PLACEMENT) 1

set ::env(PL_RESIZER_DESIGN_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_TIMING_OPTIMIZATIONS) 0
set ::env(PL_RESIZER_BUFFER_INPUT_PORTS) 0
set ::env(PL_RESIZER_BUFFER_OUTPUT_PORTS) 0

set ::env(DIODE_INSERTION_STRATEGY) 0
set ::env(FILL_INSERTION) 0
set ::env(TAP_DECAP_INSERTION) 0
#set ::env(CLOCK_TREE_SYNTH) 0
