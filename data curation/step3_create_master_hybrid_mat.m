clc
clear
close all
folder_address = 'C:\Users\mrirc\Desktop\Master Data\IRB17\pat083';
load(fullfile(folder_address,'HM57.mat'))
raw57 = raw;
load(fullfile(folder_address,'HM70.mat'))
raw70 = raw;
load(fullfile(folder_address,'HM150.mat'))
raw150 = raw;
load(fullfile(folder_address,'HM200.mat'))
raw200 = raw;

num_slices = size(raw57,3);
num_voxels = size(raw57,2);

hybrid_raw = cell(4,4);
TEs = {'raw57', 'raw70', 'raw150', 'raw200'};
for i=1:4
    temp = abs(squeeze(eval(TEs{i})));
    hybrid_raw{1, i} = squeeze(mean(temp(:,:,:,1,1,1:2),[5,6]));
    hybrid_raw{2, i} = reshape(temp(:,:,:,2,1:3,1), num_voxels,num_voxels, num_slices, 3);
    hybrid_raw{3, i} = reshape(temp(:,:,:,3,1:3,1), num_voxels, num_voxels, num_slices,3);
    hybrid_raw{4, i} = reshape(temp(:,:,:,4,1:3,1:4), num_voxels, num_voxels, num_slices,12);
end

mat_address = fullfile(folder_address, 'Hybrid6D_raw.mat');
save(mat_address, 'hybrid_raw')

delete(fullfile(folder_address,'HM57.mat'))
delete(fullfile(folder_address,'HM70.mat'))
delete(fullfile(folder_address,'HM150.mat'))
delete(fullfile(folder_address,'HM200.mat'))
