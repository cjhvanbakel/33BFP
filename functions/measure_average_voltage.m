function V_avg = measure_average_voltage(mm, measurement_time)

    voltages = []; % Initialize voltage array.
    t0 = tic;

    while toc(t0) < measurement_time % when not reached 5 seconds.
        V = mm.measure_voltage(); % measure voltage.
        voltages(end+1) = V; % add it to the array.
    end
    
    V_avg = mean(voltages); % Average voltage.

end