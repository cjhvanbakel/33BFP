function Splice_analysis(filename)
    % SPLICE_ANALYSIS Main function to execute the statistical analysis of splice loss.
    
    % Load the data.
    data = load_splice_data(filename);

    % Run statistical calculations.
    stats = calculate_statistics(data);
    
    % Print the statistical summary.
    print_stats(stats);
    
    % Generate all figures.
    visualize_data(data, stats);
end