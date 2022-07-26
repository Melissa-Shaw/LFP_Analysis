% specMat - 3D matrix of frequencies X time bins (1 Hz) X recordings
function [h] = plot_LFP_psd(specMatB,specMatA, mean_color)
    specMatB = squeeze(nanmean(specMatB(:,:,:),2)); % baseline
    specMatA = squeeze(nanmean(specMatA(:,:,:),2)); % frequencies by recordings
    
    m = nanmean(specMatA ./ specMatB, 2);
    s = nanstd(specMatA ./ specMatB, [], 2);
    
    g = gausswin(7); g = g/sum(g);
    m = nanconv(m, g, 'same')';
    s = nanconv(s, g, 'same')'/sqrt(size(specMatB, 2));
    
    % we start plotting from 0.1 to allow log scale (0 cannot work)
    fill([0.1:1:size(specMatB, 1)-0.9 size(specMatB, 1)-0.9:-1:0.1],[m+s fliplr(m-s)], mean_color, 'FaceAlpha', 0.3, 'linestyle', 'none')
    hold on, h = plot(0.1:1:size(specMatB, 1)-0.9, m, mean_color, 'LineWidth', 2);
end