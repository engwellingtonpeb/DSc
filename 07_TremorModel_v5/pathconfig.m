%=========================================================================%
%                   Federal University of Rio de Janeiro                  %
%                  Biomedical Engineering Program - COPPE                 %
%                   https://www.peb.ufrj.br/index.php/pt/                 %
%                                                                         %
% Advisor: Prof. Dr. Luciano L. Menegaldo                                 %
% Doctoral Candidate: Wellington C. Pinheiro MSc.                         %
%                                                                         %
% Set paths and configurations to run on different PCs the FD simulations %
%                                                                         %
%=========================================================================%


%clear all
%clc
%close all hidden

import org.opensim.modeling.*
opengl('save', 'software');

name = getenv('COMPUTERNAME'); 


if strcmp(name,'ENGWELLPC')

    % Specify the folder path where the .xml files are located and delete
    % it to avoid crash during RL training
    folderPath = 'C:\Users\engwe\AppData\Local\MathWorks\MATLAB\R2023b';
    deleteXML(folderPath)

    addpath('Tuning_Feature\')
    addpath('\Users\engwe\Desktop\DSc_v5\DSc\02_Coletas')
    addpath('\Users\engwe\Desktop\DSc_v5\DSc\03_ODE_Solvers')
    addpath('\Users\engwe\Desktop\DSc_v5\DSc\04_DMDc_IDTF\simulations')
    addpath('\Users\engwe\Desktop\DSc_v5\DSc\05_TuningScripts\')
    addpath('C:\Users\engwe\anaconda3\envs\mat_py')
    
    osimModel=Model('C:\Users\engwe\Desktop\DSc_v5\DSc\01_ModelFilesOsim41\MoBL-ARMS Upper Extremity Model\Benchmarking Simulations\4.1 Model with Millard-Schutte Matched Curves\MOBL_ARMS_module2_4_allmuscles_ignoreactivation.osim');
    

elseif strcmp(name,'MARCOPOLO')
    % Specify the folder path where the .xml files are located and delete
    % it to avoid crash during RL training
    folderPath = 'C:\Users\Wellington\AppData\Local\MathWorks\MATLAB\R2023b';
    deleteXML(folderPath)
    
    addpath('Tuning_Feature\')
    addpath('\Users\Wellington\Desktop\DSc\02_Coletas\')
    addpath('\Users\Wellington\Desktop\DSc\03_ODE_Solvers\')
    addpath('\Users\Wellington\Desktop\DSc\04_DMDc_IDTF\simulations\')
    addpath('\Users\Wellington\Desktop\DSc\05_TuningScripts\')
    addpath('C:\Users\Wellington\.conda\envs\mat_py\')

    osimModel=Model('C:\Users\Wellington\Desktop\DSc\01_ModelFilesOsim41\MoBL-ARMS Upper Extremity Model\Benchmarking Simulations\4.1 Model with Millard-Schutte Matched Curves\MOBL_ARMS_module2_4_allmuscles_ignoreactivation.osim');
        

elseif strcmp(name,'ENGWELLSURFACE')

    addpath('\02_DSc_v5\DSc\07_TremorModel_v5\Tuning_Feature')
   
    addpath('\02_DSc_v5\DSc\02_Coletas\')
    addpath('\02_DSc_v5\DSc\03_ODE_Solvers\')
    addpath('\02_DSc_v5\DSc\04_DMDc_IDTF\simulations\')
    addpath('\02_DSc_v5\DSc\05_TuningScripts\')

    osimModel=Model('D:\02_DSc_v5\DSc\01_ModelFilesOsim41\MoBL-ARMS Upper Extremity Model\Benchmarking Simulations\4.1 Model with Millard-Schutte Matched Curves\MOBL_ARMS_module2_4_allmuscles_ignoreactivation.osim');
    
end