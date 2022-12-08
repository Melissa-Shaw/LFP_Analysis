% specMat - 3D matrix of frequencies X time bins (1 Hz) X recordings
function [h] = plot_LFP_psd(specMatBase,specMatCond, mean_color)
    specMatBase = squeeze(nanmean(specMatBase(:,:,:),2)); % baseline
    specMatCond = squeeze(nanmean(specMatCond(:,:,:),2)); % frequencies by recordings
    
    m = nanmean(specMatCond ./ specMatBase, 2);
    s = nanstd(specMatCond ./ specMatBase, [], 2)./sqrt(size(specMatBase, 2));
    
    g = gausswin(7); g = g/sum(g);
    m = nanconv(m, g, 'same')';
    s = nanconv(s, g, 'same')';
    
    % we start plotting from 0.1 to allow log scale (0 cannot work)
    fill([0.1:1:size(specMatBase, 1)-0.9 size(specMatBase, 1)-0.9:-1:0.1],[m+s fliplr(m-s)], mean_color, 'FaceAlpha', 0.3, 'linestyle', 'none')
    hold on, h = plot(0.1:1:size(specMatBase, 1)-0.9, m, mean_color, 'LineWidth', 2);
end