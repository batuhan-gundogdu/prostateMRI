% this code finalizes the curation process and creates one master.mat
% 1/22/2023
% Author: Batuhan Gundogdu
%% change the address for the current patient
clc
clear
close all
folder_address = 'C:\Users\mrirc\Desktop\Master Data\IRB17\pat104';
hybrid_data = 'pat104_hybridSortedInput.mat';
%% the rest should work with no problem
load(fullfile(folder_address,'DCE.mat'))
DCE = scanned_image;
load(fullfile(folder_address,'T1.mat'))
T1 = scanned_image;
load(fullfile(folder_address,'T2.mat'))
T2 = scanned_image;
load(fullfile(folder_address,'T2_3D.mat'))
T2_3D = scanned_image;
load(fullfile(folder_address,hybrid_data))
load(fullfile(folder_address,'DWI.mat'))
load(fullfile(folder_address,'Hybrid6D_raw.mat'))
load(fullfile(folder_address,'cancer_mask.mat'))
load(fullfile(folder_address,'benign_mask.mat'))
load(fullfile(folder_address,'noise_mask.mat'))


mat_address = fullfile(folder_address, 'master.mat');
save(mat_address, '-v7.3')

delete(fullfile(folder_address,'DCE.mat'))
delete(fullfile(folder_address,'T1.mat'))
delete(fullfile(folder_address,'T2.mat'))
delete(fullfile(folder_address,'T2_3D.mat'))
%delete(fullfile(folder_address,hybrid_data))
delete(fullfile(folder_address,'DWI.mat'))
delete(fullfile(folder_address,'Hybrid6D_raw.mat'))
delete(fullfile(folder_address,'cancer_mask.mat'))
delete(fullfile(folder_address,'benign_mask.mat'))
delete(fullfile(folder_address,'noise_mask.mat'))
