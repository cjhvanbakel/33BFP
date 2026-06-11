clc;
clear;
close all;

gap_um = 40;
%% BARE FIBER
filename = sprintf('SM19_Bare_GAP_%dum.mat',gap_um);
expData = load(filename);
disp(['Loaded: ', filename])
disp(fieldnames(expData))

WL_bare = expData.WL;
T_bare    = expData.R;
%% MODEL
data = readtable(sprintf('Wavelength_Transmittance_%dmu.xlsx', gap_um));

% Extract columns
WL_theory = data{:,1};      % First column
T_theory= data{:,2};   % Second column
T_model = T_theory(:).';
%% GMR
filename = sprintf('SM19_PhC_GAP_%dum.mat',gap_um);
expData2 = load(filename);
disp(['Loaded: ', filename])
disp(fieldnames(expData))
WL_withmem = expData2.WL;
T_withmem    = expData2.R;

% Reflection
filename = sprintf('SM19_PhC_Refl.mat');
expData3 = load(filename);
disp(['Loaded: ', filename])
disp(fieldnames(expData))
WL_refl = expData3.WL;
R_refl   = expData3.R;

%% Empty membrane
filename = sprintf('SM19_EM_GAP_%dum.mat',gap_um);
expData4 = load(filename);
disp(['Loaded: ', filename])
disp(fieldnames(expData))
WL_withemptymem = expData4.WL;
T_withemptymem    = expData4.R;

% Reflection
filename = sprintf('SM19_EM_Refl.mat');
expData5 = load(filename);
disp(['Loaded: ', filename])
disp(fieldnames(expData))
WL_refl_em = expData5.WL;
R_refl_em   = expData5.R;
%% Finding Q
% Find GMR peak in reflectance
[pks, locs] = findpeaks(R_refl, WL_refl, 'MinPeakProminence', 0.05, ...
                                    'MinPeakWidth', 0.1);

% Take the dominant peak
[~, idx_main] = max(pks);
lambda0    = locs(idx_main);
peak_val   = pks(idx_main);
half_max   = peak_val / 2;

% Find FWHM by interpolation around the peak
idx_peak   = find(WL_refl == lambda0 | abs(WL_refl - lambda0) == ...
             min(abs(WL_refl - lambda0)), 1);
% Search left and right of peak for half-maximum crossing
left_idx   = find(R_refl(1:idx_peak) <= half_max, 1, 'last');
right_idx  = find(R_refl(idx_peak:end) <= half_max, 1, 'first') + idx_peak - 1;

lambda_left  = interp1(R_refl(left_idx:left_idx+1), ...
               WL_refl(left_idx:left_idx+1), half_max);
lambda_right = interp1(R_refl(right_idx-1:right_idx), ...
               WL_refl(right_idx-1:right_idx), half_max);

FWHM = lambda_right - lambda_left;
Q    = lambda0 / FWHM;

fprintf('GMR peak wavelength:  %.3f nm\n', lambda0);
fprintf('FWHM:                 %.3f nm\n', FWHM);
fprintf('Quality factor Q:     %.1f\n',    Q);
%% Plotting
figure(1);

% Theoretical
plot(WL_bare, T_model, ...
    '-', ...
    'Color', [1 0 0], ...          % Red RGB
    'LineWidth', 2);

hold on;

% Bare fiber
plot(WL_bare, T_bare, ...
    'o-', ...
    'Color', [0 0.4470 0.7410], ...
    'LineWidth', 1.5, ...
    'MarkerSize', 1);

% With membrane
plot(WL_withmem, T_withmem, ...
    's-', ...
    'Color', [0 0.6 0], ...
    'LineWidth', 1.8, ...
    'MarkerSize', 1);

% With membrane
plot(WL_withemptymem, T_withemptymem, ...
    's-', ...
    'Color', [0.225 0.165 0], ...
    'LineWidth', 1.8, ...
    'MarkerSize', 1);

xlabel('Wavelength [nm]')
ylabel('Transmission')

xlim([1460 1620])
ylim([0 1])

title(sprintf('Air Gap = %d \\mum', gap_um), ...
      'FontSize',14)

legend('Theory', 'Bare Fiber', 'Photonic crystal','Empty membrane')

grid on;

figure(2);
plot(WL_refl, R_refl, ...
    '-', ...
    'Color', [0 0.6 0], ...
    'LineWidth', 2);
hold on;
plot(WL_refl_em, R_refl_em, ...
    's-', ...
    'Color', [0.225 0.165 0], ...
    'LineWidth', 1.8, ...
    'MarkerSize', 1);

xlabel('Wavelength [nm]')
ylabel('Reflectance')

xlim([1460 1620])
ylim([0 1])

legend('Photonic crystal','Empty membrane')
grid on;


