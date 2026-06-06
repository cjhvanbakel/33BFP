function save_experiment(masterFile, manualData, params)

    % Load existing file or create empty table
    if isfile(masterFile)
        data = readtable(masterFile);
    else
        data = table();
    end

    % Combine manual data + params
    newEntry = manualData;

    fields = fieldnames(params);

    for i = 1:length(fields)

        val = params.(fields{i});

        % Store text properly
        if ischar(val) || isstring(val)
            newEntry.(fields{i}) = string(val);
        else
            newEntry.(fields{i}) = val;
        end
    end

    % Generate ID
    if ~ismember('id', data.Properties.VariableNames) || height(data) == 0
        newEntry.id = 1;
    else
        newEntry.id = max(data.id) + 1;
    end

    % Convert to table
    newRow = struct2table(newEntry);

    % First save -> initialize table directly
    if isempty(data)
    
        % Desired front columns
        frontCols = {'id','Who','Type','Membrane'};
    
        existingFront = frontCols( ...
            ismember(frontCols, newRow.Properties.VariableNames));
    
        others = setdiff(newRow.Properties.VariableNames, ...
                         existingFront, ...
                         'stable');
    
        finalOrder = [existingFront, others];
    
        % Create empty master table with SAME headers
        data = newRow([],:);
    
        % Apply order
        data = data(:, finalOrder);
        newRow = newRow(:, finalOrder);
    
    else
    
        % Existing file -> synchronize columns
        [data, newRow] = synchronize_table_columns(data, newRow);
    
        % Desired front columns
        frontCols = {'id','Who','Type','Membrane'};
    
        existingFront = frontCols( ...
            ismember(frontCols, newRow.Properties.VariableNames));
    
        others = setdiff(newRow.Properties.VariableNames, ...
                         existingFront, ...
                         'stable');
    
        finalOrder = [existingFront, others];
    
        % Reorder
        data = data(:, finalOrder);
        newRow = newRow(:, finalOrder);
    end
    % Append
    updatedData = [data; newRow];

    % Save
    writetable(updatedData, masterFile);
    
    % Success message
    fprintf('Success: ID %d saved to %s\n', ...
            newEntry.id, masterFile);
end
