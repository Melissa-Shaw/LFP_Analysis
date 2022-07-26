%% Load and Analyse LFP
addpath('X:\cortical_dynamics\User\ms1121\Code');
run('makedb_TCB2_MS');
AwakePFC = [Batch1PFC Batch2PFC Batch3PFC]; % Batch1PFC spikestructs not on shared drive

% Set parameters
freq_bounds = [8 32]; % freq_bounds = [8 32] for beta or [55 90] for gamma
params.region = 'PFC';
params.iCh = 3; % iCh = 3 for channel 150 for PFC
params.is_dual = false;
gap = 2*60; % leave gap of 2 mins before end of condition
section = 5*60; % extract data over period of 5 mins
smth = 250;

% Find LFP
i = 1;
control_rec = [];
for exp = [Batch1PFC Batch2PFC]
    % check exclusions
    if strcmp(db(exp).animal,'M200312_B_BD')   %== 66 || exp == 68
        disp(['Animal: ' db(exp).animal ' Exp: ' num2str(exp) ' excluded']);
    else
        % Find control and tcb2 recordings
        [iscontrol] = find_drinking_contents(db,exp);
        control_rec = [control_rec iscontrol];
        if iscontrol == true
            cond_letter = 'C';
        else
            cond_letter = 'T';
        end
        
        % Load spikestruct
        if is_dual == false 
            if exp < min(Batch3PFC)
                spikestruct_idx = find(AwakePFC == exp);
                topDir = 'X:\cortical_dynamics\Shared\Npx\Dino\';
                spikestruct_filepath = [topDir 'spikestruct' num2str(spikestruct_idx) '.mat'];
                load(spikestruct_filepath);
            else
                [spikestruct] = load_spikestruct('X:',db,exp);
            end
        end
        
        % Create LFP struct wih raw LFP
        [indvLFP] = create_LFP_struct(db(exp),spikestruct,params);
        disp(['LFP Exp: ' num2str(exp) ' Complete']) % progress report
        LFP(i) = indvLFP;
    
        % Find conditions of interest
        base_cond = db(exp).cond(1);
        post_cond = db(exp).cond(2);
        COI(i,:) = [base_cond post_cond];
        
        % Reset workspace
        i = i+1;
        clear indvLFP spikestruct base_cond post_cond cond_letter iscontrol
    end
end
control_rec = logical(control_rec);

% Find frequency power
for i = 1:numel(LFP)
    [freq_LFP] = freq_filter_LFP(LFP(i),freq_bounds,COI(i,1));
    LFP(i).freq_bounds = freq_bounds;
    LFP(i).freq_power = freq_LFP;
    clear freq_LFP
end

% Find aligned frequency power
align_cond = COI(:,2)-1; % align by start of drinking condition
[LFP,align_point] = align_and_trim(LFP,align_cond);

%% Split LFP and freq power by condition
for i = 1:numel(LFP)
    [LFP_cond] = extract_section_reverse(LFP(i).raw_nosat,LFP(i).cond_timepoints.*1000,gap*1000,section*1000,COI(i,:)); % raw data is at 1kHz
    LFP(i).raw_nosat_cond = LFP_cond;
    [specgram_cond] = extract_section_reverse(LFP(i).specgram,LFP(i).cond_timepoints,gap,section,COI(i,:)); % specgram data is at 1Hz
    LFP(i).specgram_cond = specgram_cond;
    [freqpower_cond] = extract_section_reverse(LFP(i).freq_power,LFP(i).cond_timepoints,gap,section,COI(i,:)); % power data is at 1Hz
    LFP(i).freq_power_cond = freqpower_cond;

    clear LFP_cond freqpower_cond specgram_cond
end

% Split control and tcb2 recordings
%conLFP = LFP(control_rec);
%tcbLFP = LFP(~control_rec);

% Plot spectogram
for i = 1:numel(LFP)
    base(i).specgram = LFP(i).specgram_cond{1};
    post(i).specgram = LFP(i).specgram_cond{2};
