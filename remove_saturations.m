function [rawLFP] = remove_saturations(rawLFP,sat_idx)
  ms_timepoints = round(sat_idx,0);
  timepoint_range = [];
  sec_after = 0;
  for point = 1:numel(ms_timepoints)
    if ms_timepoints(point) < sec_after
      sec_before = sec_after+1;
      sec_after = ms_timepoints(point)+1000;
      sec_range = [sec_before:sec_after];
      timepoint_range = [timepoint_range sec_range];
    else
      sec_before = ms_timepoints(point)-1000;
      sec_after = ms_timepoints(point)+1000;
      sec_range = [sec_before:sec_after];
      timepoint_range = [timepoint_range sec_range];
    end
  end
  timepoint_range(timepoint_range <= 0)=1;
  timepoint_range = unique(timepoint_range);

  rawLFP(timepoint_range)=NaN; % timepoints in ms for 1kHz
end