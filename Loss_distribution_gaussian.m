clear all
filename = 'Patchcord_cal.csv'; 
addpath("functions");      % Add the functions folder to the path.

data_table = readtable(filename);

loss_data = Calculate_loss(0.5, ...
                           data_table.OP_before);

mu = round(mean(loss_data),1);          % Average loss.
sigma = std(loss_data);        % Standard deviation.

fprintf('Total Measurements Analysed: %d\n', length(loss_data));
fprintf('Average Loss (Mean): %.4f dB\n', mu);
fprintf('Repeatability (Std Dev): %.4f dB\n', sigma);

figure('Color', 'w');
hold on;

x_values = linspace(mu - 3*sigma, mu + 3*sigma, 200);
y_gaussian = normpdf(x_values, mu, sigma);

plot(x_values, y_gaussian, 'r-', 'LineWidth', 2.5);

y_points = normpdf(loss_data, mu, sigma);

plot(loss_data, y_points, 'o', ...
    'Color', [0 0.4470 0.7410], ...
    'MarkerFaceColor', [0 0.4470 0.7410], ...
    'MarkerSize', 6);


grid on;

xlabel('Insertion Loss (dB)', ...
       'FontSize', 12, ...
       'FontWeight', 'bold');

ylabel('Probability Density', ...
       'FontSize', 12, ...
       'FontWeight', 'bold');

title('Loss Distribution', ...
      'FontSize', 14, ...
      'FontWeight', 'bold');

% Legend
legend({'Gaussian Fit', 'Measured Data'},'Location', 'NorthEast', 'FontSize', 10);

hold off;