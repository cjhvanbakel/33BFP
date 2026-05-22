function loss = Calculate_loss(in, out)
    loss = 10* log10(in ./ out); % Calculate loss in dB.
end