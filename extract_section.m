function [data_cond] = extract_section(data,cond_timepoints,gap,section,COI)
    data_cond = cell(1,numel(COI));
    i = 1;
    for c = COI
        if c > 0
            data_cond{i} = data(:,cond_timepoints(c)+gap:cond_timepoints(c)+gap+section-1);
            if (cond_timepoints(c)+gap+section-1) >= cond_timepoints(c+1)
                disp(['NOTE: Condition: ' num2str(c) ' is too short for the chosen gap and section length.'])
            end
        else
            data_cond{i} = nan(size(data,1),section);
        end
        i = i+1;
    end
end