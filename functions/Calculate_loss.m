function loss = Calculate_loss(Pin, Pout)
    % Calculate power loss in dB
    loss = 10 .* log10(Pin ./ Pout);
end