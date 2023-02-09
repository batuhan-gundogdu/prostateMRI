% step-2 reconstruction of raw DWI images
% 1/22/2023
% Author: Batuhan Gundogdu
% This function reads the clinical DWI and Hybrid images from raw files
% and reconstructs them using MRECON, finally saves them as MATLAB files
% This function takes some time
%% change the following folder addresses for each patient
clc
close all;
clear
patient_folder = 'C:\Users\mrirc\Desktop\Deep_Learning_Dataset\IRB17-1694 Pt 099\raw data\2022_06_01\UR_19151';
master_directory = 'C:\Users\mrirc\Desktop\Master Data\IRB17\pat099';
%%
scans = containers.Map();

listOfFiles = dir(patient_folder);
for f=1:length(listOfFiles)
    filename = listOfFiles(f).name;
    if endsWith(filename, 'senserefscanV4.raw')
        refscan = filename;
    elseif endsWith(filename, 'coilsurveyscanV4.raw')
        coilsurveyscan = filename;
    elseif endsWith(filename, 'te057_4bV4.raw')
        scans('HM57.mat') = filename;
    elseif endsWith(filename, 'te070_4bV4.raw')
        scans('HM70.mat') = filename;
    elseif endsWith(filename, 'te150_4bV4.raw')
        scans('HM150.mat') = filename;
    elseif endsWith(filename, 'te200_4bV4.raw')
        scans('HM200.mat') = filename;
    elseif endsWith(filename, 'dwi_max_4bV4.raw')
        scans('DWI.mat') = filename;

    end
end
refscan = fullfile(patient_folder, refscan);
coilsurveyscan = fullfile(patient_folder, coilsurveyscan);
%%

for k = keys(scans)
    key = k{1};
    scan = scans(key)
    scan = fullfile(patient_folder, scan);
    disp('Reading Raw Files')
    S = MRsense(refscan, scan, coilsurveyscan);
    S.Perform;
    r = MRecon(scan);
    r.Parameter.Recon.Sensitivities = S;
    r.Parameter.Parameter2Read.typ = 1;
    r.ReadData;
    r.RandomPhaseCorrection;
    r.PDACorrection;
    r.DcOffsetCorrection;
    r.MeasPhaseCorrection;
    r.Parameter.Recon.ImmediateAveraging = 'no';
    r.SortData;
    disp('k-space finalized')
    r.GridData;
    r.RingingFilter;
    r.ZeroFill;
    r.K2IM;
    r.EPIPhaseCorrection;
    r.K2IP;
    disp('x-space created')
    r.GridderNormalization;
    r.SENSEUnfold;
    r.PartialFourier;
    r.ConcomitantFieldCorrection;
    r.DivideFlowSegments;
    %r.CombineCoils;
    %r.Average;
    r.GeometryCorrection;
    r.RemoveOversampling;
    r.FlowPhaseCorrection;
    r.ReconTKE;
    r.ZeroFill;
    r.RotateImage;
    disp('x-space finalized')
    raw = squeeze(abs(r.Data));
    mat_address = fullfile(master_directory, key);
    save(mat_address, 'raw')
end
disp('Reconstruction is Done! Now merging the files')


load(fullfile(master_directory,'HM57.mat'))
raw57 = raw;
load(fullfile(master_directory,'HM70.mat'))
raw70 = raw;
load(fullfile(master_directory,'HM150.mat'))
raw150 = raw;
load(fullfile(master_directory,'HM200.mat'))
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

mat_address = fullfile(master_directory, 'Hybrid6D_raw.mat');
save(mat_address, 'hybrid_raw')

delete(fullfile(master_directory,'HM57.mat'))
delete(fullfile(master_directory,'HM70.mat'))
delete(fullfile(master_directory,'HM150.mat'))
delete(fullfile(master_directory,'HM200.mat'))

load(fullfile(master_directory,'DWI.mat'))

num_slices = size(raw,3);
num_voxels = size(raw,2);
temp = raw;
b0 = squeeze(mean(temp(:,:,:,1,1,1:2),[5,6]));
b1 = reshape(temp(:,:,:,2,1:3,1:2), num_voxels, num_voxels, num_slices, 6);
b2 = reshape(temp(:,:,:,3,1:3,1:2), num_voxels, num_voxels, num_slices, 6);
b3 = reshape(temp(:,:,:,4,1:3,1:4), num_voxels, num_voxels, num_slices,12);
b4 = reshape(temp(:,:,:,4,1:3,1:6), num_voxels, num_voxels, num_slices,18);


mat_address = fullfile(master_directory, 'DWI.mat');
save(mat_address, 'raw','b0',"b1","b2","b3","b4")

disp('All Done!')