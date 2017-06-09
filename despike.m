% Replace outliers
% Input: raw - vector of numbers
% Output: c - vector with outliers replaced with mean of neighbors

function c = despike(raw)
% find outliers
NUM_STD = 2; % outlier threshold
cutoff = mean(raw) + NUM_STD*std(raw); 
cutoff_low = mean(raw) - NUM_STD*std(raw); % outlier threshold
isoutlier = raw>cutoff | raw<cutoff_low;
outlier_pos = find(isoutlier);

% replace outliers
c = raw;
for i = 1:sum(isoutlier)
    if outlier_pos(i)==1
        % first value
        c(outlier_pos(i)) = c(outlier_pos(i)+1);
    elseif outlier_pos(i)==length(c)
        % last value
        c(outlier_pos(i)) = c(outlier_pos(i)-1);
    else
        % somewhere in between
        c(outlier_pos(i)) = mean([c(outlier_pos(i)-1), c(outlier_pos(i)+1)]);
    end
end

% % compare raw and corrected data
% figure
% subplot(1,2,1);
% plot(raw);
% hline = refline([0 cutoff]);
% hline_low = refline([0 cutoff_low]);
% title(sprintf('Raw \n(green line = mean + 2*std for raw)'))
% 
% subplot(1,2,2)
% plot(c);
% hline2 = refline([0 cutoff]);
% hline2_low = refline([0 cutoff_low]);
% title(sprintf('Corrected \n(green line = mean + 2*std for raw)'))
% 
% refcolor = 'g';
% hline.Color = refcolor;
% hline_low.Color = refcolor;
% hline2.Color = refcolor;
% hline2_low.Color = refcolor;

end
