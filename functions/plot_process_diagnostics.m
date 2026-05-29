function plot_Process_diagnostics(data)
    % PLOT_GEOMETRIC_DIAGNOSTICS Renders a single consolidated dashboard
    % tracking.
    % Gap, Gap Offset, Overlap, Arc Time, and Arc Power vs loss.
    
    % Define data columns exactly matching your CSV table fields.
    diag_cols = {'Gap', 'Gap_offset', 'Overlap', 'Arc_time', 'Arc_power'};
    
    % Set clean, readable labels for the X-axes with scientific units.
    diag_labels_x = {'Gap (\mum)', 'Gap Offset (\mum)', 'Overlap (\mum)', 'Arc Time (ms)', 'Arc Power (mA)'};
    
    % High-contrast professional palette for separating parameter trends.
    diag_colors = [
        0.12, 0.47, 0.71; % Classic Blue for Gap.
        0.85, 0.15, 0.15; % Crimson Red for Gap Offset.
        0.12, 0.58, 0.27; % Forest Green for Overlap.
        0.50, 0.15, 0.65; % Deep Purple for Arc Time.
        0.92, 0.49, 0.19  % Vivid Orange for Arc Power.
    ];
    
    % Spawns 1 wide figure to fit the 2x3 grid.
    figure('Name', 'Fusion Parameter Process Diagnostics', 'Color', 'w', 'Position', [150, 150, 1200, 750]);
    t_layout = tiledlayout(2, 3, 'TileSpacing', 'Loose', 'Padding', 'Normal');
    
    % Sequentially populate tiles 1 through 5.
    for idx = 1:5
        nexttile;
        
        % Scatter plot: Process Parameter (X) vs Actual Measured Loss (Y).
        scatter(data.(diag_cols{idx}), data.Splice_loss, 65, diag_colors(idx, :), 'filled', 'MarkerFaceAlpha', 0.65);
        
        % Individual subplot typography and axes configuration.
        title(diag_cols{idx}, 'FontSize', 12, 'FontWeight', 'bold', 'Interpreter', 'none');
        xlabel(diag_labels_x{idx}, 'FontSize', 10);
        ylabel('Measured Splice Loss (dB)', 'FontSize', 10);
        
        % Grid line overlay.
        grid on;
        ax = gca;
        ax.GridLineStyle = ':';
        ax.GridAlpha = 0.4;
    end
    
    % Global overarching figure header.
    title(t_layout, 'Process Control Diagnostics: Loss Sensitivity vs. Fusion Parameters', 'FontSize', 15, 'FontWeight', 'bold');
end