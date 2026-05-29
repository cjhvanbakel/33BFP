function manualData = get_manual_input_prooftest()
    % This function collects the pop-up data and returns it as a struct.
    prompt = {...
        'Prooftest 1/0 (pass/fail)'};
    
    dlgtitle = 'Manual Splice Data Entry';
    answer = inputdlg(prompt, dlgtitle, [1 50], {'1'});
    
    if isempty(answer)
        manualData = []; 
        return; 
    end
    
    % Store answers in a temporary struct.
    manualData.Prooftest = str2double(answer{1});
end