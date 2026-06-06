function Data_analysis(filename, dataFolder)
    % SPLICE_ANALYSIS Main function to execute the statistical analysis of splice loss.
    
    % Load the data.
    data = load_data(filename, dataFolder);

    % Run statistical calculations.
    stats = calculate_statistics(data);
    
    % Print the statistical summary.
    print_stats(stats);
    
end