function[data_table_delta, all_data] = treatment_response(all_data, cell_types, binSize)
% Plot and compare the change in firing rate of the cells in response to treatment. 
% Ouptuts:
% - A table of the change in firing rate of each Unit in response to treatment for statistical analysis
% - A figure of the change in firing rate of each Unit in response to treatment
%
% Inputs:
% - all_data: A structure containing all the data generated from SpikeTurnpike
% - cell_types: A structure containing the cell types to plot (e.g. 'MSN', 'TAN')
%
 
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


