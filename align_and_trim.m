function [LFP,align_point] = align_and_trim(LFP,align_cond)

  timepoints = NaN(1,numel(LFP));
  length = NaN(1,numel(LFP));

  % Trim start to align according to start of given align_cond
  for i = 1:numel(LFP)
    timepoints(i) = LFP(i).cond_timepoints(align_cond(i));
    LFP(i).align_cond = align_cond(i);
  end
  
  align_point = min(timepoints);
  for i = 1:numel(LFP)
    shift = timepoints(i)-align_point;
    LFP(i).freq_power_align = LFP(i).freq_power(shift+1:end);
    length(i) = numel(LFP(i).freq_power_align);
  end
  
  % Trim end length to shortest recording
  trim_point = min(length);
  for i = 1:numel(LFP)
    LFP(i).freq_power_align = LFP(i).freq_power_align(1:trim_point);
  end
  
end