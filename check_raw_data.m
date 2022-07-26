function check_raw_data(shared_drive,db,exp,iCh)

[spikestruct] = load_spikestruct(shared_drive,db,exp);

% extract LFP
LFP = spikestruct.LFP{iCh};

% find saturations
[low_cut_off,up_cut_off] = manual_saturation(db);

if ~isnan(low_cut_off(exp)) | ~isnan(up_cut_off) 
  disp(['Exp ' num2str(exp) ' - using manual saturation marking']);
  up_sat_idx = find(LFP > up_cut_off(exp));
  low_sat_idx = find(LFP < low_cut_off(exp));
  sat_idx = [low_sat_idx up_sat_idx];
  sat_idx = unique(sat_idx);
else
  [sat_idx] = find_saturations(LFP,15);
end

% plot saturations
nexttile
plot(LFP);
hold on
plot(sat_idx,LFP(sat_idx),'ro');
title(['Exp: ' num2str(exp) ' ' db(exp).animal ' ' db(exp).date]);

% remove saturations
[LFP_nosat] = remove_saturations(LFP,sat_idx);

% plot LFP with saturations removed
nexttile
plot(LFP_nosat);
title(['Exp: ' num2str(exp) ' ' db(exp).animal ' ' db(exp).date],'Interpreter','none');

end