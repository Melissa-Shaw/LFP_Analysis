function [sat_idx] = find_saturations(rawLFP,pct_margin)

  LFPdata = rawLFP;

  [~,edges]=histcounts(LFPdata);

  min_value = edges(1);
  max_value = edges(end);

  excl_margin = (pct_margin/100)*range(LFPdata);

  sat_idx = find(LFPdata<=min_value+excl_margin | LFPdata>=max_value-excl_margin);

end