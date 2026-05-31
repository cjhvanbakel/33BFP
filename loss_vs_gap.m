% Extract data
addpath("functions");      % Add the functions folder to the path.
addpath("raw Data");      % Add the functions folder to the path.

filename = 'Optical_transmission.csv'; 

data_table = readtable(filename);

gap  = data_table.Gap;   % measured gaps [um]

% Create theoretical gap vector with 0.5 um spacing
gap_theory = min(gap):0.5:max(gap);

loss_data = Calculate_loss(data_table.OP_before, ...
                           data_table.OP_after);

% Parameters
lambda = 1550e-9;        % wavelength [m]
w0     = 5.2e-6;         % beam waist [m]
n0     = 1.0;            % refractive index of air
n      = 1.4682;         % fiber index

% Fresnel reflectivity
R = ((n - n0)/(n + n0))^2;
F= 4*R ./ ((1-R)^2);

% Convert gaps to meters
z_meas   = gap * 1e-6;
z_theory = gap_theory * 1e-6;

% Divergence loss
zR = 2 * pi * n0 * w0^2 / lambda;
loss_div = 10 * log10(1 + (z_theory ./ zR).^2);

% Fresnel  loss
delta = 2* pi* n0* z_theory ./ lambda;
loss_fresnel = 10 * log10(1 + F .* (sin(delta)).^2);

% Total theoretical loss

loss_total = loss_div + loss_fresnel;

%Plot
figure;

% Measured data.
plot(gap, loss_data, 'o-', ...
    'Color', [0 0.4470 0.7410], ...
    'LineWidth', 1.5, ...
    'MarkerSize', 6);
hold on;

% Total theoretical loss
plot(gap_theory, loss_total, 'r-', ...
    'LineWidth', 2);

% Labels and Title (Matching the image casing and font weight)
xlabel('Distance between fibers (\mum)');
ylabel('System Loss (dB)');
title('System Loss vs distance between fibers', 'FontWeight', 'bold');

% Legend (Matching the exact text and top-left placement)
legend('Measured Data', ...
       'Theoretical distance Loss', ...
       'Location', 'northwest');

% Grid
grid on;

figure;

% Measured data.
plot(gap, loss_data, 'o-', ...
    'Color', [0 0.4470 0.7410], ...
    'LineWidth', 1.5, ...
    'MarkerSize', 6);
hold on;

% Total theoretical loss
plot(gap_theory, loss_div, 'r-', ...
    'LineWidth', 2);

% Labels and Title
xlabel('Distance between fibers (\mum)');
ylabel('System Loss (dB)');
title('System Loss vs distance between fibers', 'FontWeight', 'bold');

% Legend
legend('Measured Data', ...
       'Theoretical distance Loss', ...
       'Location', 'northwest');

% Grid
grid on;

