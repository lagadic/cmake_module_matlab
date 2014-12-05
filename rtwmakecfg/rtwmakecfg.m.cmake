 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %
 % Software License Agreement (BSD License)
 %
 % Copyright (c) 2014-2015, Inria
 % All rights reserved.
 %
 % Redistribution and use in source and binary forms, with or without
 % modification, are permitted provided that the following conditions
 % are met:
 %
 %  * Redistributions of source code must retain the above copyright
 %    notice, this list of conditions and the following disclaimer.
 %  * Redistributions in binary form must reproduce the above
 %    copyright notice, this list of conditions and the following
 %    disclaimer in the documentation and/or other materials provided
 %    with the distribution.
 %  * Neither the name of the copyright holder nor the names of its
 %    contributors may be used to endorse or promote products derived
 %    from this software without specific prior written permission.
 %
 % THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 % "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 % LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
 % FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
 % COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 % INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 % BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 % LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 % CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 % LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 % ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 % POSSIBILITY OF SUCH DAMAGE.
 %
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function makeInfo = rtwmakecfg() 
% RTWMAKECFG Add include and source directories to 
% Simulink Coder make files. 
% makeInfo = RTWMAKECFG returns a structured array containing 
% following fields: 
% makeInfo.includePath - cell array containing additional include 
% directories. Those directories will be expanded into include 
% instructions of Simulink Coder generated make files. 
% makeInfo.sourcePath - cell array containing additional source 
% directories. Those directories will be expanded into rules of 
% Simulink Coder generated make files. 
% makeInfo.library - structure containing additional runtime library 
% names and module objects. This information will be expanded into 
% rules of generated make files. 
% ... .library(1).Name - name of runtime library 
% ... .library(1).Modules - cell array containing source file names 
% for the runtime library 
% ... .library(2).Name 
% ... .library(2).Modules 
% This RTWMAKECFG file must be located in the same directory as the 
% related S-Function MEX-DLL(s). If one or more S-Functions of the 
% directory are referenced by a model Simulink Coder will evaluate 
% RTWMAKECFG to obtain the additional include and source directories. 
% To examine more RTWMAKECFG files in your installation issue at the 
% MATLAB prompt: 
% >> which RTWMAKECFG -all 
% Issue a message. 

makeInfo = lct_rtwmakecfg();

% Setting up the return structure with 
% - source directories:
% makeInfo.sourcePath = { ... 
% '/home/rspica/matlab/quick_test/src/' ... 
% };
makeInfo.sourcePath = { ... 
@MAKE_INFO_SOURCE_PATH@ ... 
};

% - include directories
makeInfo.includePath = { ... 
@MAKE_INFO_INCLUDE_PATH@ ... 
};

makeInfo.linkLibsObjs = { ... 
@MAKE_INFO_LINK_LIBS_OBJS@ ... 
};

 
