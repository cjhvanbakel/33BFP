% Extract data
addpath("functions");
addpath("raw Data");

filename  = 'OP_data_1550.csv'; 
filename2 = 'OP_data_membrane_1550.csv';

% Read tables.
data_table  = readtable(filename);
data_table2 = readtable(filename2);

% Keep only Optical transmission measurements.
data_table  = data_table(data_table.MeasurementType == "Optical transmission", :);
data_table2 = data_table2(data_table2.MeasurementType == "Optical transmission", :);

%% Original measurements
gap = data_table.Gap;   % measured gaps in um.

loss_data = Calculate_loss(data_table.OP_before, data_table.OP_after);

%% Membrane measurements
gap_mem = data_table2.Gap;

loss_mem = Calculate_loss(data_table2.OP_before, data_table2.OP_after);

%% Create theoretical gap vector with 0.5 um spacing
gap_theory = min(gap):0.5:max(gap);

% Parameters
lambda = 1550e-9;        % wavelength [m]
w0     = 5.2e-6;         % beam waist [m]
n0     = 1.0;            % refractive index of air
n      = 1.4682;         % fiber index

% Fresnel reflectivity.
R = ((n - n0)/(n + n0))^2;
F = 4*R ./ ((1-R)^2);

% Convert gaps to meters.
z_meas   = gap * 1e-6;
z_theory = gap_theory * 1e-6;

% Divergence loss.
zR = 2 * pi * n0 * w0^2 / lambda;
loss_div = 10 * log10(1 + (z_theory ./ zR).^2);

% Fresnel loss.
delta = 2 * pi * n0 * z_theory ./ lambda;
loss_fresnel = 10 * log10(1 + F .* (sin(delta)).^2);


%% Plot 1: Total theoretical loss
figure;

% measured data (BLUE).
plot(gap, loss_data, 'o-', ...
    'Color', [0 0.4470 0.7410], ...
    'LineWidth', 1.5, ...
    'MarkerSize', 6);
hold on;

% Membrane averaged data (GREEN).
plot(gap_mem, loss_mem, 's-', ...
    'Color', [0 0.6 0], ...
    'LineWidth', 1.8, ...
    'MarkerSize', 7);

% Total theoretical loss (RED).
plot(gap_theory, loss_fresnel, 'r-', ...
    'LineWidth', 2);

xlabel('Distance between fibers (\mum)');
ylabel('System Loss (dB)');
title('System Loss vs distance between fibers', ...
      'FontWeight', 'bold');

legend('Measured Data', ...
       'Measured Data with Membrane', ...
       'Theoretical distance Loss', ...
       'Location', 'northwest');

grid on;
%% Plot 2: Divergence only
figure;

% measured data(BLUE).
plot(gap, loss_data, 'o-', ...
    'Color', [0 0.4470 0.7410], ...
    'LineWidth', 1.5, ...
    'MarkerSize', 6);
hold on;

% Membrane averaged data (GREEN).
plot(gap_mem, loss_mem, 's-', ...
    'Color', [0 0.6 0], ...
    'LineWidth', 1.8, ...
    'MarkerSize', 7);

% Divergence loss(RED).
plot(gap_theory, loss_div, 'r-', ...
    'LineWidth', 2);

xlabel('Distance between fibers (\mum)');
ylabel('System Loss (dB)');
title('System Loss vs distance between fibers', ...
      'FontWeight', 'bold');

legend('Measured Data', ...
       'Measured Data with Membrane', ...
       'Theoretical distance Loss', ...
       'Location', 'northwest');

grid on;