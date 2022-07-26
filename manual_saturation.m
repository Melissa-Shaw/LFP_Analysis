
function [low_cut_off,up_cut_off] = manual_saturation(db)

low_cut_off = nan; % manual cut off point is nan unless specified
up_cut_off = nan;

% PFC
if strcmp(db.animal,'M191023_A_BD') 
  if strcmp(db.date,'131119')
    low_cut_off = -1000; % M191023_A_BD - arbituray lower bound (not needed)
    up_cut_off = 300;
  end
elseif strcmp(db.animal,'M200312_A_BD') 
  if strcmp(db.date,'270320') 
    if strcmp(db.location,'PFC')
      low_cut_off = -100; % M200312_A_BD
      up_cut_off = 120;
    elseif strcmp(db.location,'V1')
      low_cut_off = -200; % M200312_A_BD
      up_cut_off = 200;
    end
  end
elseif strcmp(db.animal,'M201008_C_BD')
  if strcmp(db.date,'211020') 
    if strcmp(db.location,'PFC')
      low_cut_off = -50; % M201008_C_BD
      up_cut_off = 50;
    end
  elseif strcmp(db.date,'031120') 
    low_cut_off = -100; % M201008_C_BD
    up_cut_off = 100;
  elseif strcmp(db.date,'041120') 
    low_cut_off = -100; % M201008_C_BD
    up_cut_off = 100;
  elseif strcmp(db.date,'051120') 
    low_cut_off = -100; % M201008_C_BD
    up_cut_off = 100;
  end
elseif strcmp(db.animal,'M201008_B_BD')
  if strcmp(db.date,'080920') 
    if strcmp(db.location,'PFC')
      low_cut_off = -200; % M201008_B_BD
      up_cut_off = 200;
    end
  elseif strcmp(db.date,'101120') 
    low_cut_off = -200; % M201008_B_BD
    up_cut_off = 200;
  elseif strcmp(db.date,'111120') 
    low_cut_off = -150; % M201008_B_BD
    up_cut_off = 100;
  elseif strcmp(db.date,'121120') 
    low_cut_off = -100; % M201008_B_BD
    up_cut_off = 50;
  end
% V1
elseif strcmp(db.animal,'M201008_A_BD')
  if strcmp(db.date,'271020') 
    if strcmp(db.location,'V1')
      low_cut_off = -300; % M201008_A_BD
      up_cut_off = 300;
    end
  elseif strcmp(db.date,'281020') 
    if strcmp(db.location,'V1')
      low_cut_off = -250; % M201008_A_BD
      up_cut_off = 250;
    end
  end
elseif strcmp(db.animal,'M200826_B_BD') 
  if strcmp(db.date,'080920') 
    if strcmp(db.location,'V1')
      low_cut_off = -250; % M200826_B_BD
      up_cut_off = 200;
    end
  end
% Anaesthesia  
elseif strcmp(db.animal,'M210316_MS')
  if strcmp(db.date,'160321')
    low_cut_off = -150;
    up_cut_off = 150;
  end
elseif strcmp(db.animal,'M210319_MS')
  if strcmp(db.date,'190321')
    low_cut_off = -180;
    up_cut_off = 150;
  end
elseif strcmp(db.animal,'M210826_MS')
    if strcmp(db.date,'260821')
        if strcmp(db.location,'PFC')
            low_cut_off = -300;
            up_cut_off = 300;
        end
    end
elseif strcmp(db.animal,'M210907_MS')
    if strcmp(db.date,'070921')
        if strcmp(db.location,'PFC')
            low_cut_off = -200;
            up_cut_off = 200;
        end
    end
elseif strcmp(db.animal,'M220117_B_MS')
    if strcmp(db.date,'110222')
        if strcmp(db.location,'PFC')
            low_cut_off = -150;
            up_cut_off = 150;
        end
    end
end

  
  
end
