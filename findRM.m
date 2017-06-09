%%%%%%% findRM.m %%%%%%%
% Goal: Find Reissner's membrane from segmentation of scala media or scala vestibuli
% Input: I - cropped OCT image slice
%        mask - mask of scala media or scala vestibuli
%        direction - string of 'left' or 'right' for where RM is to search
% Output: 
%         D - calculated displacement of RM
%
% %         RM - nx2 matrix of [y, x] for coordinates of Reissner's membrane
% %         BWrm - mask of RM
%
% Last edit: 6/17/2016
%
% Dependencies: flattenMaskOverlay.m, despike.m, perpd.m

function D = findRM(I, mask, direction, TURNONFIGURES)

% TURNONFIGURES = false;
SEARCHWIDTH = 7;

if find(sum(mask,1),1)>SEARCHWIDTH % mask of SM is away from left edge of image
    SMyrange = find(sum(mask,2)); % range of y-coordinates in SM
    N = length(SMyrange);
    RM = zeros(N,2);
    BWrm = zeros(size(I));
    for i = 1:N
        y = SMyrange(i);
        if strcmp(direction, 'right')
            SMrightx = find(mask(y, :),1,'last');
            [~, index] = max(I(y,SMrightx:SMrightx+SEARCHWIDTH));
            x = index + SMrightx - 1;
        else % default
            SMleftx = find(mask(y, :),1,'first');
            [~, index] = max(I(y,SMleftx-SEARCHWIDTH:SMleftx));
            x = index + SMleftx - SEARCHWIDTH - 1;
            % display warning if invalid direction is input
            if ~strcmp(direction, 'left')
                display('Warning: Specify direction for findRM. Going left')
            end
        end
        RM(i,:) = [y, x];
        BWrm(y, x) = 1;
    end

    RM(:,2) = despike(RM(:,2)); % remove outliers from RM point finding
    % Fix RM: remove end of RM (bottom pts) if suddenly bends to
    % right below RM
    dydx = diff(RM(:,2));
    jumpright = find(dydx > 4);
    if ~isempty(jumpright)
        if jumpright > 15
            RM = RM(1:jumpright-1,:);
            N = size(RM,1); % update N to reflect new length of RM
        end
    end

    % display RM segmentation
    RMoverlay = flattenMaskOverlay(I, logical(BWrm), 1, 'r'); 
    if TURNONFIGURES
        figure, imshow(RMoverlay, 'InitialMag', 'fit')
        title('Reissner''s membrane')
    end

    RMpts = zeros(3,2);
    midy = round(N/2);
    RMpts(1,:) = [round(mean(RM(1:4,2))), RM(2,1)];
    RMpts(2,:) = [round(mean(RM(midy-2:midy+2,2))), RM(midy,1)];
    RMpts(3,:) = [round(mean(RM(end-3:end,2))), RM(end-1,1)];

    % display points on Reissner's membrane
    colorRMfinal = {'cyan','cyan','cyan'};
    SMoverlay = flattenMaskOverlay(I, mask, 0.2, 'g'); 
    RGB = insertMarker(SMoverlay, RMpts, '*','color',colorRMfinal,'size',1); % display just 3 points for curvature
    RGBI = insertMarker(I, RMpts, '*','color',colorRMfinal,'size',1); % display just 3 points for curvature
    if TURNONFIGURES
        figure, imshow(RGB,'InitialMagnification','fit')
        title('Reissner''s membrane and scala media')
        % plot without shading scala media
        figure, imshow(RGBI,'InitialMagnification','fit')
        title('Reissner''s membrane and scala media')
        
        display(RMpts)
    end

    % calculate displacement of RM
    D = perpd(RMpts(:,1),RMpts(:,2));

else % SM segmentation too close to left border. Don't find RM.
    display('Warning: SM to close to left border. Outputting NaN variables: SMarea, D')
    D = NaN;
end