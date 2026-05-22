function plot_global_quality(stats)
    % PLOT_GLOBAL_QUALITY Spawns an independent chart showing global pass/fail statistics.
    figure('Name', 'Global Splice Quality', 'Color', 'w', 'Position', [100, 450, 480, 400]);
    
    pie([stats.pct_pass, stats.pct_fail], [1, 0], ...
        {sprintf('Pass: %.1f%%', stats.pct_pass), sprintf('Fail: %.1f%%', stats.pct_fail)});
    colormap(gca, [0.18, 0.80, 0.44; 0.91, 0.30, 0.24]);
    title('Total Splice Quality (All Operators)', 'FontSize', 12, 'FontWeight', 'bold');
end