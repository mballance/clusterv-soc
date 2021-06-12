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

set ::env(DESIGN_NAME) clusterv_caravel_top

set ::env(CLOCK_PORT) "wb_clk_i"
#set ::env(CLOCK_NET) "counter.clk"
set ::env(CLOCK_PERIOD) "10"

# save some time
set ::env(RUN_KLAYOUT_XOR) 0
set ::env(RUN_KLAYOUT_DRC) 0

set ::env(FP_SIZING) absolute
set ::env(DIE_AREA) "0 0 1000 1000"
#set ::env(DIE_AREA) "0 0 2000 2000"
set ::env(DESIGN_IS_CORE) 0

set ::env(FP_VERTICAL_HALO) 6

set ::env(VDD_NETS) [list {vccd1} {vccd2} {vdda1} {vdda2}]
set ::env(GND_NETS) [list {vssd1} {vssd2} {vssa1} {vssa2}]

set ::env(FP_PIN_ORDER_CFG)    $::env(SYNTH_DIR)/pin_order.cfg
set ::env(MACRO_PLACEMENT_CFG) $::env(SYNTH_DIR)/macro.cfg

#set ::env(GLB_RT_ADJUSTMENT) 0.38
set ::env(GLB_RT_ADJUSTMENT) 0
set ::env(CELL_PAD) 4
set ::env(GLB_RT_TILES) 14
set ::env(GLB_RT_MAXLAYER) 5

#set ::env(PL_BASIC_PLACEMENT) 1
set ::env(PL_RANDOM_GLB_PLACEMENT) 1
set ::env(PL_TARGET_DENSITY) 0.01

#set ::env(FP_PDN_CHECK_NODES) 0

# If you're going to use multiple power domains, then keep this disabled.
set ::env(RUN_CVC) 0

set ::env(ROUTING_CORES) 10
set ::env(CLOCK_TREE_SYNTH) 0

