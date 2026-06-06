clearvars; clc;

ChipName='HIF1 Fusion Splice 1';
address = '10.0.0.55';  %IP address of Hyperion
channel = 4;            %Channel used of Hyperion
%% Sweep Parameters

%1460nm to 1620nm is max
WL_Start=1470;
WL_End=1610;

exptime = 100; %in seconds

%% Presweep Stuff
addpath(genpath('.\hLibrary_matlab_0.9.5.0'));
expDate=char(datetime('now','Format','yyyy_MM_dd''__''HH_mm_ss'));
expDate=expDate(1:10);

%% Measuring + plotting

hyperionInstrument = hCOMMOpenConnection(address, 'commandPort', 1);
[offset, scale] = hACQGetPowerCalibrationInfo(hyperionInstrument);
[spectrum, header] = hACQGetSpectrum(hyperionInstrument, channel, 1);

%Change Start and End points of Data acq
data_SFinal=(WL_Start-(header.startWavelength))/(header.wavelengthIncrement);
data_EFinal=(WL_End-(header.startWavelength))/(header.wavelengthIncrement);
WL = double(header.startWavelength) + double(0:header.numPoints-1)*header.wavelengthIncrement;
WL2 = WL(data_SFinal:data_EFinal);
%Ptot = zeros(20000,exptime);
Ptot = zeros((data_EFinal-data_SFinal+1),exptime);



%Live Measurement
for i = 1:exptime*10
    [spectrum, header] = hACQGetSpectrum(hyperionInstrument, channel, 1);
    P_dBm = double(spectrum(data_SFinal:data_EFinal))/double(scale(channel)) + double(offset(channel));
    P=10.^(P_dBm/10);              %[mW]
    Ptot(:,i) = P;
    

    plot(WL2,P);
    hold on
    ylabel('R [mW]');
    xlabel('Wavelength [nm]');
    %xlim([1580 1586])
    hold off

    pause(0.1);
end
hCOMMCloseConnection(hyperionInstrument);
%writematrix([WL2.',Ptot],"Ptot " + ChipName + " " + num2str(exptime) + " seconds.txt")
msgbox('Measurement Complete','Finished','replace');
