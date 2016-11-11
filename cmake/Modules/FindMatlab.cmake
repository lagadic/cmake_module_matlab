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
 #
 #
 # This module looks for Matlab using mex executable
 # Defines:
 #   MATLAB_CXX_MEXOPTS: mexopts file used to configure Matlab
 #   MATLAB_ROOT:  root directory of MATLAB
 #   MATLAB_CXX_COMPILER: C++ compiler
 #   MATLAB_CXX_FLAGS: C++ compiler flags
 #   MATLAB_CXX_FLAGS_DEBUG: C++ compiler flags for debug mode
 #   MATLAB_CXX_FLAGS_RELEASE: C++ compiler flags for release mode
 #
 #   MATLAB_C_COMPILER: C compiler
 #   MATLAB_C_FLAGS: C compiler flags
 #   MATLAB_C_FLAGS_DEBUG: C compiler flags for debug mode
 #   MATLAB_C_FLAGS_RELEASE: C compiler flags for release mode 
 #
 #   MATLAB_LINKER_FLAGS: common linking flags
 #   MATLAB_LIBRARIES: MATLAB libraries
 #   MATLAB_MEX_EXT: mex files extension for the current system
 #
 #   MATLAB_DEFINITIONS: additional defines
 #   MATLAB_INCLUDE_DIRS: include path for MATLAB headers
 #   SIMULINK_INCLUDE_DIRS: include path for SIMULINK headers 
 #
 #   MATLAB_MEX: full path of the mex command
 #   MATLAB_EXE: full path of matlab command
 #   
 # Note: mex executable must be in your system path or you need to define
 #  MATLAB_DIR to be the path of your MATLAB installation
 ####################################################################


set(MATLAB_FOUND 0)

if(WIN32)
  #message(FATAL "Windows is not supported")
else()

  if(NOT MATLAB_DIR)
    set(MATLAB_DIR $ENV{MATLAB_DIR} CACHE PATH "Installation prefix for Matlab." FORCE)
  endif()

