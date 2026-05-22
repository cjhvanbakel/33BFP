% Data
gapPos = [45 40 35 30 25 20 45 40 35 30 25 20];
overlap = [5 5 5 5 5 5 10 10 10 10 10 10];
loss = [0.02 0.02 0.02 0.01 0.02 0.01 0.03 0.01 0.01 0.00 0.01 0.00];

% Failed proof test flags
failed = [1 1 0 0 1 0 0 0 0 0 0 0];

% Separate overlap groups
idx5 = overlap == 5;
idx10 = overlap == 10;

% Create figure
figure;
hold on;
grid on;

% Plot overlap = 5
plot(gapPos(idx5), loss(idx5), '-o', ...
    'LineWidth', 2, ...
    'MarkerSize', 8);

% Plot overlap = 10
plot(gapPos(idx10), loss(idx10), '-s', ...
    'LineWidth', 2, ...
    'MarkerSize', 8);

% Add crosses for failed proof tests
plot(gapPos(failed == 1), loss(failed == 1), 'rx', ...
    'MarkerSize', 14, ...
    'LineWidth', 3);

% Labels and title
xlabel('Gap Position');
ylabel('Loss');
title('Loss vs Gap Position');

% Legend
legend('Overlap = 5', ...
       'Overlap = 10', ...
       'Failed Proof Test', ...
       'Location', 'best');

hold off;