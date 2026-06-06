% Load the .mat file
data = load('Splice_membrane_2.mat');

% Extract variables
WL = data.WL2;      % Wavelength axis
Ptot = data.Ptot;   % Power matrix

% Average Ptot over all measurements (columns)
Ptot_avg = mean(Ptot, 2);

% Create figure
figure;

plot(WL2, Ptot_avg, 'LineWidth', 1.5);

xlabel('Wavelength [nm]');
ylabel('Average Ptot [mW]');
title('Averaged Spectrum');

grid on;