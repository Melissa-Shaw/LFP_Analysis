%% Load and Analyse LFP
addpath('X:\cortical_dynamics\User\ms1121\Code');
run('makedb_TCB2_MS');

% Set parameters
freq_bounds = [55 90]; % freq_bounds = [8 32] for beta or [55 90] for gamma
params.region = 'PFC';
params.iCh = 3; % iCh = 3 for channel 150 for PFC
params.is_dual = false; % if using shared BD spikestruct then need to load dual_spikestruct on shared drive (not needed for anaes recordings)
gap = 2*60; % leave gap of 2 mins before end of condition
section = 5*60; % extract data over period of 5 mins
smth = 250;

% Find LFP
i = 1;
for exp = AnaesPFC
    
    % exclusions
    if exp ~= 142 && exp ~= 145 % exp 142 excluded for lack of units, exp 145 excluded as animal died
    
    % Load spikestruct
    [spikestruct] = load_spikestruct('X:',db,exp);
    
    % Create LFP struct wih raw LFP
    [indvLFP] = create_LFP_struct(db(exp),spikestruct,params);
    disp(['LFP Exp: ' num2str(exp) ' Complete']) % progress report
    LFP(i) = indvLFP;

    % Find conditions of interest
    base_cond = db(exp).cond(1);
    if exp == 135 && strcmp(db(exp).animal,'M210826_MS')
        disp('NOTE: Exp 135 Manual baseline shift to match alignment.');
        base_cond = 2; % change baseline condition to be previsual condition
    end
    if numel(db(exp).cond)<3
        tcb_cond = db(exp).cond(2);
        tcb_low_cond = 0;
    else
        tcb_cond = db(exp).cond(3);
        tcb_low_cond = db(exp).cond(2);
    end
    [sal_cond] = check_conditions(db(exp).animal,db(exp).date);
    COI(i,:) = [base_cond sal_cond tcb_low_cond tcb_cond];
    
    % Reset workspace
    i = i+1;
    clear indvLFP spikestruct base_cond sal_cond tcb_low_cond tcb_cond
    
    end

end

%%
% Find frequency power
for i = 1:numel(LFP)
    [freq_LFP] = freq_filter_LFP(LFP(i),freq_bounds,COI(i,1));
    LFP(i).freq_bounds = freq_bounds;
    LFP(i).freq_power = freq_LFP;
    if LFP(i).exp == 135 && strcmp(LFP(i).animal,'M210826_MS')
        LFP(i).freq_power(2666:2791) = NaN; % manual exclusion of single saturation
    end
    clear freq_LFP
end

% Find aligned frequency power
align_cond = [COI(COI(:,3)==0,4);COI(COI(:,3)>0,3)]; % align by first tcb injection (e.g. tcb cond if  low tcb not present)
[LFP,align_point] = align_and_trim(LFP,align_cond);

% Split LFP and freq power by condition
for i = 1:numel(LFP)
    [LFP_cond] = extract_section_reverse(LFP(i).raw_nosat,LFP(i).cond_timepoints.*1000,gap*1000,section*1000,COI(i,:)); % raw data is at 1kHz
    LFP(i).raw_nosat_cond = LFP_cond;
    [specgram_cond] = extract_section_reverse(LFP(i).specgram,LFP(i).cond_timepoints,gap,section,COI(i,:)); % specgram data is at 1Hz
    LFP(i).specgram_cond = specgram_cond;
    [freqpower_cond] = extract_section_reverse(LFP(i).freq_power,LFP(i).cond_timepoints,gap,section,COI(i,:)); % power data is at 1Hz
    LFP(i).freq_power_cond = freqpower_cond;

    clear LFP_cond freqpower_cond specgram_cond
end

% Plot spectogram
for i = 1:numel(LFP)
    base(i).specgram = LFP(i).specgram_cond{1};
    sal(i).specgram = LFP(i).specgram_cond{2};
    tcb_low(i).specgram = LFP(i).specgram_cond{3};
    tcb(i).specgram = LFP(i).specgram_cond{4};
end
figure
hold on
if sum(COI(:,2)) > 0
    [h1] = plot_LFP_psd(cat(3, base.specgram), cat(3, sal.specgram), 'k'); % saline
end
if sum(COI(:,3)) > 0
    [h2] = plot_LFP_psd(cat(3, base.specgram), cat(3, tcb_low.specgram), 'b'); % low_tcb2
end
[h3] = plot_LFP_psd(cat(3, base.specgram), cat(3, tcb.specgram), 'r'); % tcb2
xlim([3.5 129])
hold on, plot(xlim, [1 1], '--', 'Color', 0.5*[1 1 1])
xlabel('Frequency (Hz)')
ylabel('PSD ratio (post/pre)')
if sum(COI(:,2)) > 0 && sum(COI(:,3)) > 0
    h = [h1 h2 h3];
    legend(h, 'Control', 'Low TCB-2', 'TCB-2','location','southeast')
