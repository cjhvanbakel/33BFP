function manualData = get_manual_input_angles()
    % This function collects the pop-up data and returns it as a struct.
    prompt = {...
        'L Cleave Angle(°):', 'R Cleave Angle(°):', ...
        'L Fiber Angle(°):', 'R Fiber Angle(°):'};
    
    dlgtitle = 'Manual Splice Data Entry';
    answer = inputdlg(prompt, dlgtitle, [1 50], {'0','0','0','0'});
    
    if isempty(answer)
        manualData = []; 
        return; 
    end
    
    % Store answers in a temporary struct.
    manualData.L_cleave_angle = str2double(answer{1});
    manualData.R_cleave_angle = str2double(answer{2});
    manualData.L_fiber_angle = str2double(answer{3});
    manualData.R_fiber_angle = str2double(answer{4});
end
