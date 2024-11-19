%=========================================================================%
%                   Federal University of Rio de Janeiro                  %
%                  Biomedical Engineering Program - COPPE                 %
%                                                                         %
% Advisor: Prof. Dr. Luciano L. Menegaldo                                 %
% Doctoral Candidate: Wellington C. Pinheiro MSc.                         %
%                                                                         %
% RL Trained FES Control Law                                              %
%                                                                         %
%=========================================================================%

% Prompt user to select the agent file
[file, path] = uigetfile('*.mat', 'Select the agent to test');

if isequal(file, 0)
   disp('No file selected');
else
   % Load the selected agent
   agentFile = fullfile(path, file);
   loadedData = load(agentFile);
   
   % Assuming the agent is stored with the variable name 'agent'
   agent = loadedData.saved_agent;
   
   % Display episode reward and steps if they are saved in the loaded file
   if ~isempty(loadedData.savedAgentResult.EpisodeReward') && ~isempty(loadedData.savedAgentResult.EpisodeSteps)
       % disp(['Episode Reward: ', num2str(loadedData.savedAgentResult.EpisodeReward)]);
       % disp(['Episode Steps: ', num2str(loadedData.savedAgentResult.EpisodeSteps)]);
        
       TrainEpisodeDuration=loadedData.savedAgentResult.EpisodeSteps*SimuInfo.Ts
   
   else
       disp('Episode Reward and Steps not found in the loaded file.');
   end

   % Simulation options
   simOptions =rlSimulationOptions('MaxSteps', 200000);
   
   % Run the simulation
   experience = sim(env, agent, simOptions);
end

% Nome do campo a ser verificado
fieldName = 'StoreStim';
% Verifica a existência do campo e se o conteúdo é 'on'
if isfield(SimuInfo, fieldName) && strcmp(SimuInfo.(fieldName), 'on')

    % Declarando a variável global
    global e_stim data
    motionData.data=data;
    motionData.e_stim=e_stim(:, (1:9));
    motionData.Energy=e_stim(:, (10:end));
end