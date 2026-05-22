% Data
gapPos = [85 75 65 55 45 35 85 75 65 55 45 35];
overlap = [10 10 10 10 10 10 5 5 5 5 5 5];
loss = [0.05 0.03 0.03 0.01 0.01 0.01 0.04 0.02 0.02 0.00 0.01 0.00];

% Separate data based on overlap
idx10 = overlap == 10;
idx5 = overlap == 5;

% Create figure
figure;
hold on;
grid on;

% Plot overlap = 10
plot(gapPos(idx10), loss(idx10), '-o', ...
    'LineWidth', 2, 'MarkerSize', 8);

% Plot overlap = 5
plot(gapPos(idx5), loss(idx5), '-s', ...
    'LineWidth', 2, 'MarkerSize', 8);

% Labels and title
xlabel('Gap Position');
ylabel('Loss (dB)');
title('Loss vs Gap Position');

% Legend
legend('Overlap = 10', 'Overlap = 5', 'Location', 'best');

hold off;


