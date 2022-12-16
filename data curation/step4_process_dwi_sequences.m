clc
clear
close all
folder_address = 'C:\Users\mrirc\Desktop\Master Data\IRB17\pat083';
load(fullfile(folder_address,'DWI.mat'))

num_slices = size(raw,3);
num_voxels = size(raw,2);
temp = raw;
b0 = squeeze(mean(temp(:,:,:,1,1,1:2),[5,6]));
b1 = reshape(temp(:,:,:,2,1:3,1:2), num_voxels, num_voxels, num_slices, 6);
b2 = reshape(temp(:,:,:,3,1:3,1:2), num_voxels, num_voxels, num_slices, 6);
b3 = reshape(temp(:,:,:,4,1:3,1:4), num_voxels, num_voxels, num_slices,12);
b4 = reshape(temp(:,:,:,4,1:3,1:6), num_voxels, num_voxels, num_slices,18);


mat_address = fullfile(folder_address, 'DWI.mat');
save(mat_address, 'raw','b0',"b1","b2","b3","b4")
