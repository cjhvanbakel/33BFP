%% Initialisation

close all; clear; clc;
addpath("Instruments\"); % Add the instruments folder to the path so MATLAB can find it.
addpath('functions'); % Add the functions folder to the path so MATLAB can find the scripts.

% Initialisation of splicing parameters.
params.Arc_time = 2000;     %(ms)       
params.Arc_power = 20;      %(UNIT OF SPLICER)  
params.Gap_offset = 0;      % (μm)

% Initialisation of fiber/ operator.
params.Type = 'Silica';     % Type of fiber.
params.Membrane = 0;        % Membrane in betweeen, yes(1)/no(0).
params.Who = 'Chris';       % Operator.

% Initialisation of Instruments.
mm=AgilentMultimeter22_new_batch();
laser=SantecTSL710_new();

params.Laser_power = 0.5;   % (mW) (0.04 is the minimum).
WL=1550;                   % (nm) start:increment:stop.
laser.wavelength(WL(1)); % The exact wavelength rightnow.
laser.power_unit(1);  %1=Watt, 0=dBm
laser.power(params.Laser_power);  % Set the laser power to the specific value.
laser.coh_control(0);  %1=on 
mm.impedance(0);  % Can i remove this? probably yes but to be sure left here

Gain = 10;               % V/A, Gain of the photodiode.
Responsitivity = 1.05;        % A/W, Responsitivity of osciloscope.
measurement_time = 20;      % seconds

%% Measuring before

laser.shutter(0);   %shutter open.
V_avg_before_splice = measure_average_voltage(mm, measurement_time); % Measure average voltage.
params.OP_before = (V_avg_before_splice)/(Gain * Responsitivity);
laser.shutter(1); % shutter closed.

%% Splicing parameters
manualPart_angles = get_manual_input_angles(); % Get a pop-up to fill in the manual parameters after the splice.
if isempty(manualPart_angles), error('Data entry cancelled.'); % Raise error when not filled in correctly
end

manualPart_loss = get_manual_input_loss();
if isempty(manualPart_loss), error('Data entry cancelled.'); % Raise error when not filled in correctly
end

manualPart = cell2struct([struct2cell(manualPart_angles); struct2cell(manualPart_loss)], ...
                         [fieldnames(manualPart_angles); fieldnames(manualPart_loss)], 1);
%% measuring after
laser.shutter(0); % shutter open.
V_avg_after_splice = measure_average_voltage(mm, measurement_time); % Measure average voltage.
params.OP_after = (V_avg_after_splice)/(Gain * Responsitivity);
laser.shutter(1); % shutter closed.

%% Appending the file
save_splice_experiment('Splice_data.csv', manualPart, params); % Save the parameters to a file.
clear all
%% Data analysis
%Splice_analysis('Test_file.csv')