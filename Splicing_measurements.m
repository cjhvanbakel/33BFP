%% Initialisation
close all; clear; clc;

addpath("Instruments\");   % Add the instruments folder to the path.
addpath("functions");      % Add the functions folder to the path.
addpath('raw Data')
% Data storage location
dataFolder = "Data";
masterFile = fullfile(dataFolder, "Splice_data.csv");

% Common metadata
params.Type     = 'Silica';
params.Membrane = 0;
params.Who      = 'Chris';

% Laser / detector settings
params.Laser_power = 0.5;   % (mW)
WL = 1550;                  % (nm)

Gain = 10;                  % V/mW
%Responsitivity = 1.05;      % A/W
measurement_time = 20;      % seconds

% Splicing parameters (used only for splice runs)
spliceParams.Arc_time   = 3000;  % (ms)
spliceParams.Arc_power  = 15;    % (mA)
spliceParams.Gap_offset = 0;    % (um) Position of the gap.
spliceParams.Gap = 0;           % (um) Width of the gap.
spliceParams.Overlap = 10;      % (um)

% File that stores the most recent reference OP_before
referenceFile = "latest_reference_OP_before.mat";

%% Instrument initialisation
mm = AgilentMultimeter22_new_batch();
laser = SantecTSL710_new();

laser.wavelength(WL);
laser.power_unit(1);                 % 1 = Watt, 0 = dBm
laser.power(params.Laser_power);
mm.impedance(0);

mm.set_null('VOLTage:DC');
%% Choose measurement type
mode = questdlg( ...
    'Choose measurement type:', ...
    'Measurement Type', ...
    'Reference', 'Splice', 'Splice');

if isempty(mode)
    error('Data entry cancelled.');
end

switch mode

    case 'Reference'

        params.MeasurementType = 'Reference';

        % Reference has no splice parameters
        params.Membrane   = NaN;
        params.Arc_time   = NaN;
        params.Arc_power  = NaN;
        params.Gap_offset = NaN;
        params.Gap        = NaN;
        params.Overlap    = NaN;
        laser.shutter(0);
        params.V_avg_before_splice = measure_average_voltage(mm, measurement_time);
        params.OP_before = params.V_avg_before_splice / Gain;
        laser.shutter(1);

        % Store latest reference
        reference.OP_before = params.OP_before;
        reference.V_avg_before_splice = params.V_avg_before_splice;
        save(referenceFile, "reference");

        % Empty manual input for reference measurements
        manualPart = struct();

        % Save to CSV
        save_splice_experiment(masterFile, manualPart, params);


    case 'Splice'

        params.MeasurementType = 'Splice';

        if ~isfile(referenceFile)
            error('No reference measurement found. Run a Reference measurement first.');
        end

        S = load(referenceFile, "reference");

        % Use latest reference value
        params.OP_before = S.reference.OP_before;
        params.V_avg_before_splice = S.reference.V_avg_before_splice;

        % Splicing parameters
        params.Arc_time   = spliceParams.Arc_time;
        params.Arc_power  = spliceParams.Arc_power;
        params.Gap_offset = spliceParams.Gap_offset;
        params.Gap = spliceParams.Gap;
        params.Overlap = spliceParams.Overlap;

        % Ask operator input

        manualPart_angles = get_manual_input_angles(); % Get a pop-up to fill in the manual parameters after the splice.
        if isempty(manualPart_angles), error('Data entry cancelled.'); % Raise error when not filled in correctly
        end
        
        manualPart_loss = get_manual_input_loss();
        if isempty(manualPart_loss), error('Data entry cancelled.'); % Raise error when not filled in correctly
        end
        
        
        
        % Measurement after the splice 
        laser.shutter(0);
        params.V_avg_after_splice = measure_average_voltage(mm, measurement_time);
        params.OP_after = params.V_avg_after_splice /Gain;
        laser.shutter(1);
        
        % Prooftest
        manualPart_prooftest = get_manual_input_prooftest();
        if isempty(manualPart_prooftest), error('Data entry cancelled.'); % Raise error when not filled in correctly
        end
        
        % Combine all manual parts.
        manualPart = cell2struct([struct2cell(manualPart_angles); struct2cell(manualPart_loss); struct2cell(manualPart_prooftest)], ...
                         [fieldnames(manualPart_angles); fieldnames(manualPart_loss); fieldnames(manualPart_prooftest)], 1);

        save_splice_experiment(masterFile, manualPart, params);

end

clear all

%% Data analysis
%Splice_analysis('Splice_data.csv')