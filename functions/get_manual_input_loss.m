function manualData = get_manual_input_loss()
    % This function collects the pop-up data and returns it as a struct.
    prompt = {...
        'Splice Loss Machine (dB):', 'MFD Mismatch (dB):', ...
        'Core Bending (dB):', 'Axis Offset (dB)'};
    
    dlgtitle = 'Manual Splice Data Entry';
    answer = inputdlg(prompt, dlgtitle, [1 50], {'0','0','0','0'});
    
    if isempty(answer)
        manualData = []; 
        return; 
    end
    
    % Store answers in a temporary struct.
    manualData.Splice_loss_machine = str2double(answer{1});
    manualData.MFD_mismatch = str2double(answer{2});
    manualData.Core_bending = str2double(answer{3});
    manualData.Axis_offset = str2double(answer{4});
end