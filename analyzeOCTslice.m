%%%%%%% analyzeOCTslice.m %%%%%%%
% Goal: Analyze an OCT image slice to detect RM displacement and SM area
% Input: I - cropped OCT image slice
% Output: D - measured Reissner's membrane displacement
%         SMarea - area of scala media
%
% Last edit: 6/16/2016
%
% Dependencies: findScalaMediaB.m, flattenMaskOverlay.m, findRM.m

function [D, SMarea] = analyzeOCTslice(I)
    
TURNONFIGURES = true;

% find scala media
[numObj, mask, SMcentroid] = findScalaMediaB(I);

% analyze segmentation
if numObj==1 || numObj==2
    SMcoord = round(SMcentroid);
    maskSM_raw = mask==mask(SMcoord(2),SMcoord(1)); % mask of SM only
    SMarea = sum(maskSM_raw(:));

    % morphologically dilate, fill, and erode SM mask to fill spurious holes in edges
    se = strel('square', 3);
    BW2 = imdilate(maskSM_raw,se); 
    BW3 = imfill(BW2, 'holes');
    BW4 = imerode(BW3, se);
    % open mask to remove wrong border components
    maskSM = imopen(BW4, se);
    CCmaskSM = bwconncomp(maskSM);
    if CCmaskSM.NumObjects > 1 % keep largest connected component only
        numPixels = cellfun(@numel,CCmaskSM.PixelIdxList);
        [~,idx] = max(numPixels);
        maskSM = false(size(maskSM));
        maskSM(CCmaskSM.PixelIdxList{idx}) = true;
    end

    % display final SM segmentation
    SMoverlay = flattenMaskOverlay(I, maskSM, 0.2, 'g'); 
    if TURNONFIGURES
        figure, imshow(SMoverlay, 'InitialMag', 'fit')
        title('Scala media')
        figure, imshow(maskSM, 'InitialMag', 'fit'), title('Scala media post-processed')
    end

    % find points on Reissner's membrane and calculate RM displacement. 
    D = findRM(I, maskSM, 'left', TURNONFIGURES);

    % Ensure outputs are real numbers or NaN
    if isnan(D) || isnan(SMarea)
        D = NaN;
        SMarea = NaN;
    end

else
    display('Decision - outputting NaN variables: SMarea, D')
    SMarea = NaN;
    D = NaN;
end

end