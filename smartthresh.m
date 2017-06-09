%%%%%%% smartthresh.m %%%%%%%
% Goal: Threshold and remove small and border connected components
% 
% Input: I - original image
%        thresh - threshold level [0 1]
% Output: BWnew - segmented image
% 5/3/2016
%
% Dependencies: none

function BWnew = smartthresh(I, thresh)

CUTOFFSIZE_SCALA = 200; % smallest size of scala media and vestibuli [px]
SIZEMAX = 750; % largest size of scala media
    
% Pre-process with opening by reconstruction to remove signal noise
se = strel('disk', 3);
Ie = imerode(I, se);
Iobr = imreconstruct(Ie, I);
% figure
% imshow(Iobr,'InitialMagnification','fit'), title('Opening-by-reconstruction (Iobr)')
    
% Threshold image
BW = ~im2bw(Iobr, thresh);
% figure, imshow(BW,'InitialMagnification','fit'), title('Threshold (BW)')

% remove small CC
BW_2 = bwareaopen(BW, CUTOFFSIZE_SCALA, 4); 
CC = bwconncomp(BW_2, 4);

% remove border CC's
BWnew = BW_2;
for i = 1:CC.NumObjects
    cci = CC.PixelIdxList{i};
    [row, col] = ind2sub(size(I),cci);
    % remove cc if it contains a border pixel
    if any(row==1) || any(row==size(I,1)) || any(col==1) || any(col==size(I,2)) 
        BWnew(cci) = 0;
    end
end

% remove remaining super-large CC's
BWnew_withlarge = BWnew;
BWonlylarge = bwareaopen(BWnew_withlarge, SIZEMAX, 4);
BWnew = BWnew_withlarge - BWonlylarge;

end