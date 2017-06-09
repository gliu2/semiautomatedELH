%%%%%%% findScalaMediaB.m %%%%%%%
% Goal: Find scala media and svala vestibuli in OCT image slice.
% Input: I - raw grayscale, cropped image
% Output:   numCC - number of compartments segmented
%           L2 - labeled matrix of segmented compartments
%           centroid_SM - 1x2 vector [x,y] of scala media centroid coordinate
%
% Last edit: 6/13/2016
%
% Dependencies: checkSMsegmentation.m, smartthresh.m, findScalaMediaC.m

function [numCC, L2, centroid_SM] = findScalaMediaB(I)

TURNONFIGURES = false;
CUTOFFSIZE_SCALA = 200; % smallest size of scala media and vestibuli [px]
THRESHFACTOR = 1.3; % control mice
% THRESHFACTOR = 1.5; % blast mice
    
% Pre-process with opening by reconstruction to remove signal noise
se = strel('disk', 3);
Ie = imerode(I, se);
Iobr = imreconstruct(Ie, I);
if TURNONFIGURES
    figure
    imshow(Iobr,'InitialMagnification','fit'), title('Opening-by-reconstruction (Iobr)')
end
    
% Threshold image
T = graythresh(Iobr)/THRESHFACTOR;
BW = ~im2bw(Iobr, T);
% figure, imshow(BW,'InitialMagnification','fit'), title('Threshold (BW)')

% Throw out small segmented blobs
BW2 = bwareaopen(BW, CUTOFFSIZE_SCALA, 4);
if TURNONFIGURES
    figure;
    imshow(BW2,'InitialMagnification','fit'), title('Remove small blobs (BW2)')
end

% display all large connected components
L = bwlabel(BW2,4);
if TURNONFIGURES
    figure, imagesc(L)
    title('L')
end

% remove border CC's, small CC's, and large CC's
BWnew = smartthresh(I, T);

[numCC, L2, centroid_SM] = checkSMsegmentation(I, BWnew);

% Try alternative segmentation method 1 if fail to find scala media
if sum(L2(:))==0
    display(' Try alternative (ladder) segmentation method')
    BWnew2 = findScalaMediaC(I);
    if ~isempty(BWnew2)
        [numCC, L2, centroid_SM] = checkSMsegmentation(I, BWnew2);
    end
end

end