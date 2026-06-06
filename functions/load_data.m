function data = load_data(filename, dataFolder)

    % LOAD_SPLICE_DATA Loads file, calculates metrics, and saves back.

    % Make sure the file saves i nthe right folder (raw Data).
    filename = fullfile(dataFolder, filename);
    
    % avg_membrane loss at 5 micron gap is universal, and our reference.
    avg_membrane_loss = 5; % dB

    % Load data.
    data = readtable(filename);

    isSplice  = strcmp(data.MeasurementType, 'Splice');
    isRef     = strcmp(data.MeasurementType, 'Reference');

    % Membrane rows
    hasMembrane = data.Membrane == 1;

    % Initialise.
    data.Reference_loss   = NaN(height(data),1);
    data.System_loss      = NaN(height(data),1);
    data.Total_loss       = NaN(height(data),1);
    data.Splice_loss      = NaN(height(data),1);   % NEW
    data.Loss_difference  = NaN(height(data),1);
    data.Percent_Off      = NaN(height(data),1);
    data.Result           = repmat({''}, height(data), 1);

    % Reference loss.
    data.Reference_loss = Calculate_loss( ...
        data.Laser_power, ...
        data.OP_before);

    % System loss for splice measurements.
    loss_threshold = 1; % dB

    data.System_loss(isSplice) = Calculate_loss( ...
        data.OP_before(isSplice), ...
        data.OP_after(isSplice));
    
    membraneSpliceIdx = isSplice & hasMembrane;

    data.Splice_loss(membraneSpliceIdx) = ...
        data.System_loss(membraneSpliceIdx) - avg_membrane_loss;

    % Total loss.
    data.Total_loss(isSplice) = ...
        data.Reference_loss(isSplice) + ...
        data.System_loss(isSplice);

    % Result.
    data.Result(isRef) = {'reference'};
    data.Result(isSplice) = repmat({'pass'}, sum(isSplice), 1);

    data.Result(isSplice & ...
        data.System_loss > loss_threshold) = {'fail'};

    % Machine deviation only for splices.
    data.Loss_difference(isSplice) = ...
        data.System_loss(isSplice) - ...
        data.Splice_loss_machine(isSplice);

    % Percent deviation.
    data.Percent_Off(isSplice) = ...
        ((data.System_loss(isSplice) - ...
        data.Splice_loss_machine(isSplice)) ...
        ./ data.System_loss(isSplice)) * 100;

    % Geometry of the fibers.
    data.Total_cleave_angle = ...
        data.L_cleave_angle + data.R_cleave_angle;

    data.Total_Fiber_Angle = ...
        data.L_fiber_angle + data.R_fiber_angle;

    % Save updated table.
    writetable(data, filename);

    fprintf('File "%s" updated with calculated columns.\n', filename);

end
