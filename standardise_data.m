
function [standardised_Array] = standardise_data(dataArray)

  M = nanmean(dataArray);
  SD = nanstd(dataArray);
  standardised_Array = (dataArray-M)./SD;

end


