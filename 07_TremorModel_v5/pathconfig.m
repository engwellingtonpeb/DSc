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
global GAResultsPath
import org.opensim.modeling.*
opengl('save', 'software');

name = getenv('COMPUTERNAME'); 


if strcmp(name,'ENGWELLPC')

    if opt==1
        if isempty(gcp('nocreate'))  % Check if a parallel pool is not running
            c = parcluster;
            c.NumWorkers = 12;
            parpool(c, 12);  % Create a parallel pool with 12 workers
        else
            disp('Parallel pool is already running.');
        end

        GAResultsPath = 'C:\Users\engwe\Desktop\DSc_v5\DSc\07_TremorModel_v5';
        % Change to the target folder
        targetFolder = 'C:\Users\engwe\Desktop\DSc_v5\DSc\02_Coletas';
    end

    % Specify the folder path where the .xml files are located and delete
    % it to avoid crash during RL training
    folderPath = 'C:\Users\engwe\AppData\Local\MathWorks\MATLAB\R2023b';
    deleteXML(folderPath)

    addpath('Tuning_Feature\')
    addpath('\Users\engwe\Desktop\DSc_v5\DSc\02_Coletas')
    addpath('\Users\engwe\Desktop\DSc_v5\DSc\03_ODE_Solvers')
    addpath('\Users\engwe\Desktop\DSc_v5\DSc\04_DMDc_IDTF\simulations')
    addpath('\Users\engwe\Desktop\DSc_v5\DSc\05_TuningScripts\')
    %addpath('C:\Users\engwe\anaconda3\envs\mat_py')
    
    osimModel=Model('C:\Users\engwe\Desktop\DSc_v5\DSc\01_ModelFilesOsim41\MoBL-ARMS Upper Extremity Model\Benchmarking Simulations\4.1 Model with Millard-Schutte Matched Curves\MOBL_ARMS_module2_4_allmuscles_ignoreactivation.osim');
    
    
elseif strcmp(name,'MARCOPOLO')
    if opt==1
        if isempty(gcp('nocreate'))  % Check if a parallel pool is not running
            c = parcluster;
            c.NumWorkers = 32;
            parpool(c, 32);  % Create a parallel pool with 12 workers
        else
            disp('Parallel pool is already running.');
        end
        
        GAResultsPath = 'C:\Users\Wellington\Desktop\DSc\07_TremorModel_v5\Tuning_Feature';
        
        % Change to the target folder
        targetFolder = 'C:\Users\Wellington\Desktop\DSc\02_Coletas';
    end

    % Specify the folder path where the .xml files are located and delete
    % it to avoid crash during RL training
    folderPath = 'C:\Users\Wellington\AppData\Local\MathWorks\MATLAB\R2023b';
    deleteXML(folderPath)
    
    addpath('Tuning_Feature\')
    addpath('\Users\Wellington\Desktop\DSc\02_Coletas\')
    addpath('\Users\Wellington\Desktop\DSc\03_ODE_Solvers\')
    addpath('\Users\Wellington\Desktop\DSc\04_DMDc_IDTF\simulations\')
    addpath('\Users\Wellington\Desktop\DSc\05_TuningScripts\')
    %addpath('C:\Users\Wellington\.conda\envs\mat_py\')

    osimModel=Model('C:\Users\Wellington\Desktop\DSc\01_ModelFilesOsim41\MoBL-ARMS Upper Extremity Model\Benchmarking Simulations\4.1 Model with Millard-Schutte Matched Curves\MOBL_ARMS_module2_4_allmuscles_ignoreactivation.osim');
        

elseif strcmp(name,'ENGWELLSURFACE')

    if opt==1
        if isempty(gcp('nocreate'))  % Check if a parallel pool is not running
            c = parcluster;
            c.NumWorkers = 16;
            parpool(c, 16);  % Create a parallel pool with 12 workers
        else
            disp('Parallel pool is already running.');
        end
        
        GAResultsPath = 'D:\02_DSc_v5\DSc\07_TremorModel_v5\Tuning_Feature';
        
        % Change to the target folder
        targetFolder = 'D:\02_DSc_v5\DSc\02_Coletas';
    end

    addpath('\02_DSc_v5\DSc\07_TremorModel_v5\Tuning_Feature')
   
    addpath('\02_DSc_v5\DSc\02_Coletas\')
    addpath('\02_DSc_v5\DSc\03_ODE_Solvers\')
    addpath('\02_DSc_v5\DSc\04_DMDc_IDTF\simulations\')
    addpath('\02_DSc_v5\DSc\05_TuningScripts\')

    osimModel=Model('D:\02_DSc_v5\DSc\01_ModelFilesOsim41\MoBL-ARMS Upper Extremity Model\Benchmarking Simulations\4.1 Model with Millard-Schutte Matched Curves\MOBL_ARMS_module2_4_allmuscles_ignoreactivation.osim');
    % Change to the target folder
    targetFolder = 'D:\02_DSc_v5\DSc\02_Coletas';

elseif strcmp(name,'PROJETOFINEP_01')

    if opt==1
        if isempty(gcp('nocreate'))  % Check if a parallel pool is not running
            c = parcluster;
            c.NumWorkers = 36;
            parpool(c, 36);  % Create a parallel pool with 12 workers
        else
            disp('Parallel pool is already running.');
        end
        
        GAResultsPath = 'C:\Users\wellington\Desktop\DSc\07_TremorModel_v5\Tuning_Feature';
        
        % Change to the target folder
        targetFolder = 'C:\Users\wellington\Desktop\DSc\02_Coletas';
    end

    addpath('\Users\wellington\Desktop\DSc\07_TremorModel_v5\Tuning_Feature\')
   
    addpath('\Users\wellington\Desktop\DSc\02_Coletas\')
    addpath('\Users\wellington\Desktop\DSc\03_ODE_Solvers\')
    addpath('\Users\wellington\Desktop\DSc\04_DMDc_IDTF\simulations\')
    addpath('\Users\wellington\Desktop\DSc\05_TuningScripts\')

    osimModel=Model('C:\Users\wellington\Desktop\DSc\01_ModelFilesOsim41\MoBL-ARMS Upper Extremity Model\Benchmarking Simulations\4.1 Model with Millard-Schutte Matched Curves\MOBL_ARMS_module2_4_allmuscles_ignoreactivation.osim');
    
    % Change to the target folder
    targetFolder = 'C:\Users\wellington\Desktop\DSc\02_Coletas';

end