function print_stats(stats)
    % PRINT_STATS Formats and displays statistical summaries to the command window.
   
    fprintf('Pass: %d splices (%.2f%%)\n', stats.counts_pass, stats.pct_pass);
    fprintf('Fail: %d splices (%.2f%%)\n', stats.counts_fail, stats.pct_fail);
    fprintf('-----------------------------------------\n');
    fprintf('On average, the machine is off by: %.2f%%\n', stats.avg_percent_off);
    fprintf('The average difference is: %.4f dB\n', stats.avg_difference);
    fprintf('-----------------------------------------\n');
    fprintf('Actual Splice Loss Statistics:\n');
    fprintf('  Mean:    %.3f dB\n', stats.mean_loss);
    fprintf('  Std Dev: %.3f dB\n', stats.std_loss);
    fprintf('-----------------------------------------\n');
  
end