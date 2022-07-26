
function [con_PFC,tcb_PFC,con_V1,tcb_V1,Adaptation1,Adaptation2,Adaptation3] = find_grouped_exp(db)

single_probe_tcb = {'No injection' 'TCB-2' 'End'};
single_probe_con = {'No injection' 'Quinine' 'End'};
dual_probe = {'baselinepre' 'ViStimpre' 'drinking' 'baselinepost' 'ViStimpost' 'End'};
adaptation = {'baselinepre' 'drinking' 'baselinepost' 'End'};

con_PFC = [];
tcb_PFC = [];
con_V1 = [];
tcb_V1 = [];
all_adapt = [];
Adaptation1 = [];
Adaptation2 = [];
Adaptation3 = [];

for exp=48:numel(db)
  if strcmp(db(exp).animal,'M200826_B_BD') && strcmp(db(exp).date,'220920') && strcmp(db(exp).location,'V1')
    disp(['Animal: ' db(exp).animal ' Date: ' db(exp).date ' Exp: ' num2str(exp) ' Excluded']);
  elseif strcmp(db(exp).animal,'M200826_B_BD') && strcmp(db(exp).date,'220920') && strcmp(db(exp).location,'PFC')
    all_adapt = [all_adapt exp];
  elseif strcmp(db(exp).animal,'M191023_A_BD') && strcmp(db(exp).date,'191119')
    tcb_PFC = [tcb_PFC exp];
  else
    [match] = check_cells(db(exp).injection,single_probe_con);
    if match == true
      con_PFC = [con_PFC exp];
    else
      [match] = check_cells(db(exp).injection,single_probe_tcb);
      if match == true
        tcb_PFC = [tcb_PFC exp];
      else
        [match] = check_cells(db(exp).injection,dual_probe);
        if match == true
          if strcmp(db(exp).location,'PFC')
            if startsWith(db(exp).syringe_contents,'CONTROL')
              con_PFC = [con_PFC exp];
            elseif startsWith(db(exp).syringe_contents,'TCB-2')
              tcb_PFC = [tcb_PFC exp];
            end
          elseif strcmp(db(exp).location,'V1')
            if startsWith(db(exp).syringe_contents,'CONTROL')
              con_V1 = [con_V1 exp];
            elseif startsWith(db(exp).syringe_contents,'TCB-2')
              tcb_V1 = [tcb_V1 exp];
            end
          end
        else
          [match] = check_cells(db(exp).injection,adaptation);
          if match == true
            all_adapt = [all_adapt exp];
          end
        end
      end
    end
  end
end

animals = {};
for exp=all_adapt
  animals = [animals db(exp).animal];
end
animals = unique(animals);
count = 0;
%a=1;
for a=1:numel(animals)
  for exp=all_adapt
    if strcmp(db(exp).animal,animals(a)) && count == 0
      Adaptation1 = [Adaptation1 exp];
      count = 1;
    elseif strcmp(db(exp).animal,animals(a)) && count == 1
      Adaptation2 = [Adaptation2 exp];
      count = 2;
    elseif strcmp(db(exp).animal,animals(a)) && count == 2
      Adaptation3 = [Adaptation3 exp];
      count = 0;
    end
  end
end


%% LOCAL FUNCTIONS

%[match] = check_cells(db(62).injection,dual_probe);

function [match] = check_cells(strA,strB)
  match = false;
  if numel(strA) == numel(strB)
    matches = strcmp(strA,strB);
    if sum(matches)==numel(strA)
      match = true;
    end
  end
end

end