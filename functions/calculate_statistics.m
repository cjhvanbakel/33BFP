function stats = calculate_statistics(data)
    % CALCULATE_STATISTICS Computes only the metrics needed for visual labels.
    
    % Base the statistics fully on Splice data.
    isSplice = strcmp(data.MeasurementType, 'Splice');
    spliceData = data(isSplice, :);

    % Overall counts for Pie Charts.
    stats.counts_pass = sum(strcmp(spliceData.Result, 'pass'));
    stats.counts_fail = sum(strcmp(spliceData.Result, 'fail'));
    stats.total_splices = height(spliceData);
    
    % Percentages for Chart Labels.
    stats.pct_pass = (stats.counts_pass / stats.total_splices) * 100;
    stats.pct_fail = (stats.counts_fail / stats.total_splices) * 100;
    
    % Averages for the Bar Chart/Console Summary.
    stats.avg_percent_off = mean(data.Percent_Off, 'omitnan');
    stats.avg_difference = mean(data.Loss_difference, 'omitnan');
    
    % Mean & Median.
    stats.mean_loss   = mean(spliceData.Splice_loss, 'omitnan');
    stats.std_loss    = std(spliceData.Splice_loss, 'omitnan');
    
    % List of Operators for the Performance Tiling.
    stats.unique_who = unique(data.Who);
end