end
set(gca, 'XScale', 'log')
set(gca, 'XTick', 2.^(2:7))

%% Plot frequency power
figure
t = tiledlayout('flow');
title(t, ['Freq: ' num2str(freq_bounds(1)) ' - ' num2str(freq_bounds(2)) ' Hz']);

ax1 = nexttile; % plots individual recordings with mean
lowtcb_present = COI(:,3) > 0;
plot_freq(LFP(lowtcb_present),align_point,'b',smth);
xline(900);
box off
%hold on
ax2 = nexttile;
plot_freq(LFP(~lowtcb_present),align_point,'r',smth);
box off

ax3 = nexttile; % plots mean with standard deviation in shaded region
time_array = [(-align_point+1):(numel(LFP(1).freq_power_align)-align_point)];
[~,powermat] = find_mean_freq(LFP(lowtcb_present));
stdshade(powermat,0.4,'b',smth,time_array);
xline(0,'LineWidth',1);
xline(900,'LineWidth',1);
ylabel('Frequency Power');
xlabel('Time (s)')
box off
%hold on
ax4 = nexttile;
[~,powermat] = find_mean_freq(LFP(~lowtcb_present));
stdshade(powermat,0.4,'r',smth,time_array);
xline(0,'LineWidth',1);
ylabel('Frequency Power');
xlabel('Time (s)')
box off

linkaxes([ax1 ax2 ax3 ax4],'y');

nexttile % plots boxplot of perc change
for i = 1:numel(LFP)
    base_power = nanmean(LFP(i).freq_power_cond{1});
    for c = 2:size(COI,2)
        cond_power = nanmean(LFP(i).freq_power_cond{c});
        perc_change(i,c-1) = ((cond_power - base_power)./base_power)*100;
    end
end
boxplot(perc_change,'Color','k','Symbol',''); 
h = findobj(gca,'Tag','Box');
fill_color = [1 0 0; 0 0 1; 0 0 0];
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),fill_color(j,:),'FaceAlpha',.25,'EdgeColor',fill_color(j,:),'LineWidth',2);
end
hold on  
x_val = ones(size(perc_change,1),1);
marker_colours = {'k','b','r'};
for c = 1:size(perc_change,2)
    plot(x_val,perc_change(:,c),'o','MarkerFaceColor',marker_colours{c});
    x_val = x_val+1;
end
hold off
box off
ylabel(['\Delta Freq Power (%)']);
set(gca,'XTickLabel',{'Control' 'lowTCB2' 'TCB-2'});
[~,p1] = ttest(perc_change(~lowtcb_present,1),perc_change(~lowtcb_present,3)); % saline vs tcb2
[~,p2] = ttest(perc_change(lowtcb_present,2),perc_change(lowtcb_present,3)); % tcblow vs tcb2
[~,p3] = ttest2(perc_change(~lowtcb_present,1),perc_change(lowtcb_present,2)); % saline vs tcblow
title('P values:');
subtitle(['salVtcb2 = ' num2str(round(p1,2)) ' tcblowVtcb2 = ' num2str(round(p2,2)) ' salVtcblow = ' num2str(round(p3,2))]);


nexttile % plots boxplot of post power only
for i = 1:numel(LFP)
    for c = 2:size(COI,2)
        cond_power(i,c-1) = nanmean(LFP(i).freq_power_cond{c});
    end
end
boxplot(cond_power,'Color','k','Symbol',''); 
h = findobj(gca,'Tag','Box');
fill_color = [1 0 0; 0 0 1; 0 0 0];
for j=1:length(h)
    patch(get(h(j),'XData'),get(h(j),'YData'),fill_color(j,:),'FaceAlpha',.25,'EdgeColor',fill_color(j,:),'LineWidth',2);
end
hold on  
x_val = ones(size(cond_power,1),1);
marker_colours = {'k','b','r'};
for c = 1:size(cond_power,2)
    plot(x_val,cond_power(:,c),'o','MarkerFaceColor',marker_colours{c});
    x_val = x_val+1;
end
hold off
box off
ylabel('Post Freq Power');
set(gca,'XTickLabel',{'Control' 'lowTCB2' 'TCB-2'});
[~,p1] = ttest(cond_power(~lowtcb_present,1),cond_power(~lowtcb_present,3)); % saline vs tcb2
[~,p2] = ttest(cond_power(lowtcb_present,2),cond_power(lowtcb_present,3)); % tcblow vs tcb2
[~,p3] = ttest2(cond_power(~lowtcb_present,1),cond_power(lowtcb_present,2)); % saline vs tcblow
title('P values:');
subtitle(['salVtcb2 = ' num2str(round(p1,2)) ' tcblowVtcb2 = ' num2str(round(p2,2)) ' salVtcblow = ' num2str(round(p3,2))]);



