%%%%%%% checkSMsegmentation.m %%%%%%%
% Goal: Find scala media and svala vestibuli in OCT image slice.
% Input: I - raw grayscale, cropped image
%        BW - segmentation of SM and/or SV
% Output:   numCC - number of compartments segmented
%           L2 - labeled matrix of segmented compartments
%           centroid_SM - 1x2 vector [x,y] of scala media centroid coordinate
%
% Last edit: 6/13/2016
%
% Dependencies: none

function [numCC, L2, centroid_SM] = checkSMsegmentation(I, BWnew)

TURNONFIGURES = false;

% display all medium connected components
L2 = bwlabel(BWnew,4);
if TURNONFIGURES
    figure, imagesc(L2)
    title('L2')
    figure, imshow(BWnew, 'InitialMag', 'fit'), title('L2')
end

CC2 = bwconncomp(BWnew,4);
numCC = CC2.NumObjects;

% Identify SM using an approach that varies with number of components in mask
if numCC==0
    display('Detected 0 connected components.')
    centroid_SM = [];
    
elseif numCC==1
    display('Detected 1 connected component.')
    stats = regionprops(BWnew,'Centroid','Extrema');
    color_one = 'green'; % scala media is green
    centroid_SM = stats.Centroid;
    RGB_CC = insertMarker(I,centroid_SM,'*','color',color_one,'size',1);
    if TURNONFIGURES
%         figure, imshow(RGB_CC,'InitialMagnification','fit'), title('Centroid')
    end
    
    isSM = 1;
    
elseif numCC==2 % Clean segmentation: keep only scala media and scala vestibuli
    display('Detected 2 connected components.')
    % larger of two is scala vestibuli
%     if numel(find(L2==1)) > numel(find(L2==2))
%         scalaVestibuli_is1=true;
%     else
%         scalaVestibuli_is1=false;
%     end

    % obtain centroids
    CC2 = bwconncomp(BWnew,4);
    stats = regionprops(CC2,'Centroid','Extrema');
    [centroid1, centroid2] = stats.Centroid;
%     if scalaVestibuli_is1
    if centroid2(1) > centroid1(1)
        color_two = {'red','green'}; % scala vestibuli is red; scala media is green
        isSM = 2;
        centroid_SM = centroid2;
    else
        color_two = {'green','red'};
        isSM = 1;
        centroid_SM = centroid1;
    end
    if TURNONFIGURES
        RGB_CC = insertMarker(I,[centroid1; centroid2],'*','color',color_two,'size',1);
%         figure, imshow(RGB_CC,'InitialMagnification','fit'), title('Centroids')
    end
    
else
    display('More than 2 connected components detected.')
    centroid_SM = [];

end

% final checks for segmentation
if ~isempty(centroid_SM)
    
    % ensure centroid is in mask
    pixelsSM = CC2.PixelIdxList{isSM}; 
    SMval = L2(pixelsSM(1));
    if SMval~=L2(round(centroid_SM(2)),round(centroid_SM(1))) % centroid is outside SM mask
        [row, col] = ind2sub(size(L2), pixelsSM(round(end/2)));
        centroid_SM = [col, row];
    end
    
%     % ensure segmented scala media is away from left edge of image
%     SEARCHWIDTH = 7;
%     SMcoord = round(centroid_SM);
%     maskSM_raw = L2==L2(SMcoord(2),SMcoord(1)); % mask of SM only
%     % morphologically dilate, fill, and erode SM mask to fill spurious holes in edges
%     se = strel('square', 3);
%     BW2 = imdilate(maskSM_raw,se); 
%     BW3 = imfill(BW2, 'holes');
%     maskSM = imerode(BW3, se);
%     if find(sum(maskSM,1),1) <= SEARCHWIDTH % scala media is too close to left edge; return NaN
%         numCC = NaN;
%         L2 = NaN;
%         centroid_SM = NaN;
%     end

end


end