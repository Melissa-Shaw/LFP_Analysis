function [data_cond] = extract_section_reverse(data,cond_timepoints,gap,section,COI)
    data_cond = cell(1,size(COI,2));
    i = 1;
    for c = COI
        if c > 0
            data_cond{1,i} = data(:,cond_timepoints(c+1)-section-gap+1:cond_timepoints(c+1)-gap);
            if (cond_timepoints(c+1)-section-gap+1) <= cond_timepoints(c)
                disp(['NOTE: Condition: ' num2str(c) ' is too short for the chosen gap and section length.'])
            end
        else
            data_cond{1,i} = nan(size(data,1),section);
        end
        i = i+1;
    end
end