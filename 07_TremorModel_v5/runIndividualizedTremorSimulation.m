%=========================================================================%
%                   Federal University of Rio de Janeiro                  %
%                  Biomedical Engineering Program - COPPE                 %
%                                                                         %
% Advisor: Prof. Dr. Luciano L. Menegaldo                                 %
% Doctoral Candidate: Wellington C. Pinheiro MSc.                         %
%                                                                         %
% This script runs FD simulation of individualized tremor handling        %
% OpenSim as a control theory plant                                       %
%                                                                         %
%=========================================================================%



 %% Run Simulation
tic
    motionData = IntegrateOsimPlant(osimModel,integratorName,SimuInfo,integratorOptions);
elapsedTime=toc
SimuInfo.elapsedTime=elapsedTime;


%% Calling the Metrics

%% Get Patient Files

% Save the current working directory
originalFolder = pwd;


cd(targetFolder);

% Prompt user to select two .mat files to import
[file1, path1] = uigetfile('*.mat', 'Select the voluntary aquisition .mat file');
[file2, path2] = uigetfile('*.mat', 'Select the tremor distribution .mat file');

% Return to the original directory
cd(originalFolder);

% Load the selected files if the user didn't cancel the selection
if ischar(file1) && ischar(file2)
    % Construct the full file paths
    fullPath1 = fullfile(path1, file1);
    fullPath2 = fullfile(path2, file2);

    % Load the selected files
    data1 = load(fullPath1);
    data2 = load(fullPath2); %distribution file 

% Assuming data1 has been loaded already
fieldsData1 = fieldnames(data1);

% Display the list of fields in data1 and ask the user to choose
fprintf('Available datasets in data1:\n');
for i = 1:length(fieldsData1)
    fprintf('%d: %s\n', i, fieldsData1{i});
end

% Prompt the user for a selection using input
choice = input('Save to SimuInfo.pd011: ');

% Validate the choice
if isnumeric(choice) && choice >= 1 && choice <= length(fieldsData1)
    selectedField = fieldsData1{choice};

    % Assign the chosen dataset to SimuInfo.pd011
    pd011 = table2array(data1.(selectedField));
else
    error('Invalid selection. Please run the code again and select a valid option.');
end

end

SimuInfo.pd011=pd011;
SimuInfo.P=data2.P;
pd = makedist('Uniform','lower',1,'upper',length(data2.P));
SimuInfo.pd=pd;             
SimuInfo.PatientID=file1(1:end-4); %removes '.mat'

[MetricsTable, J] = JSD(motionData, SimuInfo)


%Gerating a motion file (.mot) to import on opensim

