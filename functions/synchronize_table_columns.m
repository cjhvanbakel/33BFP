function [tableA, tableB] = synchronize_table_columns(tableA, tableB)
    % There is nothing to synchronize, so use tableB as the template.
    if isempty(tableA)
        return;
    end
    
    % Get the list of column names for both the master file and the new
    % entry.
    colsA = tableA.Properties.VariableNames;
    colsB = tableB.Properties.VariableNames;

    % Find columns that exist in the CSV but were not provided in this
    % current run.
    missingInB = setdiff(colsA, colsB);
    for i = 1:length(missingInB)
        col = missingInB{i};
        % If the master column contains text (cells), fill the new row with
        % an empty string.
        if iscell(tableA.(col)) 
            tableB.(col) = {''};
        else
            % If the master column is numeric, fill the gap with NaN
            % (Not-a-Number).
            tableB.(col) = NaN;
        end
    end

    % Find new columns that you just added to your script but aren't in the
    % CSV yet.
    missingInA = setdiff(colsB, colsA);
    for i = 1:length(missingInA)
        col = missingInA{i};
        % Extend the existing CSV rows with empty values to accommodate the
        % new column.
        if iscell(tableB.(col))
            tableA.(col) = repmat({''}, height(tableA), 1);
        else
            tableA.(col) = NaN(height(tableA), 1);
        end
    end
    % This line reshuffles tableB so its columns match tableA from left-to-right.
    tableB = tableB(:, tableA.Properties.VariableNames);
end