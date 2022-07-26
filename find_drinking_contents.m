function [control] = find_drinking_contents(db,exp)  
    control = true;
    for i = 1:numel(db(exp).injection)
        if strcmp(db(exp).injection{i},'TCB-2')
            control = false;
        end
    end
    if startsWith(db(exp).syringe_contents,'TCB-2')
        control = false;
    end
end