 ####################################################################
 #
 # Software License Agreement (BSD License)
 #
 # Copyright (c) 2014-2015, Inria
 # All rights reserved.
 #
 # Redistribution and use in source and binary forms, with or without
 # modification, are permitted provided that the following conditions
 # are met:
 #
 #  * Redistributions of source code must retain the above copyright
 #    notice, this list of conditions and the following disclaimer.
 #  * Redistributions in binary form must reproduce the above
 #    copyright notice, this list of conditions and the following
 #    disclaimer in the documentation and/or other materials provided
 #    with the distribution.
 #  * Neither the name of the copyright holder nor the names of its
 #    contributors may be used to endorse or promote products derived
 #    from this software without specific prior written permission.
 #
 # THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 # "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 # LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 # FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 # COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 # INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 # BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 # LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 # CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 # LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 # ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 # POSSIBILITY OF SUCH DAMAGE.
 #
 ####################################################################


cmake_minimum_required (VERSION 2.6)

project (test)


set(CMAKE_MODULE_PATH ${PROJECT_SOURCE_DIR}/../cmake/Modules ${CMAKE_MODULE_PATH})

message(STATUS "CMAKE_MODULE_PATH = ${CMAKE_MODULE_PATH}")

find_package(Matlab REQUIRED)


message(STATUS "MATLAB_INCLUDE_DIR = ${MATLAB_INCLUDE_DIRS}")# include path for mex.h, engine.h
message(STATUS "SIMULINK_INCLUDE_DIR = ${SIMULINK_INCLUDE_DIRS}")# include path for simstruc.h
message(STATUS "MATLAB_LIBRARIES = ${MATLAB_LIBRARIES}")# required libraries: libmex, etc
message(STATUS "MATLAB_MEX_LIBRARY = ${MATLAB_MEX_LIBRARY}")# path to libmex.lib
message(STATUS "MATLAB_MX_LIBRARY = ${MATLAB_MX_LIBRARY}")# path to libmx.lib
message(STATUS "MATLAB_ENG_LIBRARY = ${MATLAB_ENG_LIBRARY}")# path to libeng.lib
message(STATUS "MATLAB_FOUND = ${MATLAB_FOUND}")# path to libeng.lib


include_directories(${MATLAB_INCLUDE_DIRS} ${SIMULINK_INCLUDE_DIRS})
link_directories(${MATLAB_LIB_DIR})
add_definitions(${MATLAB_DEFINITIONS})

# C MEX compilation
add_library(timestwo_mex SHARED ${MATLAB_ROOT}/extern/examples/refbook/timestwo.c)
target_link_libraries(timestwo_mex ${MATLAB_LIBRARIES})
set_target_properties(timestwo_mex PROPERTIES PREFIX "" SUFFIX ${MATLAB_MEX_EXT})

# C S-Function
add_library(timestwo SHARED ${MATLAB_ROOT}/toolbox/simulink/simdemos/simfeatures/src/timestwo.c)
target_link_libraries(timestwo ${MATLAB_LIBRARIES})
set_target_properties(timestwo PROPERTIES PREFIX "" SUFFIX ${MATLAB_MEX_EXT} COMPILE_DEFINITIONS "MATLAB_MEX_FILE")

# C++ S-Function
add_library(sfun_counter_cpp SHARED ${MATLAB_ROOT}/toolbox/simulink/simdemos/simfeatures/src/sfun_counter_cpp.cpp)
target_link_libraries(sfun_counter_cpp ${MATLAB_LIBRARIES})
set_target_properties(sfun_counter_cpp PROPERTIES PREFIX "" SUFFIX ${MATLAB_MEX_EXT} COMPILE_DEFINITIONS "MATLAB_MEX_FILE")
