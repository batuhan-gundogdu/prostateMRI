clc
clear
close all
folder_address = 'C:\Users\mrirc\Desktop\Master Data\IRB17\pat083';
load(fullfile(folder_address,'DWI.mat'))
load(fullfile(folder_address,'DWI.mat'))
load(fullfile(folder_address,'DCE.mat'))
DCE = scanned_image;
load(fullfile(folder_address,'pat083_cancer_mask.mat'))
load(fullfile(folder_address,'pat083_benign_mask.mat'))
load(fullfile(folder_address,'pat083_hybridSortedInput.mat'))
load(fullfile(folder_address,'T1.mat'))
T1 = scanned_image;
load(fullfile(folder_address,'T2.mat'))
T2 = scanned_image;
load(fullfile(folder_address,'T2_3D.mat'))
T2_3D = scanned_image;
load(fullfile(folder_address,'Hybrid6D_raw.mat'))
mat_address = fullfile(folder_address, 'master.mat');
save(mat_address, '-v7.3')
delete(fullfile(folder_address,'Hybrid6D_raw.mat'))
delete(fullfile(folder_address,'DWI.mat'))
delete(fullfile(folder_address,'DCE.mat'))
delete(fullfile(folder_address,'pat083_cancer_mask.mat'))
delete(fullfile(folder_address,'pat083_benign_mask.mat'))
delete(fullfile(folder_address,'pat083_hybridSortedInput.mat'))
delete(fullfile(folder_address,'T1.mat'))
delete(fullfile(folder_address,'T2.mat'))
delete(fullfile(folder_address,'T2_3D.mat'))
