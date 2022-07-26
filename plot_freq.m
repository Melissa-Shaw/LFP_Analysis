function [powerMat] = plot_freq(LFP,align_point,mean_color,smth)
    powerMat = [];
    time_array = [(-align_point+1):(numel(LFP(1).freq_power_align)-align_point)];
    for i = 1:numel(LFP)
      LFPpower = LFP(i).freq_power_align;
      if smth>1
        g = gausswin(smth); g = g/sum(g);
        LFPpower = conv(LFPpower,g','same'); % use gausswin convolution to smooth data
      end
      plot(time_array,LFPpower,'-','Color',mean_color,'LineWidth',0.1);
      powerMat = [powerMat; LFPpower];
      hold on
    end
    plot(time_array,nanmean(powerMat,1),mean_color,'LineWidth',2);
    hold off
    xline(0, '-k','LineWidth',1);
    xlabel('Time (s)')
    ylabel('Freq Power')
end