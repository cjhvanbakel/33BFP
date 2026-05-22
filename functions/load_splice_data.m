function data = load_splice_data(filename)
    % LOAD_SPLICE_DATA Loads file, calculates metrics, and saves back.

    % Load data
    data = readtable(filename);
    isSplice = strcmp(data.MeasurementType, 'Splice');
    isRef    = strcmp(data.MeasurementType, 'Reference');
    
    % Initialise
    data.System_loss = NaN(height(data),1);
    data.Splice_loss = NaN(height(data),1);
    data.Total_loss  = NaN(height(data),1);
    data.Loss_difference = NaN(height(data),1);
    data.Percent_Off = NaN(height(data),1);
    data.Result      = repmat({''}, height(data), 1);
    
    % System loss, valid for both cases.
    data.System_loss = Calculate_loss(data.Laser_power, data.OP_before);
    
    % Splice measurements only
    loss_threshold = 1; %dB
    data.Splice_loss(isSplice) = Calculate_loss( ...
        data.OP_before(isSplice), ...
        data.OP_after(isSplice));
    
    % Total loss, only for splices
    data.Total_loss(isSplice) = ...
        data.System_loss(isSplice) + data.Splice_loss(isSplice);
    
    %Result, pass/fail or reference.
    data.Result(isRef) = {'reference'};
    data.Result(isSplice) = repmat({'pass'}, sum(isSplice), 1);
    data.Result(isSplice & data.Splice_loss > loss_threshold) = {'fail'};

    % Machine deviation only for splices
    data.Loss_difference(isSplice) = ...
        data.Splice_loss(isSplice) - data.Splice_loss_machine(isSplice);
    
    % How much % the machine is off.
    data.Percent_Off(isSplice) = ...
        ((data.Splice_loss(isSplice) - data.Splice_loss_machine(isSplice)) ...
        ./ data.Splice_loss(isSplice)) * 100;

    % Geometry of the fibers.
    data.Total_cleave_angle = data.L_cleave_angle + data.R_cleave_angle;
    data.Total_Fiber_Angle  = data.L_fiber_angle + data.R_fiber_angle;

    % Save updated table
    writetable(data, filename);

    fprintf('File "%s" updated with calculated columns.\n', filename);
end

