%%%%%%% testOCTsvm.m %%%%%%%
% Goal: Analyze Reissner's displacement in one user-selected image
%
% Output:
%   D - Reissner's membrane displacement (px)
%   SMarea - scala media area (px^2) 
%
% Last edit: 6/9/2017
%
% Dependencies: analyzeOCTslice.m

display('Select the TIF image you want to analyze:')
[file_name,folder_name,~] = uigetfile('*.tif*');
I = imread(fullfile(folder_name, file_name));
[D, SMarea] = analyzeOCTslice(I);
display(D)
display(SMarea)