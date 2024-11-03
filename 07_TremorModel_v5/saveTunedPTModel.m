



% Save the optimization results in IndividualizedModels folder with the structured filename
save_filename = fullfile(output_folder, strcat(date_str,'_',SimuInfo.PatientID,  '_GA.mat'));
save(save_filename, 'x', 'fval', 'exitflag', 'output', 'population', 'scores');

% Close any open file identifiers
fclose('all');