#  if(${MATLAB_DIR} STREQUAL "")

  set(TEST_CXX_MEX_FILE ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/testMexCompiler.cxx)

  ##message(STATUS "TEST_CXX_MEX_FILE = ${TEST_CXX_MEX_FILE}")

  file(WRITE ${TEST_CXX_MEX_FILE}
    "#ifndef __cplusplus\n"
    "# error \"The CMAKE_CXX_COMPILER is set to a C compiler\"\n"
    "#endif\n"
    "int main(){return 0;}\n")

  set(TEST_C_MEX_FILE ${CMAKE_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/CMakeTmp/testMexCompiler.c)

  ##message(STATUS "TEST_C_MEX_FILE = ${TEST_C_MEX_FILE}")

  file(WRITE ${TEST_C_MEX_FILE}
    "#ifdef __cplusplus\n"
    "# error \"The CMAKE_C_COMPILER is set to a C++ compiler\"\n"
    "#endif\n"
    "int main(){return 0;}\n")

  if(NOT MATLAB_DIR)
    execute_process(COMMAND which mex COMMAND xargs readlink -f OUTPUT_VARIABLE MATLAB_MEX OUTPUT_STRIP_TRAILING_WHITESPACE)
    execute_process(COMMAND which matlab COMMAND xargs readlink -f OUTPUT_VARIABLE MATLAB_EXE OUTPUT_STRIP_TRAILING_WHITESPACE)
  else()
    set(MATLAB_MEX ${MATLAB_DIR}/bin/mex)
    set(MATLAB_EXE ${MATLAB_DIR}/bin/matlab)
  endif()

  #message(STATUS "Testing mex file compiling with ${MATLAB_MEX} -v ${TEST_CXX_MEX_FILE}")
  execute_process(COMMAND ${MATLAB_MEX} -v ${TEST_CXX_MEX_FILE} -output ${TEST_CXX_MEX_FILE} OUTPUT_VARIABLE CXX_MEX_RESULT)
  execute_process(COMMAND ${MATLAB_MEX} -v ${TEST_C_MEX_FILE} -output ${TEST_CXX_MEX_FILE} OUTPUT_VARIABLE C_MEX_RESULT)

  #file(REMOVE ${TEST_CXX_MEX_FILE})

  #message(STATUS "CXX_MEX_RESULT=${CXX_MEX_RESULT}")

  #message(STATUS "C_MEX_RESULT=${C_MEX_RESULT}")
  
  ## Extract CXX flags

  string(REGEX MATCH "FILE[ ]+=[^\n]*\n" MATLAB_CXX_MEXOPTS ${CXX_MEX_RESULT})

  if("${MATLAB_CXX_MEXOPTS}" STREQUAL "")
    set(MATLAB_NEW_MEXOPTS "TRUE")
    string(REGEX MATCH "Options file[ ]*:[^\n]*\n" MATLAB_CXX_MEXOPTS ${CXX_MEX_RESULT})
    if("${MATLAB_CXX_MEXOPTS}" STREQUAL "")
      set(MATLAB_FOUND 0)
      return()
    endif()
    string(REGEX REPLACE "Options file[ ]*:[ ]*" "" MATLAB_CXX_MEXOPTS ${MATLAB_CXX_MEXOPTS})
    string(REGEX MATCH "Options file[ ]*:[^\n]*\n" MATLAB_C_MEXOPTS ${C_MEX_RESULT})
    string(REGEX REPLACE "Options file[ ]*:[ ]*" "" MATLAB_C_MEXOPTS ${MATLAB_C_MEXOPTS})
    string(REGEX MATCH "MATLABROOT[ ]+:[^\n]*\n" MATLAB_ROOT ${CXX_MEX_RESULT})
    string(REGEX REPLACE "MATLABROOT[ ]+:[ ]*" "" MATLAB_ROOT ${MATLAB_ROOT})
  else()
    set(MATLAB_NEW_MEXOPTS "FALSE")
    string(REGEX REPLACE "FILE[ ]+=[ ]*" "" MATLAB_CXX_MEXOPTS ${MATLAB_CXX_MEXOPTS})
    set(MATLAB_C_MEXOPTS ${MATLAB_CXX_MEXOPTS})
    string(REGEX MATCH "MATLAB[ ]+=[^\n]*\n" MATLAB_ROOT ${CXX_MEX_RESULT})
    string(REGEX REPLACE "MATLAB[ ]+=[ ]*" "" MATLAB_ROOT ${MATLAB_ROOT})
  endif()

  string(REGEX REPLACE "\n" "" MATLAB_CXX_MEXOPTS ${MATLAB_CXX_MEXOPTS})
  string(REGEX REPLACE "\n" "" MATLAB_C_MEXOPTS ${MATLAB_C_MEXOPTS})
  string(REGEX REPLACE "\n" "" MATLAB_ROOT ${MATLAB_ROOT})

  string(REGEX MATCH "CXX[ \t]+[:=][^\n]*\n" MATLAB_CXX_COMPILER ${CXX_MEX_RESULT})
  string(REGEX REPLACE "CXX[ \t]+[:=][ ]*" "" MATLAB_CXX_COMPILER ${MATLAB_CXX_COMPILER})
  string(REGEX REPLACE "\n" "" MATLAB_CXX_COMPILER ${MATLAB_CXX_COMPILER})

  string(FIND ${CMAKE_CXX_COMPILER} ${MATLAB_CXX_COMPILER} COMPILER_RESULT REVERSE)
  if (${COMPILER_RESULT} MATCHES -1)
    #message(WARNING "${CMAKE_CXX_COMPILER} might not be compatible with the current Matlab version. Please run cmake with -DCMAKE_CXX_COMPILER=${MATLAB_CXX_COMPILER}")
  endif()

  string(REGEX MATCH "CXXFLAGS[ \t]+[:=][^\n]*\n" MATLAB_CXX_FLAGS ${CXX_MEX_RESULT})
  string(REGEX REPLACE "CXXFLAGS[ \t]+[:=][ \t]*" "" MATLAB_CXX_FLAGS ${MATLAB_CXX_FLAGS})
  string(REGEX REPLACE "\n" "" MATLAB_CXX_FLAGS ${MATLAB_CXX_FLAGS}) 

  string(REGEX MATCH "CXXDEBUGFLAGS[ \t]+[:=][^\n]*\n" MATLAB_CXX_FLAGS_DEBUG ${CXX_MEX_RESULT})
  string(REGEX REPLACE "CXXDEBUGFLAGS[ \t]+[:=][ \t]*" "" MATLAB_CXX_FLAGS_DEBUG ${MATLAB_CXX_FLAGS_DEBUG})
  string(REGEX REPLACE "\n" "" MATLAB_CXX_FLAGS_DEBUG ${MATLAB_CXX_FLAGS_DEBUG})

  string(REGEX MATCH "CXXOPTIMFLAGS[ \t]+[:=][^\n]*\n" MATLAB_CXX_FLAGS_RELEASE ${CXX_MEX_RESULT})
  string(REGEX REPLACE "CXXOPTIMFLAGS[ \t]+[:=][ \t]*" "" MATLAB_CXX_FLAGS_RELEASE ${MATLAB_CXX_FLAGS_RELEASE})
  string(REGEX REPLACE "\n" "" MATLAB_CXX_FLAGS_RELEASE ${MATLAB_CXX_FLAGS_RELEASE})

  if(MATLAB_NEW_MEXOPTS)
    string(REGEX MATCH "LINKLIBS[ \t]+:[^\n]*" MATLAB_LINKER_FLAGS ${CXX_MEX_RESULT})
    string(REGEX REPLACE "LINKLIBS[ \t]+:[ \t]*" "" MATLAB_LINKER_FLAGS ${MATLAB_LINKER_FLAGS})
  else()
    string(REGEX MATCH "CXXLIBS[ \t]+=[^\n]*\n" MATLAB_LINKER_FLAGS ${CXX_MEX_RESULT})
    string(REGEX REPLACE "CXXLIBS[ \t]+=[ \t]*" "" MATLAB_LINKER_FLAGS ${MATLAB_LINKER_FLAGS})
  endif()
  string(REGEX REPLACE "\n" "" MATLAB_LINKER_FLAGS ${MATLAB_LINKER_FLAGS})

  string(REGEX MATCHALL "[ ]+[-][l]([^ ;])+" MATLAB_LIBRARIES ${MATLAB_LINKER_FLAGS})
  string(REGEX REPLACE "[ ]+[-][l]([^ ;])+" "" MATLAB_LINKER_FLAGS ${MATLAB_LINKER_FLAGS})
  string(REGEX REPLACE "^[ ]*-l" "" MATLAB_LIBRARIES ${MATLAB_LIBRARIES})
  string(REGEX REPLACE "[ ]*-l" ";" MATLAB_LIBRARIES ${MATLAB_LIBRARIES})

  string(REGEX MATCHALL "[-][L]([^ ;])+" MATLAB_LIB_DIR ${MATLAB_LINKER_FLAGS})
  string(REGEX REPLACE "[-][L]([^ ;])+" "" MATLAB_LINKER_FLAGS ${MATLAB_LINKER_FLAGS})
  string(REGEX REPLACE "^[ ]*-L" "" MATLAB_LIB_DIR ${MATLAB_LIB_DIR})
  string(REGEX REPLACE "[ ]*-L" ";" MATLAB_LIB_DIR ${MATLAB_LIB_DIR})
  string(REGEX REPLACE "[\"]" "" MATLAB_LIB_DIR ${MATLAB_LIB_DIR})

  if(MATLAB_NEW_MEXOPTS)
    string(REGEX MATCH "DEFINES[ \t]+[:=][^\n]*\n" MATLAB_DEFINITIONS ${CXX_MEX_RESULT})
    string(REGEX REPLACE "DEFINES[ \t]+[:=][ ]*" "" MATLAB_DEFINITIONS ${MATLAB_DEFINITIONS})
  else()
    string(REGEX MATCH "arguments[ \t]+[:=][^\n]*\n" MATLAB_DEFINITIONS ${CXX_MEX_RESULT})
    string(REGEX REPLACE "arguments[ \t]+[:=][ ]*" "" MATLAB_DEFINITIONS ${MATLAB_DEFINITIONS})
    set(MATLAB_DEFINITIONS "-DMATLAB_MEX_FILE ${MATLAB_DEFINITIONS}")
  endif()
  string(REGEX REPLACE "\n" "" MATLAB_DEFINITIONS ${MATLAB_DEFINITIONS})
  

  foreach(MATLAB_LIBRARY ${MATLAB_LIBRARIES})
    if(IS_ABSOLUTE ${MATLAB_LIBRARY})
      set(MATLAB_${MATLAB_LIBRARY}_LIB ${MATLAB_LIBRARY})
    else(IS_ABSOLUTE ${MATLAB_LIBRARY})
      #message(STATUS "Looking for ${MATLAB_LIBRARY} in ${MATLAB_LIB_DIR}")
      string(TOUPPER ${MATLAB_LIBRARY} MATLAB_LIBRARY_NAME)
      find_library(MATLAB_${MATLAB_LIBRARY_NAME}_LIBRARY ${MATLAB_LIBRARY} HINTS ${MATLAB_LIB_DIR})
      #message(STATUS "${MATLAB_LIBRARY} found in ${MATLAB_${MATLAB_LIBRARY_NAME}_LIBRARY}")
      ##message(STATUS "MATLAB_LIBRARIES=${MATLAB_LIBRARIES}")
    endif(IS_ABSOLUTE ${MATLAB_LIBRARY})
  endforeach(MATLAB_LIBRARY)

  if(MATLAB_NEW_MEXOPTS)
    string(REGEX MATCH "LDEXT[ \t]+[:=][^\n]*\n" MATLAB_MEX_EXT ${CXX_MEX_RESULT})
    string(REGEX REPLACE "LDEXT[ \t]+[:=][ ]*" "" MATLAB_MEX_EXT ${MATLAB_MEX_EXT})
  else()
    string(REGEX MATCH "LDEXTENSION[ \t]+[:=][^\n]*\n" MATLAB_MEX_EXT ${CXX_MEX_RESULT})
    string(REGEX REPLACE "LDEXTENSION[ \t]+[:=][ ]*" "" MATLAB_MEX_EXT ${MATLAB_MEX_EXT})
  endif()
  string(REGEX REPLACE "\n" "" MATLAB_MEX_EXT ${MATLAB_MEX_EXT})

  find_path (MATLAB_INCLUDE_DIRS
      NAMES         mex.h
      HINTS         "${MATLAB_ROOT}/extern/include"
      DOC           "Include directory for MATLAB libraries."
      NO_DEFAULT_PATH
  )

  find_path (SIMULINK_INCLUDE_DIRS
      NAMES         simstruc.h
      HINTS         "${MATLAB_ROOT}"
      PATH_SUFFIXES "/simulink/include" "/extern/include"
      DOC           "Include directory for Simulink libraries."
      NO_DEFAULT_PATH
  )


  ## Extract CC flags

  string(REGEX MATCH "CC[ \t]+[:=][^\n]*\n" MATLAB_C_COMPILER ${C_MEX_RESULT})
  string(REGEX REPLACE "CC[ \t]+[:=][ ]*" "" MATLAB_C_COMPILER ${MATLAB_C_COMPILER})
  string(REGEX REPLACE "\n" "" MATLAB_C_COMPILER ${MATLAB_C_COMPILER})

  string(FIND ${CMAKE_C_COMPILER} ${MATLAB_C_COMPILER} COMPILER_RESULT REVERSE)
  if (${COMPILER_RESULT} MATCHES -1)
    #message(WARNING "${CMAKE_C_COMPILER} might not be compatible with the current Matlab version. Please run cmake with -DCMAKE_C_COMPILER=${MATLAB_C_COMPILER}")
  endif()

  string(REGEX MATCH "CFLAGS[ \t]+[:=][^\n]*\n" MATLAB_C_FLAGS ${C_MEX_RESULT})
  string(REGEX REPLACE "CFLAGS[ \t]+[:=][ ]*" "" MATLAB_C_FLAGS ${MATLAB_C_FLAGS})
  string(REGEX REPLACE "\n" "" MATLAB_C_FLAGS ${MATLAB_C_FLAGS}) 

  string(REGEX MATCH "CDEBUGFLAGS[ \t]+[:=][^\n]*\n" MATLAB_C_FLAGS_DEBUG ${C_MEX_RESULT})
  string(REGEX REPLACE "CDEBUGFLAGS[ \t]+[:=][ ]*" "" MATLAB_C_FLAGS_DEBUG ${MATLAB_C_FLAGS_DEBUG})
  string(REGEX REPLACE "\n" "" MATLAB_C_FLAGS_DEBUG ${MATLAB_C_FLAGS_DEBUG})

  string(REGEX MATCH "COPTIMFLAGS[ \t]+[:=][^\n]*\n" MATLAB_C_FLAGS_RELEASE ${C_MEX_RESULT})
  string(REGEX REPLACE "COPTIMFLAGS[ \t]+[:=][ ]*" "" MATLAB_C_FLAGS_RELEASE ${MATLAB_C_FLAGS_RELEASE})
  string(REGEX REPLACE "\n" "" MATLAB_C_FLAGS_RELEASE ${MATLAB_C_FLAGS_RELEASE})



  #string(REGEX MATCH "CLIBS[]+[:=][^\n]*\n" MATLAB_C_LINK_FLAGS ${C_MEX_RESULT})
  #string(REGEX REPLACE "CLIBS[]+[:=][ ]*" "" MATLAB_C_LINK_FLAGS ${MATLAB_C_LINK_FLAGS})
  #string(REGEX REPLACE "\n" "" MATLAB_C_LINK_FLAGS ${MATLAB_C_LINK_FLAGS})

  #string(REGEX MATCHALL "[ ]+[-][l]([^ ;])+" MATLAB_LIBRARIES ${MATLAB_C_LINK_FLAGS})
  #string(REGEX REPLACE "[ ]+[-][l]([^ ;])+" "" MATLAB_C_LINK_FLAGS ${MATLAB_C_LINK_FLAGS})
  #string(REGEX REPLACE "^[ ]*-l" "" MATLAB_LIBRARIES ${MATLAB_LIBRARIES})
  #string(REGEX REPLACE "[ ]*-l" ";" MATLAB_LIBRARIES ${MATLAB_LIBRARIES})

  #string(REGEX MATCHALL "[-][L]([^ ;])+" MATLAB_LIB_DIR ${MATLAB_C_LINK_FLAGS})
  #string(REGEX REPLACE "[-][L]([^ ;])+" "" MATLAB_C_LINK_FLAGS ${MATLAB_C_LINK_FLAGS})
  #string(REGEX REPLACE "^[ ]*-L" "" MATLAB_LIB_DIR ${MATLAB_LIB_DIR})
  #string(REGEX REPLACE "[ ]*-L" ";" MATLAB_LIB_DIR ${MATLAB_LIB_DIR})

  #string(REGEX MATCH "arguments[]+[:=][^\n]*\n" MATLAB_C_DEFINITIONS ${C_MEX_RESULT})
  #string(REGEX REPLACE "arguments[]+[:=][ ]*" "" MATLAB_C_DEFINITIONS ${MATLAB_C_DEFINITIONS})
  #string(REGEX REPLACE "\n" "" MATLAB_C_DEFINITIONS ${MATLAB_C_DEFINITIONS})
  #set(MATLAB_C_DEFINITIONS "-DMATLAB_MEX_FILE ${MATLAB_C_DEFINITIONS}")

  #foreach(MATLAB_LIBRARY ${MATLAB_LIBRARIES})
  #  if(IS_ABSOLUTE ${MATLAB_LIBRARY})
  #    set(MATLAB_${MATLAB_LIBRARY}_LIB ${MATLAB_LIBRARY})
  #  else(IS_ABSOLUTE ${MATLAB_LIBRARY})
  #    #message(STATUS "Looking for ${MATLAB_LIBRARY}")
  #    string(TOUPPER ${MATLAB_LIBRARY} MATLAB_LIBRARY_NAME)
  #    find_library(MATLAB_${MATLAB_LIBRARY_NAME}_LIBRARY ${MATLAB_LIBRARY} HINTS ${MATLAB_LIB_DIR})
  #    #message(STATUS "${MATLAB_LIBRARY} found in ${MATLAB_${MATLAB_LIBRARY_NAME}_LIBRARY}")
  #  endif(IS_ABSOLUTE ${MATLAB_LIBRARY})
  #endforeach(MATLAB_LIBRARY)



  
  ##message(STATUS "MATLAB_ROOT = ${MATLAB_ROOT}\n\n")
  
  #message(STATUS "C++ section")
  #message(STATUS "Using file ${MATLAB_CXX_MEXOPTS} to configure Matlab C++ compilation")
  #message(STATUS "MATLAB_CXX_COMPILER = ${MATLAB_CXX_COMPILER}")
  #message(STATUS "MATLAB_CXX_FLAGS = ${MATLAB_CXX_FLAGS}")
  #message(STATUS "MATLAB_CXX_FLAGS_DEBUG = ${MATLAB_CXX_FLAGS_DEBUG}")
  #message(STATUS "MATLAB_CXX_FLAGS_RELEASE = ${MATLAB_CXX_FLAGS_RELEASE}\n\n")
  
  #message(STATUS "C section")
  #message(STATUS "Using file ${MATLAB_C_MEXOPTS} to configure Matlab C compilation")
  #message(STATUS "MATLAB_C_COMPILER = ${MATLAB_C_COMPILER}")
  #message(STATUS "MATLAB_C_FLAGS = ${MATLAB_C_FLAGS}")
  #message(STATUS "MATLAB_C_FLAGS_DEBUG = ${MATLAB_C_FLAGS_DEBUG}")
  #message(STATUS "MATLAB_C_FLAGS_RELEASE = ${MATLAB_C_FLAGS_RELEASE}\n\n")

  #message(STATUS "Common link section")
  #message(STATUS "MATLAB_LINKER_FLAGS = ${MATLAB_LINKER_FLAGS}")
  #message(STATUS "MATLAB_LIBRARIES = ${MATLAB_LIBRARIES}")
  #message(STATUS "MATLAB_LIB_DIR = ${MATLAB_LIB_DIR}")
  #message(STATUS "MATLAB_MEX_EXT = ${MATLAB_MEX_EXT}\n\n")

  #message(STATUS "Common definitions")
  #message(STATUS "MATLAB_DEFINITIONS = ${MATLAB_DEFINITIONS}")
  #message(STATUS "MATLAB_INCLUDE_DIRS = ${MATLAB_INCLUDE_DIRS}")
  #message(STATUS "SIMULINK_INCLUDE_DIRS = ${SIMULINK_INCLUDE_DIRS}\n\n")


endif()


if(MATLAB_INCLUDE_DIRS AND MATLAB_LIBRARIES)
  set(MATLAB_FOUND 1)
endif()

