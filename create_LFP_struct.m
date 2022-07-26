function [LFP] = create_LFP_struct(db,spikestruct,params) % db input is singular (db(exp))

iCh = params.iCh;
region = params.region;
is_dual = params.is_dual;


% extract and stitch raw LFP
if is_dual == false % no dualprobestruct
  LFPdata = spikestruct.LFP{iCh};
else
  LFPdata = [];
  if strcmp(region,'PFC')
    for c = 1:size(spikestruct.PFCLFPcond,2)
      LFPdata = [LFPdata spikestruct.PFCLFPcond{iCh,c}];
    end
  elseif strcmp(region,'V1')
    for c = 1:size(spikestruct.V1LFPcond,2)
      LFPdata = [LFPdata spikestruct.V1LFPcond{iCh,c}];
    end
  end
end

% extract key info
%LFP.exp = exp;
if isfield(spikestruct,'animal')
  LFP.animal = spikestruct.animal;
  LFP.date = spikestruct.date;
end
if isfield(spikestruct,'meta')
  LFP.animal = spikestruct.meta.animal;
  LFP.date = spikestruct.meta.date;
end
LFP.chan = db.lfp(iCh);
LFP.dose = db.dose;
LFP.gain = db.LFPgain;

LFP.cond_timepoints = round(spikestruct.timepoints/1000); % cond timepoints in seconds
if LFP.cond_timepoints(1) < 1 % correct for rounding error
  LFP.cond_timepoints(1) = 1;
end
        
% Extract raw LFP
LFP.raw = LFPdata;

% Find saturations
[low_cut_off,up_cut_off] = manual_saturation(db);

if ~isnan(low_cut_off) | ~isnan(up_cut_off) 
  disp('Using manual saturation marking');
  up_sat_idx = find(LFP.raw > up_cut_off);
  low_sat_idx = find(LFP.raw < low_cut_off);
  sat_idx = [low_sat_idx up_sat_idx];
  LFP.sat_idx = unique(sat_idx);
else
  [LFP.sat_idx] = find_saturations(LFP.raw,15);
end

 % Remove saturations
[LFP.raw_nosat] = remove_saturations(LFP.raw,LFP.sat_idx);

% Normalise the LFP (z-score)
[LFP.raw_nosat] = standardise_data(LFP.raw_nosat);

% Create spectogram (up to 100Hz)
x = LFP.raw_nosat;
x(isnan(x)) = 0;
s = abs(spectrogram(x, hamming(1e3), 0, 0:1:135, 1e3)); % the output is often complex so we take abs
s(:, max(1, unique(floor(find(isnan(LFP.raw_nosat))/1e3)))) = NaN;
s(:, min(size(s, 2), unique(ceil(find(isnan(LFP.raw_nosat))/1e3)))) = NaN;
LFP.specgram = s; % s is 2D matrix of 101  frequencies (0:1:100) and 1Hz resolution

% Create placeholder variables
LFP.aligned_cond_timepoints = [];

end