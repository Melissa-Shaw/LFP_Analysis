% Function to analyse spiking and LFP of 2 day recording of single animal with unknown drinking contents
function [LFP] = analyse_awake_animal(db,exp_pair)

% Set LFP parameters
freq_bounds = [8 32]; % freq_bounds = [8 32] for beta or [55 90] for gamma
region = 'PFC';
iCh = 3; % iCh = 3 for channel 150 for PFC
gap = 2*60; % leave gap of 2 mins before end of condition
section = 5*60; % extract data over period of 5 mins
smth = 250;
is_dual = false;

i = 1;
for exp = exp_pair
    % load spikestruct
    [spikestruct] = load_spikestruct('X:',db,exp);

    % Create LFP struct wih raw LFP
    [indvLFP] = create_LFP_struct(db,exp,spikestruct,iCh,region,is_dual);
    LFP(i) = indvLFP;

    % Find conditions of interest
    base_cond = db(exp).cond(1);
    post_cond = db(exp).cond(2);
    COI(i,:) = [base_cond post_cond];

    % Reset workspace
    i = i+1;
    clear indvLFP spikestruct base_cond post_cond
end

% Find frequency power
for i = 1:numel(LFP)
    [freq_LFP] = freq_filter_LFP(LFP(i),freq_bounds);
    LFP(i).freq_bounds = freq_bounds;
    LFP(i).freq_power = freq_LFP;
    clear freq_LFP
end

% Find aligned frequency power
align_cond = COI(:,2)-1; % align by start of drinking condition
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

% Set up figure
s = get(0,'ScreenSize');
figure('Position',[0 0 s(3)/2 s(4)/2]);
t = tiledlayout('flow');
title(t,db(exp_pair(1)).animal,'interpreter','None');

% Plot spectogram
nexttile
hold on
[h1] = plot_LFP_psd(LFP(1).specgram_cond{1}, LFP(1).specgram_cond{2}, 'c'); % day 1
[h2] = plot_LFP_psd(LFP(2).specgram_cond{1}, LFP(2).specgram_cond{2}, 'g'); % day 2
xlim([3.5 129])
hold on, plot(xlim, [1 1], '--', 'Color', 0.5*[1 1 1])
xlabel('Frequency (Hz)')
ylabel('PSD ratio (post/pre)')
h = [h1 h2];
legend(h, 'Day 1', 'Day 2','location','southeast')
set(gca, 'XScale', 'log')
set(gca, 'XTick', 2.^(2:7))

% Plot frequency power
ax1 = nexttile;
title(ax1, ['Freq: ' num2str(freq_bounds(1)) ' - ' num2str(freq_bounds(2)) ' Hz']);
plot_freq(LFP(1),align_point,'c',smth);
hold on
plot_freq(LFP(2),align_point,'g',smth);
box off


end