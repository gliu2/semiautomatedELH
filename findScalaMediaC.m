%%%%%%% findScalaMediaC.m %%%%%%%
% Goal: Find scala media and svala vestibuli in OCT image slice.
% Input: I - raw grayscale, cropped image
% Output:   numCC - number of compartments segmented
%           L2 - labeled matrix of segmented compartments
%           centroid_SM - 1x2 vector [x,y] of scala media centroid coordinate
%
% Last edit: 6/9/2017
%
% Dependencies: smartthresh.m

function BWnew = findScalaMediaC(I)

TURNONFIGURES = false;
CUTOFFSIZE_SCALA = 200; % smallest size of scala media and vestibuli [px]
SIZEMAX = 750; % largest size of scala media
THRESHFACTOR = 1.3; % control mice
% THRESHFACTOR = 1.5; % blast mice
    

% Pre-process with opening by reconstruction to remove signal noise
se = strel('disk', 3);
Ie = imerode(I, se);
Iobr = imreconstruct(Ie, I);
% figure
% imshow(Iobr,'InitialMagnification','fit'), title('Opening-by-reconstruction (Iobr)')
    
% get CC vs. seg threshold curve to re-optimize segmentation
MAXDISTBETWCC = 8;
priorT = graythresh(Iobr)/THRESHFACTOR;
thr = priorT + linspace(0,0.4,41)-0.2; % threshold values [0 1]
cc_t = zeros(length(thr),1);
for j=1:length(thr)
    BWnew_t = smartthresh(Iobr, thr(j));

    % get final number of CC at threshold t(j)
    CC2_t = bwconncomp(BWnew_t,8);
    numCC_t = CC2_t.NumObjects;
    % if 2 objects are far apart, say there are 3 objects
    if numCC_t == 2
        pixels_t = regionprops(CC2_t,'PixelList');
        D = pdist2(pixels_t(1).PixelList,pixels_t(2).PixelList,'euclidean');
        d_t = min(D(:)); % minimum distance among all pairwise d between 2 CC
        if d_t > MAXDISTBETWCC;
            numCC_t = 4;
        end
    end
    % if 1 object, check area criterion
    if numCC_t == 1
        pixelidxlist = CC2_t.PixelIdxList;
        ccsize = numel(pixelidxlist);
        if ccsize < CUTOFFSIZE_SCALA || ccsize > SIZEMAX
            numCC_t = 3;
        end
    end
    cc_t(j) = numCC_t;

%         % display thresholding if it gives 2 cc 
%         if numCC_t ==2
%             figure, imagesc(BWnew_t)
%             title(['T = ', num2str(t(j))])
%         end
end
%     figure, plot(t, cc_t)
% end
% find and display best threshold value for distinguishing SM and SV
bestT = thr(find(cc_t==2, 1, 'last')); % largest value of t that distinguishes SM and SV
if isempty(bestT)
    bestT = thr(find(cc_t==1, 1, 'last')); % segment SM only on try 2
end
    
if isempty(bestT)
    display('Cannot segment: no threshold to separate SM and SV found')
    if TURNONFIGURES
        figure, plot(thr, cc_t), title('Error: cannot separate scala media and scala vestibuli')
        xlabel('Threshold value')
        ylabel('Number of connected components')
    end
    BWnew = [];
    
else
    bestBWnew = smartthresh(Iobr, bestT);
    if TURNONFIGURES
        figure, imagesc(bestBWnew)
        title(['Try 2, T = ', num2str(bestT)])
    end
    
    BWnew = bestBWnew; % pretend this is the originally segmented good BW
    
end

end