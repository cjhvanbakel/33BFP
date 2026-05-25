function save_splice_experiment(masterFile, manualData, params)
    % Load existing data
    if exist(masterFile, 'file') && ~isempty(dir(masterFile))
        data = readtable(masterFile); % If the file exists and has content, load it into a MATLAB table.
    else
        data = table(); % If the file doesn't exist yet, initialize an empty table.
    end

    % Combine all data into a single struct
    newEntry = manualData; 
    fields = fieldnames(params);
    for i = 1:length(fields)
        val = params.(fields{i}); % Get the current value for this specific field
        if ischar(val) || isstring(val) % If the value is a string or characters.
            newEntry.(fields{i}) = {char(val)}; 
        else
            newEntry.(fields{i}) = val; % If it is a number store directly.
        end
    end
    
    % Get the id of the row.
    if isempty(data) || ~any(strcmp(data.Properties.VariableNames, 'id'))
        newEntry.id = 1; % if first entry, id is 1.
    else
        newEntry.id = max(data.id) + 1; % else it is last id +1.
    end

    newRow = struct2table(newEntry); % Convert struct to table.
    
    % Define the order of the file.
    masterOrder = {'id', 'MeasurementType','Who', 'Type', 'Membrane', 'Arc_time', 'Arc_power', ...
                   'Gap_offset', 'Gap','Overlap', 'Laser_power', 'OP_before', 'V_avg_before_splice', 'L_cleave_angle', ...
                   'R_cleave_angle', 'L_fiber_angle', 'R_fiber_angle', ...
                   'Splice_loss_machine', 'MFD_mismatch', 'Core_bending', ...
                   'Axis_offset', 'OP_after', 'V_avg_after_splice', 'Prooftest'};
    
    
    existingDesired = masterOrder(ismember(masterOrder, newRow.Properties.VariableNames)); % Find which of these columns actually exist in newRow.
    
    others = setdiff(newRow.Properties.VariableNames, existingDesired, 'stable'); % Find any columns we didn't mention (like Notes).
    
    newRow = newRow(:, [existingDesired, others]); % Reorder the table: Desired columns first, then anything else.
 
    [data, newRow] = synchronize_table_columns(data, newRow);

    % Force final column order again
    existingDesired = masterOrder( ...
        ismember(masterOrder, newRow.Properties.VariableNames));
    
    others = setdiff(newRow.Properties.VariableNames, ...
                     existingDesired, ...
                     'stable');
    
    finalOrder = [existingDesired, others];
    
    data   = data(:, finalOrder);
    newRow = newRow(:, finalOrder);
    
    % Append and Save
    updatedData = [data; newRow];
    writetable(updatedData, masterFile);
    % Print if it is succesfull.
    fprintf('Success: ID %d saved to %s\n', newEntry.id, masterFile);
end