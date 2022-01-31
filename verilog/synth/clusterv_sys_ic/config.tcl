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

# Disable streaming GDS using klayout
set ::env(RUN_KLAYOUT) 0

set ::env(CLOCK_PORT) "clock"
set ::env(CLOCK_NET) "clock"
set ::env(CLOCK_PERIOD) "30"

set ::env(FP_SIZING) absolute
#set ::env(DIE_AREA) "0 0 1000 70"
set ::env(DIE_AREA) "0 0 1200 400"
#set ::env(CELL_PAD) 4
set ::env(DESIGN_IS_CORE) 0

#set ::env(VDD_NETS) [list {vccd1} {vccd2} {vdda1} {vdda2}]
#set ::env(GND_NETS) [list {vssd1} {vssd2} {vssa1} {vssa2}]
set ::env(VDD_NETS) [list {vccd1}]
set ::env(GND_NETS) [list {vssd1}]

#set ::env(FP_PIN_ORDER_CFG) $::env(SYNTH_DIR)/pin_order.cfg

#set ::env(PL_BASIC_PLACEMENT) 1
set ::env(PL_TARGET_DENSITY) 0.15
#set ::env(PL_RANDOM_GLB_PLACEMENT) 1

# If you're going to use multiple power domains, then keep this disabled.
set ::env(RUN_CVC) 0

### Routing
# Add routing obstruction on met5 to avoid having shorts on the top level where met5 power straps intersect with the macro
set ::env(GLB_RT_OBS)               "met5 $::env(DIE_AREA)"
set ::env(GLB_RT_MAXLAYER)          5
set ::env(GLB_RT_ADJUSTMENT)        0.25

### Diode Insertion
set ::env(DIODE_INSERTION_STRATEGY) "5"

set ::env(ROUTING_CORES) 10
#set ::env(ROUTING_OPT_ITERS) 80

