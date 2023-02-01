% read non-dwi sequences from parrecs
% 1/22/2023
% Author: Batuhan Gundogdu
% This function reads the T1W, T2W and DCE images from PARRECs and
% saves them as MATLAB files
%% Confirm the following from the scans
clc
close all;
clear
scans = containers.Map();
scans('T2_3D.mat') = 2;
scans('T1.mat') = 5;
scans('T2.mat') = 6;
scans('DCE.mat') = 13;
%% Change the following two variables
pt_id = 29;
pt_folder = 'C:\Users\mrirc\Desktop\Deep_Learning_Dataset\IRB17-1694 Pt 029\PARREC';
master_folder = 'C:\Users\mrirc\Desktop\Master Data\IRB17\pat029';
%%
for k = keys(scans)
    key = k{1};
    par_file = sprintf('IRB17-1694-Pt%02d_%d_1.PAR', pt_id, scans(key))
    fileID = fopen(fullfile(pt_folder,par_file),'r');
    lines = textscan(fileID,'%s','delimiter','\n');
    fclose(fileID);
    lines = lines{1};

    listOfStrings = {'#  Contrast Bolus Start Time                (string)',...
        '#  Contrast Bolus Total Dose                (float)',...
        '#  Contrast Bolus Ingredient                (string)',...
        '#  Contrast Bolus Ingredient Concentration  (float)'};
    fileID = fopen(fullfile(pt_folder,par_file),'w');
    for i = 1:length(lines)
        if any(strcmp(listOfStrings, lines{i}))
            continue
        else
            fprintf(fileID,'%s\n',lines{i});
        end
    end
    fclose(fileID);

    [scanned_image, ~]=loadPARREC(fullfile(pt_folder,par_file));
    mat_address = fullfile(master_folder, key);
    save(mat_address, "scanned_image",'-v7.3')


end
