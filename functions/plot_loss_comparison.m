function plot_loss_comparison(data)
    % PLOT_LOSS_COMPARISON Renders a standalone figure containing two stacked graphs:
    % 1) Grouped absolute loss chart comparing actual physical metrics vs software estimates.
    % 2) Percentage error bar chart mapping the estimation variance per individual splice.
    num_splices = height(data);
    
    % Determine X-axis indexing labels (Uses 'id' column if present,
    % otherwise row index).
    if ismember('id', data.Properties.VariableNames)
        x_labels = data.id;
        x_title_str = 'Splice ID';
    else
        x_labels = 1:num_splices;
        x_title_str = 'Splice Index';
    end
    
    % Retrieve or dynamically compute the percentage discrepancy 
    if ismember('Percent_Off', data.Properties.VariableNames)
        pct_off = data.Percent_Off;
    else
        pct_off = ((data.Splice_loss - data.Splice_loss_machine) ./ data.Splice_loss) * 100;
    end
    
    % Create a taller standalone window layout to fit both graphs cleanly
    figure('Name', 'Loss Verification & Percentage Error Analysis', 'Color', 'w', 'Position', [120, 50, 1050, 780]);
    t_layout = tiledlayout(2, 1, 'TileSpacing', 'Loose', 'Padding', 'Normal');
    
    % GRAPH 1: Absolute Loss Grouped Chart 
    nexttile;
    hBar = bar([data.Splice_loss, data.Splice_loss_machine], 'grouped', 'EdgeColor', 'none');
    hBar(1).FaceColor = [0.12, 0.47, 0.71]; % Deep Blue = True Measured Loss
    hBar(2).FaceColor = [0.92, 0.49, 0.19]; % Vivid Orange = Machine Estimate
    
    set(gca, 'XTick', 1:num_splices, 'XTickLabel', x_labels);
    if num_splices > 12
        xtickangle(45);
    end
    
    xlabel(x_title_str, 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Splice Loss (dB)', 'FontSize', 11, 'FontWeight', 'bold');
    title('Individual Splice Verification: Actual vs. Machine Estimated Loss', 'FontSize', 12, 'FontWeight', 'bold');
    legend({'Actual Loss (Power Meter)', 'Machine Estimated Loss'}, ...
           'Location', 'northoutside', 'Orientation', 'horizontal', 'FontSize', 10);
    
    grid on;
    ax1 = gca;
    ax1.GridLineStyle = ':';
    ax1.GridAlpha = 0.4;
    ax1.Layer = 'top';
    
    % GRAPH 2: Percentage Discrepancy Error Chart
    nexttile;
    % Uses a clean, contrasting plum/purple tone for the distinct percentage axis
    hBarPct = bar(pct_off, 'FaceColor', [0.57, 0.29, 0.62], 'EdgeColor', 'none'); 
    
    set(gca, 'XTick', 1:num_splices, 'XTickLabel', x_labels);
    if num_splices > 12
        xtickangle(45);
    end
    
    xlabel(x_title_str, 'FontSize', 11, 'FontWeight', 'bold');
    ylabel('Estimation Error (%)', 'FontSize', 11, 'FontWeight', 'bold');
    title('Machine Estimation Discrepancy Percentage Relative to Actual Loss', 'FontSize', 12, 'FontWeight', 'bold');
    
    % Render a solid black baseline at 0% error to visibly partition trends
    hold on;
    xlim_vals = xlim;
    plot(xlim_vals, [0, 0], 'k-', 'LineWidth', 1.2);
    hold off;
    
    grid on;
    ax2 = gca;
    ax2.GridLineStyle = ':';
    ax2.GridAlpha = 0.4;
    ax2.Layer = 'top';
    
    % Global overarching layout header
    title(t_layout, 'Per-Splice Accuracy Analysis', 'FontSize', 15, 'FontWeight', 'bold');
end