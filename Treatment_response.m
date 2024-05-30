function[data_table_delta, all_data] = treatment_response(all_data, cell_types, binSize, sortByVar)
%% Goal: have the function pull spike times from  0-30min (1:54,000,000) and 30-60min (54,000,001:108,000,000) and 
%% 60-90min (108,000,001:162,000,000) and calculate the firing rate for each cell in each time period. 
%% Then, calculate the change in firing rate for each cell in response to treatment.
% 
% 
% Plot and compare the change in firing rate of the cells in response to treatment. 
% Ouptuts:
% - A table of the change in firing rate of each Unit in response to treatment for statistical analysis
% - A figure of the change in firing rate of each Unit in response to treatment
%
% Inputs:
% - all_data: A structure containing all the data generated from SpikeTurnpike
% - cell_types: A structure containing the cell types to plot (e.g. 'MSN', 'TAN')
% - treatment_period: an numeric specifiying in minutes the time of treatment
 
groupNames = fieldnames(all_data);

groupsVec = {};
cellTypesVec = {};
FRs_vec = [];

% Loop through all the groups
for groupNum = 1:length(groupNames)
    % Code inside the for loop
    group = groupNames{groupNum};
    mouseNames = fieldnames(all_data.(groupName));
    % Loop through all the mice
    for MouseNum = 1:length(mouseNames)
        mouseName = mouseNames{MouseNum};

        cellIDs = fieldnames(all_data.(groupName).(mouseName)); % Loop through all the cells

         for cellID_num = 1:length(cellIDs) % Loop through all the cells
            cellID = cellIDs{cellID_num};

            thisCellType = all_data.(groupName).(mouseName).(cellID).cellType; % Get the cell type of the cell
            isSingleUnit = all_data.(groupName).(mouseName).(cellID).isSingleUnit; % Check if the cell is a single unit
            if any(strcmp(cell_types, thisCellType)) && isSingleUnit % Check if the cell type is in the list
                groupsVec{end+1,1} = groupName; % Add the group name to the groupsVec
                cellTypesVec{end+1,1} = thisCellType; % Add the cell type to the cellTypesVec
                recNames_vec{end+1,1} = mouseName; % Add the mouse name to the recNames_vec
                cellIDs_vec{end+1,1} = cellID; % Add the cell ID to the cellIDs_vec
            
                if ~isempty(sortByVar)
                    sortByVar_vec{end+1,1} = all_data.(groupName).(mouseName).(cellID).(sortByVar); % Add the sortByVar to the sortByVar_vec
                end

                if binSize == 0
                    FRs_vec(end+1,1) = all_data.(groupName).(mouseName).(cellID).MeanFR_total;
                else
                    %calculate FR as max of 200s bins
                    FRs_vec(end+1,1) = all_data.(groupName).(mouseName).(cellID).FR_binned;
                    Spiketimes = all_data.(groupName).(mouseName).(cellID).SpikeTimes_all / all_data.(groupName).(mouseName).(cellID).Sampling_Frequency;
                    RecDuration = all_data.(groupName).(mouseName).(cellID).RecordingDuration;
                    intervalBounds = 0:binSize:RecDuration;
                    binned_FRs_vec = [];
                    for ii = 1:length(intervalBounds)-1
                        n_spikes = length(Spiketimes(Spiketimes > intervalBounds(ii) & Spiketimes <= intervalBounds(ii+1)));
                        binned_FRs_vec(ii) = sum(Spiketimes > intervalBounds(ii) & Spiketimes <= intervalBounds(ii+1)) / binSize;
                    end
                    FRs_vec(end) = max(binned_FRs_vec);
                end
            end
        end 
    end
end

%% Plotting the data as violin plot for each group 
figure;
imagesc(data);  % This will create a heat map where each cell color represents a firing rate
colorbar;  % Shows the color scale
xlabel('Time (bins)');  % Label the x-axis
ylabel('Neuron/Trial');  % Label the y-axis
title('Firing Rate Over Time');



