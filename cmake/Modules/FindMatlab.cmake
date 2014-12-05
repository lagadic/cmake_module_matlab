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
 #   MATLAB_MEXOPTS: mexopts file used to configure Matlab
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
 # Note: mex executable must be in your system path or you need to define
 #  MATLAB_DIR to be the path of your MATLAB installation
 ####################################################################


set(MATLAB_FOUND 0)

if(WIN32)
  message(FATAL "Windows is not supported")
else()

  if(NOT MATLAB_DIR)
    set(MATLAB_DIR $ENV{MATLAB_DIR} CACHE PATH "Installation prefix for Matlab." FORCE)
  endif()

#  if(${MATLAB_DIR} STREQUAL "")
  if(NOT MATLAB_DIR)
    execute_process(COMMAND mex -v 2> /dev/null OUTPUT_VARIABLE MEX_RESULT)
  else()
    execute_process(COMMAND ${MATLAB_DIR}/bin/mex -v 2> /dev/null OUTPUT_VARIABLE MEX_RESULT)
  endif()

  #message(STATUS "MEX_RESULT=${MEX_RESULT}")


  ## Extract CXX flags

  string(REGEX MATCH "FILE[ ]+=[^\n]*\n" MATLAB_MEXOPTS ${MEX_RESULT})
  string(REGEX REPLACE "FILE[ ]+=[ ]*" "" MATLAB_MEXOPTS ${MATLAB_MEXOPTS})
  string(REGEX REPLACE "\n" "" MATLAB_MEXOPTS ${MATLAB_MEXOPTS})

  string(REGEX MATCH "MATLAB[ ]+=[^\n]*\n" MATLAB_ROOT ${MEX_RESULT})
  string(REGEX REPLACE "MATLAB[ ]+=[ ]*" "" MATLAB_ROOT ${MATLAB_ROOT})
  string(REGEX REPLACE "\n" "" MATLAB_ROOT ${MATLAB_ROOT})

  string(REGEX MATCH "CXX[ ]+=[^\n]*\n" MATLAB_CXX_COMPILER ${MEX_RESULT})
  string(REGEX REPLACE "CXX[ ]+=[ ]*" "" MATLAB_CXX_COMPILER ${MATLAB_CXX_COMPILER})
  string(REGEX REPLACE "\n" "" MATLAB_CXX_COMPILER ${MATLAB_CXX_COMPILER})

  string(FIND ${CMAKE_CXX_COMPILER} ${MATLAB_CXX_COMPILER} COMPILER_RESULT REVERSE)
  if (${COMPILER_RESULT} MATCHES -1)
    message(WARNING "Please run cmake with -DCMAKE_CXX_COMPILER=${MATLAB_CXX_COMPILER}")
  endif()

  string(REGEX MATCH "CXXFLAGS[ ]+=[^\n]*\n" MATLAB_CXX_FLAGS ${MEX_RESULT})
  string(REGEX REPLACE "CXXFLAGS[ ]+=[ ]*" "" MATLAB_CXX_FLAGS ${MATLAB_CXX_FLAGS})
  string(REGEX REPLACE "\n" "" MATLAB_CXX_FLAGS ${MATLAB_CXX_FLAGS}) 

  string(REGEX MATCH "CXXDEBUGFLAGS[ ]+=[^\n]*\n" MATLAB_CXX_FLAGS_DEBUG ${MEX_RESULT})
  string(REGEX REPLACE "CXXDEBUGFLAGS[ ]+=[ ]*" "" MATLAB_CXX_FLAGS_DEBUG ${MATLAB_CXX_FLAGS_DEBUG})
  string(REGEX REPLACE "\n" "" MATLAB_CXX_FLAGS_DEBUG ${MATLAB_CXX_FLAGS_DEBUG})

  string(REGEX MATCH "CXXOPTIMFLAGS[ ]+=[^\n]*\n" MATLAB_CXX_FLAGS_RELEASE ${MEX_RESULT})
  string(REGEX REPLACE "CXXOPTIMFLAGS[ ]+=[ ]*" "" MATLAB_CXX_FLAGS_RELEASE ${MATLAB_CXX_FLAGS_RELEASE})
  string(REGEX REPLACE "\n" "" MATLAB_CXX_FLAGS_RELEASE ${MATLAB_CXX_FLAGS_RELEASE})

  string(REGEX MATCH "CXXLIBS[ ]+=[^\n]*\n" MATLAB_LINKER_FLAGS ${MEX_RESULT})
  string(REGEX REPLACE "CXXLIBS[ ]+=[ ]*" "" MATLAB_LINKER_FLAGS ${MATLAB_LINKER_FLAGS})
  string(REGEX REPLACE "\n" "" MATLAB_LINKER_FLAGS ${MATLAB_LINKER_FLAGS})

  string(REGEX MATCHALL "[ ]+[-][l]([^ ;])+" MATLAB_LIBRARIES ${MATLAB_LINKER_FLAGS})
  string(REGEX REPLACE "[ ]+[-][l]([^ ;])+" "" MATLAB_LINKER_FLAGS ${MATLAB_LINKER_FLAGS})
  string(REGEX REPLACE "^[ ]*-l" "" MATLAB_LIBRARIES ${MATLAB_LIBRARIES})
  string(REGEX REPLACE "[ ]*-l" ";" MATLAB_LIBRARIES ${MATLAB_LIBRARIES})

  string(REGEX MATCHALL "[-][L]([^ ;])+" MATLAB_LIB_DIR ${MATLAB_LINKER_FLAGS})
  string(REGEX REPLACE "[-][L]([^ ;])+" "" MATLAB_LINKER_FLAGS ${MATLAB_LINKER_FLAGS})
  string(REGEX REPLACE "^[ ]*-L" "" MATLAB_LIB_DIR ${MATLAB_LIB_DIR})
  string(REGEX REPLACE "[ ]*-L" ";" MATLAB_LIB_DIR ${MATLAB_LIB_DIR})

  string(REGEX MATCH "arguments[ ]+=[^\n]*\n" MATLAB_DEFINITIONS ${MEX_RESULT})
  string(REGEX REPLACE "arguments[ ]+=[ ]*" "" MATLAB_DEFINITIONS ${MATLAB_DEFINITIONS})
  string(REGEX REPLACE "\n" "" MATLAB_DEFINITIONS ${MATLAB_DEFINITIONS})
  set(MATLAB_DEFINITIONS "-DMATLAB_MEX_FILE ${MATLAB_DEFINITIONS}")

  foreach(MATLAB_LIBRARY ${MATLAB_LIBRARIES})
    if(IS_ABSOLUTE ${MATLAB_LIBRARY})
      set(MATLAB_${MATLAB_LIBRARY}_LIB ${MATLAB_LIBRARY})
    else(IS_ABSOLUTE ${MATLAB_LIBRARY})
      #message(STATUS "Looking for ${MATLAB_LIBRARY}")
      string(TOUPPER ${MATLAB_LIBRARY} MATLAB_LIBRARY_NAME)
      find_library(MATLAB_${MATLAB_LIBRARY_NAME}_LIBRARY ${MATLAB_LIBRARY} HINTS ${MATLAB_LIB_DIR})
      #message(STATUS "${MATLAB_LIBRARY} found in ${MATLAB_${MATLAB_LIBRARY_NAME}_LIBRARY}")
      #message(STATUS "MATLAB_LIBRARIES=${MATLAB_LIBRARIES}")
    endif(IS_ABSOLUTE ${MATLAB_LIBRARY})
  endforeach(MATLAB_LIBRARY)


  string(REGEX MATCH "LDEXTENSION[ ]+=[^\n]*\n" MATLAB_MEX_EXT ${MEX_RESULT})
  string(REGEX REPLACE "LDEXTENSION[ ]+=[ ]*" "" MATLAB_MEX_EXT ${MATLAB_MEX_EXT})
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

  string(REGEX MATCH "CC[ ]+=[^\n]*\n" MATLAB_C_COMPILER ${MEX_RESULT})
  string(REGEX REPLACE "CC[ ]+=[ ]*" "" MATLAB_C_COMPILER ${MATLAB_C_COMPILER})
  string(REGEX REPLACE "\n" "" MATLAB_C_COMPILER ${MATLAB_C_COMPILER})

  string(FIND ${CMAKE_C_COMPILER} ${MATLAB_C_COMPILER} COMPILER_RESULT REVERSE)
  if (${COMPILER_RESULT} MATCHES -1)
    message(WARNING "Please run cmake with -DCMAKE_C_COMPILER=${MATLAB_C_COMPILER}")
  endif()

  string(REGEX MATCH "CFLAGS[ ]+=[^\n]*\n" MATLAB_C_FLAGS ${MEX_RESULT})
  string(REGEX REPLACE "CFLAGS[ ]+=[ ]*" "" MATLAB_C_FLAGS ${MATLAB_C_FLAGS})
  string(REGEX REPLACE "\n" "" MATLAB_C_FLAGS ${MATLAB_C_FLAGS}) 

  string(REGEX MATCH "CDEBUGFLAGS[ ]+=[^\n]*\n" MATLAB_C_FLAGS_DEBUG ${MEX_RESULT})
  string(REGEX REPLACE "CDEBUGFLAGS[ ]+=[ ]*" "" MATLAB_C_FLAGS_DEBUG ${MATLAB_C_FLAGS_DEBUG})
  string(REGEX REPLACE "\n" "" MATLAB_C_FLAGS_DEBUG ${MATLAB_C_FLAGS_DEBUG})

  string(REGEX MATCH "COPTIMFLAGS[ ]+=[^\n]*\n" MATLAB_C_FLAGS_RELEASE ${MEX_RESULT})
  string(REGEX REPLACE "COPTIMFLAGS[ ]+=[ ]*" "" MATLAB_C_FLAGS_RELEASE ${MATLAB_C_FLAGS_RELEASE})
  string(REGEX REPLACE "\n" "" MATLAB_C_FLAGS_RELEASE ${MATLAB_C_FLAGS_RELEASE})

  #string(REGEX MATCH "CLIBS[ ]+=[^\n]*\n" MATLAB_C_LINK_FLAGS ${MEX_RESULT})
  #string(REGEX REPLACE "CLIBS[ ]+=[ ]*" "" MATLAB_C_LINK_FLAGS ${MATLAB_C_LINK_FLAGS})
  #string(REGEX REPLACE "\n" "" MATLAB_C_LINK_FLAGS ${MATLAB_C_LINK_FLAGS})

  #string(REGEX MATCHALL "[ ]+[-][l]([^ ;])+" MATLAB_LIBRARIES ${MATLAB_C_LINK_FLAGS})
  #string(REGEX REPLACE "[ ]+[-][l]([^ ;])+" "" MATLAB_C_LINK_FLAGS ${MATLAB_C_LINK_FLAGS})
  #string(REGEX REPLACE "^[ ]*-l" "" MATLAB_LIBRARIES ${MATLAB_LIBRARIES})
  #string(REGEX REPLACE "[ ]*-l" ";" MATLAB_LIBRARIES ${MATLAB_LIBRARIES})

  #string(REGEX MATCHALL "[-][L]([^ ;])+" MATLAB_LIB_DIR ${MATLAB_C_LINK_FLAGS})
  #string(REGEX REPLACE "[-][L]([^ ;])+" "" MATLAB_C_LINK_FLAGS ${MATLAB_C_LINK_FLAGS})
  #string(REGEX REPLACE "^[ ]*-L" "" MATLAB_LIB_DIR ${MATLAB_LIB_DIR})
  #string(REGEX REPLACE "[ ]*-L" ";" MATLAB_LIB_DIR ${MATLAB_LIB_DIR})

  #string(REGEX MATCH "arguments[ ]+=[^\n]*\n" MATLAB_C_DEFINITIONS ${MEX_RESULT})
  #string(REGEX REPLACE "arguments[ ]+=[ ]*" "" MATLAB_C_DEFINITIONS ${MATLAB_C_DEFINITIONS})
  #string(REGEX REPLACE "\n" "" MATLAB_C_DEFINITIONS ${MATLAB_C_DEFINITIONS})
  #set(MATLAB_C_DEFINITIONS "-DMATLAB_MEX_FILE ${MATLAB_C_DEFINITIONS}")

  #foreach(MATLAB_LIBRARY ${MATLAB_LIBRARIES})
  #  if(IS_ABSOLUTE ${MATLAB_LIBRARY})
  #    set(MATLAB_${MATLAB_LIBRARY}_LIB ${MATLAB_LIBRARY})
  #  else(IS_ABSOLUTE ${MATLAB_LIBRARY})
  #    message(STATUS "Looking for ${MATLAB_LIBRARY}")
  #    string(TOUPPER ${MATLAB_LIBRARY} MATLAB_LIBRARY_NAME)
  #    find_library(MATLAB_${MATLAB_LIBRARY_NAME}_LIBRARY ${MATLAB_LIBRARY} HINTS ${MATLAB_LIB_DIR})
  #    message(STATUS "${MATLAB_LIBRARY} found in ${MATLAB_${MATLAB_LIBRARY_NAME}_LIBRARY}")
  #  endif(IS_ABSOLUTE ${MATLAB_LIBRARY})
  #endforeach(MATLAB_LIBRARY)


  #message(STATUS "Using file ${MATLAB_MEXOPTS} to configure Matlab")
  #message(STATUS "MATLAB_ROOT=${MATLAB_ROOT}")




  #message(STATUS "Using file ${MATLAB_MEXOPTS} to configure Matlab")
  #message(STATUS "MATLAB_ROOT=${MATLAB_ROOT}")
  
  #message(STATUS "\n\nC++ section")
  #message(STATUS "MATLAB_CXX_COMPILER=${MATLAB_CXX_COMPILER}")
  #message(STATUS "MATLAB_CXX_FLAGS=${MATLAB_CXX_FLAGS}")
  #message(STATUS "MATLAB_CXX_FLAGS_DEBUG=${MATLAB_CXX_FLAGS_DEBUG}")
  #message(STATUS "MATLAB_CXX_FLAGS_RELEASE=${MATLAB_CXX_FLAGS_RELEASE}")
  
  #message(STATUS "\n\nC section")
  #message(STATUS "MATLAB_C_COMPILER=${MATLAB_C_COMPILER}")
  #message(STATUS "MATLAB_C_FLAGS=${MATLAB_C_FLAGS}")
  #message(STATUS "MATLAB_C_FLAGS_DEBUG=${MATLAB_C_FLAGS_DEBUG}")
  #message(STATUS "MATLAB_C_FLAGS_RELEASE=${MATLAB_C_FLAGS_RELEASE}")

  #message(STATUS "\n\nCommond link section")
  #message(STATUS "MATLAB_LINKER_FLAGS=${MATLAB_LINKER_FLAGS}")
  #message(STATUS "MATLAB_LIBRARIES=${MATLAB_LIBRARIES}")
  #message(STATUS "MATLAB_LIB_DIR=${MATLAB_LIB_DIR}")
  #message(STATUS "MATLAB_MEX_EXT=${MATLAB_MEX_EXT}")

  #message(STATUS "\n\nCommond definitions")
  #message(STATUS "MATLAB_DEFINITIONS=${MATLAB_DEFINITIONS}")
  #message(STATUS "MATLAB_INCLUDE_DIRS = ${MATLAB_INCLUDE_DIRS}")
  #message(STATUS "SIMULINK_INCLUDE_DIRS = ${SIMULINK_INCLUDE_DIRS}") 
  #message(STATUS "MATLAB_DEFINITIONS = ${MATLAB_DEFINITIONS}")


endif()


if(MATLAB_INCLUDE_DIRS AND MATLAB_LIBRARIES)
  set(MATLAB_FOUND 1)
endif()