end
figure
hold on
[h1] = plot_LFP_psd(cat(3, base(control_rec).specgram), cat(3, post(control_rec).specgram), 'k'); % saline
[h2] = plot_LFP_psd(cat(3, base(~control_rec).specgram), cat(3, post(~control_rec).specgram), 'r'); % tcb2
xlim([3.5 129])
hold on, plot(xlim, [1 1], '--', 'Color', 0.5*[1 1 1])
xlabel('Frequency (Hz)')
ylabel('PSD ratio (post/pre)')
h = [h1 h2];
legend(h, 'Control', 'TCB-2','location','southeast')
set(gca, 'XScale', 'log')
set(gca, 'XTick', 2.^(2:7))

%% Plot frequency power
figure
t = tiledlayout('flow');
title(t, ['Freq: ' num2str(freq_bounds(1)) ' - ' num2str(freq_bounds(2)) ' Hz']);

nexttile % plots individual recordings with mean
plot_freq(LFP(control_rec),align_point,'k',smth);
hold on
plot_freq(LFP(~control_rec),align_point,'r',smth);
box off

nexttile % plots mean with standard deviation in shaded region
[~,powermat] = find_mean_freq(LFP(control_rec));
stdshade(powermat,0.4,'k',smth,-align_point+1:size(powermat,2)-align_point);
hold on
[~,powermat] = find_mean_freq(LFP(~control_rec));
stdshade(powermat,0.4,'r',smth,-align_point+1:size(powermat,2)-align_point);
hold off
xline(0, '-b','LineWidth',1);
ylabel('Frequency Power');
xlabel('Time (s)')
box off

nexttile % plots boxplot of perc change
for i = 1:numel(LFP)
    base_power = nanmean(LFP(i).freq_power_cond{1});
    cond_power = nanmean(LFP(i).freq_power_cond{2});
    perc_change(i) = ((cond_power - base_power)./base_power)*100;
end
perc_change = [perc_change(control_rec)' perc_change(~control_rec)'];
boxplot(perc_change,'Color','k','Symbol',''); 
h = findobj(gca,'Tag','Box');
fill_color = [1 0 0; 0 0 0];
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),fill_color(j,:),'FaceAlpha',.25,'EdgeColor',fill_color(j,:),'LineWidth',2);
end
hold on  
x_val = ones(size(perc_change,1),1);
marker_colours = {'k','r'};
for c = 1:size(perc_change,2)
    plot(x_val,perc_change(:,c),'o','MarkerFaceColor',marker_colours{c});
    x_val = x_val+1;
end
hold off
box off
ylabel(['\Delta Freq Power (%)']);
set(gca,'XTickLabel',{'Control' 'TCB-2'});
[~,p1] = ttest(perc_change(:,1),perc_change(:,2)); % control vs tcb2
title(['p = ' num2str(round(p1,2))]);

nexttile % plots boxplot of post power only
for i = 1:numel(LFP)
    cond_power(i) = nanmean(LFP(i).freq_power_cond{2});
end
cond_power = [cond_power(control_rec)' cond_power(~control_rec)'];
boxplot(cond_power,'Color','k','Symbol',''); 
h = findobj(gca,'Tag','Box');
fill_color = [1 0 0; 0 0 0];
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),fill_color(j,:),'FaceAlpha',.25,'EdgeColor',fill_color(j,:),'LineWidth',2);
end
hold on  
x_val = ones(size(cond_power,1),1);
marker_colours = {'k','r'};
for c = 1:size(cond_power,2)
    plot(x_val,cond_power(:,c),'o','MarkerFaceColor',marker_colours{c});
    x_val = x_val+1;
end
hold off
box off
ylabel('Post Freq Power');
set(gca,'XTickLabel',{'Control' 'TCB-2'});
[~,p1] = ttest(cond_power(:,1),cond_power(:,2)); % control vs tcb2
title(['p = ' num2str(round(p1,2))]);


