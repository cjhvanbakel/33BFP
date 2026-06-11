clearvars; clc;
addpath("Instruments\");
%% Sample Name and details

ChipName='SM19';
Quadrant='Bare ';
Column='Gap ';
Row='40um';
dIndex='';              %optional
Comment0='';
MeasurandName='';
Operator='Chris';

address = '10.0.0.55';  %IP address of Hyperion
channel = 4;            %Channel used of Hyperion
%% Sweep Parameters

% WL_Start=1460;              % Minimal wavelength
% WL_End=1620;                % Maximal wavelength
% Averaging_Repetitions=20;   % Number of spectra for one averaging
% Spectra_Repeat=1;           % Repetition of experiments


%% Presweep Stuff
addpath(genpath('.\hLibrary_matlab_0.9.5.0'));
expDate=char(datetime('now','Format','yyyy_MM_dd''__''HH_mm_ss'));
expDate=expDate(1:10);

%% Checking reference
if ~exist(string(expDate), 'dir')
       mkdir(string(expDate))
end

if ~exist("C:\Users\fainterrogator\Documents\measurements\Hasan\"+string(expDate)+"\"+string(expDate)+"-_Reference-.mat", 'file')
    prompt=['A recent reference spectrum does not exist, do you want to connect the mirror and acquire one? y/n' newline];
    answer=input(prompt,'s');
    if answer=='y' 
        SampleName="_Reference";
        Comment='';
        chStartTime=expDate;
        hyperionInstrument = hCOMMOpenConnection(address, 'commandPort', 1);
        [offset, scale] = hACQGetPowerCalibrationInfo(hyperionInstrument);
        [spectrum, header] = hACQGetSpectrum(hyperionInstrument, channel, 1);
        P_dBm = double(spectrum)/double(scale(channel)) + double(offset(channel));
        WL = double(header.startWavelength) + double(0:header.numPoints-1)*header.wavelengthIncrement;
        P=10.^(P_dBm/10);              %[mW]
        figure(100)
        plot(WL,P)
        xlabel('Wavelength [nm]')
        ylabel('Optical Power [mW]')
        hCOMMCloseConnection(hyperionInstrument);
        Filename=sprintf('%s-%s-%s',chStartTime,SampleName,Comment);
        if ~exist(string(chStartTime),'dir');
            mkdir(string(chStartTime))
        end
        savedir=string(chStartTime);
        fullname=fullfile(savedir,Filename);
        save(fullname, "WL","P","P_dBm");
        refCom=msgbox({'Reference Complete!';'Connect Sample and press OK'})
        uiwait(refCom) 
    else warning('Continuing without reference...')      
    end
end

if exist("C:\Users\fainterrogator\Documents\measurements\Hasan\"+string(expDate)+"\"+string(expDate)+"-_Reference-.mat", 'file')
    ref=load("C:\Users\fainterrogator\Documents\measurements\Hasan\"+string(expDate)+"\"+string(expDate)+"-_Reference-.mat",'WL','P');
    ref=ref.P;
else
    warning('Using old reference')
    warning('no reference!')
    ref=load("C:\Users\LAB-Homodyne\Documents\measurements\Hasan\2026_02_26\2026_02_26-_Reference-.mat",'WL','P');
    ref=ref.P;
end

warning('Normalizing by reference!!!')
disp(' ')

%% Measuring + plotting

hyperionInstrument = hCOMMOpenConnection(address, 'commandPort', 1);
[offset, scale] = hACQGetPowerCalibrationInfo(hyperionInstrument);
[spectrum, header] = hACQGetSpectrum(hyperionInstrument, channel, 1);
P_dBm = double(spectrum)/double(scale(channel)) + double(offset(channel));
WL = double(header.startWavelength) + double(0:header.numPoints-1)*header.wavelengthIncrement;
hCOMMCloseConnection(hyperionInstrument);

P=10.^(P_dBm/10);              %[mW]
R=P./ref;                      %Reflectance
figure(10)
plot(WL,R)
xlabel('Wavelength [nm]')
ylabel('Transmission')
xlim([1460 1620])
% ylim([])
set(gca,'FontSize',12)
SampleName=sprintf('%s_%s%s%s%s',ChipName,Quadrant,Column,Row,dIndex);
startTime=datetime('now','Format','yyyy_MM_dd''__''HH_mm_ss');
chStartTime=char(startTime);
title(regexprep(SampleName+" "+string(Comment0),'_',' '))
Filename=sprintf('%s-%s-%s',chStartTime,SampleName,Comment0);
if ~exist(string(expDate),'dir');
    mkdir(string(expDate))
end
savedir=string(expDate);
fullname=fullfile(savedir,Filename);
save(fullname,"WL","P","P_dBm","R");

msgbox('Measurement Complete','Finished','replace');
