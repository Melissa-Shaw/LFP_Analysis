function [freq_LFP] = freq_filter_LFP(LFP,freq_bounds,base_cond) % freq_bounds = [8 32] for beta or [55 90] for gamma
    
    % Filter signal to extract frequency
    freq_LFP = leaveFrequencies(LFP.raw, 1e3, freq_bounds(1), freq_bounds(2)); % bandpass-filter frequency of interest, sampling rate at 1e3 for 1kHz

    % remove saturations
    [freq_LFP] = remove_saturations(freq_LFP,LFP.sat_idx);
    
    % standardise data by z-score
    [freq_LFP] = standardise_data(freq_LFP);
    
    % calculate the power
    freq_LFP = freq_LFP(1:floor(numel(freq_LFP)/1e3)*1e3); % trim to a length thats a multiple of 1000
    freq_LFP = reshape(freq_LFP(:),1e3,[]); 
    freq_LFP = sum(freq_LFP.^2); % sum the squared values at 1Hz resolution
    
    % normalise the power by pre-baseline
    freq_LFP = freq_LFP/nanmean(freq_LFP(LFP.cond_timepoints(base_cond):LFP.cond_timepoints(base_cond+1))); 

    % smooth the data across each minute
    gaus = gausswin(60)/sum(gausswin(60)); % guassian filter
    freq_LFP = nanconv(freq_LFP,gaus'); % convolution with gaussian filter
    
end