function [M,powerMat] = find_mean_freq(LFP)
    powerMat = [];
    for i = 1:numel(LFP)
      LFPpower = LFP(i).freq_power_align;
      powerMat = [powerMat; LFPpower];
    end
    M = nanmean(powerMat,1);
end