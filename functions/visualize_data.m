function visualize_data(data, stats)
    close all; 
    plot_global_quality(stats);
    plot_loss_comparison(data);
    plot_process_diagnostics(data);
end